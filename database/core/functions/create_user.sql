create or replace function core.create_user(_invoker_id  bigint,
                                            _username    text,
                                            _email       text,
                                            _password    text,
                                            _timezone_id smallint,
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
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Invoker not found.',
        'code', 'UNAUTHORIZED'
      )
    );
    return;
  end if;

  if not exists(select 1
                from core.timezones t
                where t.id = _timezone_id)
  then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Timezone not found.',
        'code', 'NOT_FOUND'
      )
    );
    return;
  end if;

  if exists(select 1
                from core.users u
                where lower(u.username) = lower(_username))
  then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Username already taken.',
        'code', 'OBJECT_DUPLICATE'
      )
    );
    return;
  end if;

  if exists(select 1
                from core.users u
                where lower(u.email) = lower(_email))
  then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Email already taken.',
        'code', 'OBJECT_DUPLICATE'
      )
    );
    return;
  end if;

  if _name is not null and _name = '' then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Name cannot be empty.',
        'code', 'INVALID_ARGUMENT'
      )
    );
    return;
  end if;

  insert into main.users(id, username, email, password, creator_id, name, payload, timezone_id)
  values(default, _username, _email, _password, _invoker_id, _name, _payload, _timezone_id)
  returning id into user_id;

  error := jsonb_build_object('status', 0);

exception
  when others then

    user_id := null;
    error := jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile security definer;

alter function core.create_user(bigint, text, text, text, smallint, text, jsonb) owner to postgres;
grant execute on function core.create_user(bigint, text, text, text, smallint, text, jsonb) to postgres, web;
revoke all on function core.create_user(bigint, text, text, text, smallint, text, jsonb) from public;