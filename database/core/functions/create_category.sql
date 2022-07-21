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
    error := core.error_response(
      'UNAUTHORIZED',
      'Invoker not found.',
      'UNAUTHORIZED'
      );
    return;
  end if;

  if length(_name) < 1 or length(_name) > 64 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'Category name is out of range.',
       'INVALID_ARGUMENT',
       1, 64
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