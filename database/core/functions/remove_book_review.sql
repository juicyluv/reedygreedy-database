create or replace function core.remove_book_review(_invoker_id  bigint,
                                                   _review_id   bigint)
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
                from core.book_reviews br
                where br.id = _review_id)
  then
    return core.error_response(
      'REVIEW_NOT_FOUND',
      'Review not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  delete from main.book_reviews br
  where br.id = _review_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile strict security definer;

alter function core.remove_book_review(bigint, bigint) owner to postgres;
grant execute on function core.remove_book_review(bigint, bigint) to postgres, web;
revoke all on function core.remove_book_review(bigint, bigint) from public;