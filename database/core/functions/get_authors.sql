create or replace function core.get_authors(_search          text = null,
                                            _page_size       int = 60,
                                            _page            int = 1,
                                            _sort            text[] = null,
  out                                       author_id        bigint,
  out                                       name             text,
  out                                       creator_id       bigint,
  out                                       creator_username text,
  out                                       description      text,
  out                                       created_at       timestamptz,
  out                                       updated_at       timestamptz,
  out                                       total            bigint)
returns setof record as $$
declare
  _sqlstr text;
begin

  _sqlstr := 'WITH tab AS (SELECT
                             a.id          AS author_id,
                             a.name        AS name,
                             a.creator_id  AS creator_id,
                             u.username    AS creator_username,
                             a.description AS description,
                             a.created_at  AS created_at,
                             a.updated_at  AS updated_at,
                             NULL::BIGINT  AS total
                           FROM core.authors a
                             LEFT JOIN main.users u
                               ON u.id = a.creator_id
                           WHERE 1 = 1 ' ||

             case when coalesce(_search, '') != ''
               then 'AND a.name ILIKE ''%'' || $1 || ''%'
             else '' end ||

            core.order_by(_sort) ||

             ' )

             SELECT
              NULL::BIGINT,
              NULL::TEXT,
              NULL::BIGINT,
              NULL::TEXT,
              NULL::TEXT,
              NULL::TIMESTAMPTZ,
              NULL::TIMESTAMPTZ,

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
                                   null::bigint,
                                   null::text,
                                   null::text,
                                   null::timestamptz,
                                   null::timestamptz,
                                   null::bigint))

    select *
    from t
    where 1 = 2;

end;
$$ language plpgsql stable security definer;

alter function core.get_authors(text, int, int, text[]) owner to postgres;
grant execute on function core.get_authors(text, int, int, text[]) to postgres, web;
revoke all on function core.get_authors(text, int, int, text[]) from public;