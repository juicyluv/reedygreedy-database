create table if not exists core.users(
  id          uuid        primary key,
  username    text        not null check(username != ''),
  email       text        not null check(email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
  password    text        not null check(password != ''),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz,
  disabled_at timestamptz,
  deleted_at  timestamptz
);

alter table core.users owner to postgres;