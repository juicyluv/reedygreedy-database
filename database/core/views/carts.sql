drop view if exists core.carts;
create view core.carts as
select
  id,
  user_id,
  created_at,
  promocode_id
from main.carts;

alter view core.carts owner to postgres;