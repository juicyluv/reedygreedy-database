create or replace function core.create_role(_invoker_id   bigint,
                                            _name         text,
                                            _access_level smallint,
  out                                       role_id       smallint,
  out                                       error         jsonb)
as $$
begin

  if not exists(select 1
                from core.users u
                where u.id = _invoker_id)
  then
    error := core.error_response(
      'UNAUTHORIZED',
      'Invoker not found.',
      'UNAUTHORIZED'
      );
    return;
  end if;

  if length(_name) < 1 or length(_name) > 64 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'Category name is out of range.',
       'INVALID_ARGUMENT',
       1, 64
    );
    return;
  end if;

  if _access_level < 0 or _access_level > 30000 then
    error := core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Role access level is out of range.',
      'INVALID_ARGUMENT',
      1, 30000
      );
    return;
  end if;

  if exists(select 1
            from core.roles r
            where lower(r.name) = lower(_name))
  then
    error := core.error_response(
      'ROLE_ALREADY_EXISTS',
      'Role already exists.',
      'OBJECT_DUPLICATE'
      );
    return;
  end if;

  insert into main.roles(name, access_level)
  values(_name, _access_level)
  returning id into role_id;

  error := jsonb_build_object('status', 0);

exception
  when others then

    role_id := null;
    error := jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.create_role(bigint, text, smallint) owner to postgres;
grant execute on function core.create_role(bigint, text, smallint) to postgres, web;
revoke all on function core.create_role(bigint, text, smallint) from public;