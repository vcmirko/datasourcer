#!/usr/bin/env python3

import logging
import traceback
import datetime
import timeit
import sys
import os
import pandas as pd
import argparse
import yaml
from prettytable import PrettyTable

from my_library.mysql_functions import (
    open_database, close_database, start_transaction, commit, rollback, execute_sql, execute_multiple_line, get_schema_sql_from_yaml,
    disable_foreign_key_checks, enable_foreign_key_checks, set_global_local_infile, set_allow_invalid_dates,schema_exists
)
from my_library.database_functions import drop_database
from my_library.common import get_datasource_config, prompt_for_secure_value, get_datasourcer_schema_sql
from my_library.import_functions import *

# set current directory to the path of the script
os.chdir(os.path.dirname(os.path.abspath(__file__)))    

# =============================================================================
# Config
# =============================================================================
# read config file (config.yaml)
CONFIG = yaml.safe_load(open("config.yaml"))
DATASOURCER = CONFIG.get("datasourcer",{})

LOGGING = DATASOURCER.get("logging",{})
LOG_FILE = LOGGING.get("file","datasourcer.log")
LOG_FORMAT = LOGGING.get("format","%(asctime)s - %(name)s - %(levelname)s - %(message)s")
LOG_DATE_FORMAT = LOGGING.get("date_format","%Y-%m-%d %H:%M:%S")
LOG_FILE_LEVEL = LOGGING.get("file_level","DEBUG")
LOG_CONSOLE_LEVEL = LOGGING.get("console_level","INFO")

IMPORT_PATH = DATASOURCER.get("import_path","./import")

MYSQL = DATASOURCER.get("mysql",{})
MYSQL_HOST = MYSQL.get("host","localhost")
MYSQL_PORT = MYSQL.get("port",3306)
MYSQL_USER = MYSQL.get("user","root")
MYSQL_PASSWORD = MYSQL.get("password",'')
MYSQL_DATABASE = MYSQL.get("database","ds")

# =============================================================================
# Logging
# =============================================================================

log_console_level = logging._nameToLevel.get(LOG_CONSOLE_LEVEL)
log_file_level = logging._nameToLevel.get(LOG_FILE_LEVEL)

logger = logging.getLogger('datasourcer')
logger.setLevel(logging.DEBUG)

file_handler = logging.FileHandler(LOG_FILE)
file_handler.setLevel(log_file_level)

console_handler = logging.StreamHandler(sys.stdout)
console_handler.setLevel(log_console_level) 

formatter = logging.Formatter(LOG_FORMAT, datefmt=LOG_DATE_FORMAT)
file_handler.setFormatter(formatter)
console_handler.setFormatter(formatter)

logger.addHandler(file_handler)
logger.addHandler(console_handler)

# -----------------------------------------------------------------------------
# Actions
# -----------------------------------------------------------------------------

def show_config():
    global LOG_FILE, LOG_FORMAT, LOG_DATE_FORMAT, LOG_FILE_LEVEL, LOG_CONSOLE_LEVEL, IMPORT_PATH, MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE
    logger.info("Showing config")
    config_dict = {
        "LOG_FILE": LOG_FILE,
        "LOG_FORMAT": LOG_FORMAT,
        "LOG_DATE_FORMAT": LOG_DATE_FORMAT,
        "LOG_FILE_LEVEL": LOG_FILE_LEVEL,
        "LOG_CONSOLE_LEVEL": LOG_CONSOLE_LEVEL,
        "IMPORT_PATH": IMPORT_PATH,
        "MYSQL_HOST": MYSQL_HOST,
        "MYSQL_PORT": MYSQL_PORT,
        "MYSQL_USER": MYSQL_USER,
        "MYSQL_PASSWORD": "***********",
        "MYSQL_DATABASE": MYSQL_DATABASE
    }
    table = PrettyTable()
    table.field_names = ["Config", "Value"]
    table.align= "l"
    for key, value in config_dict.items():
        table.add_row([key, value])
    print(table)
