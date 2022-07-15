create table if not exists main.users_to_promocodes(
  user_id      bigint not null references main.users(id),
  promocode_id bigint not null references main.promocodes(id)
);

alter table main.users_to_promocodes owner to postgres;