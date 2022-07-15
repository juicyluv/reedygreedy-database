create table if not exists main.authors_to_categories(
  author_id   bigint   not null references main.authors(id),
  category_id smallint not null references main.categories(id)
);

alter table main.authors_to_categories owner to postgres;