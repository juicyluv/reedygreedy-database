create or replace function core.get_achievements(_user_id         bigint = null,
                                                 _page_size       int = 60,
                                                 _page            int = 1,
                                                 _sort            text[] = null,
  out                                            achievement_id   smallint,
  out                                            name             text,
  out                                            description      text,
  out                                            payload          jsonb,
  out                                            created_at       timestamptz,
  out                                            updated_at       timestamptz,
  out                                            user_id          bigint,
  out                                            total            bigint)
returns setof record as $$
declare
  _sqlstr text;
begin

  _sqlstr := 'WITH tab AS (SELECT
                             a.id          AS achievement_id,
                             a.name        AS name,
                             a.description AS description,
                             a.payload     AS payload,
                             a.created_at  AS created_at,
                             a.updated_at  AS updated_at,
                             ua.user_id    AS user_id,
                             NULL::BIGINT  AS total
                           FROM core.achievements a
                             LEFT JOIN main.users_to_achievements ua
                               ON ua.achievement_id = a.id
                           WHERE 1 = 1 ' ||

             case when _user_id is not null
               then 'AND ua.user_id = $1'
             else '' end ||

            core.order_by(_sort) ||

             ' )

             SELECT
              NULL::SMALLINT,
              NULL::TEXT,
              NULL::TEXT,
              NULL::JSONB,
              NULL::TIMESTAMPTZ,
              NULL::TIMESTAMPTZ,
              NULL::BIGINT,

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
  using _user_id, _page_size, _page;

exception
  when others then

    return query with t as (values(null::smallint,
                                   null::text,
                                   null::text,
                                   null::jsonb,
                                   null::timestamptz,
                                   null::timestamptz,
                                   null::bigint,
                                   null::bigint))

    select *
    from t
    where 1 = 2;

end
$$ language plpgsql stable security definer;

alter function core.get_achievements(bigint, int, int, text[]) owner to postgres;
grant execute on function core.get_achievements(bigint, int, int, text[]) to postgres, web;
revoke all on function core.get_achievements(bigint, int, int, text[]) from public;