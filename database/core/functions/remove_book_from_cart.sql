create or replace function core.remove_book_from_cart(_invoker_id bigint,
                                                      _book_id    bigint,
                                                      _cart_id    bigint,
                                                      _clear      bool = false)
returns jsonb as $$
declare
  _available_books int;
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

  if not exists(select b.count
                into _available_books
                from core.books b
                where b.id = _book_id)
  then
    return core.error_response(
      'BOOK_NOT_FOUND',
      'Book not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if _available_books <= 1 then
    _clear = true;
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

  if _clear = true then
    delete from main.books_to_carts
    where book_id = _book_id and _cart_id = _cart_id;
  else
    update main.books_to_carts
    set book_count = book_count - 1
    where book_id = _book_id and _cart_id = _cart_id;
  end if;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.remove_book_from_cart(bigint, bigint, bigint, bool) owner to postgres;
grant execute on function core.remove_book_from_cart(bigint, bigint, bigint, bool) to postgres, web;
revoke all on function core.remove_book_from_cart(bigint, bigint, bigint, bool) from public;