def show_datasources():
    global MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE
    logger.info("Listing datasources")
    mysql_conn, cursor_mysql = open_database(MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD)
    try:
        sql = f"SELECT id,name,`schema` FROM {MYSQL_DATABASE}.datasource;"
        result = execute_sql(cursor_mysql, sql, fetchall=True)
        commit(mysql_conn)
        table = PrettyTable()

        table.field_names = ["ID", "Name", "Schema"]
        table.align= "l"
        for row in result:
            table.add_row(row)
        print(table)
    except Exception as e:
        logger.error("Error: " + str(e))
        if(LOG_CONSOLE_LEVEL == "DEBUG"):
            traceback.print_exc()
    finally:
        close_database(mysql_conn)
def show_datasource(datasource):
    global MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, IMPORT_PATH
    logger.info(f"Showing datasource {datasource}")
    mysql_conn, cursor_mysql = open_database(MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD)

    try:

        # get the datasource config
        datasource_config = get_datasource_config(cursor_mysql, MYSQL_DATABASE, IMPORT_PATH, datasource, details=False)    
        datasource_config_dict = {  
            "schema": datasource_config["schema"],
            "datasource": datasource_config["datasource"],
            "csv_import_path": datasource_config["csv_import_path"],
            "schema_file": datasource_config["schema_file"]
        }
        table = PrettyTable()
        table.field_names = ["Config", "Value"]
        table.align= "l"
        for key, value in datasource_config_dict.items():
            table.add_row([key, value])
        print(table)
    except Exception as e:
        logger.error("Error: " + str(e))
        if(LOG_CONSOLE_LEVEL == "DEBUG"):
            traceback.print_exc()
    finally:
        close_database(mysql_conn)
def add_datasource(datasource, schema):
    global MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE
    logger.info(f"Adding datasource {datasource} with schema {schema}")
    mysql_conn, cursor_mysql = open_database(MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD)
    try:
        sql = f"INSERT INTO {MYSQL_DATABASE}.datasource (name, `schema`) VALUES ('{datasource}', '{schema}');"
        start_transaction(mysql_conn)
        execute_sql(cursor_mysql, sql)
        commit(mysql_conn)
        logger.info(f"Added datasource {datasource} with schema {schema}")
        # reset the schema immediately
        if not schema_exists(cursor_mysql, schema):
            reset_schema(schema)
    except Exception as e:
        rollback(mysql_conn)
        logger.error("Error: " + str(e))
        if(LOG_CONSOLE_LEVEL == "DEBUG"):
            traceback.print_exc()
    finally:
        close_database(mysql_conn)
def remove_datasource(datasource):
    global MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE
    logger.warning(f"Removing datasource {datasource}")
    mysql_conn, cursor_mysql = open_database(MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD)
    datasource_config = get_datasource_config(cursor_mysql, MYSQL_DATABASE, IMPORT_PATH, datasource)
    try:
        start_transaction(mysql_conn)
        delete_from_tables(cursor_mysql, datasource_config)
        delete_from_staging(cursor_mysql, datasource_config)
        sql = f"DELETE FROM {MYSQL_DATABASE}.datasource WHERE name='{datasource}';"
        execute_sql(cursor_mysql, sql)
        commit(mysql_conn)
        logger.info(f"Removed datasource {datasource}")
    except Exception as e:
        rollback(mysql_conn)
        logger.error("Error: " + str(e))
        if(LOG_CONSOLE_LEVEL == "DEBUG"):
            traceback.print_exc()
    finally:
        close_database(mysql_conn)
def reset_schema(schema):
    global MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, IMPORT_PATH
    logger.warning(f"Resetting schema {schema}")
    mysql_conn, cursor_mysql = open_database(MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD)

    schema_yaml_file = os.path.join(IMPORT_PATH, schema, "schema.yaml")
    if not os.path.exists(schema_yaml_file):
        raise Exception(f"Could not find file : {schema_yaml_file}")
    try:
        schema_data = yaml.safe_load(open(schema_yaml_file))
    except Exception as e:
        logger.error("Could not parse schema yaml file")
        logger.error("Error: " + str(e))
        raise e
    try:
        logger.info(f"Reset schema {schema}")
        start_transaction(mysql_conn)
        # delete all staging for schema (can be multiple datasources)
        delete_sql = (
            f"DELETE {MYSQL_DATABASE}.staging "
            f"FROM {MYSQL_DATABASE}.staging JOIN "
            f"{MYSQL_DATABASE}.datasource ON staging.datasource_id=datasource.id "
            f"WHERE datasource.schema='{schema}';"
        )
        execute_sql(cursor_mysql, delete_sql)
        schema_sql = get_schema_sql_from_yaml(schema, schema_data)
        # write sql
        with open(f"{schema}.sql", "w") as f:
            f.write(schema_sql)
        execute_multiple_line(cursor_mysql, schema_sql)
        commit(mysql_conn)
       
    except Exception as e:
        rollback(mysql_conn)
        logger.error("Error: " + str(e))
        if(LOG_CONSOLE_LEVEL == "DEBUG"):
            traceback.print_exc()
    finally:
        close_database(mysql_conn)
