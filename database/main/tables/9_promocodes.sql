create table if not exists main.promocodes(
  id          bigserial   primary key,
  promocode   text        not null,
  created_at  timestamptz default now(),
  payload     jsonb,
  usage_count int         default 1,
  ending_at   timestamptz
);

alter table main.promocodes owner to postgres;