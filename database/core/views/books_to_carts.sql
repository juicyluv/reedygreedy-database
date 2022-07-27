drop view if exists core.books_to_carts;
create view core.books_to_carts as
select
  book_id,
  cart_id,
  book_count,
  created_at
from main.books_to_carts;

alter view core.books_to_carts owner to postgres;