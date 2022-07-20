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
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Invoker not found.',
        'code', 'UNAUTHORIZED'
      )
    );
  end if;

  if not exists(select 1
                from core.book_reviews br
                where br.id = _review_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Review not found.',
        'code', 'NOT_FOUND'
        )
      );
  end if;

  if _review is null
    and _comment is null
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Nothing to update.',
        'code', 'EMPTY_QUERY'
      )
    );
  end if;

  if _review is not null then
    if _review <= 0 or _review > 5 then
      return jsonb_build_object(
        'status', 1,
        'details', jsonb_build_object(
          'message', 'Review must be between 0 and 5.',
          'code', 'INVALID_ARGUMENT'
        )
      );
    end if;
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