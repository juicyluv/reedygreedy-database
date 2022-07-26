create or replace function core.update_achievement(_invoker_id     bigint,
                                                   _achievement_id smallint,
                                                   _name           text = null,
                                                   _description    text = null,
                                                   _payload        jsonb = null)
returns jsonb as $$
declare
  _query text;
  _sqlstr text;
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

  if _name is null
     and _description is null
     and _payload is null
  then
    return core.error_response(
      'EMPTY_QUERY',
      'Nothing to update.',
      'INVALID_ARGUMENT'
      );
  end if;

  if _name is not null and (length(_name) < 1 or length(_name) > 30) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Achievement name is out of range.',
      'INVALID_ARGUMENT',
      1, 30
      );
  end if;

  if _description is not null and (length(_description) < 5 or length(_description) > 128) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Achievement description is out of range.',
      'INVALID_ARGUMENT',
      5, 128
      );
  end if;

  if _name is not null and exists(select 1
                                  from main.achievements a
                                  where lower(a.name) = lower(_name))
  then
    return core.error_response(
      'ACHIEVEMENT_ALREADY_EXISTS',
      'Achievement already exists.',
      'OBJECT_DUPLICATE'
      );
  end if;

  _query := case when _name is null then '' else 'name = $1,' end ||
            case when _description is null then '' else 'description = $2,' end ||
            case when _payload is null then '' else 'payload = $3,' end ||
            'updated_at = now() ';

  _sqlstr := format('UPDATE main.achievements ' ||
                    'SET %s ' ||
                    'WHERE id = $4', left(_query, length(_query) - 1));

  execute _sqlstr
  using _name, _description, _payload, _achievement_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.update_achievement(bigint, smallint, text, text, jsonb) owner to postgres;
grant execute on function core.update_achievement(bigint, smallint, text, text, jsonb) to postgres, web;
revoke all on function core.update_achievement(bigint, smallint, text, text, jsonb) from public;