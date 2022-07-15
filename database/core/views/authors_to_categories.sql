drop view if exists core.authors_to_categories;
create view core.authors_to_categories as
select
  author_id,
  category_id
from main.authors_to_categories;

alter view core.authors_to_categories owner to postgres;