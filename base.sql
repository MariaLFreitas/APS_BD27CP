SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner:
--
CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;
--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner:
--
COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';
--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner:
--
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner:
--
COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';
-- Name: orders_payment_type_enum; Type: TYPE; Schema: public; Owner: postgres
--
CREATE TYPE public.orders_payment_type_enum AS ENUM (
    'credit_card',
    'money',
    'pix',
    'bank_slip',
    'bank_transfer'
);
ALTER TYPE public.orders_payment_type_enum OWNER TO postgres;
-- Name: products_category_enum; Type: TYPE; Schema: public; Owner: postgres
--
CREATE TYPE public.products_category_enum as ENUM(
    'food',
    'clothing',
    'eletronic',
    'object'
);
ALTER TYPE public.products_category_enum OWNER TO postgres;
--
-- Name: products_unit_sale_enum; Type: TYPE; Schema: public; Owner: postgres
--
CREATE TYPE public.products_unit_sale_enum AS ENUM (
    'kg',
    'g',
    'l',
    'ml',
    'un',
    'box',
    'bag',
    'ton'
);
ALTER TYPE public.products_unit_sale_enum OWNER TO postgres;
--
-- Name: update_stock(); Type: FUNCTION; Schema: public; Owner: postgres
--
CREATE FUNCTION public.update_stock() RETURNS trigger LANGUAGE plpgsql AS $$
declare var_stock_id uuid;
begin
select s.id into var_stock_id
from stock s
where s.product_id = new.product_id;
IF(TG_OP = 'INSERT') then
update order_details
set unit_price = (
        select s.price
        from stock s
        where s.id = var_stock_id
        limit 1
    )
where id = new.id;
return new;
end if;
IF(
    TG_OP = 'UPDATE'
    or TG_OP = 'INSERT'
) THEN
update stock
set quantity = (
        select quantity
        from stock s
        where s.id = var_stock_id
    ) - new.quantity
where id = var_stock_id;
return new;
END IF;
IF(TG_OP = 'DELETE') then
update stock
set quantity = (
        select quantity
        from stock s
        where s.id = var_stock_id
    ) + old.quantity
