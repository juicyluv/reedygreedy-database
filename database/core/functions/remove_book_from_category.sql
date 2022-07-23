create or replace function core.remove_book_from_category(_invoker_id  bigint,
                                                          _book_id     bigint,
                                                          _category_id smallint)
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
                from core.categories c
                where c.id = _category_id)
  then
    return core.error_response(
      'CATEGORY_NOT_FOUND',
      'Category not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if not exists(select 1
                from core.books_to_categories bc
                where bc.book_id = _book_id
                      and bc.category_id = _category_id)
  then
    return core.error_response(
      'BOOK_IS_NOT_IN_CATEGORY',
      'Book is not in given category.',
      'OBJECT_DEPENDENCY'
      );
  end if;

  delete from main.books_to_categories bc
  where bc.book_id = _book_id and bc.category_id = _category_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.remove_book_from_category(bigint, bigint, smallint) owner to postgres;
grant execute on function core.remove_book_from_category(bigint, bigint, smallint) to postgres, web;
revoke all on function core.remove_book_from_category(bigint, bigint, smallint) from public;