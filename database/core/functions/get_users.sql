create or replace function core.get_users(_search          text = null,
                                          _page_size       int = 60,
                                          _page            int = 1,
                                          _sort            text[] = null,
  out                                     user_id          bigint,
  out                                     username         text,
  out                                     email            text,
  out                                     payload          jsonb,
  out                                     name             text,
  out                                     timezone         text,
  out                                     creator_id       bigint,
  out                                     creator_username text,
  out                                     created_at       timestamptz,
  out                                     updated_at       timestamptz,
  out                                     disabled_at      timestamptz,
  out                                     disable_reason   smallint,
  out                                     total            bigint)
returns setof record as $$
declare
  _sqlstr text;
begin

  _sqlstr := 'WITH tab AS (SELECT
                             u.id             AS user_id,
                             u.username       AS username,
                             u.email          AS email,
                             u.payload        AS payload,
                             u.name           AS name,
                             t.timezone       AS timezone,
                             u.creator_id     AS creator_id,
                             u2.username      AS creator_username,
                             u.created_at     AS created_at,
                             u.updated_at     AS updated_at,
                             u.disabled_at    AS disabled_at,
                             u.disable_reason AS disable_reason,
                             NULL::BIGINT     AS total
                           FROM core.users u
                             LEFT JOIN main.users u2
                               ON u2.id = u.creator_id
                             LEFT JOIN main.timezones t
                               ON t.id = u.timezone_id
                           WHERE 1 = 1 ' ||

             case when coalesce(_search, '') != ''
               then 'AND (u.username ILIKE ''%'' || $1 || ''%''
                          OR a.name ILIKE ''%'' || $1 || ''%'') '
             else '' end ||

            core.order_by(_sort) ||

             ' )

             SELECT
              NULL::BIGINT,
              NULL::TEXT,
              NULL::TEXT,
              NULL::JSONB,
              NULL::TEXT,
              NULL::TEXT,
              NULL::BIGINT,
              NULL::TEXT,
              NULL::TIMESTAMPTZ,
              NULL::TIMESTAMPTZ,
              NULL::TIMESTAMPTZ,
              NULL::SMALLINT,

              (SELECT count(*)
               FROM tab)

              UNION ALL

              SELECT *
              FROM(SELECT *
                   FROM tab ' ||

              case when _page_size <= 0 then ''
              else 'LIMIT $2 OFFSET $2 * ($3 - 1)' end ||

             ') t';

  return query execute _sqlstr
  using _search, _page_size, _page;

exception
  when others then

    return query with t as (values(null::bigint,
                                   null::text,
                                   null::text,
                                   null::jsonb,
                                   null::text,
                                   null::text,
                                   null::bigint,
                                   null::text,
                                   null::timestamptz,
                                   null::timestamptz,
                                   null::timestamptz,
                                   null::smallint,
                                   null::bigint))

    select *
    from t
    where 1 = 2;

end;
$$ language plpgsql stable security definer;

alter function core.get_users(text, int, int, text[]) owner to postgres;
grant execute on function core.get_users(text, int, int, text[]) to postgres, web;
revoke all on function core.get_users(text, int, int, text[]) from public;