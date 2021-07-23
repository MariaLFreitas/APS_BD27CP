
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


ALTER TYPE public.orders_sales_type_enum OWNER TO postgres;

--
-- Name: products_category_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.products_category_enum AS ENUM (
    'Verduras',
    'Legumes',
    'Proteínas',
    'Bebidas',
    'Carboidratos'
);


ALTER TYPE public.products_category_enum OWNER TO postgres;

--
-- Name: products_unit_buy_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.products_unit_buy_enum AS ENUM (
    'kg',
    'g',
    'l',
    'ml',
    'un',
    'box',
    'bag',
    'ton'
);


ALTER TYPE public.products_unit_buy_enum OWNER TO postgres;

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
-- Name: update_stock_and_unit_price(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_stock_and_unit_price() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        declare
          var_list_offer_id uuid;
        begin
          select lod.id into var_list_offer_id from list_offers_details lod
          join products p on lod.product_id = new.product_id
          join lists l on now() between l.created_at and l.end_date
          where l.type = 'offer';

        IF(TG_OP = 'INSERT') then
          update order_details
          set unit_price = (select lod.unit_price from list_offers_details lod
        join products p on lod.product_id = new.product_id
        join lists l on now() between l.created_at and l.end_date
        limit 1)
          where id = new.id;
        return new;
        end if;
          IF(TG_OP = 'UPDATE' or TG_OP = 'INSERT') THEN
              update list_offers_details
              set quantity_stock = (select quantity_stock from list_offers_details lod where lod.id = var_list_offer_id) - new.quantity
              where id = var_list_offer_id;
          return new;
          END IF;

              IF(TG_OP = 'DELETE') then
                  update list_offers_details
                  set quantity_stock = (select quantity_stock from list_offers_details lod where lod.id = var_list_offer_id) + old.quantity
                  where id = var_list_offer_id;
              return new;
              END IF;
          END;
      $$;


ALTER FUNCTION public.update_stock_and_unit_price() OWNER TO postgres;

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
    price double precision NOT NULL,
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
    cnpj character varying,
    role character varying DEFAULT 'b'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;


ALTER TABLE ONLY public.products
    ADD CONSTRAINT "PK_0806c755e0aca124e67c0cf6d7d" PRIMARY KEY (id);


--
-- Name: order_details PK_278a6e0f21c9db1653e6f406801; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT "PK_278a6e0f21c9db1653e6f406801" PRIMARY KEY (id);


--
-- Name: user_tokens PK_63764db9d9aaa4af33e07b2f4bf; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT "PK_63764db9d9aaa4af33e07b2f4bf" PRIMARY KEY (id);


--
-- Name: orders PK_710e2d4957aa5878dfe94e4ac2f; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "PK_710e2d4957aa5878dfe94e4ac2f" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: delivery_points PK_ee6d715a5812180cd569684ac06; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_points
    ADD CONSTRAINT "PK_ee6d715a5812180cd569684ac06" PRIMARY KEY (id);


--
-- Name: users UQ_230b925048540454c8b4c481e1c; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_230b925048540454c8b4c481e1c" UNIQUE (cpf);


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: users UQ_a7815967475d0accd76feba8a1e; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_a7815967475d0accd76feba8a1e" UNIQUE (cnpj);


--
-- Name: products_name_search; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX products_name_search ON public.products USING btree (name);


--
-- Name: order_details tg_update_stock_and_unit_price; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER tg_update_stock_and_unit_price AFTER INSERT OR DELETE OR UPDATE ON public.order_details FOR EACH ROW EXECUTE PROCEDURE public.update_stock_and_unit_price();


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

