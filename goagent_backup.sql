--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Homebrew)
-- Dumped by pg_dump version 14.18 (Homebrew)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: asset; Type: TABLE; Schema: public; Owner: goagent
--

CREATE TABLE public.asset (
    id integer NOT NULL,
    category character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    hostname character varying(100) NOT NULL,
    ip character varying(45) NOT NULL,
    manager character varying(50)
);


ALTER TABLE public.asset OWNER TO goagent;

--
-- Name: asset_id_seq; Type: SEQUENCE; Schema: public; Owner: goagent
--

CREATE SEQUENCE public.asset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.asset_id_seq OWNER TO goagent;

--
-- Name: asset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goagent
--

ALTER SEQUENCE public.asset_id_seq OWNED BY public.asset.id;


--
-- Name: asset id; Type: DEFAULT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.asset ALTER COLUMN id SET DEFAULT nextval('public.asset_id_seq'::regclass);


--
-- Data for Name: asset; Type: TABLE DATA; Schema: public; Owner: goagent
--

COPY public.asset (id, category, name, hostname, ip, manager) FROM stdin;
1	server	웹서버01	web01	192.168.0.10	홍길동
\.


--
-- Name: asset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: goagent
--

SELECT pg_catalog.setval('public.asset_id_seq', 1, true);


--
-- Name: asset asset_pkey; Type: CONSTRAINT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

