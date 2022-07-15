create table if not exists main.authors(
  id          uuid        primary key,
  name        text,
  surname     text not null,
  creator_id  uuid not null references main.users(id),
  created_at  timestamptz default now(),
  updated_at  timestamptz,
  deleted_at  timestamptz
);

alter table main.authors owner to postgres;