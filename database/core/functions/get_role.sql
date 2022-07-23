create or replace function core.get_role(_role_id     smallint,
  out                                    name         text,
  out                                    access_level smallint,
  out                                    error        jsonb)
as $$
begin

  select
    r.name,
    r.access_level
  into
    name,
    access_level
  from core.roles r
  where r.id = _role_id;

  if not found then
    error := core.error_response(
      'ROLE_NOT_FOUND',
      'Role not found.',
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

alter function core.get_role(smallint) owner to postgres;
grant execute on function core.get_role(smallint) to postgres, web;
revoke all on function core.get_role(smallint) from public;
