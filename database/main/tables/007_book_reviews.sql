create table if not exists main.book_reviews(
  id         bigserial   primary key,
  book_id    bigint      not null references main.books(id),
  creator_id bigint      not null references main.users(id),
  review     smallint    not null check(review >= 0 and review <= 5),
  created_at timestamptz default now(),
  updated_at timestamptz,
  comment    text
);

alter table main.book_reviews owner to postgres;