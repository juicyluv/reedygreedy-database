create or replace function core.create_achievement(_invoker_id    bigint,
                                                   _name          text,
                                                   _description   text,
                                                   _payload       jsonb = null,
  out                                              achievement_id smallint,
  out                                              error          jsonb)
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

  if length(_name) < 1 or length(_name) > 30 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'Achievement name is out of range.',
       'INVALID_ARGUMENT',
       1, 30
    );
    return;
  end if;

  if length(_description) < 5 or length(_description) > 128 then
    error := core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Achievement description is out of range.',
      'INVALID_ARGUMENT',
      5, 128
      );
    return;
  end if;

  if exists(select 1
            from core.achievements a
            where lower(a.name) = lower(_name))
  then
    error := core.error_response(
      'ACHIEVEMENT_ALREADY_EXISTS',
      'Achievement already exists.',
      'OBJECT_DUPLICATE'
      );
    return;
  end if;

  insert into main.achievements(name, description, payload)
  values(_name, _description, _payload)
  returning id into achievement_id;

  error := jsonb_build_object('status', 0);

exception
  when others then

    achievement_id := null;
    error := jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.create_achievement(bigint, text, text, jsonb) owner to postgres;
grant execute on function core.create_achievement(bigint, text, text, jsonb) to postgres, web;
revoke all on function core.create_achievement(bigint, text, text, jsonb) from public;