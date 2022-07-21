create table if not exists main.roles(
  id           smallserial  primary key,
  name         text not null,
  access_level smallint not null
);

alter table main.roles owner to postgres;