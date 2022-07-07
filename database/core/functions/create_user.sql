create or replace function core.create_user(_invoker_id uuid,
                                            _username   text,
                                            _email      text,
                                            _password   text,
                                            _name       text = null,
                                            _status     text = null,
                                            _payload    jsonb = null,
out                                         user_id     uuid,
out                                         error       jsonb)
as $$
declare
  username text;
  email text;
begin

  select
    u.username,
    u.email
  into
    username,
    email
  from core.users u
  where u.id = _invoker_id;

  if not found then
    error := jsonb_build_object('code', 1, 'invoker_id', 'not_found');
    return;
  end if;

  if lower(username) = lower(_username) then
    error := jsonb_build_object('code', 1, 'username', 'duplicate');
    return;
  end if;

  if lower(email) = lower(_email) then
    error := jsonb_build_object('code', 1, 'email', 'duplicate');
    return;
  end if;

  user_id := gen_random_uuid();

  insert into main.users(id, username, email, password, creator_id, name, status, payload)
  values(user_id, _username, _email, _password, _invoker_id, _name, _status, _payload);

  error := jsonb_build_object('code', 0);

exception
  when others then

    user_id := null;
    error := jsonb_build_object('code', -1);

end;
$$ language plpgsql volatile security definer;

alter function core.create_user(uuid, text, text, text, text, text, jsonb) owner to postgres;
grant execute on function core.create_user(uuid, text, text, text, text, text, jsonb) to postgres, web;
revoke all on function core.create_user(uuid, text, text, text, text, text, jsonb) from public;