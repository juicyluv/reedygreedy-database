create table if not exists main.promocodes(
  id          bigserial   primary key,
  promocode   text        not null,
  creator_id  bigint      not null references main.users(id),
  created_at  timestamptz default now(),
  updated_at  timestamptz,
  payload     jsonb,
  usage_count int         not null default 1 check(usage_count >= 0),
  ending_at   timestamptz
);

alter table main.promocodes owner to postgres;