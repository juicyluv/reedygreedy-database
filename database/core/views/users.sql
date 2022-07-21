drop view if exists core.users;
create view core.users as
select
  id,
  username,
  email,
  password,
  creator_id,
  name,
  payload,
  created_at,
  updated_at,
  disabled_at,
  disable_reason,
  timezone_id,
  last_login,
  role_id
from main.users
where deleted_at is null;

alter view core.users owner to postgres;