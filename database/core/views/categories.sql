drop view if exists core.categories;
create view core.categories as
select
  id,
  name,
  created_at,
  updated_at
from main.categories;

alter view core.categories owner to postgres;