create table if not exists main.books_to_carts(
  book_id    bigint not null references main.books(id) on delete cascade,
  cart_id    bigint not null references main.carts(id) on delete cascade,
  created_at timestamptz default now()
);

alter table main.books_to_carts owner to postgres;
