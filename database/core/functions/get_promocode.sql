create or replace function core.get_promocode(_promocode       text,
  out                                         promocode_id     bigint,
  out                                         promocode        text,
  out                                         payload          jsonb,
  out                                         usage_count      int,
  out                                         creator_id       bigint,
  out                                         creator_username text,
  out                                         created_at       timestamptz,
  out                                         updated_at       timestamptz,
  out                                         ending_at        timestamptz,
  out                                         error            jsonb)
as $$
begin

  select
    p.id,
    p.promocode,
    p.payload,
    p.usage_count,
    p.creator_id,
    u.username,
    p.created_at,
    p.updated_at,
    p.ending_at
  into
    promocode_id,
    promocode,
    payload,
    usage_count,
    creator_id,
    creator_username,
    created_at,
    updated_at,
    ending_at
  from core.promocodes p
    left join core.users u
      on u.id = p.creator_id
  where lower(p.promocode) = lower(_promocode);

  if not found then
    error := core.error_response(
      'PROMOCODE_NOT_FOUND',
      'Promocode not found.',
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

alter function core.get_promocode(text) owner to postgres;
grant execute on function core.get_promocode(text) to postgres, web;
revoke all on function core.get_promocode(text) from public;
