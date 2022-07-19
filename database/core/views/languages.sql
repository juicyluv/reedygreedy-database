drop view if exists core.languages;
create view core.languages as
select
  id,
  language
from main.languages;

alter view core.languages owner to postgres;