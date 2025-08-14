from .mysql_functions import execute_sql
import logging

logger = logging.getLogger('datasourcer')

def get_unique_constraints(cursor_mysql, schema):
    sql = f"SELECT DISTINCT INDEX_NAME, TABLE_NAME FROM INFORMATION_SCHEMA.STATISTICS WHERE TABLE_SCHEMA = '{schema}' AND NON_UNIQUE = 0;"
    result = execute_sql(cursor_mysql, sql, fetchall=True)
    results = [{"INDEX_NAME": r[0], "TABLE_NAME": r[1]} for r in result]
    return results
def get_foreign_keys(cursor_mysql, schema):
    sql = f"SELECT kcu.CONSTRAINT_NAME, kcu.TABLE_NAME, kcu.COLUMN_NAME, kcu.REFERENCED_TABLE_NAME, kcu.REFERENCED_COLUMN_NAME, rc.DELETE_RULE FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu LEFT JOIN information_schema.REFERENTIAL_CONSTRAINTS rc ON kcu.CONSTRAINT_NAME=rc.CONSTRAINT_NAME WHERE kcu.TABLE_SCHEMA = '{schema}' AND rc.CONSTRAINT_SCHEMA = '{schema}' AND REFERENCED_COLUMN_NAME IS NOT NULL;"
    result = execute_sql(cursor_mysql, sql, fetchall=True)
    results = [{
        "CONSTRAINT_NAME": r[0],
        "TABLE_NAME": r[1],
        "COLUMN_NAME": r[2],
        "REFERENCED_TABLE_NAME": r[3],
        "REFERENCED_COLUMN_NAME": r[4],
        "DELETE_RULE": r[5]
    } for r in result]
    return results
def drop_database(cursor_mysql, schema):
    sql = f"DROP DATABASE IF EXISTS {schema};"
    execute_sql(cursor_mysql, sql)
def create_database(cursor_mysql, schema):
    sql = f"CREATE DATABASE {schema};"
    execute_sql(cursor_mysql, sql)
def get_table_columns(cursor_mysql, schema, table):
    sql = f"SHOW COLUMNS FROM {schema}.{table};"
    result = execute_sql(cursor_mysql, sql, fetchall=True)
    columns = [column[0].lower() for column in result]
    return columns
def get_tables(cursor_mysql, schema):
    result = execute_sql(cursor_mysql, f"SHOW TABLES FROM {schema}", fetchall=True)
    tables = [table[0] for table in result]
    return tables
def recreate_database(cursor_mysql, schema):
    drop_database(cursor_mysql, schema)
    create_database(cursor_mysql, schema)
def get_tables_with_correct_keys(cursor_mysql, schema):
    sql = f"""
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = '{schema}' AND COLUMN_KEY = 'PRI' AND COLUMN_NAME='id' AND DATA_TYPE='int' AND EXTRA LIKE '%auto_increment%';
    """
    result = execute_sql(cursor_mysql, sql, fetchall=True)
    tables_with_correct_keys = [r[0] for r in result]
    return tables_with_correct_keys
def collect_table_info(cursor_mysql, schema):
    logger.info("Collecting table info")
    tables = get_tables(cursor_mysql, schema)
    foreign_keys = get_foreign_keys(cursor_mysql, schema)
    unique_constraints = get_unique_constraints(cursor_mysql, schema)
    primary_keys = get_tables_with_correct_keys(cursor_mysql, schema)

    table_info = {}
    for table in tables:
        table_info[table] = {}
        table_info[table]["unique_constraints"] = [uc for uc in unique_constraints if uc["TABLE_NAME"] == table]
        table_info[table]["foreign_keys"] = [fk for fk in foreign_keys if fk["TABLE_NAME"] == table]
        has_correct_key = table in primary_keys
        if not has_correct_key:
            logger.warning(f"Table {table} does not have a correct primary key (id, int, auto_increment)")
        table_info[table]["has_correct_key"] = has_correct_key
        table_info[table]["columns"] = get_table_columns(cursor_mysql, schema, table)
    tables = [table for table in tables if table_info[table]["has_correct_key"]]

    for table in tables:
        min_id, max_id = get_min_max_id(cursor_mysql, schema, table)
        table_info[table]["min"] = min_id
        table_info[table]["max"] = max_id

    return tables, foreign_keys, unique_constraints, table_info
def get_count(cursor_mysql, schema, table):
    sql = f"SELECT COUNT(id) FROM {schema}.`{table}`;"
    result = execute_sql(cursor_mysql, sql, fetchone=True)
    return result[0]
def get_min_max_id(cursor_mysql, schema, table):
    sql = f"SELECT COALESCE(MIN(id), 0), COALESCE(MAX(id), 0) FROM {schema}.`{table}`;"
    result = execute_sql(cursor_mysql, sql, fetchone=True)
    return result[0], result[1]