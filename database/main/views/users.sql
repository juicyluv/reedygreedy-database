drop view if exists main.get_users;
create view main.get_users as
select
  id,
  username,
  email,
  created_at,
  updated_at,
  disabled_at
from main.users
where deleted_at is null;

alter view main.get_users owner to postgres;