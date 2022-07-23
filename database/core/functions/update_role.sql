create or replace function core.update_role(_invoker_id   bigint,
                                            _role_id      smallint,
                                            _name         text = null,
                                            _access_level smallint = null)
returns jsonb as $$
declare
  _query text;
  _sqlstr text;
begin

  if not exists(select 1
                from core.users u
                where u.id = _invoker_id)
  then
    return core.error_response(
      'UNAUTHORIZED',
      'Invoker not found.',
      'UNAUTHORIZED'
      );
  end if;

  if not exists(select 1
                from core.roles r
                where r.id = _role_id)
  then
    return core.error_response(
      'ROLE_NOT_FOUND',
      'Role not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if _name is null
     and _access_level is null
  then
    return core.error_response(
      'EMPTY_QUERY',
      'Nothing to update.',
      'INVALID_ARGUMENT'
      );
  end if;

  if _name is not null and (length(_name) < 1 or length(_name) > 64) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Role name is out of range.',
      'INVALID_ARGUMENT',
      1, 64
      );
  end if;

  if _access_level is null and (_access_level < 0 or _access_level > 30000) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Role access level is out of range.',
      'INVALID_ARGUMENT',
      1, 30000
      );
  end if;

  if exists(select 1
            from core.roles r
            where lower(r.name) = lower(_name))
  then
    return core.error_response(
      'ROLE_ALREADY_EXISTS',
      'Role already exists.',
      'OBJECT_DUPLICATE'
      );
  end if;

  _query := case when _name is null then '' else 'name = $1,' end ||
            case when _access_level is null then '' else 'access_level = $2,'
            'updated_at = now() ';

  _sqlstr := format('UPDATE main.roles ' ||
                    'SET %s ' ||
                    'WHERE id = $3', left(_query, length(_query) - 1));

  execute _sqlstr
  using _name, _access_level, _role_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.update_role(bigint, smallint, text, smallint) owner to postgres;
grant execute on function core.update_role(bigint, smallint, text, smallint) to postgres, web;
revoke all on function core.update_role(bigint, smallint, text, smallint) from public;