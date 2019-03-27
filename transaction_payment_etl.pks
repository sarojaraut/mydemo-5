create or replace package transaction_payment_etl
is
    -- loads target table using cursor loop
    -- and bulk fetch and bulk load
    procedure load_target_using_sql_plsql;
    -- loads target table using one sql and
    --    uses case for conditional transformation
    --    uses outer join for conditional lookup
    procedure load_target_using_sql_only;
end transaction_payment_etl;
/

show err;
