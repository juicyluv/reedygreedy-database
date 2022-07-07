create table if not exists core.books(
  id          uuid         primary key,
  title       text         not null check(title != ''),
  created_at  timestamptz  not null default now(),
  price       int          not null,
  count       int          not null,
  discount    int          not null,
  creator_id  uuid         not null references core.users(id),
  description text,
  updated_at  timestamptz,
  deleted_at  timestamptz
);

alter table core.books owner to postgres;