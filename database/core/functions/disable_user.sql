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
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Invoker not found.',
        'code', 'UNAUTHORIZED'
      )
    );
  end if;

  if not exists(select 1
                from core.users u
                where u.id = _user_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'User not found.',
        'code', 'NOT_FOUND'
      )
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
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'User already disabled.',
        'code', 'OBJECT_DUPLICATE'
      )
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