create or replace function core.update_category(_invoker_id  bigint,
                                                _category_id smallint,
                                                _name        text = null)
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
                from core.categories c
                where c.id = _category_id)
  then
    return core.error_response(
      'CATEGORY_NOT_FOUND',
      'Category not found.',
      'OBJECT_NOT_FOUND'
      );
  end if;

  if _name is null
  then
    return core.error_response(
      'EMPTY_QUERY',
      'Nothing to update.',
      'INVALID_ARGUMENT'
      );
  end if;

  if _name is not null and (length(_name) < 1 or length(_name) > 64) then
    return core.error_response(
      'VALUE_OUT_OF_RANGE',
      'Category name is out of range.',
      'INVALID_ARGUMENT',
      1, 64
      );
  end if;

  _query := case when _name is null then '' else 'name = $1,' end ||
            'updated_at = now() ';

  _sqlstr := format('UPDATE main.categories ' ||
                    'SET %s ' ||
                    'WHERE id = $2', left(_query, length(_query) - 1));

  execute _sqlstr
  using _name, _category_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.update_category(bigint, smallint, text) owner to postgres;
grant execute on function core.update_category(bigint, smallint, text) to postgres, web;
revoke all on function core.update_category(bigint, smallint, text) from public;