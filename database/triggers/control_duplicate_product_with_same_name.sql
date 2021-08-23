-- garante que não seja cadastrado um produto com o mesmo nome no banco
-- por exemplo: se existir um produto com nome 'mamão' e tentarmos inserir um com o nome 'mamao'
-- irá disparar um erro
CREATE OR REPLACE FUNCTION public.control_duplicate_product_with_same_name_trigger() RETURNS TRIGGER AS $control_duplicate_product_with_same_name_trigger$
BEGIN
	IF EXISTS(SELECT name FROM public.products WHERE unaccent(name) = unaccent(NEW.name)) THEN
		RAISE EXCEPTION 'product already registered.';
	ELSE
		RETURN NEW;
	END IF;
END;
$control_duplicate_product_with_same_name_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER tg_control_duplicate_product_with_same_name BEFORE INSERT ON public.products
FOR EACH ROW EXECUTE PROCEDURE public.control_duplicate_product_with_same_name_trigger(); 
