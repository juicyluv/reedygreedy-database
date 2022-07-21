create or replace function core.update_book_review(_invoker_id bigint,
                                                   _review_id  bigint,
                                                   _review     smallint = null,
                                                   _comment    text = null)
returns jsonb as $$
declare
  _query text;
  _sqlstr text;
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

  if _review is null
    and _comment is null
  then
    return core.error_response(
      'EMPTY_QUERY',
      'Nothing to update.',
      'INVALID_ARGUMENT'
      );
  end if;

  if _review is not null and (_review <= 0 or _review > 5) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Review value is out of range.',
      'INVALID_ARGUMENT',
      0, 5
      );
  end if;

  if _comment is not null and (length(_comment) < 4 or length(_comment) > 1024) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Review comment is out of range.',
      'INVALID_ARGUMENT',
      4, 1024
      );
  end if;

  _query := case when _review is null then '' else 'review = $1,' end ||
            case when _comment is null then '' else 'comment = $2,' end ||
            'updated_at = now() ';

  _sqlstr := format('UPDATE main.book_reviews ' ||
                    'SET %s ' ||
                    'WHERE id = $3', left(_query, length(_query) - 1));

  execute _sqlstr
  using _review, _comment, _review_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.update_book_review(bigint, bigint, smallint, text) owner to postgres;
grant execute on function core.update_book_review(bigint, bigint, smallint, text) to postgres, web;
revoke all on function core.update_book_review(bigint, bigint, smallint, text) from public;