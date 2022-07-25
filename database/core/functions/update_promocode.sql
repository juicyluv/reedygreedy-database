create or replace function core.update_promocode(_invoker_id   bigint,
                                                 _promocode_id bigint,
                                                 _promocode    text = null,
                                                 _payload      jsonb = null,
                                                 _usage_count  int = null,
                                                 _ending_at    timestamptz = null)
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
                from core.promocodes p
                where p.id = _promocode_id)
  then
    return core.error_response(
      'PROMOCODE_NOT_FOUND',
      'Promocode not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if _promocode is null
     and _payload is null
     and _usage_count is null
     and _ending_at is null
  then
    return core.error_response(
      'EMPTY_QUERY',
      'Nothing to update.',
      'INVALID_ARGUMENT'
      );
  end if;

  if _promocode is not null and (length(_promocode) < 1 or length(_promocode) > 24) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Promocode is out of range.',
      'INVALID_ARGUMENT',
      1, 24
      );
  end if;

  if _usage_count is not null and _usage_count <= 0 then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Promocode usage count is out of range.',
      'INVALID_ARGUMENT',
      1
      );
  end if;

  if _ending_at is not null and _ending_at < now() then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Promocode ending time cannot be in the past.',
      'INVALID_ARGUMENT'
      );
  end if;

  if _promocode is not null and exists(select 1
                                       from core.promocodes p
                                       where lower(p.promocode) = lower(_promocode))
  then
    return core.error_response(
      'PROMOCODE_ALREADY_EXISTS',
      'Promocode already exists',
      'OBJECT_DUPLICATE'
      );
  end if;

  _query := case when _promocode is null then '' else 'promocode = $1,' end ||
            case when _payload is null then '' else 'payload = $2,' end ||
            case when _usage_count is null then '' else 'usage_count = $3' end ||
            case when _ending_at is null then '' else 'ending_at = $4' end ||
            'updated_at = now() ';

  _sqlstr := format('UPDATE main.promocodes ' ||
                    'SET %s ' ||
                    'WHERE id = $5', left(_query, length(_query) - 1));

  execute _sqlstr
  using _promocode, _payload, _usage_count, _ending_at, _promocode_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.update_promocode(bigint, bigint, text, jsonb, int, timestamptz) owner to postgres;
grant execute on function core.update_promocode(bigint, bigint, text, jsonb, int, timestamptz) to postgres, web;
revoke all on function core.update_promocode(bigint, bigint, text, jsonb, int, timestamptz) from public;