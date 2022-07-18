create or replace function core.create_author(_invoker_id  bigint,
                                              _name        text,
                                              _description text = null,
  out                                         author_id    bigint,
  out                                         error        jsonb)
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

  if _name = '' then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Title cannot be empty.',
        'code', 'INVALID_ARGUMENT'
      )
    );
    return;
  end if;

  insert into main.authors(id, name, creator_id, description)
  values(default, _name, _invoker_id, _description)
  returning id into author_id;

  error := jsonb_build_object('status', 0);

exception
  when others then

    author_id := null;
    error := jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.create_author(bigint, text, text) owner to postgres;
grant execute on function core.create_author(bigint, text, text) to postgres, web;
revoke all on function core.create_author(bigint, text, text) from public;