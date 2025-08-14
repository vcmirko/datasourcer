import re
import os
import yaml

# /*table structure for table `disk` */
# drop table if exists `disk`;

# create table `disk` (
#   `id` int(11) not null auto_increment,
#   `name` varchar(255) character set utf8 collate utf8_bin not null,
#   `size_mb` bigint(20) not null,
#   `used_size_mb` bigint(20) not null,
#   `available_size_mb` bigint(20) not null,
#   `raid_type` varchar(255) default null comment 'possible values are raid_dp,raid4,raid0,raid_tec',
#   `node_id` int(11) not null,
#   `shelfbay` int(11) default null,
#   `containertype` varchar(255) default null,
#   `partitioningtype` varchar(255) default null,
#   `raidposition` varchar(255) default null,
#   `isfailed` tinyint(1) default null,
#   `serialnumber` varchar(255) default null,
#   `rpm` int(11) default null,
#   `iszeroing` tinyint(1) default null,
#   `iszeroed` tinyint(1) default null,
#   `zeroingpercent` int(11) default null,
#   primary key (`id`),
#   unique key `uk_cm_storage_disk_natural_key` (`name`,`node_id`),
#   key `fk_cm_storage_disk_node_id` (`node_id`),
#   constraint `fk_cm_storage_disk_node_id` foreign key (`node_id`) references `node` (`id`) on delete cascade
# ) engine=innodb default charset=utf8;

# the text part above is repeated in a sql file called ./import/cm_storage/schema copy.sql
# we need to parse this file line by line
# first drop empty lines and lines starting with r"/*"
# ignore lines starting with "drop"
# every block starts with "create" and ends with "") engine"
# the part between `` in the create line is the table name, this is the key in the dictionary

# the lines between start and end are the table definition, we need to parse this
# trim every line
# if the line starts with ` then it is a column definition
# the part between the first two ` is the column name
# the next part is the column type, with the length in parentheses
# the last part needs to be analyzed
# if it is "not null" then add flag "nullable: False"
# if it has a comment + r"([^']*)" then add property "comment: $1"
# if it has a default + r"([^\s]*)"  then add property "default: $1"
# if it has set utf8 collate utf8_bin then add flag case_sensitive: True
# lines starting with unique => parse the parts between parentheses and add a unique flag to these columns
# ignore lines starting with key
# lines starting with constraint => parse the parts between first parentheses and add a foreign_key property to these columns, the value is either delete_cascade or delete_set_null
# finally, analyze columns, if a column end with _id and it has a foreign_key property, drop the _id.

# create a dictionary with the table name as key and a dictionary as value with the column properties

# read the file

# open the file

def parse_sql_file(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    table_definitions = {}
    columns = []
    column = {}
    unique_columns = []
    foreign_key_columns = {}
    current_table = None

    for line in lines:
        line = line.strip().lower()
        if not line or line.startswith('/*') or line.startswith('drop'):
            continue
        if line.startswith('create'):
            current_table = re.search(r'`([^`]*)`', line).group(1)
            # print(f"Table: {table_name}")
            columns = []
            unique_columns = []
            foreign_key_columns = {}
            constraint_actions = {}
            table_definitions[current_table] = []
        elif line.startswith(') engine'):
            for col in columns:
                if col['name'].endswith('_id') and col['name'] in foreign_key_columns:
                    col['foreign_key'] = foreign_key_columns[col['name']]
                    col['constraint_actions'] = constraint_actions[col['name']]
                    col['name'] = col['name'][:-3]
                if col['name'] in unique_columns:
                    col['unique'] = True
            table_definitions[current_table] = columns
            current_table = None
        elif current_table:
            if line.startswith('`'):
                column = {}
                column_name = re.search(r'`([^`]*)`', line).group(1)
                # skip id column
                if(column_name == 'id'):
                    continue
                # get type and length
                matches = re.search(r"` ([^\(]*)\(([^\)]*)\)", line)
                if matches:
                    col_type = matches.group(1)
                    col_length = int(matches.group(2))
                    column["type"] = col_type
                    if(col_type == 'int') or (col_type == 'bigint'):
                        # no more length for int and bigint
                        pass 
                    elif(col_type == 'varchar') and (col_length == 255):
                        # no more length for varchar(255)
                        del column["type"] # varchar(255) is default
                        pass
                    else:
                        column["length"] = col_length
                else:
                    matches = re.search(r"` ([^\s]*)", line)
                    if matches:
                        column["type"] = matches.group(1)
                        print(f" Skipping length for column {column_name}")
                    else:
                        raise Exception(f"Could not parse type for column {column_name}")

                if 'not null' in line:
                    column['nullable'] = False
                if 'comment' in line:
                    matches = re.search(r"comment '([^']*)'", line)
                    if matches:
                        column['comment'] = matches.group(1)
                if 'default' in line:
                    if 'default null' in line:
                        # column['nullable'] = True # default null is default
                        pass
                    else:
                        matches = re.search(r'default ([^\s]*)', line)
                        if matches:
                            column['default'] = matches.group(1)
                if 'character set utf8 collate utf8_bin' in line:
                    column['case_sensitive'] = True
                columns.append({'name': column_name, **column})
            elif line.startswith('unique'):
                unique_columns = re.findall(r'\(`([^`]*)`\)', line)
            elif line.startswith('constraint'):
                foreign_key_column = re.search(r'foreign key \(`([^`]*)`\)', line).group(1)
                remote_table = re.search(r'references `([^`]*)`', line).group(1)
                foreign_key_columns[foreign_key_column] = remote_table
                if 'on delete cascade' in line:
                    constraint_actions[foreign_key_column] = 'delete_cascade'
                elif 'on delete set null' in line:
                    constraint_actions[foreign_key_column] = 'delete_set_null'

    return table_definitions

# set current path to script path
import os
os.chdir(os.path.dirname(__file__))

file_path = './import/cm_storage/schema copy.sql'
table_definitions = parse_sql_file(file_path)

# output as yaml to file
with open('table_definitions.yaml', 'w') as file:
    yaml.dump(table_definitions, file,sort_keys=False, default_flow_style=True)