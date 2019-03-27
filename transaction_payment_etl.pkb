create or replace package body transaction_payment_etl
is
    procedure load_target_using_sql_plsql
    is
        cursor payment_cur is
            select
                transaction_payment_id_seq.nextval seq_val
                ,id
                ,trans_id
                ,amount
                ,status
                ,currency_code
                ,created_date
            from payment;
        type payment_tab is table of  payment_cur%rowtype;
        l_payment_tab       payment_tab;
        c_limit   constant  number := 100;
    begin
        open payment_cur;

        loop
            fetch payment_cur
            bulk collect into l_payment_tab
            limit c_limit;

            exit when l_payment_tab.count=0;

            forall idx in 1..l_payment_tab.count
                insert all into transaction_payment(
                    id
                    ,trans_id
                    ,payment_id
                    ,trans_reference
                    ,trans_type
                    ,trans_amount
                    ,payment_amount
                    ,payment_status
                    ,trans_currency
                    ,payment_currency
                    ,fx_rate
                    ,trans_date
                    ,payment_date
                )
                select
                    l_payment_tab(idx).seq_val        as id
                    ,t.id                             as trans_id
                    ,l_payment_tab(idx).id            as payment_id
                    ,t.reference                      as trans_reference
                    ,t.type                           as trans_type
                    ,case t.type
                        when 'refund'
                        then -1 * t.amount
                    else t.amount                     
                    end                               as trans_amount
                    ,case t.type
                        when 'refund'
                        then -1*l_payment_tab(idx).amount
                    else l_payment_tab(idx).amount    
                    end                               as payment_amount
                    ,l_payment_tab(idx).status        as payment_status
                    ,t.currency_code                  as trans_currency
                    ,l_payment_tab(idx).currency_code as payment_currency
                    ,fc.fx_rate                       as fx_rate
                    ,t.created_date                   as trans_date
                    ,l_payment_tab(idx).created_date  as payment_date
                from transaction t
                left join fx_currency fc
                on (fc.from_currency    = t.currency_code
                    and fc.to_currency  = t.capture_currency_code
                    and fc.created_date = t.created_date)
                where t.id = l_payment_tab(idx).trans_id;
        end loop;
    exception
      when others then
        dbms_output.put_line(sqlerrm);
        raise;
    end load_target_using_sql_plsql;
    --
    --
    procedure load_target_using_sql_only
    is
    begin
        insert into transaction_payment(
            id
            ,trans_id
            ,payment_id
            ,trans_reference
            ,trans_type
            ,trans_amount
            ,payment_amount
            ,payment_status
            ,trans_currency
            ,payment_currency
            ,fx_rate
            ,trans_date
            ,payment_date
        )
        select
            rownum               as id
            ,t.id                as trans_id
            ,p.id                as payment_id
            ,t.reference         as trans_reference
            ,t.type              as trans_type
            ,case t.type
                when 'refund'
                then -1 * t.amount
            else t.amount        
            end                  as trans_amount
            ,case t.type
                when 'refund'
                then -1 * p.amount
            else p.amount        
            end                  as payment_amount
            ,p.status            as payment_status
            ,t.currency_code     as trans_currency
            ,p.currency_code     as payment_currency
            ,NVL(fc.fx_rate,0)   as fx_rate
            ,t.created_date      as trans_date
            ,p.created_date      as payment_date
        from payment p
        join transaction t
        on (p.trans_id = t.id)
        left join fx_currency fc
        on (fc.from_currency    = t.currency_code
            and fc.to_currency  = t.capture_currency_code
            and fc.created_date = t.created_date);
    exception
      when others then
        dbms_output.put_line(sqlerrm);
        raise;
    end load_target_using_sql_only;
end transaction_payment_etl;
/

show err;