where id = var_stock_id;
return new;
END IF;
END;
$$;
ALTER FUNCTION public.update_stock() OWNER TO postgres;
SET default_tablespace = '';
SET default_with_oids = false;
--
-- Name: delivery_points; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.delivery_points (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    city character varying NOT NULL,
    state character varying NOT NULL,
    suburb character varying NOT NULL,
    street character varying NOT NULL,
    number integer NOT NULL,
    cep character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.delivery_points OWNER TO postgres;
--
-- Name: order_details; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.order_details (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    order_id uuid,
    product_id uuid NOT NULL,
    unit_price double precision DEFAULT 0,
    quantity double precision NOT NULL,
    discount double precision NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.order_details OWNER TO postgres;
--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.orders (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    date timestamp with time zone NOT NULL,
    value double precision NOT NULL,
    payment_type public.orders_payment_type_enum NOT NULL,
    delivery_point_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.orders OWNER TO postgres;
--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.products (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    image character varying,
    unit public.products_unit_sale_enum NOT NULL,
    category public.products_category_enum NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.products OWNER TO postgres;
--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.user_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    token uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.user_tokens OWNER TO postgres;
--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    email character varying,
    phone character varying NOT NULL,
    password character varying,
    cpf character varying NOT NULL,
    role character varying DEFAULT 'b'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.users OWNER TO postgres;
--
-- Name: stock; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.stock (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    product_id uuid NOT NULL,
    price double precision NOT NULL,
    batch character varying,
    quantity double precision NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.stock OWNER TO postgres;
--
-- Name: log_stock; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.log_stock (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_name character varying not null,
    operation CHAR(10) not null,
    old_record text,
    new_record text,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.log_stock OWNER TO postgres;
--
-- Name: log_stock PK_LogStock; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.log_stock
ADD CONSTRAINT "PK_LogStock" PRIMARY KEY (id);
--
-- Name: stock PK_Stock; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.stock
ADD CONSTRAINT "PK_Stock" PRIMARY KEY (id);
--
-- Name: products PK_Products; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.products
ADD CONSTRAINT "PK_Products" PRIMARY KEY (id);
--
-- Name: order_details PK_OrderDetails; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.order_details
ADD CONSTRAINT "PK_OrderDetails" PRIMARY KEY (id);
--
-- Name: user_tokens PK_UserTokens; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.user_tokens
ADD CONSTRAINT "PK_UserTokens" PRIMARY KEY (id);
--
-- Name: orders PK_Orders; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.orders
ADD CONSTRAINT "PK_Orders" PRIMARY KEY (id);
--
-- Name: users PK_Users; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.users
ADD CONSTRAINT "PK_Users" PRIMARY KEY (id);
--
-- Name: delivery_points PK_DeliveryPoints; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.delivery_points
ADD CONSTRAINT "PK_DeliveryPoints" PRIMARY KEY (id);
--
-- Name: users UQ_CPFUsers; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.users
ADD CONSTRAINT "UQ_CPFUsers" UNIQUE (cpf);
--
-- Name: users UQ_EmailUsers; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.users
ADD CONSTRAINT "UQ_EmailUsers" UNIQUE (email);
CREATE INDEX products_name_search ON public.products USING btree (name);
--
-- Name: order_details tg_update_stock; Type: TRIGGER; Schema: public; Owner: postgres
--
CREATE TRIGGER tg_update_stock
AFTER
INSERT
    OR DELETE
    OR
UPDATE ON public.order_details FOR EACH ROW EXECUTE PROCEDURE public.update_stock();
--
-- Name: order_details OrderDetailOrder; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.order_details
ADD CONSTRAINT "OrderDetailOrder" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Name: order_details OrderDetailProduct; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.order_details
ADD CONSTRAINT "OrderDetailProduct" FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Name: orders OrderPoint; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.orders
ADD CONSTRAINT "OrderPoint" FOREIGN KEY (delivery_point_id) REFERENCES public.delivery_points(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Name: orders OrderUser; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.orders
ADD CONSTRAINT "OrderUser" FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Name: user_tokens TokenUser; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.user_tokens
ADD CONSTRAINT "TokenUser" FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- PostgreSQL database dump complete
--
ALTER TABLE ONLY public.stock
ADD CONSTRAINT "ProductStock" FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Name: stock ProductStock; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
CREATE OR REPLACE FUNCTION public.log_stock_trigger() RETURNS TRIGGER AS $log_stock_trigger$ -- VARIAVEL QUE SERÁ UTILIZADA NA TRIGGER
DECLARE var_old_record text;
var_new_record text;
BEGIN -- VERIFICA SE FOI FEITA ALGUMA ALTERAÇÃO (UPDATE)
IF (
    NEW.id IS NOT NULL
    AND OLD.id IS NOT NULL
) THEN --TG_OP = 'UPDATE'
var_old_record = OLD.product_id || ',' || OLD.price || ',' || OLD.batch || ',' || OLD.quantity;
var_new_record = NEW.product_id || ',' || NEW.price || ',' || NEW.batch || ',' || NEW.quantity;
INSERT INTO public.log_stock (
        id,
        user_name,
        operation,
        old_record,
        new_record,
        created_at
    )
VALUES(
        uuid_generate_v4(),
        CURRENT_USER,
        'update',
        var_old_record,
        var_new_record,
        now()
    );
RAISE NOTICE 'update log persist.';
RETURN NEW;
END IF;
-- VERIFICA SE FOI FEITA ALGUMA INSERÇÃO
IF (
    NEW.id IS NOT NULL
    AND OLD.id ISNULL
) THEN --TG_OP = 'INSERT'
var_old_record = NULL;
var_new_record = NEW.product_id || ',' || NEW.price || ',' || NEW.batch || ',' || NEW.quantity;
INSERT INTO public.log_stock (
        id,
        user_name,
        operation,
        old_record,
        new_record,
        created_at
    )
VALUES(
        uuid_generate_v4(),
        CURRENT_USER,
        'insert',
        var_old_record,
        var_new_record,
        now()
    );
RAISE NOTICE 'insert log persist.';
RETURN NEW;
END IF;
--VERIFICA SE FOI FEITA ALGUMA DELEÇÃO
IF (
    NEW.id ISNULL
    AND OLD.id IS NOT NULL
) THEN --TG_OP = 'DELETE'
var_old_record = OLD.product_id || ',' || OLD.price || ',' || OLD.batch || ',' || OLD.quantity;
var_new_record = NULL;
INSERT INTO public.log_stock (
        id,
        user_name,
        operation,
        old_record,
        new_record,
        created_at
    )
VALUES(
        uuid_generate_v4(),
        CURRENT_USER,
        'delete',
        var_old_record,
        var_new_record,
        now()
    );
RAISE NOTICE 'delete log persist.';
RETURN OLD;
END IF;
END;
$log_stock_trigger$ LANGUAGE plpgsql;
CREATE TRIGGER tg_log_stock BEFORE
INSERT
    OR
UPDATE
    OR DELETE ON public.stock FOR EACH ROW EXECUTE PROCEDURE public.log_stock_trigger();
-- garante que não seja cadastrado um produto com o mesmo nome no banco
-- por exemplo: se existir um produto com nome 'mamão' e tentarmos inserir um com o nome 'mamao'
-- irá disparar um erro
CREATE OR REPLACE FUNCTION public.control_duplicate_product_with_same_name_trigger() RETURNS TRIGGER AS $control_duplicate_product_with_same_name_trigger$ BEGIN IF EXISTS(
        SELECT name
        FROM public.products
        WHERE unaccent(name) = unaccent(NEW.name)
    ) THEN RAISE EXCEPTION 'product already registered.';
ELSE RETURN NEW;
END IF;
END;
$control_duplicate_product_with_same_name_trigger$ LANGUAGE plpgsql;
CREATE TRIGGER tg_control_duplicate_product_with_same_name BEFORE
INSERT ON public.products FOR EACH ROW EXECUTE PROCEDURE public.control_duplicate_product_with_same_name_trigger();
-- view materializada para ver o total de estoque  de cada produto ---
CREATE VIEW public.view_products_in_stock as
select p."name",
    s.quantity
FROM public.products p
    join public.stock s on p.id = s.product_id;
-- view materializada para ver o total de vendas de cada produto ---
CREATE MATERIALIZED VIEW public.materialized_view_total_products_sold_report as
select p."name",
    (
        select sum(od2.quantity) as quantity_total_sold
        from public.order_details od2
        where p.id = od2.product_id
    )
from public.products p
    join public.order_details od on p.id = od.product_id;
