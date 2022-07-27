create or replace function core.get_author_books(_author_id       bigint,
                                                 _page_size       int = 60,
                                                 _page            int = 1,
                                                 _sort            text[] = null,
  out                                            book_id          bigint,
  out                                            title            text,
  out                                            count            int,
  out                                            price            decimal(10,2),
  out                                            creator_id       bigint,
  out                                            creator_username text,
  out                                            isbn             text,
  out                                            author_id        bigint,
  out                                            author_name      text,
  out                                            pages            smallint,
  out                                            language         text,
  out                                            description      text,
  out                                            created_at       timestamptz,
  out                                            updated_at       timestamptz,
  out                                            error            jsonb,
  out                                            total            bigint)
returns setof record as $$
declare
  _sqlstr text;
begin

  if not exists(select 1
                from core.authors a
                where a.id = _author_id)
  then
    error := core.error_response(
      'AUTHOR_NOT_FOUND',
      'Author not found.',
      'OBJECT_NOT_FOUND'
      );

    return query values(null::bigint,
                        null::text,
                        null::int,
                        null::decimal(10,2),
                        null::bigint,
                        null::text,
                        null::text,
                        null::bigint,
                        null::text,
                        null::smallint,
                        null::text,
                        null::text,
                        null::timestamptz,
                        null::timestamptz,
                        error,
                        null::bigint);
    return;
  end if;

  _sqlstr := 'WITH tab AS (SELECT
                             b.id          AS book_id,
                             b.title       AS title,
                             b.count       AS count,
                             b.price       AS price,
                             b.creator_id  AS creator_id,
                             u.username    AS creator_username,
                             b.isbn        AS isbn,
                             b.author_id   AS author_id,
                             a.name        AS author_name,
                             b.pages       AS pages,
                             l.language    AS language,
                             b.description AS description,
                             b.created_at  AS created_at,
                             b.updated_at  AS updated_at,
                             NULL::JSONB   AS error,
                             NULL::BIGINT  AS total
                           FROM core.books b
                             LEFT JOIN main.users u
                               ON u.id = b.creator_id
                             LEFT JOIN main.authors a
                               ON a.id = b.author_id
                             LEFT JOIN main.languages l
                               ON l.id = b.language_id
                           WHERE b.author_id = $1 ' ||

            core.order_by(_sort) ||

             ' )

             SELECT
              NULL::BIGINT,
              NULL::TEXT,
              NULL::INT,
              NULL::DECIMAL(10,2),
              NULL::BIGINT,
              NULL::TEXT,
              NULL::TEXT,
              NULL::BIGINT,
              NULL::TEXT,
              NULL::SMALLINT,
              NULL::TEXT,
              NULL::TEXT,
              NULL::TIMESTAMPTZ,
              NULL::TIMESTAMPTZ,
              NULL::JSONB,

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
  using _author_id, _page_size, _page;

exception
  when others then

    return query with t as (values(null::bigint,
                                   null::text,
                                   null::int,
                                   null::decimal(10,2),
                                   null::bigint,
                                   null::text,
                                   null::text,
                                   null::bigint,
                                   null::text,
                                   null::smallint,
                                   null::text,
                                   null::text,
                                   null::timestamptz,
                                   null::timestamptz,
                                   null::jsonb,
                                   null::bigint))

    select *
    from t
    where 1 = 2;

end;
$$ language plpgsql stable security definer;

alter function core.get_author_books(bigint, int, int, text[]) owner to postgres;
grant execute on function core.get_author_books(bigint, int, int, text[]) to postgres, web;
revoke all on function core.get_author_books(bigint, int, int, text[]) from public;