def import_datasource(datasource,force,keep):
    global MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, IMPORT_PATH
    logger.info(f"Importing datasource {datasource}")
    mysql_conn, cursor_mysql = open_database(MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD)
    # get the datasource config
    datasource_config = get_datasource_config(cursor_mysql, MYSQL_DATABASE, IMPORT_PATH, datasource)
    csv_import_path = datasource_config["csv_import_path"]    
    iso_time = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    marker_file = os.path.join(csv_import_path, f"{iso_time}.importing")
    # find the ready marker file
    # we only run the import if there is no .importing file
    # and there is a .ready file
    ready_files = [file for file in os.listdir(csv_import_path) if file.endswith(".ready")]
    csv_files = [file for file in os.listdir(csv_import_path) if file.endswith(".csv")]
    try:

        if len(csv_files) == 0:
            raise Exception("No csv files found to import")

        if len(ready_files) == 0 and not force:
            raise Exception("No .ready file found, datasource not ready to import")        

        # if already importing, raise an error
        # any file ending with .importing is considered as an import in progress
        # use the filename as the timestamp to show in the error message
        # find any file ending with .importing
        # get the file name
        # raise an error
        for file in os.listdir(csv_import_path):
            if file.endswith(".importing"):
                timestamp = file.split(".")[0]
                # parse the time from "%Y-%m-%d_%H-%M-%S"
                time = datetime.datetime.strptime(timestamp, "%Y-%m-%d_%H-%M-%S")
                human_time = time.strftime("%Y-%m-%d %H:%M:%S")
                raise Exception(f"Import in progress: running since {human_time}")


        # create a marker file to indicate that the import is in progress, do avoid double imports
        iso_time = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        marker_file = os.path.join(csv_import_path, f"{iso_time}.importing")
        with open(marker_file, "w") as f:
            f.write("Import in progress")

        # remove the .ready files, at this point
        for file in ready_files:
            os.remove(os.path.join(csv_import_path, file))            

        schema = datasource_config["schema"]
        fix_csvs(datasource_config)                        # fix csv columns, a collect file info
        # start the actual import
        start_transaction(mysql_conn)                      # start transaction
        disable_foreign_key_checks(cursor_mysql)           # disable foreign key checks

        # first create the dump database & tables
        recreate_dump_database(cursor_mysql, datasource_config)               # recreate the dump database from production
        remove_unique_constraints_from_dump(cursor_mysql, datasource_config)  # remove unique constraints from dump
        set_global_local_infile(cursor_mysql)                                 # set global local infile // allow local infile
        set_allow_invalid_dates(cursor_mysql)                                 # set allow invalid dates, for dates like 0000-00-00
        import_data_from_files(cursor_mysql, datasource_config)               # import data from files // load data infile

        # first commit, dump tables are ready and filled
        commit(mysql_conn)

        # add temp auto increment, it will automatically set the new___id to the new auto increment value
        # the start value is set based on the count of records in the dump table
        # this is done to avoid create clean id's and avoid conflicts
        start_transaction(mysql_conn)                                       # start transaction
        collect_auto_increments(cursor_mysql, datasource_config)            # collect auto increments
        add_temp_auto_increment_to_dump(cursor_mysql, datasource_config)    # add temp auto increment   
        # this is more due to a bug for delete from left join, we set the dump database as the current database
        execute_sql(cursor_mysql, f"USE dump___{schema};")
        correct_ids(cursor_mysql, datasource_config)                     # correct the id's
        remove_temp_auto_increment_from_dump(cursor_mysql, datasource_config)    # remove the temp auto increment
        validate_dump_data(cursor_mysql, datasource_config)                      # validate the dump data
        delete_from_tables(cursor_mysql, datasource_config)                      # remove the records in the production
        delete_from_staging(cursor_mysql, datasource_config)                     # remove the records in the staging
        add_to_staging(cursor_mysql, datasource_config)                          # add the data to staging
        add_to_production(cursor_mysql, datasource_config)                       # add the data to production
        drop_database(cursor_mysql, f"dump___{schema}")                          # drop the dump database
        enable_foreign_key_checks(cursor_mysql)                                  # enable foreign key checks
        
        commit(mysql_conn)    # commit the transaction

        if not keep:
            # remove all csv files after the import
            csv_files = [file for file in os.listdir(csv_import_path) if file.endswith(".csv")]
            for file in csv_files:
                os.remove(os.path.join(csv_import_path, file))

    except Exception as e:
        # Log the error and rollback changes in case of an error
        rollback(mysql_conn)

        # Log the error
        logger.error("Error: " + str(e))
        if(LOG_CONSOLE_LEVEL == "DEBUG"):
            traceback.print_exc()

        
    finally:


        # close databases
        close_database(mysql_conn)

        # remove the marker file if it exists
        if os.path.exists(marker_file):
            os.remove(marker_file)
