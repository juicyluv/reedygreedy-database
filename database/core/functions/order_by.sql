create or replace function core.order_by(_sort text[])
returns text as $$
declare
  _element text;
  _sqlstr  text;
begin
  if _sort is null or array_length(_sort, 1) = 0 then
    return '';
  end if;

  _sqlstr := 'ORDER BY ';

  foreach _element in array _sort loop
    _sqlstr = _sqlstr ||
      case when _sqlstr != ''
      then ', ' else '' end ||

      quote_ident(trim(both from _element)) ||

      case when left(_element, 1) not in ('+', '-') then
        _element
      else right(_element, length(_element) - 1) end ||

      case when left(_element, 1) = '-' then
        ' ASC'
      else ' DESC' end;
  end loop;
end;
$$ language plpgsql stable security definer;