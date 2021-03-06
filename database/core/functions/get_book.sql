create or replace function core.get_book(_book_id         bigint,
  out                                    title            text,
  out                                    count            int,
  out                                    price            decimal(10,2),
  out                                    creator_id       bigint,
  out                                    creator_username text,
  out                                    author_id        bigint,
  out                                    author_name      text,
  out                                    isbn             text,
  out                                    pages            smallint,
  out                                    language         text,
  out                                    description      text,
  out                                    created_at       timestamptz,
  out                                    updated_at       timestamptz,
  out                                    error            jsonb)
as $$
begin

  select
    b.title,
    b.count,
    b.price,
    b.creator_id,
    u.username,
    b.author_id,
    a.name,
    b.isbn,
    b.pages,
    l.language,
    b.description,
    b.created_at,
    b.updated_at
  into
    title,
    count,
    price,
    creator_id,
    creator_username,
    author_id,
    author_name,
    isbn,
    pages,
    language,
    description,
    created_at,
    updated_at
  from core.books b
    left join core.users u
      on u.id = b.creator_id
    left join core.authors a
      on a.id = b.author_id
    left join core.languages l
      on l.id = b.language_id
  where b.id = _book_id;

  if not found then
    error := core.error_response(
      'BOOK_NOT_FOUND',
      'Book not found.',
      'OBJECT_NOT_FOUND'
      );
    return;
  end if;

  error := jsonb_build_object('status', 0);

-- exception
--   when others then
--
--     error := jsonb_build_object('status', -1);

end;
$$ language plpgsql stable security definer;

alter function core.get_book(bigint) owner to postgres;
grant execute on function core.get_book(bigint) to postgres, web;
revoke all on function core.get_book(bigint) from public;