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
    error := core.error_response(
      'UNAUTHORIZED',
      'Invoker not found.',
      'UNAUTHORIZED'
      );
    return;
  end if;

  if length(_name) < 4 or length(_name) > 100 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'Author name is out of range.',
       'INVALID_ARGUMENT',
       4, 100
    );
    return;
  end if;

  if _description is not null and (length(_description) < 30 or length(_description) > 4096) then
    error := core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Author description is out of range.',
      'INVALID_ARGUMENT',
      30, 4096
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