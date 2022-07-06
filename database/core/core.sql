create schema if not exists core authorization postgres;
grant all on schema core to postgres;
grant usage on schema core to web;