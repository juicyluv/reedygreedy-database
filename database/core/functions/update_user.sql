create or replace function core.update_user(_invoker_id  bigint,
                                            _user_id     bigint,
                                            _username    text = null,
                                            _password    text = null,
                                            _email       text = null,
                                            _name        text = null,
                                            _payload     jsonb = null)
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
                from core.users u
                where u.id = _user_id)
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'User not found.',
        'code', 'NOT_FOUND'
        )
      );
  end if;

  if _username is null
     and _password is null
     and _email is null
     and _name is null
     and _payload is null
  then
    return jsonb_build_object(
      'status', 1,
      'details', jsonb_build_object(
        'message', 'Nothing to update.',
        'code', 'EMPTY_QUERY'
      )
    );
  end if;

  if _username is not null then
    if _username = '' then
      return jsonb_build_object(
        'status', 1,
        'details', jsonb_build_object(
          'message', 'Username cannot be empty.',
          'code', 'INVALID_ARGUMENT'
        )
      );
    elseif length(_username) > 20 then
      return jsonb_build_object(
        'status', 1,
        'details', jsonb_build_object(
          'message', 'Username is out of range.',
          'code', 'INVALID_ARGUMENT'
        )
      );
    end if;
  end if;

  if _password is not null then
    if _password = '' then
      return jsonb_build_object(
        'status', 1,
        'details', jsonb_build_object(
          'message', 'Password cannot be empty.',
          'code', 'INVALID_ARGUMENT'
          )
        );
    elseif length(_password) > 20 then
      return jsonb_build_object(
        'status', 1,
        'details', jsonb_build_object(
          'message', 'Password is out of range.',
          'code', 'INVALID_ARGUMENT'
          )
        );
    end if;
  end if;

  if _email is not null then
    if _email = '' then
      return jsonb_build_object(
        'status', 1,
        'details', jsonb_build_object(
          'message', 'Email cannot be empty.',
          'code', 'INVALID_ARGUMENT'
          )
        );
    elseif _email !~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$' then
      return jsonb_build_object(
        'status', 1,
        'details', jsonb_build_object(
          'message', 'Given email is not an email.',
          'code', 'INVALID_ARGUMENT'
          )
        );
    end if;
  end if;

  _query := case when _username is null then '' else 'username = $1,' end ||
            case when _password is null then '' else 'password = $2,' end ||
            case when _email    is null then '' else 'email = $3,' end ||
            case when _name     is null then '' else 'name = $4,' end ||
            case when _payload  is null then '' else 'payload = $5,' end;

  _sqlstr := format('UPDATE main.users ' ||
                    'SET %s ' ||
                    'WHERE id = $6', left(_query, length(_query) - 1));

  execute _sqlstr
  using _username, _password, _email, _name, _payload, _user_id;

  return jsonb_build_object('status', 0);

exception
  when others then

    return jsonb_build_object('status', -1);

end
$$ language plpgsql volatile security definer;

alter function core.update_user(bigint, bigint, text, text, text, text, jsonb) owner to postgres;
grant execute on function core.update_user(bigint, bigint, text, text, text, text, jsonb) to postgres, web;
revoke all on function core.update_user(bigint, bigint, text, text, text, text, jsonb) from public;