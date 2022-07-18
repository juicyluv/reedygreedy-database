create or replace function core.get_categories(_search     text = null,
                                               _page_size  int = 60,
                                               _page       int = 1,
                                               _sort       text[] = null,
  out                                          category_id smallint,
  out                                          name        text,
  out                                          created_at  timestamptz,
  out                                          updated_at  timestamptz,
  out                                          total       bigint)
returns setof record as $$
declare
  _sqlstr text;
begin

  _sqlstr := 'WITH tab AS (SELECT
                             c.id         AS category_id,
                             c.name       AS name,
                             c.created_at AS created_at,
                             c.updated_at AS updated_at,
                             NULL::BIGINT AS total
                           FROM core.categories c
                           WHERE 1 = 1 ' ||

             case when coalesce(_search, '') != ''
               then 'AND c.name ILIKE ''%'' || $1 || ''%'' '
             else '' end ||

            core.order_by(_sort) ||

             ' )

             SELECT
              NULL::SMALLINT,
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

    return query with t as (values(null::smallint,
                                   null::text,
                                   null::timestamptz,
                                   null::timestamptz,
                                   null::bigint))

    select *
    from t
    where 1 = 2;

end;
$$ language plpgsql stable security definer;

alter function core.get_categories(text, int, int, text[]) owner to postgres;
grant execute on function core.get_categories(text, int, int, text[]) to postgres, web;
revoke all on function core.get_categories(text, int, int, text[]) from public;