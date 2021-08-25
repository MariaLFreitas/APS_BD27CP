
CREATE INDEX idxNotFood ON products (category)
WHERE NOT (category = 'food');

explain analyze select * from products p  where category = 'clothing';

-- Suponhamos que temos uma tabela com muitos registros onde a categoria é do tipo food
-- logo podemos particionar isso com um index que exclua os registros do tipo food;
