create table if not exists main.authors(
  id          bigserial   primary key,
  name        text        not null,
  creator_id  bigint      not null references main.users(id),
  created_at  timestamptz default now(),
  updated_at  timestamptz,
  description text
);

alter table main.authors owner to postgres;