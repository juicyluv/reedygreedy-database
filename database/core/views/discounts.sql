drop view if exists core.discounts;
create view core.discounts as
select
  id,
  book_id,
  percent,
  created_at
from main.discounts;

alter view core.discounts owner to postgres;