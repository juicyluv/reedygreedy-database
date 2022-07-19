create table if not exists main.languages(
  id          smallserial  primary key,
  language    text         not null unique
);

alter table main.languages owner to postgres;