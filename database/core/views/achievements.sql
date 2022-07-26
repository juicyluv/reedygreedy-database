drop view if exists core.achievements;
create view core.achievements as
select
  id,
  name,
  description,
  payload,
  created_at,
  updated_at
from main.achievements;

alter view core.achievements owner to postgres;