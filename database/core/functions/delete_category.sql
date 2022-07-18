create or replace function core.delete_category(_invoker_id  bigint,
                                                _category_id smallint)
returns jsonb as $$
begin

  if not exists(select 1
                from core.users u
                where u.id = _invoker_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Invoker not found.',
        'code', 'UNAUTHORIZED'
      )
    );
  end if;

  delete from main.categories c
  where c.id = _category_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile strict security definer;

alter function core.delete_category(bigint, smallint) owner to postgres;
grant execute on function core.delete_category(bigint, smallint) to postgres, web;
revoke all on function core.delete_category(bigint, smallint) from public;