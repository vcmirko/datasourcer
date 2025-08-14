from .mysql_functions import execute_sql, mysql_escape_string
from .database_functions import recreate_database, get_count
from .common import get_csv_path
import pandas as pd
import csv
import os
import logging

logger = logging.getLogger('datasourcer')


# =============================================================================
# Import database functions
# =============================================================================
def recreate_dump_database(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    tables = datasource_config["tables"]
    logger.info("Creating dump database")
    recreate_database(cursor_mysql, f"dump___{schema}")
    for table in tables:
        sql = f"CREATE TABLE dump___{schema}.{table} LIKE {schema}.{table};"
        execute_sql(cursor_mysql, sql)
def remove_unique_constraints_from_dump(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    unique_constraints = datasource_config["unique_constraints"]
    tables = datasource_config["tables"]
    logger.info("Removing unique key constraints")
    for constraint in unique_constraints:
        table = constraint['TABLE_NAME']
        if table not in tables:
            continue
        index = constraint['INDEX_NAME']
        if(index=='PRIMARY'):
            sql = f"ALTER TABLE dump___{schema}.{table} CHANGE `id` `id` INT(11) NOT NULL, DROP PRIMARY KEY;"
        else:
            sql = f"ALTER TABLE dump___{schema}.{table} DROP INDEX {index};"
        execute_sql(cursor_mysql, sql)
def import_data_from_files(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    tables = datasource_config["tables"]
    csv_files = datasource_config["csv_files"]

    csv_import_path = datasource_config["csv_import_path"]
    logger.info("Importing data from files")
    # dump data in tables
    for table in tables:
        filename = get_csv_path(csv_import_path, table)
        # check if the file exists and is not empty
        if filename not in csv_files:
            continue
        file_path = mysql_escape_string(filename)
        load_sql = (
            f"LOAD DATA LOCAL INFILE '{file_path}' "
            f"INTO TABLE dump___{schema}.{table} "
            f"FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' "
            f"ESCAPED BY '\\\\' "
            f"LINES TERMINATED BY '\\n' "
            f"IGNORE 1 LINES;"
        )
        execute_sql(cursor_mysql, load_sql)
def delete_from_tables(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    datasource = datasource_config["datasource"]
    tables = datasource_config["tables"]
    datasourcer_schema = datasource_config["datasourcer_schema"]
    logger.info("Removing from tables")
    for table in tables:
        delete_sql = (
            f"DELETE {schema}.{table} "
            f"FROM {schema}.{table} JOIN "
            f"(SELECT staging.* "
            f"FROM {datasourcer_schema}.staging JOIN "
            f"{datasourcer_schema}.datasource ON staging.datasource_id=datasource.id "
            f"AND datasource.name='{datasource}' "
            f"AND staging.table_name='{table}') s "
            f"ON {table}.id=s.table_id;"
        )
        execute_sql(cursor_mysql, delete_sql)
def delete_from_staging(cursor_mysql, datasource_config):
    datasource = datasource_config["datasource"]
    datasourcer_schema = datasource_config["datasourcer_schema"]
    logger.info("Removing from staging")
    delete_sql = (
        f"DELETE {datasourcer_schema}.staging "
        f"FROM {datasourcer_schema}.staging JOIN "
        f"{datasourcer_schema}.datasource ON staging.datasource_id=datasource.id "
        f"AND datasource.name='{datasource}';"
    )
    execute_sql(cursor_mysql, delete_sql)
def validate_dump_data(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    foreign_keys = datasource_config["foreign_keys"]
    logger.info("Cleaning up bad foreign keys")
    # remove records from dump tables where with missing foreign keys
    # or update the foreign key to null if cascade delete is not set
    for foreign_key in foreign_keys:
        table = foreign_key["TABLE_NAME"]
        referenced_table = foreign_key["REFERENCED_TABLE_NAME"]
        column = foreign_key["COLUMN_NAME"]
        referenced_column = foreign_key["REFERENCED_COLUMN_NAME"]
        cascade_delete = foreign_key["DELETE_RULE"]
        # delete records from dump table where foreign key is missing and cascade delete is set
        if cascade_delete == "CASCADE":
            sql = f"DELETE `x` FROM dump___{schema}.{table} `x` LEFT JOIN dump___{schema}.{referenced_table} `y` ON x.{column} = y.{referenced_column} WHERE y.{referenced_column} IS NULL;"
            execute_sql(cursor_mysql, sql)
        if cascade_delete == "SET NULL":
            sql = f"UPDATE dump___{schema}.{table} `x` LEFT JOIN dump___{schema}.{referenced_table} `y` ON x.{column} = y.{referenced_column} SET x.{column} = NULL WHERE y.{referenced_column} IS NULL;"
            execute_sql(cursor_mysql, sql)
def collect_auto_increments(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    tables = datasource_config["tables"]
    table_info = datasource_config["table_info"]
    logger.info("Collecting auto increments")
    # get the count of records in the dump tables and register in table_info
    for table in tables:
        count = get_count(cursor_mysql, f"dump___{schema}", table)
        table_info[table]["dump_count"] = count
        # set the new auto increment value based on the count of records in the dump table and the min value
        # -----------------------------------------------
        # if the dump fits before the lowest id, insert the dump at the start
        # if not, add the dump after the highest id
        # doing this will keep clean id's non-stop increasing
        # here we search for the best place to insert the dump
        # -----------------------------------------------
        if count < (table_info[table]["min"]):
            # logger.debug(f"Dump fits before the lowest id for table {table} - {count} < {table_info[table]['min']} -> 1")
            table_info[table]["new_auto_increment"] = 1
        else:
            # logger.debug(f"Dump fits after the highest id for table {table} - {count} >= {table_info[table]['min']} -> {table_info[table]['max']} + 1")
            table_info[table]["new_auto_increment"] = table_info[table]["max"] + 1
def add_temp_auto_increment_to_dump(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    tables = datasource_config["tables"]
    table_info = datasource_config["table_info"]
    # -----------------------------------------------
    # the goal is create new clean id's
    # but still keep the references between tables
    # -----------------------------------------------
    logger.debug("Adding temp auto increment")
    for table in tables:
        auto_increment_value = table_info[table]["new_auto_increment"]
        sql = f"ALTER TABLE dump___{schema}.{table} ADD COLUMN `new___id` INT(11) NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`new___id`), AUTO_INCREMENT={auto_increment_value};"
        execute_sql(cursor_mysql, sql)
def correct_ids(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    tables = datasource_config["tables"]
    foreign_keys = datasource_config["foreign_keys"]
    logger.info("Correcting id's")
    # -----------------------------------------------
    # after adding the new auto increment id's, we have clean new id's
    # the foreign keys need to be updated to these new id's
    # -----------------------------------------------
    for table in tables:
        # for every foreign key, update the foreign key to the new id of the referenced table
        for foreign_key in foreign_keys:
            if foreign_key["TABLE_NAME"] == table:
                referenced_table = foreign_key["REFERENCED_TABLE_NAME"]
                referenced_column = foreign_key["REFERENCED_COLUMN_NAME"]
                column = foreign_key["COLUMN_NAME"]
                # update the foreign key to the new id
                sql = f"UPDATE dump___{schema}.`{table}` `x` JOIN dump___{schema}.`{referenced_table}` `y` ON x.{column} = y.{referenced_column} SET x.{column} = y.new___id;"
                execute_sql(cursor_mysql, sql)

    # finally update all the primary keys
    for table in tables:
        # set id to new auto increment id
        sql = f"UPDATE dump___{schema}.`{table}` SET id=new___id;"
        execute_sql(cursor_mysql, sql)
def remove_temp_auto_increment_from_dump(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    tables = datasource_config["tables"]
    # -----------------------------------------------
    # after correcting the id's, we can remove the temp auto increment
    # and set the primary key back to id
    # -----------------------------------------------
    logger.info("Removing temp id")
    for table in tables:
        # remove the new___id column
        # and set the primary index back to id
        sql = f"ALTER TABLE dump___{schema}.`{table}` DROP COLUMN new___id;"
        execute_sql(cursor_mysql, sql)
        sql = f"ALTER TABLE dump___{schema}.`{table}` ADD PRIMARY KEY (`id`);"
        execute_sql(cursor_mysql, sql)
def add_to_staging(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    tables = datasource_config["tables"]
    datasource_id = datasource_config["datasource_id"]
    datasourcer_schema = datasource_config["datasourcer_schema"]
    # -----------------------------------------------
    # add the data to the staging table
    # the staging tables is a table that keeps track of which record is for which datasource
    # this allows us to have multiple datasources in the same database
    # at each refresh, we need to know which old records are for which datasource to remove
    # here we add the new records to the staging table
    # ps : this table is huge, but it is only used for the delete queries
    # -----------------------------------------------
    logger.info("Adding to staging")
    for table in tables:
        sql = f"INSERT IGNORE INTO {datasourcer_schema}.staging(datasource_id,table_id,table_name) SELECT {datasource_id},id,'{table}' FROM dump___{schema}.`{table}`;"
        execute_sql(cursor_mysql, sql)
def add_to_production(cursor_mysql, datasource_config):
    schema = datasource_config["schema"]
    tables = datasource_config["tables"]
    # -----------------------------------------------
    # add the data to the production tables
    # all id's have been corrected and all foreign keys have been updated
    # and all dumps with nicely fit either at the start or at the end of the current records
    # -----------------------------------------------
    logger.info("Insert into production")
    for table in tables:
        sql = f"INSERT IGNORE INTO {schema}.`{table}` SELECT * FROM dump___{schema}.`{table}`;"
        execute_sql(cursor_mysql, sql)

# =============================================================================
# Import csv functions
# =============================================================================
def compare_headers_with_columns(headers, columns, table):
    missing_in_csv = [column for column in columns if column not in headers]
    missing_in_table = [header for header in headers if header not in columns]
    if len(missing_in_csv) > 0:
        # if only missing_in_csv = "id", accept it, we will add it with \N value using pandas reindex
        if len(missing_in_csv) == 1 and missing_in_csv[0] == "id":
            logger.warning(f"Id column missing in csv for table {table} - fixing")
            return "ADD_ID"
        else:
            raise Exception(f"Columns missing in csv: {missing_in_csv}")
    if len(missing_in_table) > 0:
        logger.warning(f"Extra column found in csv : {missing_in_table}")
    return "OK"
def correct_csv(path):
    # remove carriage return from csv files
    with open(path, 'r') as file:
        filedata = file.read()
    file.close()
    # correct line endings and \\N => \N (for NULL values)
    filedata = filedata.replace('"\\\\N"', r"\N")
    filedata = "\n".join(filedata.splitlines())

    # Write the file out again
    with open(path, 'w',newline="\n") as file:
        file.write(filedata)
    file.close()
def fix_csvs(datasource_config):
    logger.debug("Fixing csv files")
    csv_import_path = datasource_config["csv_import_path"]
    table_info = datasource_config["table_info"]
    tables = datasource_config["tables"]
    csv_files = []
    for table in tables:
        file_path = get_csv_path(csv_import_path, table)
        # check if the file exists
        if os.path.exists(file_path): 
            # check if the file is empty
            if os.path.getsize(file_path) == 0:
                os.remove(file_path)
                logger.warning(f"Removing empty file {file_path}")
                continue

            # if the first line is empty or newline, remove it
            with open(file_path, 'r') as file:
                first_line = file.readline().strip(' \t\n\r')
                if first_line == "":
                    file.close()
                    os.remove(file_path)
                    logger.warning(f"Removing empty header file {file_path}")
                    continue
            file.close()


            csv_files.append(file_path)
            # -----------------------------------
            # Start fix
            # -----------------------------------
            logger.debug(f"Checking csv columns for table {table}")

            # get the columns for the table
            columns = table_info[table]["columns"]

            # read csv, set headers to lower case
            data = pd.read_csv(file_path, delimiter=",", quotechar='"', escapechar="\\")
            data.columns = data.columns.str.lower()
            headers = data.columns.tolist()

            # compare headers with columns
            if compare_headers_with_columns(headers, columns, table) == "ADD_ID":
                data["id"] = r"\N"

            # check if the arrays are equal (same order too)
            if columns != headers:
                # reorder the columns in the csv according to the table
                data = data.reindex(columns=columns)
                data.to_csv(file_path, index=False, sep=",", header=True, doublequote=True, escapechar="\\",quoting=csv.QUOTE_ALL,lineterminator="\n")
                logger.warning(f"Reordered columns in csv for table {table}")
            else:
                pass
                logger.debug(f"Columns in csv are in correct order for table {table}")
            # correct the csv file
            correct_csv(file_path)
    # store the csv files that exists and not empty
    datasource_config["csv_files"] = csv_files

    # remove all extra csv files
    for file in os.listdir(csv_import_path):
        # get full path of file from file object
        filepath = os.path.join(csv_import_path, file)
        if file.endswith(".csv") and filepath not in csv_files:
            os.remove(filepath)
            logger.warning(f"Removing unexpected file {file}")