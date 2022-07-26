create table if not exists main.users_to_achievements(
  user_id        bigint   not null references main.users(id) on delete cascade,
  achievement_id smallint not null references main.achievements(id) on delete cascade,
  created_at     timestamptz default now()
);

alter table main.users_to_achievements owner to postgres;