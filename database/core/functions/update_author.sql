create or replace function core.update_author(_invoker_id  bigint,
                                              _author_id   bigint,
                                              _name        text = null,
                                              _description text = null)
returns jsonb as $$
declare
  _query text;
  _sqlstr text;
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

  if _name is null
     and _description is null
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Nothing to update.',
        'code', 'EMPTY_QUERY'
      )
    );
  end if;

  if _name is not null then
    if _name = '' then
      return jsonb_build_object(
        'status', 1,
        'details', jsonb_build_object(
          'message', 'Name cannot be empty.',
          'code', 'INVALID_ARGUMENT'
        )
      );
    elseif length(_name) > 100 then
      return jsonb_build_object(
        'status', 1,
        'details', jsonb_build_object(
          'message', 'Name is out of range.',
          'code', 'INVALID_ARGUMENT'
        )
      );
    end if;
  end if;

  _query := case when _name is null then '' else 'name = $1,' end ||
            case when _description is null then '' else 'description = $2,' end ||
            'updated_at = now() ';

  _sqlstr := format('UPDATE main.books ' ||
                    'SET %s ' ||
                    'WHERE id = $3', left(_query, length(_query) - 1));

  execute _sqlstr
  using _name, _description, _author_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.update_author(bigint, bigint, text, text) owner to postgres;
grant execute on function core.update_author(bigint, bigint, text, text) to postgres, web;
revoke all on function core.update_author(bigint, bigint, text, text) from public;