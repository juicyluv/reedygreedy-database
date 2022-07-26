drop view if exists core.achievements;
create view core.achievements as
select
  id,
  name,
  description,
  payload,
  user_id,
  created_at,
  updated_at
from main.authors;

alter view core.achievements owner to postgres;