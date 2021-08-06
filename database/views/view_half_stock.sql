-- view para selecionar produtos com menos de 75% do estoque máximo (100k)

CREATE or REPLACE VIEW view_products_half_stock AS
SELECT p.name AS Produto, s.quantity AS Quantidade
FROM products p JOIN stock s ON s.product_id=p.id
WHERE s.quantity<25000
ORDER BY s.quantity ASC;

select * from view_products_half_stock
