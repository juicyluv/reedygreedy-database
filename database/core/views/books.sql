drop view if exists core.books;
create view core.books as
select
  id,
  title,
  price,
  count,
  author_id,
  creator_id,
  description,
  created_at,
  updated_at
from main.books;

alter view core.books owner to postgres;