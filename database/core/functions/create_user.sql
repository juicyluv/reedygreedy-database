create or replace function core.create_user(_invoker_id  bigint,
                                            _username    text,
                                            _email       text,
                                            _password    text,
                                            _timezone_id smallint,
                                            _role_id     smallint,
                                            _name        text = null,
                                            _payload     jsonb = null,
  out                                       user_id      bigint,
  out                                       error        jsonb)
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

  if length(_username) < 1 or length(_username) > 24 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'User username is out of range.',
       'INVALID_ARGUMENT',
       1, 24
      );
    return;
  end if;

  if length(_email) < 1 or length(_email) > 256 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'User email is out of range.',
       'INVALID_ARGUMENT',
       1, 256
      );
    return;
  end if;

  if _email !~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' then
    error := core.error_response(
       'USER_EMAIL_INVALID_FORMAT',
       'User email has invalid format.',
       'INVALID_ARGUMENT'
      );
    return;
  end if;

  if length(_password) < 6 or length(_password) > 24 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'User password is out of range.',
       'INVALID_ARGUMENT',
       6, 24
      );
    return;
  end if;

  if length(_name) < 1 or length(_name) > 64 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'User name is out of range.',
       'INVALID_ARGUMENT',
       1, 64
      );
    return;
  end if;

  if not exists(select 1
                from core.timezones t
                where t.id = _timezone_id)
  then
    error := core.error_response(
       'TIMEZONE_NOT_FOUND',
       'Time zone not found.',
       'OBJECT_NOT_FOUND'
      );
    return;
  end if;

  if not exists(select 1
                from core.roles r
                where r.id = _role_id)
  then
    error := core.error_response(
       'ROLE_NOT_FOUND',
       'Role not found.',
       'OBJECT_NOT_FOUND'
      );
    return;
  end if;

  if exists(select 1
                from core.users u
                where lower(u.username) = lower(_username))
  then
    error := core.error_response(
       'USERNAME_ALREADY_TAKEN',
       'Username already taken.',
       'OBJECT_DUPLICATE'
      );
    return;
  end if;

  if exists(select 1
                from core.users u
                where lower(u.email) = lower(_email))
  then
    error := core.error_response(
       'EMAIL_ALREADY_TAKEN',
       'Email already taken.',
       'OBJECT_DUPLICATE'
      );
    return;
  end if;

  insert into main.users(id, username, email, password, creator_id, name, payload, timezone_id, role_id)
  values(default, _username, _email, _password, _invoker_id, _name, _payload, _timezone_id, _role_id)
  returning id into user_id;

  error := jsonb_build_object('status', 0);

exception
  when others then

    user_id := null;
    error := jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.create_user(bigint, text, text, text, smallint, text, jsonb) owner to postgres;
grant execute on function core.create_user(bigint, text, text, text, smallint, text, jsonb) to postgres, web;
revoke all on function core.create_user(bigint, text, text, text, smallint, text, jsonb) from public;