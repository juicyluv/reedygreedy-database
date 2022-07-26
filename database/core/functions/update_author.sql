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
    return core.error_response(
      'UNAUTHORIZED',
      'Invoker not found.',
      'UNAUTHORIZED'
      );
  end if;

  if not exists(select 1
                from core.authors a
                where a.id = _author_id)
  then
    return core.error_response(
      'AUTHOR_NOT_FOUND',
      'Author not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if _name is null
     and _description is null
  then
    return core.error_response(
      'EMPTY_QUERY',
      'Nothing to update.',
      'INVALID_ARGUMENT'
      );
  end if;

  if _name is not null and (length(_name) < 4 or length(_name) > 100) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Author name is out of range.',
      'INVALID_ARGUMENT',
      4, 100
      );
  end if;

  if _description is not null and (length(_description) < 30 or length(_description) > 4096) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Author description is out of range.',
      'INVALID_ARGUMENT',
      30, 4096
      );
  end if;

  if _name is not null and exists(select 1
                                  from main.authors a
                                  where lower(a.name) = lower(_name))
  then
    return core.error_response(
      'AUTHOR_ALREADY_EXISTS',
      'Author already exists.',
      'OBJECT_DUPLICATE'
      );
  end if;

  _query := case when _name is null then '' else 'name = $1,' end ||
            case when _description is null then '' else 'description = $2,' end ||
            'updated_at = now() ';

  _sqlstr := format('UPDATE main.authors ' ||
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