create or replace function core.create_promocode(_invoker_id  bigint,
                                                 _promocode   text,
                                                 _payload     jsonb,
                                                 _usage_count int = null,
                                                 _ending_at   timestamptz = null,
  out                                            promocode_id bigint,
  out                                            error        jsonb)
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

  if length(_promocode) < 1 or length(_promocode) > 24 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'Promocode is out of range.',
       'INVALID_ARGUMENT',
       1, 24
    );
    return;
  end if;

  if _usage_count is not null and _usage_count <= 0 then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'Promocode usage count is out of range.',
       'INVALID_ARGUMENT',
       1
    );
    return;
  end if;

  if _ending_at is not null and _ending_at < now() then
    error := core.error_response(
       'VALUE_OUT_OF_RANGE',
       'Promocode ending time cannot be in the past.',
       'INVALID_ARGUMENT'
    );
    return;
  end if;

  if exists (select 1
             from core.promocodes p
             where lower(p.promocode) = lower(_promocode))
  then
    error := core.error_response(
      'PROMOCODE_ALREADY_EXISTS',
      'Promocode already exists.',
      'OBJECT_DUPLICATE'
      );
    return;
  end if;

  insert into main.promocodes(id, promocode, creator_id, payload, usage_count, ending_at)
  values(default, _promocode, _invoker_id, _payload, _usage_count, _ending_at)
  returning id into promocode_id;

  error := jsonb_build_object('status', 0);

exception
  when others then

    promocode_id := null;
    error := jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.create_promocode(bigint, text, jsonb, int, timestamptz) owner to postgres;
grant execute on function core.create_promocode(bigint, text, jsonb, int, timestamptz) to postgres, web;
revoke all on function core.create_promocode(bigint, text, jsonb, int, timestamptz) from public;