create or replace function core.get_promocodes(_user_id         bigint = null,
                                               _search          text = null,
                                               _page_size       int = 60,
                                               _page            int = 1,
                                               _sort            text[] = null,
  out                                          promocode_id     bigint,
  out                                          promocode        text,
  out                                          payload          jsonb,
  out                                          usage_count      int,
  out                                          creator_id       bigint,
  out                                          creator_username text,
  out                                          created_at       timestamptz,
  out                                          updated_at       timestamptz,
  out                                          ending_at        timestamptz,
  out                                          total            bigint)
returns setof record as $$
declare
  _sqlstr text;
begin

  _sqlstr := 'WITH tab AS (SELECT
                             p.id          AS promocode_id,
                             p.promocode   AS promocode,
                             p.payload     AS payload,
                             p.usage_count AS usage_count,
                             p.creator_id  AS creator_id,
                             u.username    AS creator_username,
                             p.created_at  AS created_at,
                             p.updated_at  AS updated_at,
                             p.ending_at   AS ending_at,
                             NULL::BIGINT  AS total
                           FROM core.promocodes p
                             LEFT JOIN main.users u
                               ON u.id = u.creator_id
                           WHERE 1 = 1 ' ||

             case when _user_id is not null
               then 'AND p.creator_id = $1 '
             else '' end ||

             case when coalesce(_search, '') != ''
               then 'AND (p.promocode ILIKE ''%'' || $2 || ''%'' )'
             else '' end ||

            core.order_by(_sort) ||

             ' )

             SELECT
              NULL::BIGINT,
              NULL::TEXT,
              NULL::JSONB,
              NULL::INT,
              NULL::BIGINT,
              NULL::TEXT,
              NULL::TIMESTAMPTZ,
              NULL::TIMESTAMPTZ,
              NULL::TIMESTAMPTZ,

              (SELECT count(*)
               FROM tab)

              UNION ALL

              SELECT *
              FROM(SELECT *
                   FROM tab ' ||

              case when _page_size <= 0 then ''
              else 'LIMIT $3 OFFSET $3 * ($4 - 1)' end ||

             ') t';

  return query execute _sqlstr
  using _user_id, _search, _page_size, _page;

exception
  when others then

    return query with t as (values(null::bigint,
                                   null::text,
                                   null::jsonb,
                                   null::int,
                                   null::bigint,
                                   null::text,
                                   null::timestamptz,
                                   null::timestamptz,
                                   null::timestamptz,
                                   null::bigint))

    select *
    from t
    where 1 = 2;

end;
$$ language plpgsql stable security definer;

alter function core.get_promocodes(bigint, text, int, int, text[]) owner to postgres;
grant execute on function core.get_promocodes(bigint, text, int, int, text[]) to postgres, web;
revoke all on function core.get_promocodes(bigint, text, int, int, text[]) from public;