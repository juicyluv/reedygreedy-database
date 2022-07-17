create or replace function core.create_category(_invoker_id  bigint,
                                                _name        text,
  out                                           category_id  smallint,
  out                                           error        jsonb)
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
        'message', 'Name cannot be empty.',
        'code', 'INVALID_ARGUMENT'
      )
    );
    return;
  elseif length(_name) > 30 then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Name is out of range.',
        'code', 'INVALID_ARGUMENT'
      )
    );
    return;
  end if;

  insert into main.categories(id, name)
  values(default, _name)
  returning id into category_id;

  error := jsonb_build_object('status', 0);

exception
  when others then

    category_id := null;
    error := jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.create_category(bigint, text) owner to postgres;
grant execute on function core.create_category(bigint, text) to postgres, web;
revoke all on function core.create_category(bigint, text) from public;