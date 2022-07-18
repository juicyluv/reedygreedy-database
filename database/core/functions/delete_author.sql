create or replace function core.delete_author(_invoker_id bigint,
                                              _author_id  bigint)
returns jsonb as $$
begin

  if not exists(select 1
                from core.users u
                where u.id = _invoker_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Invoker not found.',
        'code', 'UNAUTHORIZED'
      )
    );
  end if;

  if not exists(select 1
                from core.authors a
                where a.id = _author_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Author not found.',
        'code', 'NOT_FOUND'
      )
    );
  end if;

  delete from main.authors a
  where a.id = _author_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end;
$$ language plpgsql volatile strict security definer;

alter function core.delete_author(bigint, bigint) owner to postgres;
grant execute on function core.delete_author(bigint, bigint) to postgres, web;
revoke all on function core.delete_author(bigint, bigint) from public;