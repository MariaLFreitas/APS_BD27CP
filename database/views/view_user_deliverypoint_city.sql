-- view para mostrar em qual cidade o usuário retira seu pedido

CREATE or REPLACE VIEW view_users_deliverypoint_city AS
select u.name as Nome, d.city as Cidade
from users u join orders o ON u.id=o.user_id join delivery_points d ON o.delivery_point_id=d.id
order by d.city ASC, u.name ASC;

SELECT * from view_users_deliverypoint_city

