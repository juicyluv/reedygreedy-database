drop view if exists core.roles;
create view core.roles as
select
  id,
  name,
  access_level
from main.roles;

alter view core.roles owner to postgres;