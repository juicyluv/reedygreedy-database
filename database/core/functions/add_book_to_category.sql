create or replace function core.add_book_to_category(_invoker_id  bigint,
                                                     _book_id     bigint,
                                                     _category_id smallint)
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
                from core.books b
                where b.id = _book_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Book not found.',
        'code', 'NOT_FOUND'
      )
    );
  end if;

  if not exists(select 1
                from core.categories c
                where c.id = _category_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Category not found.',
        'code', 'NOT_FOUND'
      )
    );
  end if;

  if exists(select 1
            from core.books_to_categories bc
            where bc.book_id = _book_id
                  and bc.category_id = _category_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Book is already added to category.',
        'code', 'OBJECT_DUPLICATE'
        )
      );
  end if;

  insert into main.books_to_categories(book_id, category_id)
  values (_book_id, _category_id);

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.add_book_to_category(bigint, bigint, smallint) owner to postgres;
grant execute on function core.add_book_to_category(bigint, bigint, smallint) to postgres, web;
revoke all on function core.add_book_to_category(bigint, bigint, smallint) from public;