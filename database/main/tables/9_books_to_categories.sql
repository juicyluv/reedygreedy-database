create table if not exists main.books_to_categories(
  book_id     bigint   not null references main.books(id),
  category_id smallint not null references main.categories(id)
);

alter table main.books_to_categories owner to postgres;