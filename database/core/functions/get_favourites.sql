create or replace function core.get_favourites(_user_id    bigint = null,
                                               _book_id    bigint = null,
  out                                          user_id     bigint,
  out                                          book_id     bigint,
  out                                          created_at  timestamptz)
returns setof record as $$
declare
  _sqlstr text;
begin

  _sqlstr := format('SELECT
                       f.user_id    AS user_id,
                       f.book_id    AS book_id,
                       f.created_at AS created_at
                     FROM core.favourites f
                     WHERE 1 = 1 ' ||

                    case when _user_id is not null
                      then 'AND f.user_id = $1 '
                    else '' end ||

                    case when _book_id is not null
                      then 'AND f.book_id = $2'
                    else '' end);

  return query execute _sqlstr
  using _user_id, _book_id;

exception
  when others then

    return query with t as (values(null::bigint,
                                   null::bigint,
                                   null::timestamptz))

    select *
    from t
    where 1 = 2;

end;
$$ language plpgsql stable security definer;

alter function core.get_favourites(bigint, bigint) owner to postgres;
grant execute on function core.get_favourites(bigint, bigint) to postgres, web;
revoke all on function core.get_favourites(bigint, bigint) from public;