create table if not exists main.achievements(
  id          smallserial primary key,
  name        text   not null,
  description text   not null,
  user_id     bigint not null references main.users(id),
  payload     jsonb,
  created_at  timestamptz default now(),
  updated_at  timestamptz
);

alter table main.achievements owner to postgres;