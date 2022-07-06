drop view if exists core.list_users;
create view core.list_users as
select
  id,
  username,
  email,
  created_at,
  updated_at,
  disabled_at
from core.users
where deleted_at is null;

alter view core.list_users owner to postgres;