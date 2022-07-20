create table if not exists main.discounts(
  id         bigserial   primary key,
  book_id    bigint      not null references main.books(id),
  percent    smallint    not null check(percent > 0 and percent < 100),
  created_at timestamptz default now()
);

alter table main.discounts owner to postgres;
