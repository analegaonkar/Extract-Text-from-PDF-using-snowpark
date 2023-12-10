--parse out specific values as fields like balance due, item name, item quantity, and more
create or replace view v_parsed_pdf_files as (
with items_to_array as (
    select parsed_text, 
    regexp_substr_all(
      substr(
           regexp_substr(parsed_text, 'Amount\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)')
           , 8)
      , '[^\n]+\n[^\n]+\n[^\n]+\n[^\n]+'
      ) as items     
     from parsed_pdf
)
, parsed_pdf_fields as (
    select
        substr(regexp_substr(parsed_text, '# [0-9]+'), 2)::int as invoice_number
        , to_number(substr(regexp_substr(parsed_text, '\\$[^A-Z]+'), 2), 10, 2) as balance_due
        , substr(
            regexp_substr(parsed_text, '[0-9]+\n[^\n]+')
                , len(regexp_substr(parsed_text, '# [0-9]+'))
            ) as invoice_from
        , to_date(regexp_substr(parsed_text, '([A-Za-z]+ [0-9]+, [0-9]+)'), 'mon dd, yyyy') as invoice_date
        , i.value::string as line_item
        , parsed_text
    from
        items_to_array
        , lateral flatten(items_to_array.items) i
)
select
    invoice_number
    , balance_due
    , invoice_from
    , invoice_date
    , regexp_substr(line_item, '\n[0-9]+\n')::integer as item_quantity
    , to_number(ltrim(regexp_substr(line_item, '\\$[^\n]+')::string, '$'), 10, 2) as item_unit_cost
    , regexp_substr(line_item, '[^\n]+', 1, 1)::string as item_name
    , to_number(ltrim(regexp_substr(line_item, '\\$[^\n]+', 1, 2)::string, '$'), 10, 2) as item_total_cost
from parsed_pdf_fields
);

--select * from v_parsed_pdf_files