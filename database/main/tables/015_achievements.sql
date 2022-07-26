create table if not exists main.achievements(
  id          smallserial primary key,
  name        text   not null,
  description text   not null,
  payload     jsonb,
  user_id     bigint not null references main.users (id),
  created_at  timestamptz default now(),
  updated_at  timestamptz
);

alter table main.achievements
  owner to postgres;