-- Source tables:

    create table currency(
        from_currency    varchar2(3)
        ,to_currency     varchar2(3)
        ,constraint currency_pk primary key (from_currency,to_currency)
    );

    create table fx_currency(
        id               number(11)
        ,from_currency   varchar2(3)
        ,to_currency     varchar2(3)
        ,fx_rate         number(5,3)
        ,created_date    date
        ,constraint fx_currency_pk primary key (id)
    );

    create table transaction(
        id                      number(11)
        ,reference              varchar2(20)
        ,type                   varchar2(15) -- capture, refund
        ,amount                 number(5,2)
        ,currency_code          varchar2(3)
        ,capture_currency_code  varchar2(3)
        ,created_date           date
        ,processed_date         date
        ,constraint transaction_pk primary key (id)
    );

    create table payment(
        id               number(11)
        ,trans_id        number(11)
        ,status          varchar2(10)  -- success, fail
        ,amount          number(5,2)
        ,currency_code   varchar2(3)
        ,created_date    date
        ,constraint payment_pk primary key (id)
        ,constraint payment_fk foreign key (trans_id) references transaction(id)
    );

-- Target Tables:
    create table transaction_payment(
        id                 number(11)
        ,trans_id          number(11)
        ,payment_id        number(11)
        ,trans_reference   varchar2(20)
        ,trans_type        varchar2(15)
        ,trans_amount      number(5,2) -- to be nagative for refund
        ,payment_amount    number(5,2) -- to be negative for refund
        ,payment_status    varchar2(10)
        ,trans_currency    varchar2(3)
        ,payment_currency  varchar2(3)
        ,fx_rate           number(5,3) -- 0 if mapping not present
        ,trans_date        date
        ,payment_date      date
        ,constraint transaction_payment_pk primary key (id)
    );
-- Create sequence
create sequence transaction_payment_id_seq start with 1 increment by 1;

-- create package spec
@transaction_payment_etl.pks

-- create package body
@transaction_payment_etl.pkb