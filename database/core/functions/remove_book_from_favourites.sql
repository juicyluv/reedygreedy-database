create or replace function core.remove_book_from_favourites(_invoker_id bigint,
                                                            _book_id    bigint,
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
                from core.books b
                where b.id = _book_id)
  then
    return core.error_response(
      'BOOK_NOT_FOUND',
      'Book not found.',
      'OBJECT_NOT_FOUND'
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
                from core.favourites f
                where f.book_id = _book_id
                      and f.user_id = _user_id)
  then
    return core.error_response(
      'BOOK_NOT_IN_FAVOURITES',
      'Book is not in favourite list.',
      'OBJECT_DEPENDENCY'
      );
  end if;

  delete from main.favourites f
  where f.book_id = _book_id and f.user_id = _user_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.remove_book_from_favourites(bigint, bigint, bigint) owner to postgres;
grant execute on function core.remove_book_from_favourites(bigint, bigint, bigint) to postgres, web;
revoke all on function core.remove_book_from_favourites(bigint, bigint, bigint) from public;