drop view if exists core.book_reviews;
create view core.book_reviews as
select
  id,
  book_id,
  creator,
  review,
  created,
  updated,
  comment
from main.book_reviews;

alter view core.book_reviews owner to postgres;