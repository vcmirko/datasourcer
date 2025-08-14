import os
from .mysql_functions import execute_sql
from .database_functions import collect_table_info
import jinja2


def get_csv_import_path(import_path, schema, datasource):
    file_path = os.path.join(import_path, schema, datasource)
    return file_path
def get_csv_path(csv_import_path, table):
    return os.path.join(csv_import_path, f"{table}.csv")
def get_datasource_schema(cursor_mysql, datasourcer_schema, datasource):
    sql = f"SELECT `schema` FROM {datasourcer_schema}.datasource WHERE name='{datasource}';"
    result = execute_sql(cursor_mysql, sql, fetchone=True)
    if result is None:
        raise Exception(f"Datasource {datasource} not found")
    return result[0]
def get_datasource_id(cursor_mysql, datasourcer_schema, datasource, schema):
    sql = f"SELECT id FROM {datasourcer_schema}.datasource WHERE {datasourcer_schema}.datasource.name='{datasource}' AND {datasourcer_schema}.datasource.schema='{schema}';"
    result = execute_sql(cursor_mysql, sql, fetchone=True)
    if result is None:
        raise Exception(f"Datasource {datasource} not found for {schema}")
    return result[0]
def get_datasource_config(cursor_mysql,datasourcer_schema, import_path, datasource, details=True):
    absolute_import_path = os.path.abspath(import_path)
    schema = get_datasource_schema(cursor_mysql, datasourcer_schema, datasource)
    datasource_id = get_datasource_id(cursor_mysql, datasourcer_schema, datasource, schema)
    csv_import_path = get_csv_import_path(absolute_import_path, schema, datasource)
    schema_file = os.path.join(absolute_import_path, schema,"schema.sql")
    if details:
        tables, foreign_keys, unique_constraints, table_info = collect_table_info(cursor_mysql, schema)    # collect table info    
    else:
        tables, foreign_keys, unique_constraints, table_info = [], [], [], {}
    datasource_config = {
        "schema": schema,
        "datasource": datasource,
        "datasourcer_schema": datasourcer_schema,
        "datasource_id": datasource_id,
        "tables": tables,
        "foreign_keys": foreign_keys,
        "unique_constraints": unique_constraints,
        "table_info": table_info,
        "csv_import_path": csv_import_path,
        "schema_file": schema_file
    }
    return datasource_config
def get_datasourcer_schema_sql(cursor_mysql, datasourcer_schema):
    init = jinja2.Environment(loader=jinja2.FileSystemLoader("my_library/templates")).get_template("init.sql.j2")
    sql = init.render({ "datasourcer_schema": datasourcer_schema })
    return sql
def prompt_for_secure_value(prompt):
    import getpass
    return getpass.getpass(prompt)