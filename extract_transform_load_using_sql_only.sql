set timing on;

EXECUTE DBMS_STATS.GATHER_TABLE_STATS (USER,'TRANSACTION_PAYMENT');

select systimestamp, 'loading using sql only' as status from dual;
exec transaction_payment_etl.load_target_using_sql_only;
commit;
select systimestamp, 'loaded using sql only' as status from dual;

EXECUTE DBMS_STATS.GATHER_TABLE_STATS (USER,'TRANSACTION_PAYMENT');

set sqlformat ansiconsole;
select
    table_name
    ,blocks
    ,avg_row_len
    ,num_rows
    ,sample_size
from user_tables where table_name in ('CURRENCY','FX_CURRENCY','TRANSACTION','PAYMENT','TRANSACTION_PAYMENT');

