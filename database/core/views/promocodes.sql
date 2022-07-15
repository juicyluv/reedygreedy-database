drop view if exists core.promocodes;
create view core.promocodes as
select
  id,
  promocode,
  created_a,
  payload,
  usage_cou,
  ending_at
from main.promocodes;

alter view core.promocodes owner to postgres;