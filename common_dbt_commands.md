# Most commun dbt commands

- dbt run
```bash
# run all models in dependency order
dbt run 

# run with full refresh, which will drop and recreate all tables/views
dbt run -f | --full-refresh

# run a specific model. Specify the nodes to include.
dbt run -s, -m, --select, --models, --model TUPLE

# Specify the nodes to exclude.
dbt run --exclude TUPLE

# run a specific model and all upstream models
dbt run -m +[model_name] 

# run a specific model and all downstream models
dbt run -m [model_name]+ 

# run a specific model and all up/downstream models
dbt run -m +[model_name]+ 
```

- dbt test

Runs tests on data in deployed models.
```bash
# run all tests (generic and singular)
dbt test 

# run tests on specific models
dbt test -m TUPLE

# Specify the nodes to exclude.
dbt test --exclude TUPLE

# run tests on all models in a subdirectory (models/dir1/subdir1)
dbt test --select dir1.subdir1 

# run tests on all models in a source
dbt test --select source:my_source_1 source:my_source_2 

# run tests in a specific test file located in the ./tests/ directory
dbt test --select name_of_test_file 
```

- dbt compile

`dbt compile` is similar as run, but it does not execute the model, it only compiles it and displays the actual executable SQL code that will be executed for a specific model. It is useful to debug a model.
```bash
# compile all models in dependency order
dbt compile

# compile a specific model
dbt compile -m [model_name]
```

- dbt build

Run all seeds, models, snapshots, and tests in DAG order. This is equivalent to running `dbt seed`, `dbt run`, and `dbt test` in succession.
```bash
# run all models and perform all tests
dbt build 

# run with full refresh, which will drop and recreate all tables/views
dbt build -f | --full-refresh

# run and tests specific models
dbt build --select TUPLE

# Specify the nodes to exclude.
dbt build --exclude TUPLE

... (similar as dbt run)
```
- Miscellaneous
```bash
# Pull the most recent version of the dependencies listed in packages.yml
dbt deps

# Load data from csv files into your data warehouse.
dbt seed

# run the named macro with any supplied arguments.
dbt run-operation [operation_name] 

# Generate the documentation for your project
dbt docs generate
# Serve the documentation website for your project
dbt docs serve

# Check the freshness of your sources
dbt source freshness

# Ask for details about a specific command
dbt [command] -h | --help
```




