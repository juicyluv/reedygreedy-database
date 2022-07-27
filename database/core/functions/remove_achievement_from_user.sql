create or replace function core.remove_achievement_from_user(_invoker_id     bigint,
                                                             _achievement_id smallint,
                                                             _user_id        bigint)
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

  if not exists(select 1
                from core.users u
                where u.id = _user_id)
  then
    return core.error_response(
      'USER_NOT_FOUND',
      'User not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if not exists(select 1
                from core.users_to_achievements ua
                where ua.achievement_id = _achievement_id
                      and ua.user_id = _user_id)
  then
    return core.error_response(
      'ACHIEVEMENT_DO_NOT_BELONG_TO_USER',
      'Achievement do not belong to user.',
      'OBJECT_DEPENDENCY'
      );
  end if;

  delete from main.users_to_achievements ua
  where ua.achievement_id = _achievement_id
        and ua.user_id = _user_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.remove_achievement_from_user(bigint, smallint, bigint) owner to postgres;
grant execute on function core.remove_achievement_from_user(bigint, smallint, bigint) to postgres, web;
revoke all on function core.remove_achievement_from_user(bigint, smallint, bigint) from public;