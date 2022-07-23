create or replace function core.add_promocode_to_user(_invoker_id   bigint,
                                                      _user_id      bigint,
                                                      _promocode_id bigint)
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
                from core.promocodes p
                where p.id = _promocode_id)
  then
    return core.error_response(
       'PROMOCODE_NOT_FOUND',
       'Promocode not found.',
       'OBJECT_NOT_FOUND'
      );
  end if;

  if exists(select 1
            from core.users_to_promocodes up
            where up.user_id = _user_id
                  and up.promocode_id = _promocode_id)
  then
    return core.error_response(
       'PROMOCODE_ALREADY_ADDED_TO_USER',
       'Promocode is already added to user.',
       'OBJECT_DUPLICATE'
      );
  end if;

  insert into main.users_to_promocodes(user_id, promocode_id)
  values (_user_id, _promocode_id);

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.add_promocode_to_user(bigint, bigint, bigint) owner to postgres;
grant execute on function core.add_promocode_to_user(bigint, bigint, bigint) to postgres, web;
revoke all on function core.add_promocode_to_user(bigint, bigint, bigint) from public;