drop view if exists core.books_to_categories;
create view core.books_to_categories as
select
  book_id,
  category_id
from main.books_to_categories;

alter view core.books_to_categories owner to postgres;