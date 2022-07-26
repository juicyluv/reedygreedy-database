create or replace function core.get_achievement(_achievement_id smallint,
  out                                           name            text,
  out                                           description     text,
  out                                           payload         jsonb,
  out                                           created_at      timestamptz,
  out                                           updated_at      timestamptz,
  out                                           error           jsonb)
as $$
begin

  select
    a.name,
    a.description,
    a.payload,
    a.created_at,
    a.updated_at
  into
    name,
    description,
    payload,
    created_at,
    updated_at
  from core.achievements a
  where a.id = _achievement_id;

  if not found then
    error := core.error_response(
      'ACHIEVEMENT_NOT_FOUND',
      'Achievement not found.',
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

alter function core.get_achievement(smallint) owner to postgres;
grant execute on function core.get_achievement(smallint) to postgres, web;
revoke all on function core.get_achievement(smallint) from public;