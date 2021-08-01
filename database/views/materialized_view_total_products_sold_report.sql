CREATE MATERIALIZED VIEW public.materialized_view_total_products_sold_report as
select p."name",
    (
        select sum(od2.quantity) as quantity_total_sold
        from public.order_details od2
        where p.id = od2.product_id
    )
from public.products p
    join public.order_details od on p.id = od.product_id;

-- testar a view
select *
from public.materialized_view_total_products_sold_report;
