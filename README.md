# Datasourcer - Command Line Arguments

This project uses Python's `argparse` module to provide a command-line interface for managing datasources. Below is an explanation of the available commands and their arguments as defined in `datasourcer.py`.

## Usage

```sh
python datasourcer.py <command> [options]
```

## Commands and Arguments

### config
Show the current configuration.

```
python datasourcer.py config
```

### list
List all available datasources.

```
python datasourcer.py list
```

### import
Import a datasource.

**Arguments:**
- `datasource` (str, required): Name of the datasource to import.
- `--force` (optional): Force import, ignore `.ready` file.
- `--keep` (optional): Keep CSV files after import.

```
python datasourcer.py import <datasource> [--force] [--keep]
```

### add
Add a new datasource.

**Arguments:**
- `datasource` (str, required): Name of the datasource to add.
- `schema` (str, required): Name of the schema to use.

```
python datasourcer.py add <datasource> <schema>
```

### remove
Remove a datasource.

**Arguments:**
- `datasource` (str, required): Name of the datasource to remove.

```
python datasourcer.py remove <datasource>
```

### show
Show details for a datasource.

**Arguments:**
- `datasource` (str, required): Name of the datasource to show.

```
python datasourcer.py show <datasource>
```

### reset
Reset a schema.

**Arguments:**
- `schema` (str, required): Name of the schema to reset.

```
python datasourcer.py reset <schema>
```

### init
Initialize the environment.

**Arguments:**
- `--force` (optional): Force initialization.

```
python datasourcer.py init [--force]
```

---

For more details, see the source code in `datasourcer.py` or run `python datasourcer.py -h` for help.
