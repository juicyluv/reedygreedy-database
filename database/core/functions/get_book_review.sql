create or replace function core.get_book_review(_review_id       bigint,
  out                                           book_id          bigint,
  out                                           book_title       text,
  out                                           creator_id       bigint,
  out                                           creator_username text,
  out                                           review           smallint,
  out                                           created_at       timestamptz,
  out                                           updated_at       timestamptz,
  out                                           comment          text,
  out                                           error            jsonb)
as $$
begin

  select
    br.book_id,
    b.title,
    br.creator_id,
    u.username,
    br.review,
    br.created_at,
    br.updated_at,
    br.comment
  into
    book_id,
    book_title,
    creator_id,
    creator_username,
    review,
    created_at,
    updated_at,
    comment
  from core.book_reviews br
    left join core.users u
      on u.id = br.creator_id
    left join core.books b
      on b.id = br.book_id
  where br.id = _review_id;

  if not found then
    error := core.error_response(
      'REVIEW_NOT_FOUND',
      'Review not found.',
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

alter function core.get_book_review(bigint) owner to postgres;
grant execute on function core.get_book_review(bigint) to postgres, web;
revoke all on function core.get_book_review(bigint) from public;