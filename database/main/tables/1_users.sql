create table if not exists main.users(
  id             bigserial   primary key,
  username       text        not null unique check(username != ''),
  email          text        not null unique check(email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
  password       text        not null check(password != ''),
  creator_id     bigint      references main.users(id),
  status         text        default 'invited',
  name           text,
  payload        json,
  created_at     timestamptz default now(),
  updated_at     timestamptz,
  disabled_at    timestamptz,
  disable_reason smallint,
  deleted_at     timestamptz
);

alter table main.users owner to postgres;