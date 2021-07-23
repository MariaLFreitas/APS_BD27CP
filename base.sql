--
-- PostgreSQL database dump
--

-- Dumped from database version 11.12
-- Dumped by pg_dump version 11.12

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


--
-- Name: lists_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.lists_status_enum AS ENUM (
    'unavailable',
    'available',
    'created'
);


ALTER TYPE public.lists_status_enum OWNER TO postgres;

--
-- Name: lists_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.lists_type_enum AS ENUM (
    'offer',
    'producer'
);


ALTER TYPE public.lists_type_enum OWNER TO postgres;

--
-- Name: orders_payment_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.orders_payment_status_enum AS ENUM (
    'processing',
    'awaiting_payment',
    'canceled',
    'expired',
    'paid'
);


ALTER TYPE public.orders_payment_status_enum OWNER TO postgres;

--
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

--
-- Name: orders_sales_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.orders_sales_type_enum AS ENUM (
    'wholesale',
    'retail'
);


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
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.delivery_points OWNER TO postgres;

--
-- Name: list_offers_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.list_offers_details (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    list_id uuid NOT NULL,
    product_id uuid NOT NULL,
    quantity_total double precision NOT NULL,
    quantity_stock double precision NOT NULL,
    unit_price double precision NOT NULL,
    sale_price double precision NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.list_offers_details OWNER TO postgres;

--
-- Name: list_producers_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.list_producers_details (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    list_id uuid NOT NULL,
    product_id uuid NOT NULL,
    due_date timestamp with time zone NOT NULL,
    lot character varying,
    quantity integer NOT NULL,
    unit_price double precision NOT NULL,
    discount double precision NOT NULL,
    total_price double precision NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.list_producers_details OWNER TO postgres;

--
-- Name: lists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lists (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    type public.lists_type_enum NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    status public.lists_status_enum NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.lists OWNER TO postgres;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


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
    final_value double precision NOT NULL,
    payment_type public.orders_payment_type_enum NOT NULL,
    payment_status public.orders_payment_status_enum NOT NULL,
    sales_type public.orders_sales_type_enum NOT NULL,
    delivery_point_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    list_id uuid
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    image character varying,
    nutritional_information text,
    observation text,
    cost_price double precision NOT NULL,
    organic boolean DEFAULT true NOT NULL,
    unit_sale public.products_unit_sale_enum NOT NULL,
    category public.products_category_enum NOT NULL,
    unit_buy public.products_unit_buy_enum NOT NULL,
    fraction_buy double precision NOT NULL,
    fraction_sale double precision NOT NULL,
    highlights boolean DEFAULT false NOT NULL,
    sale_price double precision NOT NULL,
    wholesale_price double precision,
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

--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Data for Name: delivery_points; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delivery_points (id, city, state, suburb, street, number, cep, latitude, longitude, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: list_offers_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.list_offers_details (id, list_id, product_id, quantity_total, quantity_stock, unit_price, sale_price, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: list_producers_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.list_producers_details (id, list_id, product_id, due_date, lot, quantity, unit_price, discount, total_price, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: lists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lists (id, user_id, type, start_date, end_date, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, "timestamp", name) FROM stdin;
1	1605228554307	CreateUser1605228554307
2	1609379802515	createPoints1609379802515
3	1609879520820	createProduct1609879520820
4	1609879520822	createOrder1609879520822
5	1609883515226	createOrderDetail1609883515226
6	1610039989596	createWeeklyList1610039989596
7	1610039989598	createProducersListDetail1610039989598
8	1610310641444	createOffersListDetails1610310641444
9	1612107703467	CreateUserTokens1612107703467
10	1620694873624	CreateTriggers1620694873624
11	1620783672256	addRelationOrderWithList1620783672256
\.


--
-- Data for Name: order_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_details (id, order_id, product_id, unit_price, quantity, discount, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, date, value, final_value, payment_type, payment_status, sales_type, delivery_point_id, user_id, created_at, updated_at, list_id) FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, name, image, nutritional_information, observation, cost_price, organic, unit_sale, category, unit_buy, fraction_buy, fraction_sale, highlights, sale_price, wholesale_price, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_tokens (id, token, user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, phone, password, cpf, cnpj, role, created_at, updated_at) FROM stdin;
836dbbb0-5af6-40bc-8b8f-c96b94609181	admin	admin@admin.com	46999999999	$2a$08$NQdYygarnEitwZG62.Kr7OSdy0nhgPlVE1qa.fC7xmTJ8uj4Q12ai	111111		r	2021-07-18 22:17:24.214705	2021-07-18 22:17:24.214705
457b4485-6399-4f50-929f-8428004eb5a0	Angela	Raoul80@hotmail.com	83967106000	$2a$08$xjK2rbPATd2pETV/GX7mPeOM6r9KgipjaS8QHWlZeAu2rPflTwzsm	104.136.238.183	198.83.196.249	p	2021-07-18 22:20:49.01706	2021-07-18 22:20:49.01706
\.


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 11, true);


--
-- Name: products PK_0806c755e0aca124e67c0cf6d7d; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT "PK_0806c755e0aca124e67c0cf6d7d" PRIMARY KEY (id);


--
-- Name: list_offers_details PK_0e7a1d2a40477c05e0957095015; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_offers_details
    ADD CONSTRAINT "PK_0e7a1d2a40477c05e0957095015" PRIMARY KEY (id);


--
-- Name: lists PK_268b525e9a6dd04d0685cb2aaaa; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT "PK_268b525e9a6dd04d0685cb2aaaa" PRIMARY KEY (id);


--
-- Name: order_details PK_278a6e0f21c9db1653e6f406801; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT "PK_278a6e0f21c9db1653e6f406801" PRIMARY KEY (id);


--
-- Name: list_producers_details PK_5cf219df9b28808626b14818ab2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_producers_details
    ADD CONSTRAINT "PK_5cf219df9b28808626b14818ab2" PRIMARY KEY (id);


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
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


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
-- Name: list_offers_details ListOffersDetailList; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_offers_details
    ADD CONSTRAINT "ListOffersDetailList" FOREIGN KEY (list_id) REFERENCES public.lists(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: list_offers_details ListOffersDetailProduct; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_offers_details
    ADD CONSTRAINT "ListOffersDetailProduct" FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: list_producers_details ListProducersDetailList; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_producers_details
    ADD CONSTRAINT "ListProducersDetailList" FOREIGN KEY (list_id) REFERENCES public.lists(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: list_producers_details ListProducersDetailProduct; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_producers_details
    ADD CONSTRAINT "ListProducersDetailProduct" FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lists ListUser; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT "ListUser" FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: orders OrderList; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT "OrderList" FOREIGN KEY (list_id) REFERENCES public.lists(id) ON UPDATE CASCADE ON DELETE CASCADE;


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

