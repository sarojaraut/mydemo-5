set timing on;
-- Data set up
-- create 10 thousand currency records
insert into currency
select
    dbms_random.string('U',3) as  from_currency
    ,dbms_random.string('U',3) as  to_currency
from dual
connect by rownum <= 10000; -- Elapsed: 00:00:00.21
--10,000 rows inserted. Elapsed: 00:00:00.191

commit;
EXECUTE DBMS_STATS.GATHER_TABLE_STATS (USER,'CURRENCY');
-- create 100 thousand currency conversion records
-- for last 10 days conversion date
insert into fx_currency
select
    rownum                       as  id
    ,c.from_currency             as  from_currency
    ,c.to_currency               as  to_currency
    ,dbms_random.value(1,99)     as  fx_rate
    ,dt                          as  created_date
from currency c
cross join (
    select trunc(sysdate)-rownum-1 as dt
    from dual connect by rownum <= 10
);--Elapsed: 00:00:00.56
--100,000 rows inserted. Elapsed: 00:00:00.369

commit;
EXECUTE DBMS_STATS.GATHER_TABLE_STATS (USER,'FX_CURRENCY');
-- create 1.5 million transactions
-- 0.3 million refund and 1.2 million capture
insert into transaction
select
    rownum                      as id
    ,dbms_random.string('x',10) as reference
    ,decode(mod(rec_rank,5),
        0,'refund'
        ,'capture')              as type
    ,dbms_random.value(1,999)   as amount
    ,fc.from_currency           as currency_code
    ,fc.to_currency             as capture_currency_code
    ,fc.created_date            as created_date
    ,NULL                       as processed_date
from fx_currency fc
cross join (
    select rownum as rec_rank
    from dual connect by rownum <= 15
) t; --Elapsed: 00:00:36.81
-- 1,500,000 rows inserted. Elapsed: 00:00:19.173

commit;
EXECUTE DBMS_STATS.GATHER_TABLE_STATS (USER,'TRANSACTION');
-- create ~0.4 billion payment records
insert into payment
select
    rownum                      as id
    ,t.id                       as trans_id
    ,case
        when p.rec_rank <= 24
        then 'fail'
        else 'success'
    end                         as status
    ,dbms_random.value(1,999)   as amount
    ,t.currency_code            as currency_code
    ,p.dt                       as created_date
from transaction t
cross join (
    select
        trunc(sysdate)-rownum-1 as dt,
        rownum                  as rec_rank
    from dual connect by rownum <= 25
) p; 
-- 9,000,000 rows created. Elapsed: 00:02:10.11 
-- 75,000,000 rows created. Elapsed: 00:14:11.90
-- 37,500,000 rows inserted.

commit;

EXECUTE DBMS_STATS.GATHER_TABLE_STATS (USER,'PAYMENT');
