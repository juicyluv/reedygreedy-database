create or replace function core.disable_user(_invoker_id     bigint,
                                             _user_id        bigint,
                                             _disable_reason smallint)
returns jsonb as $$
declare
  _disabled_at    timestamptz;
  _disable_reason smallint;
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

  select
    u.disabled_at,
    u.disable_reason
  into
    _disabled_at,
    _disable_reason
  from core.users u
  where u.id = _user_id;

  if _disabled_at is null then
    update main.users
    set
      disabled_at = now(),
      disable_reason = _disable_reason
    where id = _user_id;
  else
    return core.error_response(
      'USER_ALREADY_DISABLED',
      'User already disabled.',
      'OBJECT_DUPLICATE'
      );
  end if;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile strict security definer;

alter function core.disable_user(bigint, bigint, smallint) owner to postgres;
grant execute on function core.disable_user(bigint, bigint, smallint) to postgres, web;
revoke all on function core.disable_user(bigint, bigint, smallint) from public;