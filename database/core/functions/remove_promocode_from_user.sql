create or replace function core.remove_promocode_from_user(_invoker_id   bigint,
                                                           _user_id      bigint,
                                                           _promocode_id bigint)
returns jsonb as $$
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

  if not exists(select 1
                from core.promocodes p
                where p.id = _promocode_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Promocode not found.',
        'code', 'NOT_FOUND'
      )
    );
  end if;

  if not exists(select 1
                from core.users_to_promocodes up
                where up.user_id = _user_id
                  and up.promocode_id = _promocode_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Promocode is not linked to user.',
        'code', 'OBJECT_DEPENDENCY'
        )
      );
  end if;

  delete from main.users_to_promocodes up
  where up.user_id = _user_id and up.promocode_id = _promocode_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile strict security definer;

alter function core.remove_promocode_from_user(bigint, bigint, bigint) owner to postgres;
grant execute on function core.remove_promocode_from_user(bigint, bigint, bigint) to postgres, web;
revoke all on function core.remove_promocode_from_user(bigint, bigint, bigint) from public;