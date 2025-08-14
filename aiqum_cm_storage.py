aiqum = {
    "host": "172.16.0.88",
    "port": 3306,
    "user": "af",
    "password": "Netapp12"
}
import_path = './import'
datasource_name = "aiqum"

# set the path to the directory where the AIQUM data will be stored
# in ./mysql_queries, there are some sql files
# every sql file is like {schema}.{table}.sql
# go over the files and create a dictionary with the schema as key and the table as value

# loop all the files in the directory
# get the schema and table name
# create a path .\{import_path}\{datasource_name\{schema}
# execute the mysql command from the file (in my_library there is a function execute_sqlfile(mysql_cursor,path,True) )
# the result of the query must be stored in the path as an csv file : .\{import_path}\{datasource_name\{schema}\{table}.csv

import os
import pandas as pd
import csv
import pymysql

#avoid Connections using insecure transport are prohibited while --require_secure_transport=ON

mysql_conn = pymysql.connect(host=aiqum["host"], port=aiqum["port"], user=aiqum["user"], password=aiqum["password"], cursorclass=pymysql.cursors.DictCursor,ssl={"fake_flag_to_enable_tls":True})
cursor_mysql = mysql_conn.cursor()


for file in os.listdir('./mysql_queries'):

    schema, table, extension = file.split('.')
    path = os.path.join(import_path, schema, datasource_name)
    if not os.path.exists(path):
        os.makedirs(path)
    with open(f'./mysql_queries/{file}', 'r') as f:
        sql = f.read()
        # replace new lines with space
        # remove \r
        sql = sql.replace('\r', '')
        sql = sql.replace('\n', ' ')

    cursor_mysql.execute(sql)
    result = cursor_mysql.fetchall()
    # write the result to a csv file with pandas
    df = pd.DataFrame(result)
    csv_path = os.path.join(path, f'{table}.csv')
    df.to_csv(csv_path, index=False, quoting=csv.QUOTE_NONNUMERIC, doublequote=True, escapechar='\\')
# create a .ready file in the path
    with open(os.path.join(path, '.ready'), 'w') as f:
        pass
    
cursor_mysql.close()
mysql_conn.close()
# run python script "datasourcer.py import {datasource_name}"
os.system(f'python datasourcer.py import {datasource_name} --keep')
