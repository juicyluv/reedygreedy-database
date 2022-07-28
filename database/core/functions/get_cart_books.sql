create or replace function core.get_cart_books(_cart_id    bigint,
  out                                          book_id     bigint,
  out                                          title       text,
  out                                          price       decimal(10,2),
  out                                          isbn        text,
  out                                          author_id   bigint,
  out                                          author_name text,
  out                                          pages       smallint,
  out                                          language    text,
  out                                          created_at  timestamptz,
  out                                          book_count  int,
  out                                          error       jsonb,
  out                                          total       bigint)
returns setof record as $$
declare
  _sqlstr text;
begin

  if not exists(select 1
                from core.carts c
                where c.id = _cart_id)
  then
    error := core.error_response(
      'CART_NOT_FOUND',
      'Cart not found.',
      'OBJECT_NOT_FOUND'
      );

    return query values(null::bigint,
                        null::text,
                        null::decimal(10,2),
                        null::text,
                        null::bigint,
                        null::text,
                        null::smallint,
                        null::text,
                        null::timestamptz,
                        null::int,
                        error,
                        null::bigint);
    return;
  end if;

  _sqlstr := 'WITH tab AS (SELECT
                             b.id          AS book_id,
                             b.title       AS title,
                             b.price       AS price,
                             b.isbn        AS isbn,
                             b.author_id   AS author_id,
                             a.name        AS author_name,
                             b.pages       AS pages,
                             l.language    AS language,
                             b.created_at  AS created_at,
                             bc.book_count AS book_count,
                             NULL::JSONB   AS error,
                             NULL::BIGINT  AS total
                           FROM core.books b
                             LEFT JOIN core.authors a
                               ON a.id = b.author_id
                             LEFT JOIN core.languages l
                               ON l.id = b.language_id
                             LEFT JOIN core.books_to_carts bc
                               ON b.id = bc.book_id
                           WHERE bc.cart_id = $1)

                           SELECT
                            NULL::BIGINT,
                            NULL::TEXT,
                            NULL::DECIMAL(10,2),
                            NULL::TEXT,
                            NULL::BIGINT,
                            NULL::TEXT,
                            NULL::SMALLINT,
                            NULL::TEXT,
                            NULL::TIMESTAMPTZ,
                            NULL::INT,
                            NULL::JSONB,

                            (SELECT sum(book_count)
                             FROM tab)

                            UNION ALL

                            SELECT *
                            FROM(SELECT *
                                 FROM tab ) t';

  return query execute _sqlstr
  using _cart_id;

exception
  when others then

    return query with t as (values(null::bigint,
                                   null::text,
                                   null::decimal(10,2),
                                   null::text,
                                   null::bigint,
                                   null::text,
                                   null::smallint,
                                   null::text,
                                   null::timestamptz,
                                   null::int,
                                   null::jsonb,
                                   null::bigint))

    select *
    from t
    where 1 = 2;

end
$$ language plpgsql stable security definer;

alter function core.get_cart_books(bigint) owner to postgres;
grant execute on function core.get_cart_books(bigint) to postgres, web;
revoke all on function core.get_cart_books(bigint) from public;