create or replace function core.get_author(_author_id       bigint,
  out                                      name             text,
  out                                      creator_id       bigint,
  out                                      creator_username text,
  out                                      description      text,
  out                                      created_at       timestamptz,
  out                                      updated_at       timestamptz,
  out                                      error            jsonb)
as $$
begin

  select
    a.name,
    a.creator_id,
    u.username,
    a.description,
    a.created_at,
    a.updated_at
  into
    name,
    creator_id,
    creator_username,
    description,
    created_at,
    updated_at
  from core.authors a
    left join core.users u
      on u.id = a.creator_id
  where a.id = _author_id;

  if not found then
    error := core.error_response(
      'AUTHOR_NOT_FOUND',
      'Author not found.',
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

alter function core.get_author(bigint) owner to postgres;
grant execute on function core.get_author(bigint) to postgres, web;
revoke all on function core.get_author(bigint) from public;