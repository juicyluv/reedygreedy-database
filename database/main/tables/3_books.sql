create table if not exists main.books(
  id          bigserial     primary key,
  title       text          not null check(title != ''),
  price       decimal(10,2) not null,
  count       int           not null,
  creator_id  bigint        not null references main.users(id),
  author_id   bigint        not null references main.authors(id),
  description text,
  created_at  timestamptz   default now(),
  updated_at  timestamptz
);

alter table main.books owner to postgres;