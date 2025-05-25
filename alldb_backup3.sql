--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE diteogae;
ALTER ROLE diteogae WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;
CREATE ROLE goagent;
ALTER ROLE goagent WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:rN4N60483BbdpwCVpDDRDA==$nHtJ2KugttVf0kjPall6INM3mQAAysEv69qDEkWJ358=:4hYcO5OK2Ric2xyTSdMb3gyB+FhkTc6oKFGB1G/mQsM=';
CREATE ROLE myuser;
ALTER ROLE myuser WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:gC7i+z0yqjFmMfzXakWoxg==$mVtKT5o0QND4AsoCSUQYjwP5QAZ1pai+gTctO5/GYGE=:ByTR3N3dYp/Y7RWIc/XDcc1v3+WWCNMljCFhPL0rAkk=';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;
CREATE ROLE secuser;
ALTER ROLE secuser WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:mr+0rsyINouOxmR8Ec17CQ==$IqPb4sxvayjm1EVpS59rfw5OjEhBz/ZtN/5GJWNh1yw=:ZCNCv2Uqkx7hvf7AYHS0uUSilxkfFxblFuKWUicBENw=';






--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

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

--
-- PostgreSQL database dump complete
--

--
-- Database "diteogae" dump
--

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

--
-- Name: diteogae; Type: DATABASE; Schema: -; Owner: diteogae
--

CREATE DATABASE diteogae WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'C';


ALTER DATABASE diteogae OWNER TO diteogae;

\connect diteogae

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
-- PostgreSQL database dump complete
--

--
-- Database "evaluation_db" dump
--

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

--
-- Name: evaluation_db; Type: DATABASE; Schema: -; Owner: myuser
--

CREATE DATABASE evaluation_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'C';


ALTER DATABASE evaluation_db OWNER TO myuser;

\connect evaluation_db

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
-- Name: evaluation_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.evaluation_items (
    item_id text NOT NULL,
    item_name text NOT NULL
);


ALTER TABLE public.evaluation_items OWNER TO postgres;

--
-- Name: evaluation_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.evaluation_results (
    id integer NOT NULL,
    host_name text NOT NULL,
    item_id text NOT NULL,
    item_name text NOT NULL,
    result text DEFAULT '미점검'::text,
    exception_checked boolean DEFAULT false,
    detail text,
    evaluated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    checked_by_agent boolean DEFAULT false,
    last_checked_at timestamp without time zone,
    is_target boolean DEFAULT false,
    CONSTRAINT evaluation_results_result_check CHECK ((result = ANY (ARRAY['양호'::text, '취약'::text, '미점검'::text])))
);


ALTER TABLE public.evaluation_results OWNER TO postgres;

--
-- Name: evaluation_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.evaluation_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.evaluation_results_id_seq OWNER TO postgres;

--
-- Name: evaluation_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.evaluation_results_id_seq OWNED BY public.evaluation_results.id;


--
-- Name: new_template; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.new_template (
    id integer NOT NULL,
    host_name text NOT NULL,
    item_id text NOT NULL,
    item_name text NOT NULL,
    result text DEFAULT '미점검'::text,
    detail text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT new_template_result_check CHECK ((result = ANY (ARRAY['양호'::text, '취약'::text, '미점검'::text])))
);


ALTER TABLE public.new_template OWNER TO postgres;

--
-- Name: new_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.new_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.new_template_id_seq OWNER TO postgres;

--
-- Name: new_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.new_template_id_seq OWNED BY public.new_template.id;


--
-- Name: evaluation_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluation_results ALTER COLUMN id SET DEFAULT nextval('public.evaluation_results_id_seq'::regclass);


--
-- Name: new_template id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.new_template ALTER COLUMN id SET DEFAULT nextval('public.new_template_id_seq'::regclass);


--
-- Data for Name: evaluation_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.evaluation_items (item_id, item_name) FROM stdin;
snmp-001	안전한 네트워크 모니터링 서비스 사용
smtp-001	불필요한 SMTP 서비스 실행
ftp-001	FTP 접근제어 설정 여부
\.


--
-- Data for Name: evaluation_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.evaluation_results (id, host_name, item_id, item_name, result, exception_checked, detail, evaluated_at, checked_by_agent, last_checked_at, is_target) FROM stdin;
94	ggg111	ftp-001	FTP 접근제어 설정 여부	미점검	f	\N	2025-05-17 12:20:55.328138	f	\N	f
69	newme	snmp-001	안전한 네트워크 모니터링 서비스 사용	양호	f	SNMP v3 및 authPriv 설정 확인됨	2025-05-17 11:56:02.571061	t	2025-05-17 12:27:36.788487	f
97	123	snmp-001	안전한 네트워크 모니터링 서비스 사용	양호	f	SNMP v3 및 authPriv 설정 확인됨	2025-05-17 12:27:33.824265	t	2025-05-17 12:32:59.219066	f
102	test1234	snmp-001	안전한 네트워크 모니터링 서비스 사용	미점검	f	\N	2025-05-19 06:39:59.010134	f	\N	f
105	test12341	snmp-001	안전한 네트워크 모니터링 서비스 사용	미점검	f	\N	2025-05-19 06:47:23.426405	f	\N	f
107	aaaa111	snmp-001	안전한 네트워크 모니터링 서비스 사용	미점검	f	\N	2025-05-19 06:50:44.940903	f	\N	f
112	aaaa111	smtp-001	불필요한 SMTP 서비스 실행	미점검	f	\N	2025-05-19 06:54:24.846591	f	\N	f
115	ggggggg	snmp-001	안전한 네트워크 모니터링 서비스 사용	미점검	f	\N	2025-05-19 06:56:53.151287	f	\N	t
100	pauline	snmp-001	안전한 네트워크 모니터링 서비스 사용	양호	f	SNMP v3 및 authPriv 설정 확인됨	2025-05-17 12:32:55.634741	t	2025-05-19 06:56:56.011362	f
75	abcabc	snmp-001	안전한 네트워크 모니터링 서비스 사용	양호	f	SNMP v3 및 authPriv 설정 확인됨	2025-05-17 12:05:33.000422	t	2025-05-17 12:06:13.797155	f
79	gggg	snmp-001	안전한 네트워크 모니터링 서비스 사용	양호	f	SNMP v3 및 authPriv 설정 확인됨	2025-05-17 12:05:45.540356	t	2025-05-17 12:06:33.918324	f
1	ubuntu-server-01	smtp-001	불필요한 SMTP 서비스 실행	취약	f	25번 포트에서 SMTP 서비스가 실행 중입니다.	2025-05-17 10:37:08.338144	f	\N	f
47	test123	smtp-001	SMTP 서비스 점검	미점검	f	\N	2025-05-17 10:59:56.845682	f	\N	f
46	test123	snmp-001	SNMP 서비스 점검	취약	f	\N	2025-05-17 11:01:49.122076	f	\N	f
48	test2	snmp-001	SNMP 서비스 점검	미점검	f	\N	2025-05-17 11:05:30.977637	f	\N	f
53	test2	smtp-001	SMTP 서비스 점검	미점검	f	\N	2025-05-17 11:13:48.976287	f	\N	f
59	test1111	snmp-001	SNMP 서비스 점검	미점검	f	\N	2025-05-17 11:26:46.856187	f	\N	f
49	ubuntu-server-01	snmp-001	안전한 네트워크 모니터링 서비스 사용	양호	f	SNMP v3 사용 및 authPriv 설정 확인됨	2025-05-17 11:30:34.061444	t	2025-05-17 11:30:34.061444	f
67	ttttttttt	snmp-001	안전한 네트워크 모니터링 서비스 사용	미점검	f	\N	2025-05-17 11:54:49.518476	f	\N	f
63	ㅎㅎㅎㅎ	snmp-001	SNMP 서비스 점검	양호	t	SNMP v3 및 authPriv 설정 확인됨	2025-05-17 11:48:39.837984	t	2025-05-17 12:04:55.507334	f
84	uuu	snmp-001	안전한 네트워크 모니터링 서비스 사용	미점검	f	\N	2025-05-17 12:16:30.410813	f	\N	f
89	ggg111	snmp-001	안전한 네트워크 모니터링 서비스 사용	미점검	f	\N	2025-05-17 12:19:36.992	f	\N	f
\.


--
-- Data for Name: new_template; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.new_template (id, host_name, item_id, item_name, result, detail, created_at) FROM stdin;
\.


--
-- Name: evaluation_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.evaluation_results_id_seq', 116, true);


--
-- Name: new_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.new_template_id_seq', 1, false);


--
-- Name: evaluation_items evaluation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluation_items
    ADD CONSTRAINT evaluation_items_pkey PRIMARY KEY (item_id);


--
-- Name: evaluation_results evaluation_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluation_results
    ADD CONSTRAINT evaluation_results_pkey PRIMARY KEY (id);


--
-- Name: new_template new_template_host_name_item_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.new_template
    ADD CONSTRAINT new_template_host_name_item_id_key UNIQUE (host_name, item_id);


--
-- Name: new_template new_template_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.new_template
    ADD CONSTRAINT new_template_pkey PRIMARY KEY (id);


--
-- Name: evaluation_results unique_host_item; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evaluation_results
    ADD CONSTRAINT unique_host_item UNIQUE (host_name, item_id);


--
-- Name: DATABASE evaluation_db; Type: ACL; Schema: -; Owner: myuser
--

GRANT CONNECT ON DATABASE evaluation_db TO goagent;
GRANT CONNECT ON DATABASE evaluation_db TO secuser;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: diteogae
--

GRANT ALL ON SCHEMA public TO secuser;


--
-- Name: TABLE evaluation_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.evaluation_items TO secuser;


