create or replace function core.add_author_to_category(_invoker_id  bigint,
                                                       _author_id   bigint,
                                                       _category_id smallint)
returns jsonb as $$
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

  if exists(select 1
            from core.authors_to_categories ac
            where ac.author_id = _author_id
                  and ac.category_id = _category_id)
  then
    return core.error_response(
       'AUTHOR_ALREADY_ADDED_TO_CATEGORY',
       'Author is already added to category.',
       'OBJECT_DUPLICATE'
      );
  end if;

  insert into main.authors_to_categories(author_id, category_id)
  values (_author_id, _category_id);

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.add_author_to_category(bigint, bigint, smallint) owner to postgres;
grant execute on function core.add_author_to_category(bigint, bigint, smallint) to postgres, web;
revoke all on function core.add_author_to_category(bigint, bigint, smallint) from public;