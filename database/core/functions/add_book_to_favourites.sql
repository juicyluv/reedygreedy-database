create or replace function core.add_book_to_favourites(_invoker_id bigint,
                                                       _book_id    bigint,
                                                       _user_id    bigint)
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

  if exists(select 1
            from core.favourites f
            where f.book_id = _book_id
                  and f.user_id = _user_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Book is already added to favourites.',
        'code', 'OBJECT_DUPLICATE'
        )
      );
  end if;

  insert into main.favourites(book_id, user_id)
  values (_book_id, _user_id);

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.add_book_to_favourites(bigint, bigint, bigint) owner to postgres;
grant execute on function core.add_book_to_favourites(bigint, bigint, bigint) to postgres, web;
revoke all on function core.add_book_to_favourites(bigint, bigint, bigint) from public;