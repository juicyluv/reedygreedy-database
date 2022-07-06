revoke all on database postgres, template0, template1 from public;

create user web password 'qwerty';

create database reedygreedy;
grant connect on database reedygreedy to web;
revoke all on database reedygreedy from public;

\connect reedygreedy;

set statement_timeout = 0;
set lock_timeout = 0;
set idle_in_transaction_session_timeout = 0;
set client_encoding = 'UTF8';
set client_min_messages = error;
set check_function_bodies = false;

revoke all on schema public from public;