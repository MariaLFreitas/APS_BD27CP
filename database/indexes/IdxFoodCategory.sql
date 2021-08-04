-- index com a finalidade de melhorar o desempenho da pesquisa em itens da categoria Comida --

CREATE INDEX idx_food_category ON products(category) WHERE category='Comida';
