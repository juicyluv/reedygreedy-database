create or replace function core.get_user(_user_id    uuid,
  out                                    username    text,
  out                                    email       text,
  out                                    status      text,
  out                                    payload     jsonb,
  out                                    creator_id  uuid,
  out                                    created_at  timestamptz,
  out                                    updated_at  timestamptz,
  out                                    disabled_at timestamptz,
  out                                    error       jsonb)
as $$
begin

  select
    u.username,
    u.email,
    u.status,
    u.payload,
    u.creator_id,
    u.created_at,
    u.updated_at,
    u.disabled_at
  into
    username,
    email,
    status,
    payload,
    creator_id,
    created_at,
    updated_at,
    disabled_at
  from
    core.users u
  where u.id = _user_id;

  if not found then
    error := jsonb_build_object('code', 1, 'user_id', 'not_found');
    return;
  end if;

  error := jsonb_build_object('code', 0);

exception
  when others then

    error := jsonb_build_object('code', -1);

end;
$$ language plpgsql stable security definer;

alter function core.get_user(uuid) owner to postgres;
grant execute on function core.get_user(uuid) to postgres, web;
revoke all on function core.get_user(uuid) from public;