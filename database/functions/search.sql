-- Função que realiza uma pesquisa entre dois textos sem considerar letras maíusculas e acentos
CREATE OR REPLACE FUNCTION public.search(texto varchar) returns VARCHAR as $$
        BEGIN
                RETURN upper(unaccent(texto));
        END;
$$
LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT; -- Retorna NULL caso a entrada seja NULL
