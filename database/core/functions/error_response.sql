create or replace function core.error_response(_code       text,
                                               _message    text,
                                               _error_type text,
                                               _min        float = null,
                                               _max        float = null)
  returns jsonb as $$
begin
  return jsonb_build_object(
    'status', 1,
    'details', jsonb_build_object(
      'code', _code,
      'message', _message,
      'error_type', _error_type,
      'min', _min,
      'max', _max
      )
    );
end;
$$ language plpgsql stable security definer;

alter function core.error_response(text, text, text, float, float) owner to postgres;
grant execute on function core.error_response(text, text, text, float, float) to postgres;
revoke all on function core.error_response(text, text, text, float, float) from public;