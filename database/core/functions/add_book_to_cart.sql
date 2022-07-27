create or replace function core.add_book_to_cart(_invoker_id bigint,
                                                 _book_id    bigint,
                                                 _cart_id    bigint,
                                                 _book_count smallint = 1)
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

  if _book_count > _available_books then
    return core.error_response(
      'NOT_ENOUGH_BOOKS',
      'Only ' || _available_books || ' books available.',
      'INVALID_ARGUMENTS',
      _max := _available_books
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

  if _book_count < 1 then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Book count cannot be less than 1.',
      'INVALID_ARGUMENT',
      1
      );
  end if;

  update main.books_to_carts
  set book_count = book_count + _book_count
  where book_id = _book_id and _cart_id = _cart_id;

  if not found then
    insert into main.books_to_carts(book_id, cart_id, book_count)
    values(_book_id, _cart_id, _book_count);
  end if;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.add_book_to_cart(bigint, bigint, bigint, smallint) owner to postgres;
grant execute on function core.add_book_to_cart(bigint, bigint, bigint, smallint) to postgres, web;
revoke all on function core.add_book_to_cart(bigint, bigint, bigint, smallint) from public;