create or replace function core.enable_user(_invoker_id     bigint,
                                            _user_id        bigint)
returns jsonb as $$
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

  if not exists(select 1
                from core.users u
                where u.id = _user_id
                      and u.disabled_at is null
                      and u.disable_reason is null)
  then
    return core.error_response(
      'USER_NOT_DISABLED',
      'User is not disabled.',
      'OBJECT_DEPENDENCY'
      );
  end if;

  update main.users
  set disabled_at = null, disable_reason = null
  where id = _user_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile strict security definer;

alter function core.enable_user(bigint, bigint) owner to postgres;
grant execute on function core.enable_user(bigint, bigint) to postgres, web;
revoke all on function core.enable_user(bigint, bigint) from public;