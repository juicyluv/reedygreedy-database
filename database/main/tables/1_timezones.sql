create table if not exists main.timezones(
  id          smallserial  primary key,
  timezone    text         not null unique
);

alter table main.timezones owner to postgres;