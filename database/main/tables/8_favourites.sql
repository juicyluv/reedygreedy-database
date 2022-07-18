create table if not exists main.favourites(
  user_id    bigint not null references main.users(id),
  book_id    bigint not null references main.books(id),
  created_at timestamptz default now()
);

alter table main.favourites owner to postgres;