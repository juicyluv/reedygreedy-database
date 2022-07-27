create table if not exists main.carts(
  id           bigserial   primary key,
  user_id      bigint not null references main.users(id) on delete cascade,
  created_at   timestamptz default now(),
  promocode_id bigint references main.promocodes(id)
);

alter table main.carts owner to postgres;
