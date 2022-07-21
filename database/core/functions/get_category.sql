create or replace function core.get_category(_category_id smallint,
  out                                        name         text,
  out                                        created_at   timestamptz,
  out                                        updated_at   timestamptz,
  out                                        error        jsonb)
as $$
begin

  select
    c.name,
    c.created_at,
    c.updated_at
  into
    name,
    created_at,
    updated_at
  from core.categories c
  where c.id = _category_id;

  if not found then
    error := core.error_response(
      'CATEGORY_NOT_FOUND',
      'Category not found.',
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

alter function core.get_category(smallint) owner to postgres;
grant execute on function core.get_category(smallint) to postgres, web;
revoke all on function core.get_category(smallint) from public;