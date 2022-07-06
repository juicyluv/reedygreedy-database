drop view if exists core.list_books;
create view core.list_books as
select
    id,
    title,
    created_at,
    price,
    count,
    discount,
    creator_id,
    description,
    updated_at
from core.books
where deleted_at is null;

alter view core.list_books owner to postgres;