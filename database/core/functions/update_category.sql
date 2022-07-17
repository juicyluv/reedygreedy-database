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
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Invoker not found.',
        'code', 'UNAUTHORIZED'
      )
    );
  end if;

  if not exists(select 1
                from core.categories c
                where c.id = _category_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Category not found.',
        'code', 'NOT_FOUND'
        )
      );
  end if;

  if _name is null
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
    elseif length(_name) > 30 then
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