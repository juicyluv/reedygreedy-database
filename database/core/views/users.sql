drop view if exists core.users;
create view core.users as
select
  id,
  username,
  email,
  creator_id,
  status,
  payload,
  name,
  created_at,
  updated_at,
  disable_reason,
  disabled_at
from main.users
where deleted_at is null;

alter view core.users owner to postgres;