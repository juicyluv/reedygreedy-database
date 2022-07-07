drop view if exists core.books;
create view core.books as
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
from main.books
where deleted_at is null;

alter view core.books owner to postgres;