--
-- Name: TABLE evaluation_results; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.evaluation_results TO secuser;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.evaluation_results TO goagent;


--
-- Name: SEQUENCE evaluation_results_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.evaluation_results_id_seq TO secuser;


--
-- PostgreSQL database dump complete
--

--
-- Database "goagent" dump
--

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

--
-- Name: goagent; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE goagent WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'C';


ALTER DATABASE goagent OWNER TO postgres;

\connect goagent

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
-- Name: assets; Type: TABLE; Schema: public; Owner: goagent
--

CREATE TABLE public.assets (
    id integer NOT NULL,
    server_name text NOT NULL,
    host_name text NOT NULL,
    ip text NOT NULL,
    registered_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.assets OWNER TO goagent;

--
-- Name: assets_id_seq; Type: SEQUENCE; Schema: public; Owner: goagent
--

CREATE SEQUENCE public.assets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.assets_id_seq OWNER TO goagent;

--
-- Name: assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goagent
--

ALTER SEQUENCE public.assets_id_seq OWNED BY public.assets.id;


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    log_id integer NOT NULL,
    user_id integer,
    action text,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- Name: audit_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_log_log_id_seq OWNER TO postgres;

--
-- Name: audit_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_log_log_id_seq OWNED BY public.audit_log.log_id;


--
-- Name: evaluation_results; Type: TABLE; Schema: public; Owner: goagent
--

CREATE TABLE public.evaluation_results (
    id integer NOT NULL,
    templateid character varying(50),
    templatename text,
    item_id character varying(20),
    item_name text,
    result text,
    detail text,
    risk_level character varying(10),
    risk_score integer,
    vuln_score integer,
    risk_grade integer,
    host_name text,
    ip text,
    assessyn boolean,
    checked_by_agent boolean DEFAULT false,
    last_checked_at timestamp without time zone,
    service_status text
);


ALTER TABLE public.evaluation_results OWNER TO goagent;

--
-- Name: evaluation_results_id_seq; Type: SEQUENCE; Schema: public; Owner: goagent
--

CREATE SEQUENCE public.evaluation_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.evaluation_results_id_seq OWNER TO goagent;

--
-- Name: evaluation_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goagent
--

ALTER SEQUENCE public.evaluation_results_id_seq OWNED BY public.evaluation_results.id;


--
-- Name: template; Type: TABLE; Schema: public; Owner: diteogae
--

CREATE TABLE public.template (
    id integer NOT NULL,
    vulnid character varying(20),
    servername character varying(100),
    hostname character varying(100),
    ip character varying(45),
    vulname character varying(200),
    result character varying(20),
    assessyn character(1),
    createtime timestamp without time zone DEFAULT now(),
    templateid character varying(50),
    templatename character varying(100),
    risk_level character varying(10),
    risk_score integer,
    asset_score integer,
    vuln_score integer
);


ALTER TABLE public.template OWNER TO diteogae;

--
-- Name: template_id_seq; Type: SEQUENCE; Schema: public; Owner: diteogae
--

CREATE SEQUENCE public.template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.template_id_seq OWNER TO diteogae;

--
-- Name: template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diteogae
--

ALTER SEQUENCE public.template_id_seq OWNED BY public.template.id;


--
-- Name: template_items; Type: TABLE; Schema: public; Owner: goagent
--

CREATE TABLE public.template_items (
    item_id text NOT NULL,
    item_name text,
    risk_level text,
    risk_score integer,
    vuln_score integer,
    vul_info text,
    risk_grade integer
);


ALTER TABLE public.template_items OWNER TO goagent;

--
-- Name: templatesum; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.templatesum (
    id integer NOT NULL,
    templateid character varying(50) NOT NULL,
    assess_score integer DEFAULT 0,
    assess_vuln integer DEFAULT 0,
    assess_date timestamp without time zone DEFAULT now(),
    asess_good integer DEFAULT 0
);


ALTER TABLE public.templatesum OWNER TO postgres;

--
-- Name: templatesum_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.templatesum_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.templatesum_id_seq OWNER TO postgres;

--
-- Name: templatesum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.templatesum_id_seq OWNED BY public.templatesum.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username text,
    password_hash text,
    role text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: vulnerability; Type: TABLE; Schema: public; Owner: diteogae
--

CREATE TABLE public.vulnerability (
    vul_id character varying(20) NOT NULL,
    vul_name text NOT NULL,
    vul_info text,
    risk_level character varying(10),
    risk_score integer,
    vuln_score integer,
    risk_grade integer,
    target_type character varying(50)
);


ALTER TABLE public.vulnerability OWNER TO diteogae;

--
-- Name: assets id; Type: DEFAULT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.assets ALTER COLUMN id SET DEFAULT nextval('public.assets_id_seq'::regclass);


--
-- Name: audit_log log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN log_id SET DEFAULT nextval('public.audit_log_log_id_seq'::regclass);


--
-- Name: evaluation_results id; Type: DEFAULT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.evaluation_results ALTER COLUMN id SET DEFAULT nextval('public.evaluation_results_id_seq'::regclass);


--
-- Name: template id; Type: DEFAULT; Schema: public; Owner: diteogae
--

ALTER TABLE ONLY public.template ALTER COLUMN id SET DEFAULT nextval('public.template_id_seq'::regclass);


--
-- Name: templatesum id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.templatesum ALTER COLUMN id SET DEFAULT nextval('public.templatesum_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: assets; Type: TABLE DATA; Schema: public; Owner: goagent
--

COPY public.assets (id, server_name, host_name, ip, registered_at) FROM stdin;
1	정보계2	idinfo2	192.10.10.41	2025-05-25 13:30:36.461023
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_log (log_id, user_id, action, "timestamp") FROM stdin;
\.


--
-- Data for Name: evaluation_results; Type: TABLE DATA; Schema: public; Owner: goagent
--

COPY public.evaluation_results (id, templateid, templatename, item_id, item_name, result, detail, risk_level, risk_score, vuln_score, risk_grade, host_name, ip, assessyn, checked_by_agent, last_checked_at, service_status) FROM stdin;
1	tmpl-test001	보안 점검 템플릿	SRV-001	SNMPv3 설정 여부 확인	미점검	\N	상	90	20	\N	ubuntu-server	\N	\N	f	\N	\N
2	tmpl-test002	보안 점검 템플릿	SRV-002	패스워드 복잡도 설정 여부	미점검	\N	상	85	25	\N	ubuntu-server	\N	\N	f	\N	\N
4	tmpl-0yco8ae3	ttdadf	SRV-002	임시 점검 항목 2	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
5	tmpl-0yco8ae3	ttdadf	SRV-003	임시 점검 항목 3	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
6	tmpl-0yco8ae3	ttdadf	SRV-004	임시 점검 항목 4	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
7	tmpl-0yco8ae3	ttdadf	SRV-005	임시 점검 항목 5	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
8	tmpl-0yco8ae3	ttdadf	SRV-006	임시 점검 항목 6	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
9	tmpl-0yco8ae3	ttdadf	SRV-007	임시 점검 항목 7	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
10	tmpl-0yco8ae3	ttdadf	SRV-008	임시 점검 항목 8	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
11	tmpl-0yco8ae3	ttdadf	SRV-009	임시 점검 항목 9	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
12	tmpl-0yco8ae3	ttdadf	SRV-010	임시 점검 항목 10	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
14	tmpl-1os4yt9z	testsetsetest	SRV-002	임시 점검 항목 2	미점검	\N	중	50	10	\N	ttestsetsetsetset	\N	\N	f	\N	\N
15	tmpl-1os4yt9z	testsetsetest	SRV-003	임시 점검 항목 3	미점검	\N	중	50	10	\N	ttestsetsetsetset	\N	\N	f	\N	\N
16	tmpl-1os4yt9z	testsetsetest	SRV-004	임시 점검 항목 4	미점검	\N	중	50	10	\N	ttestsetsetsetset	\N	\N	f	\N	\N
17	tmpl-1os4yt9z	testsetsetest	SRV-005	임시 점검 항목 5	미점검	\N	중	50	10	\N	ttestsetsetsetset	\N	\N	f	\N	\N
18	tmpl-1os4yt9z	testsetsetest	SRV-006	임시 점검 항목 6	미점검	\N	중	50	10	\N	ttestsetsetsetset	\N	\N	f	\N	\N
19	tmpl-1os4yt9z	testsetsetest	SRV-008	임시 점검 항목 8	미점검	\N	중	50	10	\N	ttestsetsetsetset	\N	\N	f	\N	\N
20	tmpl-1os4yt9z	testsetsetest	SRV-009	임시 점검 항목 9	미점검	\N	중	50	10	\N	ttestsetsetsetset	\N	\N	f	\N	\N
21	tmpl-1os4yt9z	testsetsetest	SRV-010	임시 점검 항목 10	미점검	\N	중	50	10	\N	ttestsetsetsetset	\N	\N	f	\N	\N
13	tmpl-1os4yt9z	testsetsetest	SRV-001	임시 점검 항목 1	점검 중	\N	중	50	10	\N	ttestsetsetsetset	\N	\N	f	2025-05-22 11:27:39.534476	\N
3	tmpl-0yco8ae3	ttdadf	SRV-001	임시 점검 항목 1	점검 중	\N	중	50	10	\N	tesatestset	\N	\N	f	2025-05-22 11:29:23.708578	\N
23	tmpl-98u5f6w3	ttdadf	SRV-002	임시 점검 항목 2	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
24	tmpl-98u5f6w3	ttdadf	SRV-003	임시 점검 항목 3	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
25	tmpl-98u5f6w3	ttdadf	SRV-004	임시 점검 항목 4	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
26	tmpl-98u5f6w3	ttdadf	SRV-005	임시 점검 항목 5	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
27	tmpl-98u5f6w3	ttdadf	SRV-006	임시 점검 항목 6	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
28	tmpl-98u5f6w3	ttdadf	SRV-007	임시 점검 항목 7	미점검	\N	중	50	10	\N	tesatestset	\N	\N	f	\N	\N
22	tmpl-98u5f6w3	ttdadf	SRV-001	임시 점검 항목 1	점검 중	\N	중	50	10	\N	tesatestset	\N	\N	f	2025-05-22 11:29:36.881765	\N
29	tmpl-d6rcosy9	aaaaaaaaaaaaa	SRV-001	임시 점검 항목 1	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
30	tmpl-d6rcosy9	aaaaaaaaaaaaa	SRV-002	임시 점검 항목 2	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
31	tmpl-d6rcosy9	aaaaaaaaaaaaa	SRV-004	임시 점검 항목 4	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
32	tmpl-d6rcosy9	aaaaaaaaaaaaa	SRV-005	임시 점검 항목 5	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
33	tmpl-d6rcosy9	aaaaaaaaaaaaa	SRV-006	임시 점검 항목 6	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
34	tmpl-d6rcosy9	aaaaaaaaaaaaa	SRV-007	임시 점검 항목 7	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
35	tmpl-d6rcosy9	aaaaaaaaaaaaa	SRV-008	임시 점검 항목 8	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
36	tmpl-d6rcosy9	aaaaaaaaaaaaa	SRV-009	임시 점검 항목 9	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
38	tmpl-foxd9im0	aaaaaaaaaaaaa	SRV-002	임시 점검 항목 2	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
39	tmpl-foxd9im0	aaaaaaaaaaaaa	SRV-003	임시 점검 항목 3	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
40	tmpl-foxd9im0	aaaaaaaaaaaaa	SRV-004	임시 점검 항목 4	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
41	tmpl-foxd9im0	aaaaaaaaaaaaa	SRV-005	임시 점검 항목 5	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
42	tmpl-foxd9im0	aaaaaaaaaaaaa	SRV-006	임시 점검 항목 6	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
43	tmpl-foxd9im0	aaaaaaaaaaaaa	SRV-007	임시 점검 항목 7	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
44	tmpl-foxd9im0	aaaaaaaaaaaaa	SRV-008	임시 점검 항목 8	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
45	tmpl-foxd9im0	aaaaaaaaaaaaa	SRV-009	임시 점검 항목 9	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
46	tmpl-foxd9im0	aaaaaaaaaaaaa	SRV-010	임시 점검 항목 10	미점검	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	\N	\N
37	tmpl-foxd9im0	aaaaaaaaaaaaa	SRV-001	임시 점검 항목 1	점검 중	\N	중	50	10	\N	aaaaaaaaaaaaaa	\N	\N	f	2025-05-22 11:35:48.911505	\N
48	tmpl-4hw3pxpo	009	SRV-002	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
49	tmpl-4hw3pxpo	009	SRV-003	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
50	tmpl-4hw3pxpo	009	SRV-004	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
51	tmpl-4hw3pxpo	009	SRV-005	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
52	tmpl-4hw3pxpo	009	SRV-006	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
53	tmpl-4hw3pxpo	009	SRV-007	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
54	tmpl-4hw3pxpo	009	SRV-008	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
55	tmpl-4hw3pxpo	009	SRV-009	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
56	tmpl-4hw3pxpo	009	SRV-010	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
58	tmpl-my7njkos	009	SRV-002	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
59	tmpl-my7njkos	009	SRV-003	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
60	tmpl-my7njkos	009	SRV-004	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
61	tmpl-my7njkos	009	SRV-005	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
62	tmpl-my7njkos	009	SRV-006	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
47	tmpl-4hw3pxpo	009	SRV-001	\N	점검 중	\N	중	50	10	\N	009	\N	\N	f	2025-05-22 12:13:41.736339	\N
63	tmpl-my7njkos	009	SRV-007	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
64	tmpl-my7njkos	009	SRV-008	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
65	tmpl-my7njkos	009	SRV-009	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
66	tmpl-my7njkos	009	SRV-010	\N	미점검	\N	중	50	10	\N	009	\N	\N	f	\N	\N
57	tmpl-my7njkos	009	SRV-001	\N	점검 중	\N	중	50	10	\N	009	\N	\N	f	2025-05-22 12:11:57.796068	\N
69	tmpl-rv9efams	0091111	SRV-003	\N	미점검	\N	중	50	10	\N	0091	\N	\N	f	\N	\N
70	tmpl-rv9efams	0091111	SRV-004	\N	미점검	\N	중	50	10	\N	0091	\N	\N	f	\N	\N
71	tmpl-rv9efams	0091111	SRV-005	\N	미점검	\N	중	50	10	\N	0091	\N	\N	f	\N	\N
72	tmpl-rv9efams	0091111	SRV-006	\N	미점검	\N	중	50	10	\N	0091	\N	\N	f	\N	\N
73	tmpl-rv9efams	0091111	SRV-007	\N	미점검	\N	중	50	10	\N	0091	\N	\N	f	\N	\N
74	tmpl-rv9efams	0091111	SRV-008	\N	미점검	\N	중	50	10	\N	0091	\N	\N	f	\N	\N
75	tmpl-rv9efams	0091111	SRV-009	\N	미점검	\N	중	50	10	\N	0091	\N	\N	f	\N	\N
76	tmpl-rv9efams	0091111	SRV-010	\N	미점검	\N	중	50	10	\N	0091	\N	\N	f	\N	\N
108	tmpl-4twh0qz0	hhhhh	SRV-002	\N	미점검	\N	중	50	10	3	hhhhh	\N	\N	f	\N	\N
109	tmpl-4twh0qz0	hhhhh	SRV-003	\N	미점검	\N	중	50	10	3	hhhhh	\N	\N	f	\N	\N
98	tmpl-ui9km8sm	11121212	SRV-002	\N	미점검	\N	중	50	10	3	34324234234	\N	\N	f	\N	\N
99	tmpl-ui9km8sm	11121212	SRV-003	\N	미점검	\N	중	50	10	3	34324234234	\N	\N	f	\N	\N
100	tmpl-ui9km8sm	11121212	SRV-004	\N	미점검	\N	중	50	10	3	34324234234	\N	\N	f	\N	\N
68	tmpl-rv9efams	0091111	SRV-002	\N	❓ 알 수 없는 항목		중	50	10	\N	0091	\N	\N	t	2025-05-22 12:30:28.047102	\N
101	tmpl-ui9km8sm	11121212	SRV-005	\N	미점검	\N	중	50	10	3	34324234234	\N	\N	f	\N	\N
67	tmpl-rv9efams	0091111	SRV-001	\N	양호	Debian-+    1556       1  0 08:03 ?        00:00:06 /usr/sbin/snmpd -LOw -u Debian-snmp -g Debian-snmp -I -smux mteTrigger mteTriggerConf -f\n	중	50	10	\N	0091	\N	\N	t	2025-05-22 12:44:59.694518	\N
78	tmpl-2cyyrqo6	gasgdag	SRV-002	\N	미점검	\N	중	50	10	3	sgsdgsag	\N	\N	f	\N	\N
79	tmpl-2cyyrqo6	gasgdag	SRV-003	\N	미점검	\N	중	50	10	3	sgsdgsag	\N	\N	f	\N	\N
80	tmpl-2cyyrqo6	gasgdag	SRV-004	\N	미점검	\N	중	50	10	3	sgsdgsag	\N	\N	f	\N	\N
81	tmpl-2cyyrqo6	gasgdag	SRV-005	\N	미점검	\N	중	50	10	3	sgsdgsag	\N	\N	f	\N	\N
82	tmpl-2cyyrqo6	gasgdag	SRV-006	\N	미점검	\N	중	50	10	3	sgsdgsag	\N	\N	f	\N	\N
83	tmpl-2cyyrqo6	gasgdag	SRV-007	\N	미점검	\N	중	50	10	3	sgsdgsag	\N	\N	f	\N	\N
84	tmpl-2cyyrqo6	gasgdag	SRV-008	\N	미점검	\N	중	50	10	3	sgsdgsag	\N	\N	f	\N	\N
85	tmpl-2cyyrqo6	gasgdag	SRV-009	\N	미점검	\N	중	50	10	3	sgsdgsag	\N	\N	f	\N	\N
86	tmpl-2cyyrqo6	gasgdag	SRV-010	\N	미점검	\N	중	50	10	3	sgsdgsag	\N	\N	f	\N	\N
102	tmpl-ui9km8sm	11121212	SRV-006	\N	미점검	\N	중	50	10	3	34324234234	\N	\N	f	\N	\N
77	tmpl-2cyyrqo6	gasgdag	SRV-001	\N	양호	Debian-+    1556       1  0 08:03 ?        00:00:06 /usr/sbin/snmpd -LOw -u Debian-snmp -g Debian-snmp -I -smux mteTrigger mteTriggerConf -f\n	중	50	10	3	sgsdgsag	\N	\N	t	2025-05-22 12:51:49.621347	\N
88	tmpl-dmkhrz5s	t1212121	SRV-002	\N	미점검	\N	중	50	10	3	141432432	\N	\N	f	\N	\N
89	tmpl-dmkhrz5s	t1212121	SRV-003	\N	미점검	\N	중	50	10	3	141432432	\N	\N	f	\N	\N
90	tmpl-dmkhrz5s	t1212121	SRV-004	\N	미점검	\N	중	50	10	3	141432432	\N	\N	f	\N	\N
91	tmpl-dmkhrz5s	t1212121	SRV-005	\N	미점검	\N	중	50	10	3	141432432	\N	\N	f	\N	\N
92	tmpl-dmkhrz5s	t1212121	SRV-006	\N	미점검	\N	중	50	10	3	141432432	\N	\N	f	\N	\N
93	tmpl-dmkhrz5s	t1212121	SRV-007	\N	미점검	\N	중	50	10	3	141432432	\N	\N	f	\N	\N
94	tmpl-dmkhrz5s	t1212121	SRV-008	\N	미점검	\N	중	50	10	3	141432432	\N	\N	f	\N	\N
95	tmpl-dmkhrz5s	t1212121	SRV-009	\N	미점검	\N	중	50	10	3	141432432	\N	\N	f	\N	\N
96	tmpl-dmkhrz5s	t1212121	SRV-010	\N	미점검	\N	중	50	10	3	141432432	\N	\N	f	\N	\N
103	tmpl-ui9km8sm	11121212	SRV-007	\N	미점검	\N	중	50	10	3	34324234234	\N	\N	f	\N	\N
104	tmpl-ui9km8sm	11121212	SRV-008	\N	미점검	\N	중	50	10	3	34324234234	\N	\N	f	\N	\N
105	tmpl-ui9km8sm	11121212	SRV-009	\N	미점검	\N	중	50	10	3	34324234234	\N	\N	f	\N	\N
106	tmpl-ui9km8sm	11121212	SRV-010	\N	미점검	\N	중	50	10	3	34324234234	\N	\N	f	\N	\N
110	tmpl-4twh0qz0	hhhhh	SRV-004	\N	미점검	\N	중	50	10	3	hhhhh	\N	\N	f	\N	\N
111	tmpl-4twh0qz0	hhhhh	SRV-005	\N	미점검	\N	중	50	10	3	hhhhh	\N	\N	f	\N	\N
112	tmpl-4twh0qz0	hhhhh	SRV-006	\N	미점검	\N	중	50	10	3	hhhhh	\N	\N	f	\N	\N
113	tmpl-4twh0qz0	hhhhh	SRV-007	\N	미점검	\N	중	50	10	3	hhhhh	\N	\N	f	\N	\N
114	tmpl-4twh0qz0	hhhhh	SRV-008	\N	미점검	\N	중	50	10	3	hhhhh	\N	\N	f	\N	\N
87	tmpl-dmkhrz5s	t1212121	SRV-001	\N	점검 중	Debian-+    1556       1  0 08:03 ?        00:00:06 /usr/sbin/snmpd -LOw -u Debian-snmp -g Debian-snmp -I -smux mteTrigger mteTriggerConf -f\n	중	50	10	3	141432432	\N	\N	f	2025-05-22 13:40:34.911646	\N
115	tmpl-4twh0qz0	hhhhh	SRV-009	\N	미점검	\N	중	50	10	3	hhhhh	\N	\N	f	\N	\N
116	tmpl-4twh0qz0	hhhhh	SRV-010	\N	미점검	\N	중	50	10	3	hhhhh	\N	\N	f	\N	\N
155	tmpl-pwng7gge	test5552	SRV-009	\N	미점검	❓ 알 수 없는 항목	중	50	10	3	222	\N	\N	t	2025-05-22 16:13:40.878396	N/A
156	tmpl-pwng7gge	test5552	SRV-010	\N	미점검	❓ 알 수 없는 항목	중	50	10	3	222	\N	\N	t	2025-05-22 16:13:42.925469	N/A
149	tmpl-pwng7gge	test5552	SRV-003	\N	점검 중	❓ 알 수 없는 항목	중	50	10	3	222	\N	\N	f	2025-05-22 16:13:31.794332	N/A
152	tmpl-pwng7gge	test5552	SRV-006	\N	점검 중	Postfix 설정에 debug_peer_level 항목이 없음 → 취약\nSyslog 설정 파일 존재 확인됨: /etc/rsyslog.conf\nrsyslog.d에 4개 설정 파일 존재	중	50	10	3	222	\N	\N	f	2025-05-22 16:13:36.291083	debug_peer_level 미설정
151	tmpl-pwng7gge	test5552	SRV-005	\N	취약	VRFY 명령 결과를 해석할 수 없음\nSendmail 설정(/etc/mail/sendmail.cf): noexpn/novrfy 설정 없음 → 취약\nPostfix 설정: disable_vrfy_command 설정 없음 → 취약	중	50	10	3	222	\N	\N	t	2025-05-22 16:13:36.843559	미확인
154	tmpl-pwng7gge	test5552	SRV-008	\N	점검 중	❓ 알 수 없는 항목	중	50	10	3	222	\N	\N	f	2025-05-22 16:13:39.294944	N/A
148	tmpl-pwng7gge	test5552	SRV-002	\N	미점검	❓ 알 수 없는 항목	중	50	10	3	222	\N	\N	t	2025-05-22 16:13:31.652225	N/A
147	tmpl-pwng7gge	test5552	SRV-001	\N	양호	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	중	50	10	3	222	\N	\N	t	2025-05-22 16:13:29.640496	SNMP
107	tmpl-4twh0qz0	hhhhh	SRV-001	\N	양호	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	중	50	10	3	hhhhh	\N	\N	t	2025-05-22 13:53:34.152841	\N
118	tmpl-q4p61zo1	hhhhh	SRV-002	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ	\N	\N	f	\N	\N
119	tmpl-q4p61zo1	hhhhh	SRV-003	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ	\N	\N	f	\N	\N
120	tmpl-q4p61zo1	hhhhh	SRV-004	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ	\N	\N	f	\N	\N
121	tmpl-q4p61zo1	hhhhh	SRV-005	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ	\N	\N	f	\N	\N
122	tmpl-q4p61zo1	hhhhh	SRV-006	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ	\N	\N	f	\N	\N
123	tmpl-q4p61zo1	hhhhh	SRV-007	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ	\N	\N	f	\N	\N
124	tmpl-q4p61zo1	hhhhh	SRV-008	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ	\N	\N	f	\N	\N
125	tmpl-q4p61zo1	hhhhh	SRV-009	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ	\N	\N	f	\N	\N
126	tmpl-q4p61zo1	hhhhh	SRV-010	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ	\N	\N	f	\N	\N
157	tmpl-i2xgffjf	121212121212	SRV-001	\N	미점검	\N	중	50	10	3	12121212121212	\N	\N	f	\N	\N
117	tmpl-q4p61zo1	hhhhh	SRV-001	\N	양호	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ	\N	\N	t	2025-05-22 13:53:48.258266	\N
128	tmpl-6kq2pyrx	hhhhh121212	SRV-002	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
129	tmpl-6kq2pyrx	hhhhh121212	SRV-003	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
130	tmpl-6kq2pyrx	hhhhh121212	SRV-004	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
131	tmpl-6kq2pyrx	hhhhh121212	SRV-005	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
132	tmpl-6kq2pyrx	hhhhh121212	SRV-006	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
133	tmpl-6kq2pyrx	hhhhh121212	SRV-007	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
134	tmpl-6kq2pyrx	hhhhh121212	SRV-008	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
135	tmpl-6kq2pyrx	hhhhh121212	SRV-009	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
136	tmpl-6kq2pyrx	hhhhh121212	SRV-010	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
158	tmpl-i2xgffjf	121212121212	SRV-002	\N	미점검	\N	중	50	10	3	12121212121212	\N	\N	f	\N	\N
159	tmpl-i2xgffjf	121212121212	SRV-003	\N	미점검	\N	중	50	10	3	12121212121212	\N	\N	f	\N	\N
127	tmpl-6kq2pyrx	hhhhh121212	SRV-001	\N	점검 중	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	2025-05-22 14:04:28.085404	\N
138	tmpl-a9r6tqm6	hhhhh121212wew	SRV-002	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
139	tmpl-a9r6tqm6	hhhhh121212wew	SRV-003	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
140	tmpl-a9r6tqm6	hhhhh121212wew	SRV-004	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
141	tmpl-a9r6tqm6	hhhhh121212wew	SRV-005	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
142	tmpl-a9r6tqm6	hhhhh121212wew	SRV-006	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
143	tmpl-a9r6tqm6	hhhhh121212wew	SRV-007	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
144	tmpl-a9r6tqm6	hhhhh121212wew	SRV-008	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
145	tmpl-a9r6tqm6	hhhhh121212wew	SRV-009	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
146	tmpl-a9r6tqm6	hhhhh121212wew	SRV-010	\N	미점검	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	\N	\N
137	tmpl-a9r6tqm6	hhhhh121212wew	SRV-001	\N	점검 중	\N	중	50	10	3	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	\N	\N	f	2025-05-22 14:04:49.23643	\N
160	tmpl-i2xgffjf	121212121212	SRV-004	\N	미점검	\N	중	50	10	3	12121212121212	\N	\N	f	\N	\N
161	tmpl-i2xgffjf	121212121212	SRV-005	\N	미점검	\N	중	50	10	3	12121212121212	\N	\N	f	\N	\N
162	tmpl-i2xgffjf	121212121212	SRV-006	\N	미점검	\N	중	50	10	3	12121212121212	\N	\N	f	\N	\N
163	tmpl-i2xgffjf	121212121212	SRV-007	\N	미점검	\N	중	50	10	3	12121212121212	\N	\N	f	\N	\N
164	tmpl-i2xgffjf	121212121212	SRV-008	\N	미점검	\N	중	50	10	3	12121212121212	\N	\N	f	\N	\N
165	tmpl-i2xgffjf	121212121212	SRV-009	\N	미점검	\N	중	50	10	3	12121212121212	\N	\N	f	\N	\N
166	tmpl-i2xgffjf	121212121212	SRV-010	\N	미점검	\N	중	50	10	3	12121212121212	\N	\N	f	\N	\N
150	tmpl-pwng7gge	test5552	SRV-004	\N	취약	다음 SMTP 관련 프로세스가 확인되었습니다: sendmail	중	50	10	3	222	\N	\N	t	2025-05-22 16:13:33.836891	sendmail
153	tmpl-pwng7gge	test5552	SRV-007	\N	미점검	❓ 알 수 없는 항목	중	50	10	3	222	\N	\N	t	2025-05-22 16:13:38.852215	N/A
97	tmpl-ui9km8sm	11121212	SRV-001	\N	점검 중	\N	중	50	10	3	34324234234	\N	\N	f	2025-05-25 08:33:27.774483	\N
167	tmpl-ex530nyk	dfdf	SRV-001	\N	미점검	\N	중	50	10	3	sfd	\N	\N	f	\N	\N
169	tmpl-zyqdefbl	2025전금	SRV-004	\N	양호	SMTP 관련 프로세스가 실행되고 있지 않음 → 양호	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:15.195446	미사용
171	tmpl-mfj90yty	2025전금	SRV-004	\N	양호	SMTP 관련 프로세스가 실행되고 있지 않음 → 양호	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:15.195446	미사용
180	tmpl-vkmp6kxb	2025전금	SRV-001	\N	양호	SNMP 사용 여부: 미사용	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:05.74317	미사용
173	tmpl-xsayf3mp	2025전금	SRV-004	\N	양호	SMTP 관련 프로세스가 실행되고 있지 않음 → 양호	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:15.195446	미사용
175	tmpl-lxuwy6gh	2025전금1	SRV-004	\N	양호	SMTP 관련 프로세스가 실행되고 있지 않음 → 양호	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:15.195446	미사용
177	tmpl-k9gpu30m	2025전금	SRV-004	\N	양호	SMTP 관련 프로세스가 실행되고 있지 않음 → 양호	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:15.195446	미사용
168	tmpl-zyqdefbl	2025전금	SRV-001	\N	양호	SNMP 사용 여부: 미사용	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:05.74317	미사용
170	tmpl-mfj90yty	2025전금	SRV-001	\N	양호	SNMP 사용 여부: 미사용	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:05.74317	미사용
172	tmpl-xsayf3mp	2025전금	SRV-001	\N	양호	SNMP 사용 여부: 미사용	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:05.74317	미사용
174	tmpl-lxuwy6gh	2025전금1	SRV-001	\N	양호	SNMP 사용 여부: 미사용	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:05.74317	미사용
176	tmpl-k9gpu30m	2025전금	SRV-001	\N	양호	SNMP 사용 여부: 미사용	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:05.74317	미사용
178	tmpl-r3dto54u	2025전금	SRV-001	\N	양호	SNMP 사용 여부: 미사용	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:05.74317	미사용
179	tmpl-r3dto54u	2025전금	SRV-004	\N	양호	SMTP 관련 프로세스가 실행되고 있지 않음 → 양호	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:15.195446	미사용
181	tmpl-vkmp6kxb	2025전금	SRV-004	\N	양호	SMTP 관련 프로세스가 실행되고 있지 않음 → 양호	중	50	10	3	idinfo	\N	\N	t	2025-05-25 13:21:15.195446	미사용
183	tmpl-l7x6u5pm	test12344	SRV-004	\N	미점검	\N	중	50	10	3	idinfo2	192.10.10.41	\N	f	\N	\N
182	tmpl-l7x6u5pm	test12344	SRV-001	\N	양호	SNMP 사용 여부: 미사용	중	50	10	3	idinfo2	192.10.10.41	\N	t	2025-05-25 17:57:26.320422	미사용
\.


--
-- Data for Name: template; Type: TABLE DATA; Schema: public; Owner: diteogae
--

COPY public.template (id, vulnid, servername, hostname, ip, vulname, result, assessyn, createtime, templateid, templatename, risk_level, risk_score, asset_score, vuln_score) FROM stdin;
1	srv-002	사내계	internal	192.10.10.4	안전한 네트워크 모니터링11	미점검	N	2025-05-17 17:37:42.912083	\N	\N	\N	\N	\N	\N
2	srv-00311	정보계2	idinfo3	192.10.10.41	안전한 네트워크 모니터링1133	미점검	N	2025-05-17 18:04:51.015489	\N	\N	\N	\N	\N	\N
3	SRV-001	정보계2	idinfo2	192.10.10.11	임시 점검 항목 1	미점검	N	2025-05-17 20:19:09.776811	\N	\N	\N	\N	\N	\N
4	SRV-002	정보계2	idinfo2	192.10.10.11	임시 점검 항목 2	미점검	N	2025-05-17 20:19:09.783881	\N	\N	\N	\N	\N	\N
5	SRV-003	정보계2	idinfo2	192.10.10.11	임시 점검 항목 3	미점검	N	2025-05-17 20:19:09.787131	\N	\N	\N	\N	\N	\N
6	SRV-004	정보계2	idinfo2	192.10.10.11	임시 점검 항목 4	미점검	N	2025-05-17 20:19:09.790199	\N	\N	\N	\N	\N	\N
7	SRV-005	정보계2	idinfo2	192.10.10.11	임시 점검 항목 5	미점검	N	2025-05-17 20:19:09.794192	\N	\N	\N	\N	\N	\N
8	SRV-007	정보계2	idinfo2	192.10.10.11	임시 점검 항목 7	미점검	N	2025-05-17 20:19:09.797301	\N	\N	\N	\N	\N	\N
9	SRV-008	정보계2	idinfo2	192.10.10.11	임시 점검 항목 8	미점검	N	2025-05-17 20:19:09.800941	\N	\N	\N	\N	\N	\N
10	SRV-009	정보계2	idinfo2	192.10.10.11	임시 점검 항목 9	미점검	N	2025-05-17 20:19:09.804841	\N	\N	\N	\N	\N	\N
11	SRV-010	정보계2	idinfo2	192.10.10.11	임시 점검 항목 10	미점검	N	2025-05-17 20:19:09.808209	\N	\N	\N	\N	\N	\N
12	SRV-001	정보계2	idinfo	192.10.10.11	임시 점검 항목 1	미점검	N	2025-05-17 20:54:00.127468	\N	\N	\N	\N	\N	\N
13	SRV-004	정보계2	idinfo	192.10.10.11	임시 점검 항목 4	미점검	N	2025-05-17 20:54:00.132418	\N	\N	\N	\N	\N	\N
14	SRV-005	정보계2	idinfo	192.10.10.11	임시 점검 항목 5	미점검	N	2025-05-17 20:54:00.135706	\N	\N	\N	\N	\N	\N
15	SRV-006	정보계2	idinfo	192.10.10.11	임시 점검 항목 6	미점검	N	2025-05-17 20:54:00.138745	\N	\N	\N	\N	\N	\N
16	SRV-007	정보계2	idinfo	192.10.10.11	임시 점검 항목 7	미점검	N	2025-05-17 20:54:00.142034	\N	\N	\N	\N	\N	\N
17	SRV-008	정보계2	idinfo	192.10.10.11	임시 점검 항목 8	미점검	N	2025-05-17 20:54:00.145213	\N	\N	\N	\N	\N	\N
18	SRV-009	정보계2	idinfo	192.10.10.11	임시 점검 항목 9	미점검	N	2025-05-17 20:54:00.148127	\N	\N	\N	\N	\N	\N
19	SRV-010	정보계2	idinfo	192.10.10.11	임시 점검 항목 10	미점검	N	2025-05-17 20:54:00.151074	\N	\N	\N	\N	\N	\N
20	SRV-001	정보계	idinfo	192.10.10.43	임시 점검 항목 1	미점검	N	2025-05-17 21:20:39.072808	tmpl-da3n6v5j	uuuu	\N	\N	\N	\N
21	SRV-002	정보계	idinfo	192.10.10.43	임시 점검 항목 2	미점검	N	2025-05-17 21:20:39.080257	tmpl-da3n6v5j	uuuu	\N	\N	\N	\N
22	SRV-003	정보계	idinfo	192.10.10.43	임시 점검 항목 3	미점검	N	2025-05-17 21:20:39.083949	tmpl-da3n6v5j	uuuu	\N	\N	\N	\N
23	SRV-004	정보계	idinfo	192.10.10.43	임시 점검 항목 4	미점검	N	2025-05-17 21:20:39.087134	tmpl-da3n6v5j	uuuu	\N	\N	\N	\N
24	SRV-005	정보계	idinfo	192.10.10.43	임시 점검 항목 5	미점검	N	2025-05-17 21:20:39.090129	tmpl-da3n6v5j	uuuu	\N	\N	\N	\N
25	SRV-005	사내계	internal	192.10.10.122	임시 점검 항목 5	미점검	N	2025-05-17 21:50:20.449767	tmpl-67fy9s9s	jlkjkj	\N	\N	\N	\N
26	SRV-008	사내계	internal	192.10.10.122	임시 점검 항목 8	미점검	N	2025-05-17 21:50:20.456727	tmpl-67fy9s9s	jlkjkj	\N	\N	\N	\N
27	SRV-001	wwwww	internal	192.10.10.41	임시 점검 항목 1	미점검	N	2025-05-17 21:51:55.950858	tmpl-n05gx37m	jlkjkjwww	\N	\N	\N	\N
28	SRV-002	wwwww	internal	192.10.10.41	임시 점검 항목 2	미점검	N	2025-05-17 21:51:55.955717	tmpl-n05gx37m	jlkjkjwww	\N	\N	\N	\N
29	SRV-003	wwwww	internal	192.10.10.41	임시 점검 항목 3	미점검	N	2025-05-17 21:51:55.959304	tmpl-n05gx37m	jlkjkjwww	\N	\N	\N	\N
30	SRV-004	wwwww	internal	192.10.10.41	임시 점검 항목 4	미점검	N	2025-05-17 21:51:55.962707	tmpl-n05gx37m	jlkjkjwww	\N	\N	\N	\N
31	SRV-005	wwwww	internal	192.10.10.41	임시 점검 항목 5	미점검	N	2025-05-17 21:51:55.965852	tmpl-n05gx37m	jlkjkjwww	\N	\N	\N	\N
32	SRV-006	wwwww	internal	192.10.10.41	임시 점검 항목 6	미점검	N	2025-05-17 21:51:55.968976	tmpl-n05gx37m	jlkjkjwww	\N	\N	\N	\N
33	SRV-007	wwwww	internal	192.10.10.41	임시 점검 항목 7	미점검	N	2025-05-17 21:51:55.972444	tmpl-n05gx37m	jlkjkjwww	\N	\N	\N	\N
34	SRV-008	wwwww	internal	192.10.10.41	임시 점검 항목 8	미점검	N	2025-05-17 21:51:55.975536	tmpl-n05gx37m	jlkjkjwww	\N	\N	\N	\N
35	SRV-009	wwwww	internal	192.10.10.41	임시 점검 항목 9	미점검	N	2025-05-17 21:51:55.978894	tmpl-n05gx37m	jlkjkjwww	\N	\N	\N	\N
36	SRV-010	wwwww	internal	192.10.10.41	임시 점검 항목 10	미점검	N	2025-05-17 21:51:55.981886	tmpl-n05gx37m	jlkjkjwww	\N	\N	\N	\N
37	SRV-001	정보계	idinfo	192.10.10.43	임시 점검 항목 1	미점검	N	2025-05-17 21:54:01.793095	tmpl-88zc1xc3	ㄴㄴㄴㄴ	\N	\N	\N	\N
38	SRV-002	정보계	idinfo	192.10.10.43	임시 점검 항목 2	미점검	N	2025-05-17 21:54:01.797385	tmpl-88zc1xc3	ㄴㄴㄴㄴ	\N	\N	\N	\N
39	SRV-003	정보계	idinfo	192.10.10.43	임시 점검 항목 3	미점검	N	2025-05-17 21:54:01.800708	tmpl-88zc1xc3	ㄴㄴㄴㄴ	\N	\N	\N	\N
40	SRV-004	정보계	idinfo	192.10.10.43	임시 점검 항목 4	미점검	N	2025-05-17 21:54:01.804052	tmpl-88zc1xc3	ㄴㄴㄴㄴ	\N	\N	\N	\N
41	SRV-005	정보계	idinfo	192.10.10.43	임시 점검 항목 5	미점검	N	2025-05-17 21:54:01.808246	tmpl-88zc1xc3	ㄴㄴㄴㄴ	\N	\N	\N	\N
42	SRV-006	정보계	idinfo	192.10.10.43	임시 점검 항목 6	미점검	N	2025-05-17 21:54:01.811226	tmpl-88zc1xc3	ㄴㄴㄴㄴ	\N	\N	\N	\N
43	SRV-007	정보계	idinfo	192.10.10.43	임시 점검 항목 7	미점검	N	2025-05-17 21:54:01.81403	tmpl-88zc1xc3	ㄴㄴㄴㄴ	\N	\N	\N	\N
44	SRV-008	정보계	idinfo	192.10.10.43	임시 점검 항목 8	미점검	N	2025-05-17 21:54:01.816932	tmpl-88zc1xc3	ㄴㄴㄴㄴ	\N	\N	\N	\N
45	SRV-009	정보계	idinfo	192.10.10.43	임시 점검 항목 9	미점검	N	2025-05-17 21:54:01.82014	tmpl-88zc1xc3	ㄴㄴㄴㄴ	\N	\N	\N	\N
46	SRV-010	정보계	idinfo	192.10.10.43	임시 점검 항목 10	미점검	N	2025-05-17 21:54:01.823174	tmpl-88zc1xc3	ㄴㄴㄴㄴ	\N	\N	\N	\N
47	SRV-001	ㅁ	idinfo	192.10.10.43	임시 점검 항목 1	미점검	N	2025-05-17 21:54:17.1696	tmpl-8uglfn8t	ㄴㄴㄴㅁㅁ	\N	\N	\N	\N
48	SRV-002	ㅁ	idinfo	192.10.10.43	임시 점검 항목 2	미점검	N	2025-05-17 21:54:17.17465	tmpl-8uglfn8t	ㄴㄴㄴㅁㅁ	\N	\N	\N	\N
49	SRV-003	ㅁ	idinfo	192.10.10.43	임시 점검 항목 3	미점검	N	2025-05-17 21:54:17.177718	tmpl-8uglfn8t	ㄴㄴㄴㅁㅁ	\N	\N	\N	\N
50	SRV-004	ㅁ	idinfo	192.10.10.43	임시 점검 항목 4	미점검	N	2025-05-17 21:54:17.180463	tmpl-8uglfn8t	ㄴㄴㄴㅁㅁ	\N	\N	\N	\N
51	SRV-005	ㅁ	idinfo	192.10.10.43	임시 점검 항목 5	미점검	N	2025-05-17 21:54:17.183198	tmpl-8uglfn8t	ㄴㄴㄴㅁㅁ	\N	\N	\N	\N
52	SRV-006	ㅁ	idinfo	192.10.10.43	임시 점검 항목 6	미점검	N	2025-05-17 21:54:17.18604	tmpl-8uglfn8t	ㄴㄴㄴㅁㅁ	\N	\N	\N	\N
53	SRV-007	ㅁ	idinfo	192.10.10.43	임시 점검 항목 7	미점검	N	2025-05-17 21:54:17.189071	tmpl-8uglfn8t	ㄴㄴㄴㅁㅁ	\N	\N	\N	\N
54	SRV-008	ㅁ	idinfo	192.10.10.43	임시 점검 항목 8	미점검	N	2025-05-17 21:54:17.19189	tmpl-8uglfn8t	ㄴㄴㄴㅁㅁ	\N	\N	\N	\N
55	SRV-009	ㅁ	idinfo	192.10.10.43	임시 점검 항목 9	미점검	N	2025-05-17 21:54:17.194655	tmpl-8uglfn8t	ㄴㄴㄴㅁㅁ	\N	\N	\N	\N
56	SRV-010	ㅁ	idinfo	192.10.10.43	임시 점검 항목 10	미점검	N	2025-05-17 21:54:17.197318	tmpl-8uglfn8t	ㄴㄴㄴㅁㅁ	\N	\N	\N	\N
57	SRV-001	정보계	idinfo	192.10.10.1	임시 점검 항목 1	미점검	N	2025-05-17 21:55:04.179629	tmpl-qrwf8i89	aaa	\N	\N	\N	\N
58	SRV-002	정보계	idinfo	192.10.10.1	임시 점검 항목 2	미점검	N	2025-05-17 21:55:04.184236	tmpl-qrwf8i89	aaa	\N	\N	\N	\N
59	SRV-003	정보계	idinfo	192.10.10.1	임시 점검 항목 3	미점검	N	2025-05-17 21:55:04.187869	tmpl-qrwf8i89	aaa	\N	\N	\N	\N
60	SRV-004	정보계	idinfo	192.10.10.1	임시 점검 항목 4	미점검	N	2025-05-17 21:55:04.191501	tmpl-qrwf8i89	aaa	\N	\N	\N	\N
61	SRV-005	정보계	idinfo	192.10.10.1	임시 점검 항목 5	미점검	N	2025-05-17 21:55:04.194568	tmpl-qrwf8i89	aaa	\N	\N	\N	\N
62	SRV-006	정보계	idinfo	192.10.10.1	임시 점검 항목 6	미점검	N	2025-05-17 21:55:04.198851	tmpl-qrwf8i89	aaa	\N	\N	\N	\N
63	SRV-007	정보계	idinfo	192.10.10.1	임시 점검 항목 7	미점검	N	2025-05-17 21:55:04.201682	tmpl-qrwf8i89	aaa	\N	\N	\N	\N
64	SRV-008	정보계	idinfo	192.10.10.1	임시 점검 항목 8	미점검	N	2025-05-17 21:55:04.20545	tmpl-qrwf8i89	aaa	\N	\N	\N	\N
65	SRV-009	정보계	idinfo	192.10.10.1	임시 점검 항목 9	미점검	N	2025-05-17 21:55:04.209275	tmpl-qrwf8i89	aaa	\N	\N	\N	\N
66	SRV-010	정보계	idinfo	192.10.10.1	임시 점검 항목 10	미점검	N	2025-05-17 21:55:04.212919	tmpl-qrwf8i89	aaa	\N	\N	\N	\N
68	SRV-002	qqqqqq	idinfo3	192.10.10.11	임시 점검 항목 2	미점검	N	2025-05-17 22:30:58.735145	tmpl-8da8rwa0	qqq	\N	\N	\N	\N
69	SRV-003	qqqqqq	idinfo3	192.10.10.11	임시 점검 항목 3	미점검	N	2025-05-17 22:30:58.738722	tmpl-8da8rwa0	qqq	\N	\N	\N	\N
70	SRV-004	qqqqqq	idinfo3	192.10.10.11	임시 점검 항목 4	미점검	N	2025-05-17 22:30:58.741887	tmpl-8da8rwa0	qqq	\N	\N	\N	\N
71	SRV-005	qqqqqq	idinfo3	192.10.10.11	임시 점검 항목 5	미점검	N	2025-05-17 22:30:58.744669	tmpl-8da8rwa0	qqq	\N	\N	\N	\N
72	SRV-006	qqqqqq	idinfo3	192.10.10.11	임시 점검 항목 6	미점검	N	2025-05-17 22:30:58.747299	tmpl-8da8rwa0	qqq	\N	\N	\N	\N
73	SRV-007	qqqqqq	idinfo3	192.10.10.11	임시 점검 항목 7	미점검	N	2025-05-17 22:30:58.749791	tmpl-8da8rwa0	qqq	\N	\N	\N	\N
74	SRV-008	qqqqqq	idinfo3	192.10.10.11	임시 점검 항목 8	미점검	N	2025-05-17 22:30:58.75236	tmpl-8da8rwa0	qqq	\N	\N	\N	\N
75	SRV-009	qqqqqq	idinfo3	192.10.10.11	임시 점검 항목 9	미점검	N	2025-05-17 22:30:58.755277	tmpl-8da8rwa0	qqq	\N	\N	\N	\N
76	SRV-010	qqqqqq	idinfo3	192.10.10.11	임시 점검 항목 10	미점검	N	2025-05-17 22:30:58.758005	tmpl-8da8rwa0	qqq	\N	\N	\N	\N
67	SRV-001	qqqqqq	idinfo3	192.10.10.11	임시 점검 항목 1	✅ SNMPv3 설정 양호	Y	2025-05-17 22:31:02.488542	tmpl-8da8rwa0	qqq	\N	\N	\N	\N
79	SRV-003	1212121212	1212121212	192.10.110.43	임시 점검 항목 3	미점검	N	2025-05-18 15:55:27.823511	tmpl-ng3gwmmk	12121212	\N	\N	\N	\N
80	SRV-004	1212121212	1212121212	192.10.110.43	임시 점검 항목 4	미점검	N	2025-05-18 15:55:27.826218	tmpl-ng3gwmmk	12121212	\N	\N	\N	\N
81	SRV-005	1212121212	1212121212	192.10.110.43	임시 점검 항목 5	미점검	N	2025-05-18 15:55:27.829045	tmpl-ng3gwmmk	12121212	\N	\N	\N	\N
82	SRV-006	1212121212	1212121212	192.10.110.43	임시 점검 항목 6	미점검	N	2025-05-18 15:55:27.83174	tmpl-ng3gwmmk	12121212	\N	\N	\N	\N
83	SRV-007	1212121212	1212121212	192.10.110.43	임시 점검 항목 7	미점검	N	2025-05-18 15:55:27.834533	tmpl-ng3gwmmk	12121212	\N	\N	\N	\N
84	SRV-008	1212121212	1212121212	192.10.110.43	임시 점검 항목 8	미점검	N	2025-05-18 15:55:27.837397	tmpl-ng3gwmmk	12121212	\N	\N	\N	\N
85	SRV-009	1212121212	1212121212	192.10.110.43	임시 점검 항목 9	미점검	N	2025-05-18 15:55:27.840127	tmpl-ng3gwmmk	12121212	\N	\N	\N	\N
86	SRV-010	1212121212	1212121212	192.10.110.43	임시 점검 항목 10	미점검	N	2025-05-18 15:55:27.842671	tmpl-ng3gwmmk	12121212	\N	\N	\N	\N
77	SRV-001	1212121212	1212121212	192.10.110.43	임시 점검 항목 1	✅ SNMPv3 설정 양호	Y	2025-05-18 15:55:30.152057	tmpl-ng3gwmmk	12121212	\N	\N	\N	\N
78	SRV-002	1212121212	1212121212	192.10.110.43	임시 점검 항목 2	❓ 알 수 없는 항목	Y	2025-05-18 16:14:27.24863	tmpl-ng3gwmmk	12121212	\N	\N	\N	\N
87	SRV-001	ㅎㅎㅎㅎ	ㅎㅎㅎㅎㅎㅎ	192.10.10.43	임시 점검 항목 1	미점검	N	2025-05-18 16:55:47.933709	tmpl-x3u3h31p	ㅎㅎ	\N	\N	\N	\N
88	SRV-002	ㅎㅎㅎㅎ	ㅎㅎㅎㅎㅎㅎ	192.10.10.43	임시 점검 항목 2	미점검	N	2025-05-18 16:55:47.939401	tmpl-x3u3h31p	ㅎㅎ	\N	\N	\N	\N
89	SRV-003	ㅎㅎㅎㅎ	ㅎㅎㅎㅎㅎㅎ	192.10.10.43	임시 점검 항목 3	미점검	N	2025-05-18 16:55:47.942479	tmpl-x3u3h31p	ㅎㅎ	\N	\N	\N	\N
90	SRV-004	ㅎㅎㅎㅎ	ㅎㅎㅎㅎㅎㅎ	192.10.10.43	임시 점검 항목 4	미점검	N	2025-05-18 16:55:47.945431	tmpl-x3u3h31p	ㅎㅎ	\N	\N	\N	\N
91	SRV-005	ㅎㅎㅎㅎ	ㅎㅎㅎㅎㅎㅎ	192.10.10.43	임시 점검 항목 5	미점검	N	2025-05-18 16:55:47.94818	tmpl-x3u3h31p	ㅎㅎ	\N	\N	\N	\N
92	SRV-006	ㅎㅎㅎㅎ	ㅎㅎㅎㅎㅎㅎ	192.10.10.43	임시 점검 항목 6	미점검	N	2025-05-18 16:55:47.950991	tmpl-x3u3h31p	ㅎㅎ	\N	\N	\N	\N
93	SRV-007	ㅎㅎㅎㅎ	ㅎㅎㅎㅎㅎㅎ	192.10.10.43	임시 점검 항목 7	미점검	N	2025-05-18 16:55:47.953621	tmpl-x3u3h31p	ㅎㅎ	\N	\N	\N	\N
94	SRV-008	ㅎㅎㅎㅎ	ㅎㅎㅎㅎㅎㅎ	192.10.10.43	임시 점검 항목 8	미점검	N	2025-05-18 16:55:47.956396	tmpl-x3u3h31p	ㅎㅎ	\N	\N	\N	\N
95	SRV-009	ㅎㅎㅎㅎ	ㅎㅎㅎㅎㅎㅎ	192.10.10.43	임시 점검 항목 9	미점검	N	2025-05-18 16:55:47.958918	tmpl-x3u3h31p	ㅎㅎ	\N	\N	\N	\N
96	SRV-001	ㅇ	ㅇ	192.10.10.14	임시 점검 항목 1	미점검	N	2025-05-18 16:57:57.028424	tmpl-es4i3t6u	uuuu	\N	\N	\N	\N
97	SRV-002	ㅇ	ㅇ	192.10.10.14	임시 점검 항목 2	미점검	N	2025-05-18 16:57:57.032802	tmpl-es4i3t6u	uuuu	\N	\N	\N	\N
98	SRV-003	ㅇ	ㅇ	192.10.10.14	임시 점검 항목 3	미점검	N	2025-05-18 16:57:57.035612	tmpl-es4i3t6u	uuuu	\N	\N	\N	\N
99	SRV-004	ㅇ	ㅇ	192.10.10.14	임시 점검 항목 4	미점검	N	2025-05-18 16:57:57.038664	tmpl-es4i3t6u	uuuu	\N	\N	\N	\N
100	SRV-005	ㅇ	ㅇ	192.10.10.14	임시 점검 항목 5	미점검	N	2025-05-18 16:57:57.041397	tmpl-es4i3t6u	uuuu	\N	\N	\N	\N
101	SRV-006	ㅇ	ㅇ	192.10.10.14	임시 점검 항목 6	미점검	N	2025-05-18 16:57:57.046234	tmpl-es4i3t6u	uuuu	\N	\N	\N	\N
102	SRV-007	ㅇ	ㅇ	192.10.10.14	임시 점검 항목 7	미점검	N	2025-05-18 16:57:57.048942	tmpl-es4i3t6u	uuuu	\N	\N	\N	\N
103	SRV-008	ㅇ	ㅇ	192.10.10.14	임시 점검 항목 8	미점검	N	2025-05-18 16:57:57.051589	tmpl-es4i3t6u	uuuu	\N	\N	\N	\N
104	SRV-009	ㅇ	ㅇ	192.10.10.14	임시 점검 항목 9	미점검	N	2025-05-18 16:57:57.054366	tmpl-es4i3t6u	uuuu	\N	\N	\N	\N
105	SRV-010	ㅇ	ㅇ	192.10.10.14	임시 점검 항목 10	미점검	N	2025-05-18 16:57:57.057017	tmpl-es4i3t6u	uuuu	\N	\N	\N	\N
106	SRV-001	정보계	idinfo	192.10.10.43	임시 점검 항목 1	미점검	N	2025-05-18 19:32:35.896511	tmpl-c9fm3gpz	uuuu	\N	\N	\N	\N
107	SRV-002	정보계	idinfo	192.10.10.43	임시 점검 항목 2	미점검	N	2025-05-18 19:32:35.901951	tmpl-c9fm3gpz	uuuu	\N	\N	\N	\N
108	SRV-003	정보계	idinfo	192.10.10.43	임시 점검 항목 3	미점검	N	2025-05-18 19:32:35.905174	tmpl-c9fm3gpz	uuuu	\N	\N	\N	\N
109	SRV-004	정보계	idinfo	192.10.10.43	임시 점검 항목 4	미점검	N	2025-05-18 19:32:35.908016	tmpl-c9fm3gpz	uuuu	\N	\N	\N	\N
110	SRV-005	정보계	idinfo	192.10.10.43	임시 점검 항목 5	미점검	N	2025-05-18 19:32:35.910883	tmpl-c9fm3gpz	uuuu	\N	\N	\N	\N
111	SRV-006	정보계	idinfo	192.10.10.43	임시 점검 항목 6	미점검	N	2025-05-18 19:32:35.925608	tmpl-c9fm3gpz	uuuu	\N	\N	\N	\N
112	SRV-007	정보계	idinfo	192.10.10.43	임시 점검 항목 7	미점검	N	2025-05-18 19:32:35.928989	tmpl-c9fm3gpz	uuuu	\N	\N	\N	\N
113	SRV-008	정보계	idinfo	192.10.10.43	임시 점검 항목 8	미점검	N	2025-05-18 19:32:35.932193	tmpl-c9fm3gpz	uuuu	\N	\N	\N	\N
114	SRV-009	정보계	idinfo	192.10.10.43	임시 점검 항목 9	미점검	N	2025-05-18 19:32:35.935308	tmpl-c9fm3gpz	uuuu	\N	\N	\N	\N
115	SRV-010	정보계	idinfo	192.10.10.43	임시 점검 항목 10	미점검	N	2025-05-18 19:32:35.938726	tmpl-c9fm3gpz	uuuu	\N	\N	\N	\N
116	SRV-001	정보계	idinfo2	192.10.10.43	임시 점검 항목 1	미점검	N	2025-05-18 19:33:22.781686	tmpl-cybrt3uq	uuuu	\N	\N	\N	\N
117	SRV-002	정보계	idinfo2	192.10.10.43	임시 점검 항목 2	미점검	N	2025-05-18 19:33:22.78753	tmpl-cybrt3uq	uuuu	\N	\N	\N	\N
118	SRV-003	정보계	idinfo2	192.10.10.43	임시 점검 항목 3	미점검	N	2025-05-18 19:33:22.791255	tmpl-cybrt3uq	uuuu	\N	\N	\N	\N
119	SRV-004	정보계	idinfo2	192.10.10.43	임시 점검 항목 4	미점검	N	2025-05-18 19:33:22.795015	tmpl-cybrt3uq	uuuu	\N	\N	\N	\N
120	SRV-005	정보계	idinfo2	192.10.10.43	임시 점검 항목 5	미점검	N	2025-05-18 19:33:22.798359	tmpl-cybrt3uq	uuuu	\N	\N	\N	\N
121	SRV-006	정보계	idinfo2	192.10.10.43	임시 점검 항목 6	미점검	N	2025-05-18 19:33:22.801457	tmpl-cybrt3uq	uuuu	\N	\N	\N	\N
122	SRV-007	정보계	idinfo2	192.10.10.43	임시 점검 항목 7	미점검	N	2025-05-18 19:33:22.804049	tmpl-cybrt3uq	uuuu	\N	\N	\N	\N
123	SRV-008	정보계	idinfo2	192.10.10.43	임시 점검 항목 8	미점검	N	2025-05-18 19:33:22.806627	tmpl-cybrt3uq	uuuu	\N	\N	\N	\N
124	SRV-009	정보계	idinfo2	192.10.10.43	임시 점검 항목 9	미점검	N	2025-05-18 19:33:22.809224	tmpl-cybrt3uq	uuuu	\N	\N	\N	\N
125	SRV-010	정보계	idinfo2	192.10.10.43	임시 점검 항목 10	미점검	N	2025-05-18 19:33:22.811811	tmpl-cybrt3uq	uuuu	\N	\N	\N	\N
126	SRV-001	정보계111	1212121212	192.10.10.43	임시 점검 항목 1	미점검	N	2025-05-18 19:40:08.041569	tmpl-lzdt6ysq	uuuu111	\N	\N	\N	\N
127	SRV-002	정보계111	1212121212	192.10.10.43	임시 점검 항목 2	미점검	N	2025-05-18 19:40:08.04745	tmpl-lzdt6ysq	uuuu111	\N	\N	\N	\N
\.


--
-- Data for Name: template_items; Type: TABLE DATA; Schema: public; Owner: goagent
--

COPY public.template_items (item_id, item_name, risk_level, risk_score, vuln_score, vul_info, risk_grade) FROM stdin;
SRV-002	패스워드 복잡도 설정 여부	상	85	25	\N	\N
SRV-003	계정 잠금 정책 적용	중	70	15	\N	\N
SRV-007	로그 설정 및 보존 정책	하	50	5	\N	\N
SRV-008	ssh 설정 (Port 변경, root 로그인 차단)	중	65	10	\N	\N
SRV-009	방화벽 정책 적용 여부	상	85	20	\N	\N
SRV-010	계정 미사용 시 자동 잠금 설정	중	70	15	\N	\N
SRV-001	안전한 네트워크 모니터링 서비스 사용	상	90	20	네트워크 모니터링 서비스의 보안 설정이 미비할 경우 데이터변조, 도청 및 중간자 공격으로 시스템 정보 및 상태정보가 유출될 가능성이 존재하므로 프로토콜에 따라 알맞은 버전 및 안전한 보안 설정을 적용하여 사용하고 있는지 여부를 점검	\N
SRV-004	불필요한 SMTP 서비스 실행	중	50	10	SMTP(Postfix, Sendmail 등)가 불필요하게 실행되고 있는지 확인합니다. 필요하지 않다면 중지하는 것이 권장됩니다.	3
SRV-005	SMTP 서비스 EXPN/VRFY 명령어 실행 제한 미비	상	90	25	SMTP 서비스가 사용자 확인 명령(EXPN/VRFY)에 응답하는 경우, 외부에서 사용자 계정 존재 여부를 탐지할 수 있어 정보 노출 위험이 있습니다. 해당 명령어 응답을 비활성화하는 것이 권장됩니다.	\N
SRV-006	SMTP 서비스 로그 수준 설정 미흡	중	75	15	SMTP 서비스에서 로그 수준이 적절히 설정되지 않으면, 보안 이벤트나 오류를 추적하기 어렵습니다. 로그 기록 수준을 적절히 설정하고, 민감한 정보가 과도하게 노출되지 않도록 조치해야 합니다.	\N
\.


--
-- Data for Name: templatesum; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.templatesum (id, templateid, assess_score, assess_vuln, assess_date, asess_good) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, password_hash, role) FROM stdin;
\.


--
-- Data for Name: vulnerability; Type: TABLE DATA; Schema: public; Owner: diteogae
--

COPY public.vulnerability (vul_id, vul_name, vul_info, risk_level, risk_score, vuln_score, risk_grade, target_type) FROM stdin;
SRV-001	안전한 네트워크 모니터링 서비스 사용 | 네트워크 모니터링 서비스(SNMP 등)의 안전한 버전 사용 여부를 점검합니다.	네트워크 모니터링 서비스(SNMP 등)의 안전한 버전 사용 여부를 점검합니다.	중	50	10	3	서버
SRV-004	불필요한 SMTP 서비스 실행	SMTP 서비스가 불필요하게 실행 중인지 확인합니다.	중	50	10	3	서버
DBM-001	DB 접근 통제 설정 미흡	데이터베이스 접근 권한 설정이 적절한지 확인합니다.	상	70	15	4	데이터베이스
\.


--
-- Name: assets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: goagent
--

SELECT pg_catalog.setval('public.assets_id_seq', 2, true);


--
-- Name: audit_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_log_log_id_seq', 1, false);


--
-- Name: evaluation_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: goagent
--

SELECT pg_catalog.setval('public.evaluation_results_id_seq', 183, true);


--
-- Name: template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diteogae
--

SELECT pg_catalog.setval('public.template_id_seq', 127, true);


--
-- Name: templatesum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.templatesum_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 1, false);


