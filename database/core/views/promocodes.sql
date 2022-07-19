drop view if exists core.promocodes;
create view core.promocodes as
select
  id,
  promocode,
  creator_id,
  created_at,
  updated_at,
  payload,
  usage_count,
  ending_at
from main.promocodes
where ending_at > now();

alter view core.promocodes owner to postgres;