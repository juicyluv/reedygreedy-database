create table if not exists core.authors(
  id          uuid        primary key,
  name        text,
  surname     text not null,
  creator_id  uuid not null references core.users(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz,
  deleted_at  timestamptz
);

alter table core.authors owner to postgres;