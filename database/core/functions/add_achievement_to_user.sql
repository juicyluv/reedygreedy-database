create or replace function core.add_achievement_to_user(_invoker_id     bigint,
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

  if exists(select 1
            from core.users_to_achievements uc
            where uc.user_id = _user_id
                  and uc.achievement_id = _achievement_id)
  then
    return core.error_response(
       'ACHIEVEMENT_ALREADY_ADDED_TO_USER',
       'Achievement is already added to user.',
       'OBJECT_DUPLICATE'
      );
  end if;

  insert into main.users_to_achievements(user_id, achievement_id)
  values (_user_id, _achievement_id);

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.add_achievement_to_user(bigint, smallint, bigint) owner to postgres;
grant execute on function core.add_achievement_to_user(bigint, smallint, bigint) to postgres, web;
revoke all on function core.add_achievement_to_user(bigint, smallint, bigint) from public;