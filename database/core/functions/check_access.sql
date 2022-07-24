create or replace function core.check_access(_invoker_id            bigint,
                                             _required_access_level smallint)
returns bool as $$
declare
  _user_access_level smallint;
begin

  select
    r.access_level
  into
    _user_access_level
  from core.roles r
    left join core.users u
      on u.id = _invoker_id
         and u.role_id = r.id;

  if not found then
    return false;
  end if;

  if _user_access_level < _required_access_level then
    return false;
  else
    return true;
  end if;

exception
  when others then

    return false;

end;
$$ language plpgsql stable security definer;

alter function core.check_access(bigint, smallint) owner to postgres;
grant execute on function core.check_access(bigint, smallint) to postgres;
revoke all on function core.check_access(bigint, smallint) from public;