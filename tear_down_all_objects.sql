-- Tear Down :
set timing on;

drop package transaction_payment_etl;

drop table currency purge;

drop table fx_currency purge;

drop table payment purge;

drop table transaction purge;

drop table transaction_payment purge;

drop sequence transaction_payment_id_seq;
