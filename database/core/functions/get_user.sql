create or replace function core.get_user(_user_id       bigint,
  out                                    username       text,
  out                                    email          text,
  out                                    status         text,
  out                                    payload        jsonb,
  out                                    name           text,
  out                                    creator_id     bigint,
  out                                    created_at     timestamptz,
  out                                    updated_at     timestamptz,
  out                                    disabled_at    timestamptz,
  out                                    disable_reason smallint,
  out                                    error          jsonb)
as $$
begin

  select
    u.username,
    u.email,
    u.status,
    u.payload,
    u.name,
    u.creator_id,
    u.created_at,
    u.updated_at,
    u.disabled_at,
    u.disable_reason
  into
    username,
    email,
    status,
    payload,
    name,
    creator_id,
    created_at,
    updated_at,
    disabled_at,
    disable_reason
  from
    core.users u
  where u.id = _user_id;

  if not found then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'User not found.',
        'code', 'NOT_FOUND'
      )
    );
    return;
  end if;

  error := jsonb_build_object('status', 0);

exception
  when others then

    error := jsonb_build_object('status', -1);

end;
$$ language plpgsql stable security definer;

alter function core.get_user(bigint) owner to postgres;
grant execute on function core.get_user(bigint) to postgres, web;
revoke all on function core.get_user(bigint) from public;