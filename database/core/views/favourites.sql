drop view if exists core.favourites;
create view core.favourites as
select
  user_id,
  book_id
from main.favourites;

alter view core.favourites owner to postgres;