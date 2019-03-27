# Demonstration of how sql only solution is faster than pl/sql counter part


## Prerequisites

1. [Download](https://github.com/sarojaraut/mydemo-5) this git repo `git clone git@github.com:sarojaraut/mydemo-5.git`.

1. Connect to the desired oracle schema: e.g `sql MYDBA/MYDBA@localhost:31521/myoms`

1. Run the schema setup script `@setup_schema.sql` .

1. Run the test data setup script `@setup_test_data.sql` .

1. Now invoke the sql only version of the code `@extract_transform_load_using_sql_only.sql` .

1. Now invoke the sql/plsql version of the code `@extract_transform_load_using_sql_plsql.sql` .

1. Assert how time taken by sql only version is faster by x times(x is directly propertional to the volume of records in the source table).

_Note : Execute privilage is needed on `DBMS_RANDOM` package which is used during test data setup e.g. `grant execute on dbms_random to mydba`_

## Schema description

Table Name | Record Count | Description 
--- | --- | ---
`CURRENCY`| 10,000 | Holds list of possible source and target currency mapping.
`FX_CURRENCY`| 100,000 | Holds 10 days currency conversion rates for all supported currency conversion.
`TRANSACTION` | 1.5 Million | Holds details of financial transactions of type `capture` or `refund`.
`PAYMENT` | 0.375 Billion | Holds details of payment atempts for all financial transactions, status can be `success` or `fail`.
`TRANSACTION_PAYMENT` | 0.375 Billion | Target table to be sourced from all above tables and needs to be populated with the transformed data. Data needs to be transformed based on the following tansformation rules


## Data transformation rules

Table Name | Column_name | Description 
--- | --- | ---
`TRANSACTION_PAYMENT` | `id` | Sequence generated value, primary key
` ` | `trans_id` |  `id` column from `TRANSACTION` table
` ` | `payment_id` |  `id` column from `PAYMENT` table
` ` | `trans_reference` |  `reference` column from `TRANSACTION` table
` ` | `trans_type` |  `type` column from `TRANSACTION` table
` ` | `trans_amount` |  `amount` column from `TRANSACTION` table
` ` | `trans_amount` |  `amount` column from `TRANSACTION` table. To be stored as negative figure if type is `refund`
` ` | `trans_currency` |  `currency` column from `TRANSACTION` table.
` ` | `payment_currency` |  `currency` column from `PAYMENT` table.
` ` | `fx_rate` |  `rate` column from `FX_CURRENCY` table, look up based on ... of `TRANSACTION` table. If look up entry is not there then set value to `0` instead of `NULL`.
` ` | `trans_date` |  `created_date` column from `TRANSACTION` table.
` ` | `payment_date` |  `created_date` column from `PAYMENT` table.

## My Observation

1. With the above load the `sql only` solution populates 0.375 billion records in target table within 10 Minutes.

1. With the above load the `sql/plsql` solution , which uses `bulk fetch`, `bulk bind` and `bulk load` could not get completed in 1 hour 45 minutes.

1. With the above volume of load `sql only` solution works at least 10 times faster than the `sql/plsql`.

1. I think further improvements can be made to the `sql only` variant by using features like `parallel processing`,`no logging` and by passing buffer cache using `append` hint .

1. Another variant solution can be built using partitioning and partition exchange.
