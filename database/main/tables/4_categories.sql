create table if not exists main.categories(
  id          smallserial  primary key,
  name        text         not null,
  created_at  timestamptz  default now(),
  updated_at  timestamptz
);

alter table main.categories owner to postgres;