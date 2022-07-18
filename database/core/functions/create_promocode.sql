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
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Invoker not found.',
        'code', 'UNAUTHORIZED'
      )
    );
    return;
  end if;

  if _promocode = '' then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Promocode cannot be empty.',
        'code', 'INVALID_ARGUMENT'
      )
    );
    return;
  elseif length(_promocode) > 20 then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Promocode is out of range.',
        'code', 'INVALID_ARGUMENT'
      )
    );
    return;
  end if;

  if _usage_count is not null and _usage_count <= 0 then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Usage count must be positive number.',
        'code', 'INVALID_ARGUMENT'
        )
      );
    return;
  end if;

  if _ending_at is not null and _ending_at < now() then
    error := jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Ending at cannot be in the past.',
        'code', 'INVALID_ARGUMENT'
        )
      );
    return;
  end if;

  insert into main.promocodes(id, promocode, payload, usage_count, ending_at)
  values(default, _promocode, _payload, _usage_count, _ending_at)
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