drop view if exists core.favourites;
create view core.favourites as
select
  user_id,
  book_id,
  created_at
from main.favourites;

alter view core.favourites owner to postgres;