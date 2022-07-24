create or replace function core.get_roles(
  out                                     role_id      smallint,
  out                                     name         text,
  out                                     access_level smallint,
  out                                     created_at   timestamptz,
  out                                     updated_at   timestamptz)
returns setof record as $$
begin

  return query
    select
      r.id           as role_id,
      r.name         as name,
      r.access_level as access_level,
      r.created_at   as created_at,
      r.updated_at   as updated_at
    from core.roles r;

exception
  when others then

    return query with t as (values(null::smallint,
                                   null::text,
                                   null::smallint,
                                   null::timestamptz,
                                   null::timestamptz))
    select *
    from t
    where 1 = 2;

end;
$$ language plpgsql stable security definer;

alter function core.get_roles() owner to postgres;
grant execute on function core.get_roles() to postgres, web;
revoke all on function core.get_roles() from public;