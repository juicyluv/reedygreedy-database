create or replace function core.delete_role(_invoker_id  bigint,
                                            _role_id     smallint)
  returns jsonb as $$
begin

  if not exists(select 1
                from core.users u
                where u.id = _invoker_id)
  then
    return core.error_response(
      'UNAUTHORIZED',
      'Invoker not found.',
      'UNAUTHORIZED'
      );
  end if;

  if not exists(select 1
                from core.roles r
                where r.id = _role_id)
  then
    return core.error_response(
      'ROLE_NOT_FOUND',
      'Role not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  delete from main.roles r
  where r.id = _role_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile strict security definer;

alter function core.delete_role(bigint, smallint) owner to postgres;
grant execute on function core.delete_role(bigint, smallint) to postgres, web;
revoke all on function core.delete_role(bigint, smallint) from public;