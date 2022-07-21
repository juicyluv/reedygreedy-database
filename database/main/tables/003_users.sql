create table if not exists main.users(
  id             bigserial   primary key,
  username       text        not null unique check(username != ''),
  email          text        not null unique check(email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
  password       text        not null check(password != ''),
  creator_id     bigint      references main.users(id),
  timezone_id    smallint    not null references main.timezones(id),
  name           text,
  payload        jsonb,
  created_at     timestamptz default now(),
  updated_at     timestamptz,
  disabled_at    timestamptz,
  disable_reason smallint,
  last_login     timestamptz,
  deleted_at     timestamptz
);

alter table main.users owner to postgres;