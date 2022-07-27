create or replace function core.get_cart(_cart_id     bigint,
  out                                    user_id      bigint,
  out                                    promocode_id bigint,
  out                                    created_at   timestamptz,
  out                                    error        jsonb)
as $$
begin

  select
    c.user_id,
    c.promocode_id,
    c.created_at
  into
    user_id,
    promocode_id,
    created_at
  from core.carts c
  where c.id = _cart_id;

  if not found then
    error := core.error_response(
      'CART_NOT_FOUND',
      'Cart not found.',
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

alter function core.get_cart(bigint) owner to postgres;
grant execute on function core.get_cart(bigint) to postgres, web;
revoke all on function core.get_cart(bigint) from public;