--What are the most purchased items based on quantity?
select
    sum(item_quantity)
    , item_name
from v_parsed_pdf_files
group by item_name
order by sum(item_quantity) desc
limit 10;
--What are the items on which the most money was spent?
select
    sum(item_total_cost)
    , item_name
from v_parsed_pdf_files
group by item_name
order by sum(item_total_cost) desc
limit 10;
--Costs by Month
select
    sum(item_total_cost)
    , date_trunc('month', invoice_date) as month
from v_parsed_pdf_files
group by date_trunc('month', invoice_date);