drop view if exists core.timezones;
create view core.timezones as
select
  id,
  timezone
from main.timezones;

alter view core.timezones owner to postgres;