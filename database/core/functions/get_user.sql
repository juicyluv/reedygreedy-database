create or replace function core.get_user(_user_id          bigint,
  out                                    username          text,
  out                                    email             text,
  out                                    payload           jsonb,
  out                                    avatar_url        text,
  out                                    name              text,
  out                                    timezone          text,
  out                                    creator_id        bigint,
  out                                    creator_username  text,
  out                                    role_id           smallint,
  out                                    role_name         text,
  out                                    role_access_level smallint,
  out                                    created_at        timestamptz,
  out                                    updated_at        timestamptz,
  out                                    disabled_at       timestamptz,
  out                                    disable_reason    smallint,
  out                                    last_login        timestamptz,
  out                                    error             jsonb)
as $$
begin

  select
    u1.username,
    u1.email,
    u1.payload,
    u1.avatar_url,
    u1.name,
    t.timezone,
    u1.creator_id,
    u2.username,
    r.id,
    r.name,
    r.access_level,
    u1.created_at,
    u1.updated_at,
    u1.disabled_at,
    u1.disable_reason,
    u1.last_login
  into
    username,
    email,
    payload,
    avatar_url,
    name,
    timezone,
    creator_id,
    creator_username,
    role_id,
    role_name,
    role_access_level,
    created_at,
    updated_at,
    disabled_at,
    disable_reason,
    last_login
  from core.users u1
    left join core.users u2
      on u2.id = u1.creator_id
    left join core.timezones t
      on t.id = u1.timezone_id
    left join core.roles r
      on u1.role_id = r.id
  where u1.id = _user_id;

  if not found then
    error := core.error_response(
      'USER_NOT_FOUND',
      'User not found.',
      'OBJECT_NOT_FOUND'
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

-------------------------------------------------------------------------------------------------------

create or replace function core.get_user(_login            text,
                                         _password         text,
  out                                    user_id           bigint,
  out                                    username          text,
  out                                    email             text,
  out                                    payload           jsonb,
  out                                    avatar_url        text,
  out                                    name              text,
  out                                    timezone          text,
  out                                    creator_id        bigint,
  out                                    creator_username  text,
  out                                    role_id           smallint,
  out                                    role_name         text,
  out                                    role_access_level smallint,
  out                                    created_at        timestamptz,
  out                                    updated_at        timestamptz,
  out                                    disabled_at       timestamptz,
  out                                    disable_reason    smallint,
  out                                    last_login        timestamptz,
  out                                    error             jsonb)
as $$
begin

  select
    u1.id,
    u1.username,
    u1.email,
    u1.payload,
    u1.name,
    u1.avatar_url,
    t.timezone,
    u1.creator_id,
    u2.username,
    r.id,
    r.name,
    r.access_level,
    u1.created_at,
    u1.updated_at,
    u1.disabled_at,
    u1.disable_reason,
    u1.last_login
  into
    user_id,
    username,
    email,
    payload,
    avatar_url,
    name,
    timezone,
    creator_id,
    creator_username,
    role_id,
    role_name,
    role_access_level,
    created_at,
    updated_at,
    disabled_at,
    disable_reason,
    last_login
  from core.users u1
    left join core.users u2
      on u2.id = u1.creator_id
    left join core.timezones t
        on t.id = u1.timezone_id
  where (lower(u1.email) = lower(_login) or lower(u1.username) = lower(_login))
        and u1.password = _password;

  if not found then
    error := core.error_response(
      'USER_NOT_FOUND',
      'User not found.',
      'OBJECT_NOT_FOUND'
      );
    return;
  end if;

  error := jsonb_build_object('status', 0);

exception
  when others then

    error := jsonb_build_object('status', -1);

end;
$$ language plpgsql stable security definer;

alter function core.get_user(text, text) owner to postgres;
grant execute on function core.get_user(text, text) to postgres, web;
revoke all on function core.get_user(text, text) from public;