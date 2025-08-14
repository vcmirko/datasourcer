import pymysql
import logging
import re
import yaml
import jinja2

logger = logging.getLogger('datasourcer')

def mysql_escape_string(s):
    return s.replace("\\", "\\\\").replace("'", "\\'")
def open_database(host, port, user, password):
    mysql_conn = pymysql.connect(host=host, port=port, user=user, password=password, autocommit=False, local_infile=True,ssl={"fake_flag_to_enable_tls":True})
    logger.debug("Connected to the MySQL database")
    cursor_mysql = mysql_conn.cursor()
    return mysql_conn, cursor_mysql
def close_database(mysql_conn):
    mysql_conn.close()
    logger.debug("Disconnected from the MySQL database")
def start_transaction(mysql_conn):
    logger.debug("Starting transaction")
    mysql_conn.begin()
def commit(mysql_conn):
    logger.debug("Committing")
    mysql_conn.commit()
def rollback(mysql_conn):
    logger.warning("Rolling back")
    mysql_conn.rollback()
def execute_multiple_line(cursor_mysql, sql):
    # split on newlines
    sqls = sql.replace("\r", "").split("\n")
    block = ""
    for line in sqls:
        if line.startswith("--"):
            continue
        if line.startswith(r"/*"):
            continue
        line = line.strip()
        if line == "":
            continue
        block += line
        if line.endswith(";"):
            # replace newlines with spaces
            block = block.replace("\n", " ")
            block = block.replace("\r", " ")
            execute_sql(cursor_mysql, block)
            block = ""
def execute_sqlfile(cursor_mysql, sqlfile):
    with open(sqlfile, "r") as f:
        sqls = f.read()
    f.close()
    execute_multiple_line(cursor_mysql, sqls)
def execute_sql(cursor_mysql, sql, fetchone=False, fetchall=False):
    logger.debug(sql)
    execute_result = cursor_mysql.execute(sql)
    if fetchone:
        return cursor_mysql.fetchone()
    if fetchall:
        return cursor_mysql.fetchall()
    return execute_result
def disable_foreign_key_checks(cursor_mysql):
    execute_sql(cursor_mysql, "SET FOREIGN_KEY_CHECKS = 0;")
    execute_sql(cursor_mysql, "SET UNIQUE_CHECKS = 0;")
def enable_foreign_key_checks(cursor_mysql):
    execute_sql(cursor_mysql, "SET FOREIGN_KEY_CHECKS = 1;")
    execute_sql(cursor_mysql, "SET UNIQUE_CHECKS = 1;")
def set_global_local_infile(cursor_mysql):
    sql = "SET GLOBAL local_infile = 1;"
    execute_sql(cursor_mysql, sql)
def set_allow_invalid_dates(cursor_mysql):
    sql = "SET sql_mode = 'ALLOW_INVALID_DATES';"
    execute_sql(cursor_mysql, sql)
def schema_exists(cursor_mysql, schema):
    sql = f"SELECT schema_name FROM information_schema.schemata WHERE schema_name = '{schema}';"
    result = execute_sql(cursor_mysql, sql, fetchone=True)
    return bool(result)
def find_fk_action(fk):

    FK_ACTIONS = {
        "cascade": "CASCADE",
        "set_null": "SET NULL",
        "restrict": "RESTRICT",
        "no_action": "NO ACTION"
    }

    delete_match = re.search(r"delete_([a-z_]+)", fk)
    update_match = re.search(r"update_([a-z_]+)", fk)
    delete_action = "NO ACTION"
    update_action = "NO ACTION"
    if delete_match:
        delete_action = FK_ACTIONS.get(delete_match.group(1))
    if update_match:
        update_action = FK_ACTIONS.get(update_match.group(1))
    return delete_action, update_action
def get_schema_sql_from_yaml(schema, data):

    tables = []

    for table_name in data:
        
        table = {}
        # build list of unique keys from data[table_name] keys where unique = true
        unique_keys = [column["name"] for column in data[table_name] if column.get("unique", False)]
        foreign_keys = [ column for column in data[table_name] if column.get("foreign_key", False)]
        foreign_keys_names = [fk["name"] for fk in foreign_keys]
        table["name"] = table_name
        table["unique_key"] = False
        table["foreign_keys"] = []
        table["indexes"] = []
        table["columns"] = []

        for column in data[table_name]:

            c = ""

            # if no type is given, default to varchar(255)
            col_name = column.get("name", column)
            col_type = column.get("type", "varchar").lower()
            col_length = column.get("length", 255 if col_type == "varchar" else None)
            col_default = column.get("default", None)
            col_nullable = column.get("nullable", True)
            col_case_sensitive = column.get("case_sensitive", False)

            # if col_name in foreign_keys add _id
            if col_name in foreign_keys_names:
                col_name = f"{col_name}_id"
                col_type = "int"
                col_length = None

            # string -> varchar
            if col_type == "string":
                col_type = "varchar"

            if col_type == "bool":
                col_default = 1 if bool(col_default) else 0

            # type to TYPE(LENGTH)
            if col_length:
                col_type_length = f"{col_type}({col_length})".upper()
            else:
                col_type_length = col_type.upper()

            c = f"`{col_name}` {col_type_length}"

            if col_case_sensitive:
                c = f"{c} CHARACTER SET utf8mb4 COLLATE utf8mb4_bin"

            # correct defaults
            if col_default:

                if col_type in ["date", "datetime", "timestamp"] and col_default.lower() == "current_timestamp":
                    c = f"{c} DEFAULT CURRENT_TIMESTAMP"

                elif col_type in ["int", "bigint", "tinyint", "smallint", "mediumint", "decimal", "float", "double"]:
                    c = f"{c} DEFAULT {col_default}"

                else:
                    c = f"{c} DEFAULT '{col_default}'"

            elif not col_nullable:
                c = f"{c} NOT NULL"
            else:
                c = f"{c} DEFAULT NULL"

            if "comment" in column:
                c = f"{c} COMMENT '{column['comment']}'"

            table["columns"].append(c)

        # UNIQUE KEY `uk_cm_storage_aggregate_natural_key` (`name`,`node_id`),
        if bool(unique_keys):
            table["unique_key"] = f"UNIQUE KEY `uk_{schema}_{table_name}_natural_key` ({','.join([f'`{key}`' for key in unique_keys])})" if unique_keys else ""
        else:
            table["unique_key"] = False

        if bool(foreign_keys):
            for fk in foreign_keys:
                # CONSTRAINT `fk_cm_storage_aggregate_node_id` FOREIGN KEY (`node_id`) REFERENCES `node` (`id`) ON DELETE CASCADE
                delete_action,update_action = find_fk_action(fk.get("constraint_actions", ""))
                table["foreign_keys"].append(f"CONSTRAINT `fk_{schema}_{table_name}_{fk['name']}` FOREIGN KEY (`{fk['name']}_id`) REFERENCES `{fk['foreign_key']}` (`id`) ON DELETE {delete_action} ON UPDATE {update_action}")

        foreign_keys_names = [fk["name"] for fk in foreign_keys]
        # index is foreign_keys_names, subtract unique_keys
        indexes = [k for k in foreign_keys_names if k not in unique_keys]
        
        table["indexes"] = [f"KEY `idx_{schema}_{table_name}_{index}` (`{index}_id`)" for index in indexes]
        # add KEY `fk_cm_storage_aggregate_node_id` (`node_id`),
        tables.append(table)



    table_definitions = jinja2.Environment(loader=jinja2.FileSystemLoader("my_library/templates")).get_template("schema.sql.j2")
    sql = table_definitions.render({"schema": schema, "tables": tables })
    return sql