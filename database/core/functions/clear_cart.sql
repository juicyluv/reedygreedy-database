create or replace function core.clear_cart(_invoker_id bigint,
                                           _cart_id    bigint)
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
                from core.carts c
                where c.id = _cart_id)
  then
    return core.error_response(
      'CART_NOT_FOUND',
      'Cart not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  delete from main.books_to_carts
  where cart_id = _cart_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile strict security definer;

alter function core.clear_cart(bigint, bigint) owner to postgres;
grant execute on function core.clear_cart(bigint, bigint) to postgres, web;
revoke all on function core.clear_cart(bigint, bigint) from public;