def init_datasourcer(force):
    global MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, IMPORT_PATH
    logger.info("Init datasourcer")
    mysql_conn, cursor_mysql = open_database(MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD)
    try:
        if force or not schema_exists(cursor_mysql, MYSQL_DATABASE):
            drop_database(cursor_mysql, MYSQL_DATABASE)
            sql = get_datasourcer_schema_sql(cursor_mysql, MYSQL_DATABASE)
            start_transaction(mysql_conn)
            execute_multiple_line(cursor_mysql, sql)
            commit(mysql_conn)
            logger.info("Datasourcer initialized")
        else:
            # check if the schema exists
            logger.warning(f"Schema {MYSQL_DATABASE} already exists")
    except Exception as e:
        rollback(mysql_conn)
        logger.error("Error: " + str(e))
        if(LOG_CONSOLE_LEVEL == "DEBUG"):
            traceback.print_exc()
    finally:
        close_database(mysql_conn)

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Datasourcer")
    
    subparsers = parser.add_subparsers(dest="command")

    # Config command
    subparsers.add_parser("config", help="Show config")

    # List command
    subparsers.add_parser("list", help="List datasources")

    # Import command
    import_parser = subparsers.add_parser("import", help="Import datasource")
    import_parser.add_argument("datasource", type=str, help="Datasource name")
    import_parser.add_argument("--force", action="store_true", help="Force import, ignore .ready file")    
    import_parser.add_argument("--keep", action="store_true", help="Keep csv files after import")

    # Add command
    add_parser = subparsers.add_parser("add", help="Add datasource")
    add_parser.add_argument("datasource", type=str, help="Datasource name")
    add_parser.add_argument("schema", type=str, help="Schema name")

    # Remove command
    remove_parser = subparsers.add_parser("remove", help="Remove datasource")
    remove_parser.add_argument("datasource", type=str, help="Datasource name")

    # Show command
    show_parser = subparsers.add_parser("show", help="Show datasource")
    show_parser.add_argument("datasource", type=str, help="Datasource name")

    # Reset command
    reset_parser = subparsers.add_parser("reset", help="Reset schema")
    reset_parser.add_argument("schema", type=str, help="Schema name")

    # init command (with optional force)
    init_parser = subparsers.add_parser("init", help="Init")
    init_parser.add_argument("--force", action="store_true", help="Force init")

    args = parser.parse_args()

    match args.command:
        case "config":
            show_config()
        case "show":
            show_datasource(args.datasource)
        case "list":
            show_datasources()
        case "import":
            start_time = timeit.default_timer()
            import_datasource(args.datasource,args.force,args.keep)
            elapsed = timeit.default_timer() - start_time
            logger.info(f"Elapsed time: {elapsed:.2f} seconds")
        case "add":
            add_datasource(args.datasource, args.schema)
        case "remove":
            remove_datasource(args.datasource)
        case "reset":
            reset_schema(args.schema)
        case "init":
            init_datasourcer(args.force)
        case _:
            parser.print_help()
