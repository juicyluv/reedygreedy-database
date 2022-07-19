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
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Invoker not found.',
        'code', 'UNAUTHORIZED'
      )
    );
    return;
  end if;

  if _title = '' then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Title cannot be empty.',
        'code', 'INVALID_ARGUMENT'
      )
    );
    return;
  end if;

  if _price <= 0 then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Price must be a positive number.',
        'code', 'INVALID_ARGUMENT'
      )
    );
    return;
  end if;

  if _count <= 0 then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Count must be a positive number.',
        'code', 'INVALID_ARGUMENT'
      )
    );
    return;
  end if;

  if _pages is not null and _pages <= 0 then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Page count must be a positive number.',
        'code', 'INVALID_ARGUMENT'
      )
    );
    return;
  end if;

  if not exists(select 1
                from core.authors a
                where a.id = _author_id)
  then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Author not found.',
        'code', 'NOT_FOUND'
        )
      );
    return;
  end if;

  if not exists(select 1
                from core.languages l
                where l.id = _language_id)
  then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Language not found.',
        'code', 'NOT_FOUND'
        )
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

alter function core.create_book(bigint, text, decimal(10,2), int, bigint, text, smallint, text) owner to postgres;
grant execute on function core.create_book(bigint, text, decimal(10,2), int, bigint, text, smallint, text) to postgres, web;
revoke all on function core.create_book(bigint, text, decimal(10,2), int, bigint, text, smallint, text) from public;