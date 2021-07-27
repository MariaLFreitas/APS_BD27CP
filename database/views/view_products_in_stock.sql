CREATE VIEW view_products_in_stock as
select p."name", s.quantity FROM public.products p join public.stock s on p.id = s.product_id;

select * from public.view_products_in_stock;
