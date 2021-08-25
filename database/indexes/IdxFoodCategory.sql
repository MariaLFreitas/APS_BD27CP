-- index com a finalidade de melhorar o desempenho da pesquisa em itens

CREATE INDEX idx_food_category ON products(category)

create index idx_category on products using gin (category);
