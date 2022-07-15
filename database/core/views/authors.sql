drop view if exists core.authors;
create view core.authors as
select
  id,
  name,
  creator_id,
  created_at,
  updated_at,
  description
from main.authors;

alter view core.authors owner to postgres;