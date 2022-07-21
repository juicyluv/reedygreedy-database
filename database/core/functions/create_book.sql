create or replace function core.create_book(_invoker_id  bigint,
                                            _title       text,
                                            _price       decimal(10,2),
                                            _count       int,
                                            _author_id   bigint,
                                            _isbn        text,
                                            _pages       smallint = null,
                                            _language_id smallint = null,
                                            _description text = null,
  out                                       book_id      bigint,
  out                                       error        jsonb)
as $$
begin

  if not exists(select 1
                from core.users u
                where u.id = _invoker_id)
  then
    error := core.error_response(
      'UNAUTHORIZED',
      'Invoker not found.',
      'UNAUTHORIZED'
      );
    return;
  end if;

  if length(_title) < 1 or length(_title) > 256 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'Book title is out of range.',
       'INVALID_ARGUMENT',
       1, 256
    );
    return;
  end if;

  if _price < 0.1 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'Book price is out of range.',
       'INVALID_ARGUMENT',
       0.1
    );
    return;
  end if;

  if _count < 0 then
    error := core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Book count is out of range.',
      'INVALID_ARGUMENT',
      0
      );
    return;
  end if;

  if _pages is not null and _pages <= 0 then
    error := core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Book count is out of range.',
      'INVALID_ARGUMENT',
      1
      );
    return;
  end if;

  if not exists(select 1
                from core.authors a
                where a.id = _author_id)
  then
    error := core.error_response(
      'AUTHOR_NOT_FOUND',
      'Author not found.',
      'OBJECT_NOT_FOUND'
      );
    return;
  end if;

  if not exists(select 1
                from core.languages l
                where l.id = _language_id)
  then
    error := core.error_response(
      'LANGUAGE_NOT_FOUND',
      'Language not found.',
      'OBJECT_NOT_FOUND'
      );
    return;
  end if;

  insert into main.books(id, title, price, count, creator_id, author_id, isbn, pages, language_id, description)
  values(default, _title, _price, _count, _invoker_id, _author_id, _isbn, _pages, _language_id, _description)
  returning id into book_id;

  error := jsonb_build_object('status', 0);

exception
  when others then

    book_id := null;
    error := jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.create_book(bigint, text, decimal(10,2), int, bigint, text, smallint, smallint, text) owner to postgres;
grant execute on function core.create_book(bigint, text, decimal(10,2), int, bigint, text, smallint, smallint, text) to postgres, web;
revoke all on function core.create_book(bigint, text, decimal(10,2), int, bigint, text, smallint, smallint, text) from public;