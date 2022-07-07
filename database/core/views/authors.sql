drop view if exists core.list_authors;
create view core.list_authors as
select
    id,
    name,
    surname,
    creator_id,
    created_at,
    updated_at
from core.authors
where deleted_at is null;

alter view core.list_authors owner to postgres;