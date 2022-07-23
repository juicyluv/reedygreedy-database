create or replace function core.update_book(_invoker_id  bigint,
                                            _book_id     bigint,
                                            _title       text = null,
                                            _price       decimal(10,2) = null,
                                            _count       int = null,
                                            _author_id   bigint = null,
                                            _language_id smallint = null,
                                            _description text = null)
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
                from core.books b
                where b.id = _book_id)
  then
    return core.error_response(
      'BOOK_NOT_FOUND',
      'Book not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if _title is null
     and _price is null
     and _count is null
     and _author_id is null
     and _description is null
  then
    return core.error_response(
      'EMPTY_QUERY',
      'Nothing to update.',
      'INVALID_ARGUMENT'
      );
  end if;

  if _title is not null and (length(_title) < 1 or length(_title) > 256) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Book title is out of range.',
      'INVALID_ARGUMENT',
      1, 256
      );
  end if;

  if _price is not null and _price < 0.1 then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Book price is out of range.',
      'INVALID_ARGUMENT',
      0.1
      );
  end if;

  if _count < 0 then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Book count is out of range.',
      'INVALID_ARGUMENT',
      0
      );
  end if;

  if _author_id is not null and not exists(select 1
                                           from core.authors a
                                           where a.id = _author_id)
  then
    return core.error_response(
      'AUTHOR_NOT_FOUND',
      'Author not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if _language_id is not null and not exists(select 1
                from core.languages l
                where l.id = _language_id)
  then
    return core.error_response(
      'LANGUAGE_NOT_FOUND',
      'Language not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  _query := case when _title is null then '' else 'title = $1,' end ||
            case when _price is null then '' else 'price = $2,' end ||
            case when _count is null then '' else 'count = $3,' end ||
            case when _author_id is null then '' else 'author_id = $4,' end ||
            case when _description is null then '' else 'description = $5,' end ||
            case when _language_id is null then '' else 'language_id = $6,' end ||
            'updated_at = now() ';

  _sqlstr := format('UPDATE main.books ' ||
                    'SET %s ' ||
                    'WHERE id = $7', left(_query, length(_query) - 1));

  execute _sqlstr
  using _title, _price, _count, _author_id, _description, _language_id, _book_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.update_book(bigint, bigint, text, decimal(10,2), int, bigint, smallint, text) owner to postgres;
grant execute on function core.update_book(bigint, bigint, text, decimal(10,2), int, bigint, smallint, text) to postgres, web;
revoke all on function core.update_book(bigint, bigint, text, decimal(10,2), int, bigint, smallint, text) from public;