--
-- Name: assets assets_ip_key; Type: CONSTRAINT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_ip_key UNIQUE (ip);


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (log_id);


--
-- Name: evaluation_results evaluation_results_pkey; Type: CONSTRAINT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.evaluation_results
    ADD CONSTRAINT evaluation_results_pkey PRIMARY KEY (id);


--
-- Name: template_items template_items_pkey; Type: CONSTRAINT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.template_items
    ADD CONSTRAINT template_items_pkey PRIMARY KEY (item_id);


--
-- Name: template template_pkey; Type: CONSTRAINT; Schema: public; Owner: diteogae
--

ALTER TABLE ONLY public.template
    ADD CONSTRAINT template_pkey PRIMARY KEY (id);


--
-- Name: templatesum templatesum_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.templatesum
    ADD CONSTRAINT templatesum_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: vulnerability vulnerability_pkey; Type: CONSTRAINT; Schema: public; Owner: diteogae
--

ALTER TABLE ONLY public.vulnerability
    ADD CONSTRAINT vulnerability_pkey PRIMARY KEY (vul_id);


--
-- Name: audit_log audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: DATABASE goagent; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE goagent TO goagent;


--
-- Name: TABLE audit_log; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.audit_log TO goagent;


--
-- Name: SEQUENCE audit_log_log_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.audit_log_log_id_seq TO goagent;


--
-- Name: TABLE template; Type: ACL; Schema: public; Owner: diteogae
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.template TO goagent;


--
-- Name: SEQUENCE template_id_seq; Type: ACL; Schema: public; Owner: diteogae
--

GRANT SELECT,USAGE ON SEQUENCE public.template_id_seq TO goagent;


--
-- Name: TABLE templatesum; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.templatesum TO goagent;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.users TO goagent;


--
-- Name: SEQUENCE users_user_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.users_user_id_seq TO goagent;


--
-- Name: TABLE vulnerability; Type: ACL; Schema: public; Owner: diteogae
--

GRANT ALL ON TABLE public.vulnerability TO goagent;


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

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

--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

