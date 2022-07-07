drop view if exists core.authors;
create view core.authors as
select
    id,
    name,
    surname,
    creator_id,
    created_at,
    updated_at
from main.authors
where deleted_at is null;

alter view core.authors owner to postgres;