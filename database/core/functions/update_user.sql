create or replace function core.update_user(_invoker_id  bigint,
                                            _user_id     bigint,
                                            _username    text = null,
                                            _avatar_url  text = null,
                                            _name        text = null,
                                            _timezone_id smallint = null,
                                            _role_id     smallint = null,
                                            _payload     jsonb = null)
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
                from core.users u
                where u.id = _user_id)
  then
    return core.error_response(
      'USER_NOT_FOUND',
      'User not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if _username is null
     and _name is null
     and _payload is null
     and _timezone_id is null
     and _avatar_url is null
  then
    return core.error_response(
      'EMPTY_QUERY',
      'Nothing to update.',
      'INVALID_ARGUMENT'
      );
  end if;

  if _avatar_url is not null and length(_avatar_url) < 1  then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'User avatar URL is out of range.',
      'INVALID_ARGUMENT',
      1
      );
  end if;

  if _username is not null then
    if length(_username) < 1 or length(_username) > 24 then
      return core.error_response(
        'VALUE_OUT_OF_RANGE',
        'User username is out of range.',
        'INVALID_ARGUMENT',
        1, 24
        );
    end if;

    if exists(select 1
              from core.users u
              where lower(u.username) = lower(_username))
    then
       return core.error_response(
        'USERNAME_ALREADY_TAKEN',
        'Username already taken.',
        'OBJECT_DUPLICATE'
        );
    end if;
  end if;

  if _timezone_id is not null and not exists(select 1
                from core.timezones t
                where t.id = _timezone_id)
  then
    return core.error_response(
      'TIMEZONE_NOT_FOUND',
      'Time zone not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if _role_id is not null and not exists(select 1
                                             from core.roles r
                                             where r.id = _role_id)
  then
    return core.error_response(
      'ROLE_NOT_FOUND',
      'Role not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  _query := case when _username is null then '' else 'username = $1,' end ||
            case when _name     is null then '' else 'name = $2,' end ||
            case when _payload  is null then '' else 'payload = $3,' end ||
            case when _timezone_id is null then '' else 'timezone_id = $4,' end ||
            case when _role_id is null then '' else 'role_id = $5,' end ||
            case when _avatar_url is null then '' else 'avatar_url = $6' end ||
            'updated_at = now() ';

  _sqlstr := format('UPDATE main.users ' ||
                    'SET %s ' ||
                    'WHERE id = $7', left(_query, length(_query) - 1));

  execute _sqlstr
  using _username, _name, _payload, _timezone_id, _role_id, _avatar_url, _user_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.update_user(bigint, bigint, text, text, text, smallint, smallint, jsonb) owner to postgres;
grant execute on function core.update_user(bigint, bigint, text, text, text, smallint, smallint, jsonb) to postgres, web;
revoke all on function core.update_user(bigint, bigint, text, text, text, smallint, smallint, jsonb) from public;