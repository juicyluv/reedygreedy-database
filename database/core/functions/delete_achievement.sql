create or replace function core.delete_achievement(_invoker_id     bigint,
                                                   _achievement_id smallint)
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
                from core.achievements a
                where a.id = _achievement_id)
  then
    return core.error_response(
      'ACHIEVEMENT_NOT_FOUND',
      'Achievement not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  delete from main.achievements a
  where a.id = _achievement_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile strict security definer;

alter function core.delete_achievement(bigint, smallint) owner to postgres;
grant execute on function core.delete_achievement(bigint, smallint) to postgres, web;
revoke all on function core.delete_achievement(bigint, smallint) from public;