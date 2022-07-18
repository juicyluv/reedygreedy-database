drop view if exists core.users_to_promocodes;
create view core.users_to_promocodes as
select
  user_id,
  promocode_id,
  created_at
from main.users_to_promocodes;

alter view core.users_to_promocodes owner to postgres;