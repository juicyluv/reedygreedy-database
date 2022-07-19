create or replace function core.get_book(_book_id         bigint,
  out                                    title            text,
  out                                    price            int,
  out                                    count            decimal(10,2),
  out                                    creator_id       bigint,
  out                                    creator_username text,
  out                                    author_id        bigint,
  out                                    author_name      text,
  out                                    pages            smallint,
  out                                    description      text,
  out                                    created_at       timestamptz,
  out                                    updated_at       timestamptz,
  out                                    error            jsonb)
as $$
begin

  select
    b.title,
    b.price,
    b.count,
    b.creator_id,
    u.username,
    b.author_id,
    a.name,
    b.pages,
    b.description,
    b.created_at,
    b.updated_at
  into
    title,
    price,
    count,
    creator_id,
    creator_username,
    author_id,
    author_name,
    pages,
    description,
    created_at,
    updated_at
  from core.books b
    left join core.users u
      on u.id = b.creator_id
    left join core.authors a
      on a.id = b.author_id
  where b.id = _book_id;

  if not found then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Book not found.',
        'code', 'NOT_FOUND'
      )
    );
    return;
  end if;

  error := jsonb_build_object('status', 0);

exception
  when others then

    error := jsonb_build_object('status', -1);

end;
$$ language plpgsql stable security definer;

alter function core.get_book(bigint) owner to postgres;
grant execute on function core.get_book(bigint) to postgres, web;
revoke all on function core.get_book(bigint) from public;