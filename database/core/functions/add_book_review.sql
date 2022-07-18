create or replace function core.add_book_review(_invoker_id  bigint,
                                                _book_id     bigint,
                                                _review      smallint,
                                                _comment     text = null,
  out                                           review_id    bigint,
  out                                           error        jsonb)
as $$
begin

  if not exists(select 1
                from core.users u
                where u.id = _invoker_id)
  then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Invoker not found.',
        'code', 'UNAUTHORIZED'
      )
    );
    return;
  end if;

  if not exists(select 1
                from core.books b
                where b.id = _book_id)
  then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Book not found.',
        'code', 'NOT_FOUND'
      )
    );
    return;
  end if;

  if exists(select 1
            from core.book_reviews br
            where br.creator_id = _invoker_id
                  and br.book_id = _book_id)
  then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'You already added a review to this book.',
        'code', 'OBJECT_DUPLICATE'
        )
      );
    return;
  end if;

  if _review <=0 or _review > 5 then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Review must be between 0 and 5.',
        'code', 'INVALID_ARGUMENT'
        )
      );
    return;
  end if;

  insert into main.book_reviews(id, book_id, creator_id, review, comment)
  values (default, _book_id, _invoker_id, _review, _comment)
  returning id into review_id;

  error := jsonb_build_object('status', 0);

exception
  when others then

    review_id := null;
    error := jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.add_book_review(bigint, bigint, smallint, text) owner to postgres;
grant execute on function core.add_book_review(bigint, bigint, smallint, text) to postgres, web;
revoke all on function core.add_book_review(bigint, bigint, smallint, text) from public;