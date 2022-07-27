create or replace function core.create_cart(_invoker_id bigint,
                                            _user_id    bigint)
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

  insert into main.carts(user_id)
  values (_user_id);

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile strict security definer;

alter function core.create_cart(bigint, bigint) owner to postgres;
grant execute on function core.create_cart(bigint, bigint) to postgres, web;
revoke all on function core.create_cart(bigint, bigint) from public;