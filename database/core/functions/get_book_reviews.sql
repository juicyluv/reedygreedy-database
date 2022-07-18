create or replace function core.get_book_reviews(_book_id         bigint = null,
                                                 _search          text = null,
                                                 _page_size       int = 60,
                                                 _page            int = 1,
                                                 _sort            text[] = null,
  out                                            review_id        bigint,
  out                                            book_id          bigint,
  out                                            book_title       text,
  out                                            creator_id       bigint,
  out                                            creator_username text,
  out                                            review           smallint,
  out                                            created_at       timestamptz,
  out                                            updated_at       timestamptz,
  out                                            comment          text,
  out                                            total            bigint)
returns setof record as $$
declare
  _sqlstr text;
begin

  _sqlstr := 'WITH tab AS (SELECT
                             br.id         AS book_id,
                             br.book_id    AS book_id,
                             b.title       AS book_title,
                             br.creator_id AS creator_id,
                             u.username    AS creator_username,
                             br.review     AS review,
                             br.created_at AS created_at,
                             br.updated_at AS updated_at,
                             br.comment    AS comment,
                             NULL::BIGINT  AS total
                           FROM core.book_reviews br
                             LEFT JOIN main.users u
                               ON u.id = br.creator_id
                             LEFT JOIN main.books b
                               ON b.id = br.book_id
                           WHERE 1 = 1 ' ||

             case when _book_id is not null then
               'AND br.book_id = $1 '
             else '' end ||

             case when coalesce(_search, '') != ''
               then 'AND (b.title ILIKE ''%'' || $2 || ''%'') '
             else '' end ||

            core.order_by(_sort) ||

             ' )

             SELECT
              NULL::BIGINT,
              NULL::BIGINT,
              NULL::TEXT,
              NULL::BIGINT,
              NULL::TEXT,
              NULL::SMALLINT,
              NULL::TIMESTAMPTZ,
              NULL::TIMESTAMPTZ,
              NULL::TEXT,

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
  using _book_id, _search, _page_size, _page;

exception
  when others then

    return query with t as (values(null::bigint,
                                   null::bigint,
                                   null::text,
                                   null::bigint,
                                   null::text,
                                   null::smallint,
                                   null::timestamptz,
                                   null::timestamptz,
                                   null::bigint))

    select *
    from t
    where 1 = 2;

end
$$ language plpgsql stable security definer;

alter function core.get_book_reviews(bigint, text, int, int, text[]) owner to postgres;
grant execute on function core.get_book_reviews(bigint, text, int, int, text[]) to postgres, web;
revoke all on function core.get_book_reviews(bigint, text, int, int, text[]) from public;