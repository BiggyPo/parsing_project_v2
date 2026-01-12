--
-- PostgreSQL database dump
--

\restrict d7p61OSaZ5cl78cMhPbv3JNtuTBioN6FTFgalAf04wRs8oeSRNfoEQLfx4Tp8Eo

-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 15.15 (Debian 15.15-1.pgdg13+1)

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
-- Name: dds; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA dds;


ALTER SCHEMA dds OWNER TO admin;

--
-- Name: dwh; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA dwh;


ALTER SCHEMA dwh OWNER TO admin;

--
-- Name: dwh_dds; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA dwh_dds;


ALTER SCHEMA dwh_dds OWNER TO admin;

--
-- Name: dwh_mart; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA dwh_mart;


ALTER SCHEMA dwh_mart OWNER TO admin;

--
-- Name: dwh_staging; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA dwh_staging;


ALTER SCHEMA dwh_staging OWNER TO admin;

--
-- Name: mart; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA mart;


ALTER SCHEMA mart OWNER TO admin;

--
-- Name: public_dds; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA public_dds;


ALTER SCHEMA public_dds OWNER TO admin;

--
-- Name: public_mart; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA public_mart;


ALTER SCHEMA public_mart OWNER TO admin;

--
-- Name: public_staging; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA public_staging;


ALTER SCHEMA public_staging OWNER TO admin;

--
-- Name: raw; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA raw;


ALTER SCHEMA raw OWNER TO admin;

--
-- Name: staging; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA staging;


ALTER SCHEMA staging OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: dim_metals; Type: TABLE; Schema: dds; Owner: admin
--

CREATE TABLE dds.dim_metals (
    metal_code integer,
    metal_name text
);


ALTER TABLE dds.dim_metals OWNER TO admin;

--
-- Name: fact_metal_prices; Type: TABLE; Schema: dds; Owner: admin
--

CREATE TABLE dds.fact_metal_prices (
    price_id bigint,
    trade_date date,
    metal_code integer,
    metal_name text,
    buy_price_rub numeric(10,2),
    sell_price_rub numeric(10,2),
    loaded_at timestamp without time zone,
    dwh_loaded_at timestamp with time zone
);


ALTER TABLE dds.fact_metal_prices OWNER TO admin;

--
-- Name: dim_metals; Type: TABLE; Schema: dwh_dds; Owner: admin
--

CREATE TABLE dwh_dds.dim_metals (
    metal_code integer,
    metal_name text
);


ALTER TABLE dwh_dds.dim_metals OWNER TO admin;

--
-- Name: fact_metal_prices; Type: TABLE; Schema: dwh_dds; Owner: admin
--

CREATE TABLE dwh_dds.fact_metal_prices (
    price_id bigint,
    trade_date date,
    metal_code integer,
    metal_name text,
    buy_price_rub numeric(10,2),
    sell_price_rub numeric(10,2),
    loaded_at timestamp without time zone,
    dwh_loaded_at timestamp with time zone
);


ALTER TABLE dwh_dds.fact_metal_prices OWNER TO admin;

--
-- Name: metal_prices_analytics; Type: TABLE; Schema: dwh_mart; Owner: admin
--

CREATE TABLE dwh_mart.metal_prices_analytics (
    trade_date date,
    metal_name text,
    buy_price_rub numeric(10,2),
    sell_price_rub numeric(10,2),
    avg_price_rub numeric,
    prev_buy_price numeric,
    prev_sell_price numeric,
    buy_price_change_percent numeric,
    sell_price_change_percent numeric
);


ALTER TABLE dwh_mart.metal_prices_analytics OWNER TO admin;

--
-- Name: cbr_precious_metals; Type: TABLE; Schema: raw; Owner: admin
--

CREATE TABLE raw.cbr_precious_metals (
    id integer NOT NULL,
    record_date date NOT NULL,
    metal_code integer NOT NULL,
    buy_price numeric(10,2),
    sell_price numeric(10,2),
    from_date date,
    to_date date,
    load_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE raw.cbr_precious_metals OWNER TO admin;

--
-- Name: stg_cbr_precious_metals; Type: VIEW; Schema: dwh_staging; Owner: admin
--

CREATE VIEW dwh_staging.stg_cbr_precious_metals AS
 SELECT cbr_precious_metals.record_date AS trade_date,
    cbr_precious_metals.metal_code,
        CASE
            WHEN (cbr_precious_metals.metal_code = 1) THEN 'Золото'::text
            WHEN (cbr_precious_metals.metal_code = 2) THEN 'Серебро'::text
            WHEN (cbr_precious_metals.metal_code = 3) THEN 'Платина'::text
            WHEN (cbr_precious_metals.metal_code = 4) THEN 'Палладий'::text
            ELSE 'Неизвестный металл'::text
        END AS metal_name,
    cbr_precious_metals.buy_price AS buy_price_rub,
    cbr_precious_metals.sell_price AS sell_price_rub,
    cbr_precious_metals.load_timestamp AS loaded_at
   FROM raw.cbr_precious_metals;


ALTER TABLE dwh_staging.stg_cbr_precious_metals OWNER TO admin;

--
-- Name: metal_prices_analytics; Type: TABLE; Schema: mart; Owner: admin
--

CREATE TABLE mart.metal_prices_analytics (
    trade_date date,
    metal_name text,
    buy_price_rub numeric(10,2),
    sell_price_rub numeric(10,2),
    avg_price_rub numeric,
    prev_buy_price numeric,
    prev_sell_price numeric,
    buy_price_change_percent numeric,
    sell_price_change_percent numeric
);


ALTER TABLE mart.metal_prices_analytics OWNER TO admin;

--
-- Name: dim_metals; Type: TABLE; Schema: public_dds; Owner: admin
--

CREATE TABLE public_dds.dim_metals (
    metal_code integer,
    metal_name text
);


ALTER TABLE public_dds.dim_metals OWNER TO admin;

--
-- Name: fact_metal_prices; Type: TABLE; Schema: public_dds; Owner: admin
--

CREATE TABLE public_dds.fact_metal_prices (
    price_id bigint,
    trade_date date,
    metal_code integer,
    metal_name text,
    buy_price_rub numeric(10,2),
    sell_price_rub numeric(10,2),
    loaded_at timestamp without time zone,
    dwh_loaded_at timestamp with time zone
);


ALTER TABLE public_dds.fact_metal_prices OWNER TO admin;

--
-- Name: metal_prices_analytics; Type: TABLE; Schema: public_mart; Owner: admin
--

CREATE TABLE public_mart.metal_prices_analytics (
    trade_date date,
    metal_name text,
    buy_price_rub numeric(10,2),
    sell_price_rub numeric(10,2),
    avg_price_rub numeric,
    prev_buy_price numeric,
    prev_sell_price numeric,
    buy_price_change_percent numeric,
    sell_price_change_percent numeric
);


ALTER TABLE public_mart.metal_prices_analytics OWNER TO admin;

--
-- Name: stg_cbr_precious_metals; Type: VIEW; Schema: public_staging; Owner: admin
--

CREATE VIEW public_staging.stg_cbr_precious_metals AS
 SELECT cbr_precious_metals.record_date AS trade_date,
    cbr_precious_metals.metal_code,
        CASE
            WHEN (cbr_precious_metals.metal_code = 1) THEN 'Золото'::text
            WHEN (cbr_precious_metals.metal_code = 2) THEN 'Серебро'::text
            WHEN (cbr_precious_metals.metal_code = 3) THEN 'Платина'::text
            WHEN (cbr_precious_metals.metal_code = 4) THEN 'Палладий'::text
            ELSE 'Неизвестный металл'::text
        END AS metal_name,
    cbr_precious_metals.buy_price AS buy_price_rub,
    cbr_precious_metals.sell_price AS sell_price_rub,
    cbr_precious_metals.load_timestamp AS loaded_at
   FROM raw.cbr_precious_metals;


ALTER TABLE public_staging.stg_cbr_precious_metals OWNER TO admin;

--
-- Name: cbr_meta; Type: TABLE; Schema: raw; Owner: admin
--

CREATE TABLE raw.cbr_meta (
    key character varying(50) NOT NULL,
    value character varying(255),
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE raw.cbr_meta OWNER TO admin;

--
-- Name: cbr_precious_metals_id_seq; Type: SEQUENCE; Schema: raw; Owner: admin
--

CREATE SEQUENCE raw.cbr_precious_metals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE raw.cbr_precious_metals_id_seq OWNER TO admin;

--
-- Name: cbr_precious_metals_id_seq; Type: SEQUENCE OWNED BY; Schema: raw; Owner: admin
--

ALTER SEQUENCE raw.cbr_precious_metals_id_seq OWNED BY raw.cbr_precious_metals.id;


--
-- Name: load_logs; Type: TABLE; Schema: raw; Owner: admin
--

CREATE TABLE raw.load_logs (
    id integer NOT NULL,
    load_date date DEFAULT CURRENT_DATE,
    records_added integer,
    status character varying(20),
    error_message text,
    loaded_at timestamp without time zone DEFAULT now()
);


ALTER TABLE raw.load_logs OWNER TO admin;

--
-- Name: load_logs_id_seq; Type: SEQUENCE; Schema: raw; Owner: admin
--

CREATE SEQUENCE raw.load_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE raw.load_logs_id_seq OWNER TO admin;

--
-- Name: load_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: raw; Owner: admin
--

ALTER SEQUENCE raw.load_logs_id_seq OWNED BY raw.load_logs.id;


--
-- Name: stg_cbr_precious_metals; Type: VIEW; Schema: staging; Owner: admin
--

CREATE VIEW staging.stg_cbr_precious_metals AS
 WITH ranked_data AS (
         SELECT cbr_precious_metals.id,
            cbr_precious_metals.record_date AS trade_date,
            cbr_precious_metals.metal_code,
            cbr_precious_metals.buy_price AS buy_price_rub,
            cbr_precious_metals.sell_price AS sell_price_rub,
            cbr_precious_metals.from_date AS valid_from,
            cbr_precious_metals.to_date AS valid_to,
            cbr_precious_metals.load_timestamp AS loaded_at,
            row_number() OVER (PARTITION BY cbr_precious_metals.record_date, cbr_precious_metals.metal_code ORDER BY cbr_precious_metals.load_timestamp DESC) AS rn
           FROM raw.cbr_precious_metals
          WHERE ((cbr_precious_metals.record_date IS NOT NULL) AND (cbr_precious_metals.metal_code IS NOT NULL) AND (cbr_precious_metals.buy_price IS NOT NULL))
        )
 SELECT ranked_data.trade_date,
    ranked_data.metal_code,
        CASE
            WHEN (ranked_data.metal_code = 1) THEN 'Золото'::text
            WHEN (ranked_data.metal_code = 2) THEN 'Серебро'::text
            WHEN (ranked_data.metal_code = 3) THEN 'Платина'::text
            WHEN (ranked_data.metal_code = 4) THEN 'Палладий'::text
            ELSE 'Неизвестный металл'::text
        END AS metal_name,
    ranked_data.buy_price_rub,
    ranked_data.sell_price_rub,
    ranked_data.valid_from,
    ranked_data.valid_to,
    ranked_data.loaded_at
   FROM ranked_data
  WHERE (ranked_data.rn = 1);


ALTER TABLE staging.stg_cbr_precious_metals OWNER TO admin;

--
-- Name: cbr_precious_metals id; Type: DEFAULT; Schema: raw; Owner: admin
--

ALTER TABLE ONLY raw.cbr_precious_metals ALTER COLUMN id SET DEFAULT nextval('raw.cbr_precious_metals_id_seq'::regclass);


--
-- Name: load_logs id; Type: DEFAULT; Schema: raw; Owner: admin
--

ALTER TABLE ONLY raw.load_logs ALTER COLUMN id SET DEFAULT nextval('raw.load_logs_id_seq'::regclass);


--
-- Name: cbr_meta cbr_meta_pkey; Type: CONSTRAINT; Schema: raw; Owner: admin
--

ALTER TABLE ONLY raw.cbr_meta
    ADD CONSTRAINT cbr_meta_pkey PRIMARY KEY (key);


--
-- Name: cbr_precious_metals cbr_precious_metals_pkey; Type: CONSTRAINT; Schema: raw; Owner: admin
--

ALTER TABLE ONLY raw.cbr_precious_metals
    ADD CONSTRAINT cbr_precious_metals_pkey PRIMARY KEY (id);


--
-- Name: load_logs load_logs_pkey; Type: CONSTRAINT; Schema: raw; Owner: admin
--

ALTER TABLE ONLY raw.load_logs
    ADD CONSTRAINT load_logs_pkey PRIMARY KEY (id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO admin;


--
-- Name: SCHEMA staging; Type: ACL; Schema: -; Owner: admin
--

GRANT USAGE ON SCHEMA staging TO monitor;


--
-- PostgreSQL database dump complete
--

\unrestrict d7p61OSaZ5cl78cMhPbv3JNtuTBioN6FTFgalAf04wRs8oeSRNfoEQLfx4Tp8Eo

