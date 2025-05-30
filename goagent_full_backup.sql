--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)

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
-- Name: goagent_schema; Type: SCHEMA; Schema: -; Owner: goagent
--

CREATE SCHEMA goagent_schema;


ALTER SCHEMA goagent_schema OWNER TO goagent;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: vul_temp; Type: TABLE; Schema: goagent_schema; Owner: goagent
--

CREATE TABLE goagent_schema.vul_temp (
    vul_id character varying(20) NOT NULL,
    category character varying(20),
    control_area character varying(50),
    control_type_large character varying(50),
    control_type_medium character varying(50),
    item_description text,
    risk_level character varying(10),
    details text,
    basis_financial character(1),
    basis_critical_info character(1),
    target_aix character(1),
    target_hp_ux character(1),
    target_system character varying(50)
);


ALTER TABLE goagent_schema.vul_temp OWNER TO goagent;

--
-- Name: asset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asset (
    id integer NOT NULL,
    target_type character varying(50) NOT NULL,
    server_name character varying(100) NOT NULL,
    host_name character varying(100) NOT NULL,
    ip character varying(15) NOT NULL,
    manager character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.asset OWNER TO postgres;

--
-- Name: asset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.asset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.asset_id_seq OWNER TO postgres;

--
-- Name: asset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.asset_id_seq OWNED BY public.asset.id;


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: goagent
--

CREATE TABLE public.audit_log (
    log_id integer NOT NULL,
    user_id integer,
    action text,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_log OWNER TO goagent;

--
-- Name: audit_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: goagent
--

CREATE SEQUENCE public.audit_log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_log_log_id_seq OWNER TO goagent;

--
-- Name: audit_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goagent
--

ALTER SEQUENCE public.audit_log_log_id_seq OWNED BY public.audit_log.log_id;


--
-- Name: evaluation_results; Type: TABLE; Schema: public; Owner: goagent
--

CREATE TABLE public.evaluation_results (
    id integer NOT NULL,
    templateid text,
    templatename text,
    host_name text,
    item_id text,
    item_name text,
    result text DEFAULT '미점검'::text,
    risk_level text,
    risk_score integer,
    vuln_score integer,
    checked_by_agent boolean DEFAULT false,
    last_checked_at timestamp without time zone,
    detail text,
    risk_grade integer DEFAULT 3,
    service_status text,
    CONSTRAINT evaluation_results_risk_grade_check CHECK (((risk_grade >= 1) AND (risk_grade <= 5)))
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


ALTER SEQUENCE public.evaluation_results_id_seq OWNER TO goagent;

--
-- Name: evaluation_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goagent
--

ALTER SEQUENCE public.evaluation_results_id_seq OWNED BY public.evaluation_results.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pages (
    id integer NOT NULL,
    page_name character varying(100) NOT NULL,
    url_path character varying(200) NOT NULL,
    description text
);


ALTER TABLE public.pages OWNER TO postgres;

--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pages_id_seq OWNER TO postgres;

--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- Name: role_page_access; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_page_access (
    role_id integer NOT NULL,
    page_id integer NOT NULL
);


ALTER TABLE public.role_page_access OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    role_name character varying(50) NOT NULL,
    description text
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: template; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.template (
    template_id integer NOT NULL,
    template_name character varying(100) NOT NULL,
    target_type character varying(50) NOT NULL,
    basis_type text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    description text
);


ALTER TABLE public.template OWNER TO postgres;

--
-- Name: template_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.template_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.template_template_id_seq OWNER TO postgres;

--
-- Name: template_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.template_template_id_seq OWNED BY public.template.template_id;


--
-- Name: template_vuln; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.template_vuln (
    id integer NOT NULL,
    template_id character varying(50),
    vul_id character varying(50) NOT NULL,
    vul_name text NOT NULL
);


ALTER TABLE public.template_vuln OWNER TO postgres;

--
-- Name: template_vuln_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.template_vuln_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.template_vuln_id_seq OWNER TO postgres;

--
-- Name: template_vuln_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.template_vuln_id_seq OWNED BY public.template_vuln.id;


--
-- Name: templatesum; Type: TABLE; Schema: public; Owner: goagent
--

CREATE TABLE public.templatesum (
    templateid text NOT NULL,
    assess_score integer,
    assess_vuln integer,
    assess_pass integer,
    assess_date timestamp without time zone
);


ALTER TABLE public.templatesum OWNER TO goagent;

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


ALTER SEQUENCE public.templatesum_id_seq OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password_hash text NOT NULL,
    name character varying(100),
    email character varying(100),
    role character varying(20) DEFAULT 'user'::character varying,
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vulnerability; Type: TABLE; Schema: public; Owner: goagent
--

CREATE TABLE public.vulnerability (
    vul_id character varying(20) NOT NULL,
    category character varying(20),
    control_area character varying(50),
    control_type_large character varying(50),
    control_type_medium character varying(50),
    vul_name text,
    risk_level integer,
    details text,
    target_system character varying(50),
    basis text,
    basis_financial character(1),
    basis_critical_info character(1),
    target_aix character(1),
    target_hp_ux character(1),
    target_linux character(1),
    target_solaris character(1),
    target_win character(1),
    target_webservice character(1),
    target_apache character(1),
    target_webtob character(1),
    target_iis character(1),
    target_tomcat character(1),
    target_jeus character(1),
    target_type character varying(50)
);


ALTER TABLE public.vulnerability OWNER TO goagent;

--
-- Name: asset id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asset ALTER COLUMN id SET DEFAULT nextval('public.asset_id_seq'::regclass);


--
-- Name: audit_log log_id; Type: DEFAULT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN log_id SET DEFAULT nextval('public.audit_log_log_id_seq'::regclass);


--
-- Name: evaluation_results id; Type: DEFAULT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.evaluation_results ALTER COLUMN id SET DEFAULT nextval('public.evaluation_results_id_seq'::regclass);


--
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: template template_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template ALTER COLUMN template_id SET DEFAULT nextval('public.template_template_id_seq'::regclass);


--
-- Name: template_vuln id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_vuln ALTER COLUMN id SET DEFAULT nextval('public.template_vuln_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: vul_temp; Type: TABLE DATA; Schema: goagent_schema; Owner: goagent
--

COPY goagent_schema.vul_temp (vul_id, category, control_area, control_type_large, control_type_medium, item_description, risk_level, details, basis_financial, basis_critical_info, target_aix, target_hp_ux, target_system) FROM stdin;
\.


--
-- Data for Name: asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.asset (id, target_type, server_name, host_name, ip, manager, created_at) FROM stdin;
3	server	정보계1	idinfo1	192.10.10.41	홍길동	2025-05-29 12:36:26.737977
4	server	정보계2	idinfo2	192.10.10.42	홍길동	2025-05-29 12:36:26.737977
5	server	정보계3	idinfo3	192.10.10.43	홍길동	2025-05-29 12:36:26.737977
6	server	정보계4	idinfo4	192.10.10.44	홍길동	2025-05-29 12:36:26.737977
7	server	정보계5	idinfo5	192.10.10.45	홍길동	2025-05-29 12:36:26.737977
8	server	정보계6	idinfo6	192.10.10.46	홍길동	2025-05-29 12:36:26.737977
9	server	정보계7	idinfo7	192.10.10.47	홍길동	2025-05-29 12:36:26.737977
10	server	정보계8	idinfo8	192.10.10.48	홍길동	2025-05-29 12:36:26.737977
11	server	정보계9	idinfo9	192.10.10.49	홍길동	2025-05-29 12:36:26.737977
12	server	정보계10	idinfo10	192.10.10.50	홍길동	2025-05-29 12:36:26.737977
13	server	정보계1	idinfo1	192.10.10.41	홍길동	2025-05-29 12:37:02.792361
14	server	정보계2	idinfo2	192.10.10.42	홍길동	2025-05-29 12:37:02.792361
15	server	정보계3	idinfo3	192.10.10.43	홍길동	2025-05-29 12:37:02.792361
16	server	정보계4	idinfo4	127.0.0.1	홍길동dfsfd	2025-05-29 12:37:02.792361
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: goagent
--

COPY public.audit_log (log_id, user_id, action, "timestamp") FROM stdin;
\.


--
-- Data for Name: evaluation_results; Type: TABLE DATA; Schema: public; Owner: goagent
--

COPY public.evaluation_results (id, templateid, templatename, host_name, item_id, item_name, result, risk_level, risk_score, vuln_score, checked_by_agent, last_checked_at, detail, risk_grade, service_status) FROM stdin;
1	tmpl-test001	보안 점검 템플릿	ubuntu-server	SRV-001	SNMPv3 설정 여부 확인	미점검	상	90	20	f	\N	\N	\N	\N
2	tmpl-test002	보안 점검 템플릿	ubuntu-server	SRV-002	패스워드 복잡도 설정 여부	미점검	상	85	25	f	\N	\N	\N	\N
4	tmpl-0yco8ae3	ttdadf	tesatestset	SRV-002	임시 점검 항목 2	미점검	중	50	10	f	\N	\N	\N	\N
5	tmpl-0yco8ae3	ttdadf	tesatestset	SRV-003	임시 점검 항목 3	미점검	중	50	10	f	\N	\N	\N	\N
6	tmpl-0yco8ae3	ttdadf	tesatestset	SRV-004	임시 점검 항목 4	미점검	중	50	10	f	\N	\N	\N	\N
7	tmpl-0yco8ae3	ttdadf	tesatestset	SRV-005	임시 점검 항목 5	미점검	중	50	10	f	\N	\N	\N	\N
8	tmpl-0yco8ae3	ttdadf	tesatestset	SRV-006	임시 점검 항목 6	미점검	중	50	10	f	\N	\N	\N	\N
9	tmpl-0yco8ae3	ttdadf	tesatestset	SRV-007	임시 점검 항목 7	미점검	중	50	10	f	\N	\N	\N	\N
10	tmpl-0yco8ae3	ttdadf	tesatestset	SRV-008	임시 점검 항목 8	미점검	중	50	10	f	\N	\N	\N	\N
11	tmpl-0yco8ae3	ttdadf	tesatestset	SRV-009	임시 점검 항목 9	미점검	중	50	10	f	\N	\N	\N	\N
12	tmpl-0yco8ae3	ttdadf	tesatestset	SRV-010	임시 점검 항목 10	미점검	중	50	10	f	\N	\N	\N	\N
14	tmpl-1os4yt9z	testsetsetest	ttestsetsetsetset	SRV-002	임시 점검 항목 2	미점검	중	50	10	f	\N	\N	\N	\N
15	tmpl-1os4yt9z	testsetsetest	ttestsetsetsetset	SRV-003	임시 점검 항목 3	미점검	중	50	10	f	\N	\N	\N	\N
16	tmpl-1os4yt9z	testsetsetest	ttestsetsetsetset	SRV-004	임시 점검 항목 4	미점검	중	50	10	f	\N	\N	\N	\N
17	tmpl-1os4yt9z	testsetsetest	ttestsetsetsetset	SRV-005	임시 점검 항목 5	미점검	중	50	10	f	\N	\N	\N	\N
18	tmpl-1os4yt9z	testsetsetest	ttestsetsetsetset	SRV-006	임시 점검 항목 6	미점검	중	50	10	f	\N	\N	\N	\N
19	tmpl-1os4yt9z	testsetsetest	ttestsetsetsetset	SRV-008	임시 점검 항목 8	미점검	중	50	10	f	\N	\N	\N	\N
20	tmpl-1os4yt9z	testsetsetest	ttestsetsetsetset	SRV-009	임시 점검 항목 9	미점검	중	50	10	f	\N	\N	\N	\N
21	tmpl-1os4yt9z	testsetsetest	ttestsetsetsetset	SRV-010	임시 점검 항목 10	미점검	중	50	10	f	\N	\N	\N	\N
13	tmpl-1os4yt9z	testsetsetest	ttestsetsetsetset	SRV-001	임시 점검 항목 1	점검 중	중	50	10	f	2025-05-22 11:27:39.534476	\N	\N	\N
3	tmpl-0yco8ae3	ttdadf	tesatestset	SRV-001	임시 점검 항목 1	점검 중	중	50	10	f	2025-05-22 11:29:23.708578	\N	\N	\N
23	tmpl-98u5f6w3	ttdadf	tesatestset	SRV-002	임시 점검 항목 2	미점검	중	50	10	f	\N	\N	\N	\N
24	tmpl-98u5f6w3	ttdadf	tesatestset	SRV-003	임시 점검 항목 3	미점검	중	50	10	f	\N	\N	\N	\N
25	tmpl-98u5f6w3	ttdadf	tesatestset	SRV-004	임시 점검 항목 4	미점검	중	50	10	f	\N	\N	\N	\N
26	tmpl-98u5f6w3	ttdadf	tesatestset	SRV-005	임시 점검 항목 5	미점검	중	50	10	f	\N	\N	\N	\N
27	tmpl-98u5f6w3	ttdadf	tesatestset	SRV-006	임시 점검 항목 6	미점검	중	50	10	f	\N	\N	\N	\N
28	tmpl-98u5f6w3	ttdadf	tesatestset	SRV-007	임시 점검 항목 7	미점검	중	50	10	f	\N	\N	\N	\N
22	tmpl-98u5f6w3	ttdadf	tesatestset	SRV-001	임시 점검 항목 1	점검 중	중	50	10	f	2025-05-22 11:29:36.881765	\N	\N	\N
39	tmpl-foxd9im0	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-003	임시 점검 항목 3	미점검	중	50	10	f	\N	\N	\N	\N
40	tmpl-foxd9im0	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-004	임시 점검 항목 4	미점검	중	50	10	f	\N	\N	\N	\N
42	tmpl-foxd9im0	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-006	임시 점검 항목 6	미점검	중	50	10	f	\N	\N	\N	\N
46	tmpl-foxd9im0	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-010	임시 점검 항목 10	미점검	중	50	10	f	\N	\N	\N	\N
49	tmpl-4hw3pxpo	009	009	SRV-003	\N	미점검	중	50	10	f	\N	\N	\N	\N
52	tmpl-4hw3pxpo	009	009	SRV-006	\N	미점검	중	50	10	f	\N	\N	\N	\N
54	tmpl-4hw3pxpo	009	009	SRV-008	\N	미점검	중	50	10	f	\N	\N	\N	\N
59	tmpl-my7njkos	009	009	SRV-003	\N	점검 중	중	50	10	f	2025-05-22 17:02:57.666564	\N	\N	\N
48	tmpl-4hw3pxpo	009	009	SRV-002	\N	미점검	중	50	10	t	2025-05-22 17:02:57.540087	❓ 알 수 없는 항목	\N	N/A
53	tmpl-4hw3pxpo	009	009	SRV-007	\N	미점검	중	50	10	t	2025-05-22 17:03:04.788316	❓ 알 수 없는 항목	\N	N/A
50	tmpl-4hw3pxpo	009	009	SRV-004	\N	취약	중	50	10	t	2025-05-22 17:02:59.702063	다음 SMTP 관련 프로세스가 확인되었습니다: sendmail	\N	sendmail
62	tmpl-my7njkos	009	009	SRV-006	\N	점검 중	중	50	10	f	2025-05-22 17:03:02.157209	\N	\N	\N
55	tmpl-4hw3pxpo	009	009	SRV-009	\N	미점검	중	50	10	t	2025-05-22 17:03:06.800698	❓ 알 수 없는 항목	\N	N/A
56	tmpl-4hw3pxpo	009	009	SRV-010	\N	미점검	중	50	10	t	2025-05-22 17:03:08.808202	❓ 알 수 없는 항목	\N	N/A
37	tmpl-foxd9im0	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-001	임시 점검 항목 1	양호	중	50	10	t	2025-05-22 17:06:12.227817	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	\N	SNMP
31	tmpl-d6rcosy9	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-004	임시 점검 항목 4	점검 중	중	50	10	f	2025-05-22 17:04:40.11293	\N	\N	\N
38	tmpl-foxd9im0	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-002	임시 점검 항목 2	미점검	중	50	10	t	2025-05-22 17:04:40.042513	❓ 알 수 없는 항목	\N	N/A
33	tmpl-d6rcosy9	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-006	임시 점검 항목 6	점검 중	중	50	10	f	2025-05-22 17:04:43.111934	\N	\N	\N
41	tmpl-foxd9im0	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-005	임시 점검 항목 5	취약	중	50	10	t	2025-05-22 17:04:43.057116	VRFY 명령 결과를 해석할 수 없음\nSendmail 설정(/etc/mail/sendmail.cf): noexpn/novrfy 설정 없음 → 취약\nPostfix 설정: disable_vrfy_command 설정 없음 → 취약	\N	미확인
43	tmpl-foxd9im0	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-007	임시 점검 항목 7	미점검	중	50	10	t	2025-05-22 17:04:45.063838	❓ 알 수 없는 항목	\N	N/A
44	tmpl-foxd9im0	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-008	임시 점검 항목 8	미점검	중	50	10	t	2025-05-22 17:04:47.070131	❓ 알 수 없는 항목	\N	N/A
35	tmpl-d6rcosy9	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-008	임시 점검 항목 8	미점검	중	50	10	t	2025-05-22 17:04:47.070131	❓ 알 수 없는 항목	\N	N/A
45	tmpl-foxd9im0	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-009	임시 점검 항목 9	미점검	중	50	10	t	2025-05-22 17:04:49.08259	❓ 알 수 없는 항목	\N	N/A
29	tmpl-d6rcosy9	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-001	임시 점검 항목 1	양호	중	50	10	t	2025-05-22 17:06:12.227817	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	\N	SNMP
69	tmpl-rv9efams	0091111	0091	SRV-003	\N	미점검	중	50	10	f	\N	\N	\N	\N
70	tmpl-rv9efams	0091111	0091	SRV-004	\N	미점검	중	50	10	f	\N	\N	\N	\N
71	tmpl-rv9efams	0091111	0091	SRV-005	\N	미점검	중	50	10	f	\N	\N	\N	\N
72	tmpl-rv9efams	0091111	0091	SRV-006	\N	미점검	중	50	10	f	\N	\N	\N	\N
73	tmpl-rv9efams	0091111	0091	SRV-007	\N	미점검	중	50	10	f	\N	\N	\N	\N
74	tmpl-rv9efams	0091111	0091	SRV-008	\N	미점검	중	50	10	f	\N	\N	\N	\N
75	tmpl-rv9efams	0091111	0091	SRV-009	\N	미점검	중	50	10	f	\N	\N	\N	\N
76	tmpl-rv9efams	0091111	0091	SRV-010	\N	미점검	중	50	10	f	\N	\N	\N	\N
108	tmpl-4twh0qz0	hhhhh	hhhhh	SRV-002	\N	미점검	중	50	10	f	\N	\N	3	\N
109	tmpl-4twh0qz0	hhhhh	hhhhh	SRV-003	\N	미점검	중	50	10	f	\N	\N	3	\N
98	tmpl-ui9km8sm	11121212	34324234234	SRV-002	\N	미점검	중	50	10	f	\N	\N	3	\N
99	tmpl-ui9km8sm	11121212	34324234234	SRV-003	\N	미점검	중	50	10	f	\N	\N	3	\N
100	tmpl-ui9km8sm	11121212	34324234234	SRV-004	\N	미점검	중	50	10	f	\N	\N	3	\N
68	tmpl-rv9efams	0091111	0091	SRV-002	\N	❓ 알 수 없는 항목	중	50	10	t	2025-05-22 12:30:28.047102		\N	\N
101	tmpl-ui9km8sm	11121212	34324234234	SRV-005	\N	미점검	중	50	10	f	\N	\N	3	\N
67	tmpl-rv9efams	0091111	0091	SRV-001	\N	양호	중	50	10	t	2025-05-22 12:44:59.694518	Debian-+    1556       1  0 08:03 ?        00:00:06 /usr/sbin/snmpd -LOw -u Debian-snmp -g Debian-snmp -I -smux mteTrigger mteTriggerConf -f\n	\N	\N
78	tmpl-2cyyrqo6	gasgdag	sgsdgsag	SRV-002	\N	미점검	중	50	10	f	\N	\N	3	\N
79	tmpl-2cyyrqo6	gasgdag	sgsdgsag	SRV-003	\N	미점검	중	50	10	f	\N	\N	3	\N
80	tmpl-2cyyrqo6	gasgdag	sgsdgsag	SRV-004	\N	미점검	중	50	10	f	\N	\N	3	\N
81	tmpl-2cyyrqo6	gasgdag	sgsdgsag	SRV-005	\N	미점검	중	50	10	f	\N	\N	3	\N
82	tmpl-2cyyrqo6	gasgdag	sgsdgsag	SRV-006	\N	미점검	중	50	10	f	\N	\N	3	\N
83	tmpl-2cyyrqo6	gasgdag	sgsdgsag	SRV-007	\N	미점검	중	50	10	f	\N	\N	3	\N
84	tmpl-2cyyrqo6	gasgdag	sgsdgsag	SRV-008	\N	미점검	중	50	10	f	\N	\N	3	\N
85	tmpl-2cyyrqo6	gasgdag	sgsdgsag	SRV-009	\N	미점검	중	50	10	f	\N	\N	3	\N
86	tmpl-2cyyrqo6	gasgdag	sgsdgsag	SRV-010	\N	미점검	중	50	10	f	\N	\N	3	\N
102	tmpl-ui9km8sm	11121212	34324234234	SRV-006	\N	미점검	중	50	10	f	\N	\N	3	\N
77	tmpl-2cyyrqo6	gasgdag	sgsdgsag	SRV-001	\N	양호	중	50	10	t	2025-05-22 12:51:49.621347	Debian-+    1556       1  0 08:03 ?        00:00:06 /usr/sbin/snmpd -LOw -u Debian-snmp -g Debian-snmp -I -smux mteTrigger mteTriggerConf -f\n	3	\N
88	tmpl-dmkhrz5s	t1212121	141432432	SRV-002	\N	미점검	중	50	10	f	\N	\N	3	\N
89	tmpl-dmkhrz5s	t1212121	141432432	SRV-003	\N	미점검	중	50	10	f	\N	\N	3	\N
90	tmpl-dmkhrz5s	t1212121	141432432	SRV-004	\N	미점검	중	50	10	f	\N	\N	3	\N
91	tmpl-dmkhrz5s	t1212121	141432432	SRV-005	\N	미점검	중	50	10	f	\N	\N	3	\N
92	tmpl-dmkhrz5s	t1212121	141432432	SRV-006	\N	미점검	중	50	10	f	\N	\N	3	\N
93	tmpl-dmkhrz5s	t1212121	141432432	SRV-007	\N	미점검	중	50	10	f	\N	\N	3	\N
94	tmpl-dmkhrz5s	t1212121	141432432	SRV-008	\N	미점검	중	50	10	f	\N	\N	3	\N
95	tmpl-dmkhrz5s	t1212121	141432432	SRV-009	\N	미점검	중	50	10	f	\N	\N	3	\N
96	tmpl-dmkhrz5s	t1212121	141432432	SRV-010	\N	미점검	중	50	10	f	\N	\N	3	\N
103	tmpl-ui9km8sm	11121212	34324234234	SRV-007	\N	미점검	중	50	10	f	\N	\N	3	\N
104	tmpl-ui9km8sm	11121212	34324234234	SRV-008	\N	미점검	중	50	10	f	\N	\N	3	\N
105	tmpl-ui9km8sm	11121212	34324234234	SRV-009	\N	미점검	중	50	10	f	\N	\N	3	\N
106	tmpl-ui9km8sm	11121212	34324234234	SRV-010	\N	미점검	중	50	10	f	\N	\N	3	\N
110	tmpl-4twh0qz0	hhhhh	hhhhh	SRV-004	\N	미점검	중	50	10	f	\N	\N	3	\N
111	tmpl-4twh0qz0	hhhhh	hhhhh	SRV-005	\N	미점검	중	50	10	f	\N	\N	3	\N
112	tmpl-4twh0qz0	hhhhh	hhhhh	SRV-006	\N	미점검	중	50	10	f	\N	\N	3	\N
113	tmpl-4twh0qz0	hhhhh	hhhhh	SRV-007	\N	미점검	중	50	10	f	\N	\N	3	\N
114	tmpl-4twh0qz0	hhhhh	hhhhh	SRV-008	\N	미점검	중	50	10	f	\N	\N	3	\N
87	tmpl-dmkhrz5s	t1212121	141432432	SRV-001	\N	점검 중	중	50	10	f	2025-05-22 13:40:34.911646	Debian-+    1556       1  0 08:03 ?        00:00:06 /usr/sbin/snmpd -LOw -u Debian-snmp -g Debian-snmp -I -smux mteTrigger mteTriggerConf -f\n	3	\N
115	tmpl-4twh0qz0	hhhhh	hhhhh	SRV-009	\N	미점검	중	50	10	f	\N	\N	3	\N
116	tmpl-4twh0qz0	hhhhh	hhhhh	SRV-010	\N	미점검	중	50	10	f	\N	\N	3	\N
155	tmpl-pwng7gge	test5552	222	SRV-009	\N	미점검	중	50	10	t	2025-05-22 16:13:40.878396	❓ 알 수 없는 항목	3	N/A
64	tmpl-my7njkos	009	009	SRV-008	\N	점검 중	중	50	10	f	2025-05-22 17:03:05.157365	\N	\N	\N
156	tmpl-pwng7gge	test5552	222	SRV-010	\N	미점검	중	50	10	t	2025-05-22 16:13:42.925469	❓ 알 수 없는 항목	3	N/A
57	tmpl-my7njkos	009	009	SRV-001	\N	양호	중	50	10	t	2025-05-22 17:03:13.905171	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	\N	SNMP
61	tmpl-my7njkos	009	009	SRV-005	\N	취약	중	50	10	t	2025-05-22 17:03:02.722674	VRFY 명령 결과를 해석할 수 없음\nSendmail 설정(/etc/mail/sendmail.cf): noexpn/novrfy 설정 없음 → 취약\nPostfix 설정: disable_vrfy_command 설정 없음 → 취약	\N	미확인
63	tmpl-my7njkos	009	009	SRV-007	\N	미점검	중	50	10	t	2025-05-22 17:03:04.788316	❓ 알 수 없는 항목	\N	N/A
32	tmpl-d6rcosy9	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-005	임시 점검 항목 5	취약	중	50	10	t	2025-05-22 17:04:43.057116	VRFY 명령 결과를 해석할 수 없음\nSendmail 설정(/etc/mail/sendmail.cf): noexpn/novrfy 설정 없음 → 취약\nPostfix 설정: disable_vrfy_command 설정 없음 → 취약	\N	미확인
65	tmpl-my7njkos	009	009	SRV-009	\N	미점검	중	50	10	t	2025-05-22 17:03:06.800698	❓ 알 수 없는 항목	\N	N/A
66	tmpl-my7njkos	009	009	SRV-010	\N	미점검	중	50	10	t	2025-05-22 17:03:08.808202	❓ 알 수 없는 항목	\N	N/A
47	tmpl-4hw3pxpo	009	009	SRV-001	\N	양호	중	50	10	t	2025-05-22 17:03:13.905171	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	\N	SNMP
34	tmpl-d6rcosy9	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-007	임시 점검 항목 7	미점검	중	50	10	t	2025-05-22 17:04:45.063838	❓ 알 수 없는 항목	\N	N/A
149	tmpl-pwng7gge	test5552	222	SRV-003	\N	점검 중	중	50	10	f	2025-05-22 16:13:31.794332	❓ 알 수 없는 항목	3	N/A
152	tmpl-pwng7gge	test5552	222	SRV-006	\N	점검 중	중	50	10	f	2025-05-22 16:13:36.291083	Postfix 설정에 debug_peer_level 항목이 없음 → 취약\nSyslog 설정 파일 존재 확인됨: /etc/rsyslog.conf\nrsyslog.d에 4개 설정 파일 존재	3	debug_peer_level 미설정
151	tmpl-pwng7gge	test5552	222	SRV-005	\N	취약	중	50	10	t	2025-05-22 16:13:36.843559	VRFY 명령 결과를 해석할 수 없음\nSendmail 설정(/etc/mail/sendmail.cf): noexpn/novrfy 설정 없음 → 취약\nPostfix 설정: disable_vrfy_command 설정 없음 → 취약	3	미확인
154	tmpl-pwng7gge	test5552	222	SRV-008	\N	점검 중	중	50	10	f	2025-05-22 16:13:39.294944	❓ 알 수 없는 항목	3	N/A
148	tmpl-pwng7gge	test5552	222	SRV-002	\N	미점검	중	50	10	t	2025-05-22 16:13:31.652225	❓ 알 수 없는 항목	3	N/A
147	tmpl-pwng7gge	test5552	222	SRV-001	\N	양호	중	50	10	t	2025-05-22 16:13:29.640496	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	3	SNMP
107	tmpl-4twh0qz0	hhhhh	hhhhh	SRV-001	\N	양호	중	50	10	t	2025-05-22 13:53:34.152841	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	3	\N
118	tmpl-q4p61zo1	hhhhh	hhhhhㄴㄹㄴㅇㄹㄴㅇ	SRV-002	\N	미점검	중	50	10	f	\N	\N	3	\N
119	tmpl-q4p61zo1	hhhhh	hhhhhㄴㄹㄴㅇㄹㄴㅇ	SRV-003	\N	미점검	중	50	10	f	\N	\N	3	\N
120	tmpl-q4p61zo1	hhhhh	hhhhhㄴㄹㄴㅇㄹㄴㅇ	SRV-004	\N	미점검	중	50	10	f	\N	\N	3	\N
121	tmpl-q4p61zo1	hhhhh	hhhhhㄴㄹㄴㅇㄹㄴㅇ	SRV-005	\N	미점검	중	50	10	f	\N	\N	3	\N
122	tmpl-q4p61zo1	hhhhh	hhhhhㄴㄹㄴㅇㄹㄴㅇ	SRV-006	\N	미점검	중	50	10	f	\N	\N	3	\N
123	tmpl-q4p61zo1	hhhhh	hhhhhㄴㄹㄴㅇㄹㄴㅇ	SRV-007	\N	미점검	중	50	10	f	\N	\N	3	\N
124	tmpl-q4p61zo1	hhhhh	hhhhhㄴㄹㄴㅇㄹㄴㅇ	SRV-008	\N	미점검	중	50	10	f	\N	\N	3	\N
125	tmpl-q4p61zo1	hhhhh	hhhhhㄴㄹㄴㅇㄹㄴㅇ	SRV-009	\N	미점검	중	50	10	f	\N	\N	3	\N
126	tmpl-q4p61zo1	hhhhh	hhhhhㄴㄹㄴㅇㄹㄴㅇ	SRV-010	\N	미점검	중	50	10	f	\N	\N	3	\N
157	tmpl-i2xgffjf	121212121212	12121212121212	SRV-001	\N	미점검	중	50	10	f	\N	\N	3	\N
117	tmpl-q4p61zo1	hhhhh	hhhhhㄴㄹㄴㅇㄹㄴㅇ	SRV-001	\N	양호	중	50	10	t	2025-05-22 13:53:48.258266	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	3	\N
128	tmpl-6kq2pyrx	hhhhh121212	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-002	\N	미점검	중	50	10	f	\N	\N	3	\N
129	tmpl-6kq2pyrx	hhhhh121212	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-003	\N	미점검	중	50	10	f	\N	\N	3	\N
130	tmpl-6kq2pyrx	hhhhh121212	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-004	\N	미점검	중	50	10	f	\N	\N	3	\N
131	tmpl-6kq2pyrx	hhhhh121212	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-005	\N	미점검	중	50	10	f	\N	\N	3	\N
132	tmpl-6kq2pyrx	hhhhh121212	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-006	\N	미점검	중	50	10	f	\N	\N	3	\N
133	tmpl-6kq2pyrx	hhhhh121212	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-007	\N	미점검	중	50	10	f	\N	\N	3	\N
134	tmpl-6kq2pyrx	hhhhh121212	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-008	\N	미점검	중	50	10	f	\N	\N	3	\N
135	tmpl-6kq2pyrx	hhhhh121212	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-009	\N	미점검	중	50	10	f	\N	\N	3	\N
136	tmpl-6kq2pyrx	hhhhh121212	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-010	\N	미점검	중	50	10	f	\N	\N	3	\N
158	tmpl-i2xgffjf	121212121212	12121212121212	SRV-002	\N	미점검	중	50	10	f	\N	\N	3	\N
159	tmpl-i2xgffjf	121212121212	12121212121212	SRV-003	\N	미점검	중	50	10	f	\N	\N	3	\N
127	tmpl-6kq2pyrx	hhhhh121212	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-001	\N	점검 중	중	50	10	f	2025-05-22 14:04:28.085404	SNMP 버전: v3\nauthPriv 설정되어 있어 양호	3	\N
138	tmpl-a9r6tqm6	hhhhh121212wew	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-002	\N	미점검	중	50	10	f	\N	\N	3	\N
139	tmpl-a9r6tqm6	hhhhh121212wew	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-003	\N	미점검	중	50	10	f	\N	\N	3	\N
140	tmpl-a9r6tqm6	hhhhh121212wew	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-004	\N	미점검	중	50	10	f	\N	\N	3	\N
141	tmpl-a9r6tqm6	hhhhh121212wew	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-005	\N	미점검	중	50	10	f	\N	\N	3	\N
142	tmpl-a9r6tqm6	hhhhh121212wew	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-006	\N	미점검	중	50	10	f	\N	\N	3	\N
143	tmpl-a9r6tqm6	hhhhh121212wew	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-007	\N	미점검	중	50	10	f	\N	\N	3	\N
144	tmpl-a9r6tqm6	hhhhh121212wew	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-008	\N	미점검	중	50	10	f	\N	\N	3	\N
145	tmpl-a9r6tqm6	hhhhh121212wew	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-009	\N	미점검	중	50	10	f	\N	\N	3	\N
146	tmpl-a9r6tqm6	hhhhh121212wew	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-010	\N	미점검	중	50	10	f	\N	\N	3	\N
137	tmpl-a9r6tqm6	hhhhh121212wew	hhhhhㄴㄹㄴㅇㄹㄴㅇ1212	SRV-001	\N	점검 중	중	50	10	f	2025-05-22 14:04:49.23643	\N	3	\N
160	tmpl-i2xgffjf	121212121212	12121212121212	SRV-004	\N	미점검	중	50	10	f	\N	\N	3	\N
161	tmpl-i2xgffjf	121212121212	12121212121212	SRV-005	\N	미점검	중	50	10	f	\N	\N	3	\N
162	tmpl-i2xgffjf	121212121212	12121212121212	SRV-006	\N	미점검	중	50	10	f	\N	\N	3	\N
163	tmpl-i2xgffjf	121212121212	12121212121212	SRV-007	\N	미점검	중	50	10	f	\N	\N	3	\N
164	tmpl-i2xgffjf	121212121212	12121212121212	SRV-008	\N	미점검	중	50	10	f	\N	\N	3	\N
165	tmpl-i2xgffjf	121212121212	12121212121212	SRV-009	\N	미점검	중	50	10	f	\N	\N	3	\N
166	tmpl-i2xgffjf	121212121212	12121212121212	SRV-010	\N	미점검	중	50	10	f	\N	\N	3	\N
150	tmpl-pwng7gge	test5552	222	SRV-004	\N	취약	중	50	10	t	2025-05-22 16:13:33.836891	다음 SMTP 관련 프로세스가 확인되었습니다: sendmail	3	sendmail
153	tmpl-pwng7gge	test5552	222	SRV-007	\N	미점검	중	50	10	t	2025-05-22 16:13:38.852215	❓ 알 수 없는 항목	3	N/A
58	tmpl-my7njkos	009	009	SRV-002	\N	미점검	중	50	10	t	2025-05-22 17:02:57.540087	❓ 알 수 없는 항목	\N	N/A
60	tmpl-my7njkos	009	009	SRV-004	\N	취약	중	50	10	t	2025-05-22 17:02:59.702063	다음 SMTP 관련 프로세스가 확인되었습니다: sendmail	\N	sendmail
51	tmpl-4hw3pxpo	009	009	SRV-005	\N	취약	중	50	10	t	2025-05-22 17:03:02.722674	VRFY 명령 결과를 해석할 수 없음\nSendmail 설정(/etc/mail/sendmail.cf): noexpn/novrfy 설정 없음 → 취약\nPostfix 설정: disable_vrfy_command 설정 없음 → 취약	\N	미확인
30	tmpl-d6rcosy9	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-002	임시 점검 항목 2	미점검	중	50	10	t	2025-05-22 17:04:40.042513	❓ 알 수 없는 항목	\N	N/A
36	tmpl-d6rcosy9	aaaaaaaaaaaaa	aaaaaaaaaaaaaa	SRV-009	임시 점검 항목 9	미점검	중	50	10	t	2025-05-22 17:04:49.08259	❓ 알 수 없는 항목	\N	N/A
97	tmpl-ui9km8sm	11121212	34324234234	SRV-001	\N	점검 중	중	50	10	f	2025-05-26 14:24:13.818861	\N	3	\N
190	33	po	idinfo9	SRV-005	\N	미점검	중	\N	\N	f	\N	\N	3	\N
191	33	po	idinfo9	SRV-007	\N	미점검	중	\N	\N	f	\N	\N	3	\N
192	33	po	idinfo9	SRV-008	\N	미점검	중	\N	\N	f	\N	\N	3	\N
185	38	tttt	idinfo6	SRV-007	\N	점검 중	중	\N	\N	f	2025-05-30 16:04:49.480128	\N	3	\N
184	38	tttt	idinfo6	SRV-005	\N	취약	중	\N	\N	t	2025-05-30 16:04:50.352926	VRFY 명령 결과를 해석할 수 없음\nSendmail 설정(/etc/mail/sendmail.cf): noexpn/novrfy 설정 없음 → 취약\nPostfix 설정: disable_vrfy_command 설정 없음 → 취약	3	미확인
186	38	tttt	idinfo6	SRV-008	\N	미점검	중	\N	\N	t	2025-05-30 16:04:52.386113	❓ 알 수 없는 항목	3	N/A
194	37	testppp	idinfo5	SRV-007	\N	미점검	중	\N	\N	t	2025-05-30 16:04:54.393273	❓ 알 수 없는 항목	3	N/A
188	38	tttt	idinfo5	SRV-007	\N	미점검	중	\N	\N	t	2025-05-30 16:04:54.393273	❓ 알 수 없는 항목	3	N/A
195	37	testppp	idinfo5	SRV-008	\N	미점검	중	\N	\N	t	2025-05-30 16:04:56.399568	❓ 알 수 없는 항목	3	N/A
189	38	tttt	idinfo5	SRV-008	\N	미점검	중	\N	\N	t	2025-05-30 16:04:56.399568	❓ 알 수 없는 항목	3	N/A
196	38	tttt	idinfo4	SRV-005	\N	취약	중	\N	\N	t	2025-05-30 16:04:59.54173	VRFY 명령 결과를 해석할 수 없음\nSendmail 설정(/etc/mail/sendmail.cf): noexpn/novrfy 설정 없음 → 취약\nPostfix 설정: disable_vrfy_command 설정 없음 → 취약	3	미확인
197	38	tttt	idinfo4	SRV-007	\N	미점검	중	\N	\N	t	2025-05-30 16:05:01.550153	❓ 알 수 없는 항목	3	N/A
198	38	tttt	idinfo4	SRV-008	\N	미점검	중	\N	\N	t	2025-05-30 16:05:05.626287	❓ 알 수 없는 항목	3	N/A
193	37	testppp	idinfo5	SRV-005	\N	취약	중	\N	\N	t	2025-05-30 16:05:17.660573	VRFY 명령 결과를 해석할 수 없음\nSendmail 설정(/etc/mail/sendmail.cf): noexpn/novrfy 설정 없음 → 취약\nPostfix 설정: disable_vrfy_command 설정 없음 → 취약	3	미확인
187	38	tttt	idinfo5	SRV-005	\N	취약	중	\N	\N	t	2025-05-30 16:05:17.660573	VRFY 명령 결과를 해석할 수 없음\nSendmail 설정(/etc/mail/sendmail.cf): noexpn/novrfy 설정 없음 → 취약\nPostfix 설정: disable_vrfy_command 설정 없음 → 취약	3	미확인
\.


--
-- Data for Name: pages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pages (id, page_name, url_path, description) FROM stdin;
\.


--
-- Data for Name: role_page_access; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_page_access (role_id, page_id) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, role_name, description) FROM stdin;
\.


--
-- Data for Name: template; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.template (template_id, template_name, target_type, basis_type, created_at, description) FROM stdin;
7	lfdgd	Server	전자금융,주요정보	2025-05-28 13:52:58.746682	\N
8	yrdydry	Server	전자금융,주요정보	2025-05-28 13:53:12.099218	\N
9	ㄹㅇㄹ	Server	전자금융,주요정보	2025-05-28 14:03:30.678277	\N
10	ㄹㅇㄹ	Server	전자금융,주요정보	2025-05-28 14:03:30.714139	\N
11	ㅅㄷㄴㅅ	Server	전자금융,주요정보	2025-05-28 14:07:42.40982	\N
12	ㅅㄷㄴㅅ	Server	전자금융,주요정보	2025-05-28 14:07:54.603446	\N
13	ㅅㄷㄴㅅ123	Server	전자금육,주요정보	2025-05-28 14:16:13.969752	\N
14	ㅅㄷㄴㅅ123	Server	전자금육,주요정보	2025-05-28 14:16:25.282525	\N
15	ㅅㄷㄴㅅ123	Server	전자금육,주요정보	2025-05-28 14:16:34.976912	\N
16	ㅅㄷㄴㅅ1231	Server	전자금육,주요정보	2025-05-28 14:27:22.29765	\N
17	ㅅㄷㄴㅅ1231	Server	전자금육,주요정보	2025-05-28 14:27:35.289641	\N
18	ㅅㄷ2	Server	전자금육,주요정보	2025-05-28 14:35:51.534569	\N
19	ㅅㄷ2	Server	전자금육,주요정보	2025-05-28 14:35:54.461243	\N
20	123	Server	전자금육,주요정보	2025-05-28 14:39:30.127591	\N
21	123	Server	전자금육,주요정보	2025-05-28 14:39:32.014535	\N
22	123	Server	전자금육,주요정보	2025-05-28 14:39:33.438197	\N
23	123	Server	전자금육,주요정보	2025-05-28 14:39:34.999785	\N
24	2ㅈㄷㅈ	Server	전자금육,주요정보	2025-05-28 14:43:19.648252	\N
25	2ㅈㄷㅈ	Server	전자금육,주요정보	2025-05-28 14:43:21.511743	\N
26	2ㅈㄷㅈ	Server	전자금육,주요정보	2025-05-28 14:43:23.447257	\N
27	ppp	Server	전자금육,주요정보	2025-05-28 14:44:10.56656	\N
28	ppp	Server	전자금육,주요정보	2025-05-28 14:44:12.456265	\N
29	po	Server	전자금육,주요정보	2025-05-28 14:50:35.664403	\N
30	po	Server	전자금육,주요정보	2025-05-28 14:50:37.896145	\N
31	po	Server	전자금육,주요정보	2025-05-28 14:50:49.647879	\N
32	po	Server	전자금육,주요정보	2025-05-28 14:51:26.440575	\N
33	po	Server	전자금육,주요정보	2025-05-28 14:51:28.970458	\N
34	po1	Server	전자금육,주요정보	2025-05-28 14:59:21.260891	\N
35	ㄳㄷ	Server	전자금육,주요정보	2025-05-28 15:07:33.301702	\N
36	test	Server	전자금육,주요정보	2025-05-28 15:38:24.25354	\N
37	testppp	Server	전자금육,주요정보	2025-05-30 08:23:36.729041	\N
38	tttt	Server	전자금육,주요정보	2025-05-30 13:41:42.541808	\N
\.


--
-- Data for Name: template_vuln; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.template_vuln (id, template_id, vul_id, vul_name) FROM stdin;
1	7	SRV-005	불필요한 SMTP 서비스 실행
2	7	SRV-006	방화벽 정책 설정 미흡
3	7	SRV-007	보안 정책 미흡
4	7	SRV-008	서버실 출입관리 미흡
5	8	SRV-005	불필요한 SMTP 서비스 실행
6	8	SRV-006	방화벽 정책 설정 미흡
7	8	SRV-007	보안 정책 미흡
8	8	SRV-008	서버실 출입관리 미흡
9	9	SRV-005	불필요한 SMTP 서비스 실행
10	9	SRV-006	방화벽 정책 설정 미흡
11	9	SRV-007	보안 정책 미흡
12	9	SRV-008	서버실 출입관리 미흡
13	10	SRV-005	불필요한 SMTP 서비스 실행
14	10	SRV-006	방화벽 정책 설정 미흡
15	10	SRV-007	보안 정책 미흡
16	10	SRV-008	서버실 출입관리 미흡
17	11	SRV-005	불필요한 SMTP 서비스 실행
18	11	SRV-006	방화벽 정책 설정 미흡
19	11	SRV-007	보안 정책 미흡
20	11	SRV-008	서버실 출입관리 미흡
21	12	SRV-005	불필요한 SMTP 서비스 실행
22	12	SRV-006	방화벽 정책 설정 미흡
23	12	SRV-007	보안 정책 미흡
24	12	SRV-008	서버실 출입관리 미흡
25	13	SRV-005	불필요한 SMTP 서비스 실행
26	13	SRV-007	보안 정책 미흡
27	13	SRV-008	서버실 출입관리 미흡
28	14	SRV-005	불필요한 SMTP 서비스 실행
29	14	SRV-007	보안 정책 미흡
30	14	SRV-008	서버실 출입관리 미흡
31	15	SRV-005	불필요한 SMTP 서비스 실행
32	15	SRV-007	보안 정책 미흡
33	15	SRV-008	서버실 출입관리 미흡
34	16	SRV-005	불필요한 SMTP 서비스 실행
35	16	SRV-007	보안 정책 미흡
36	16	SRV-008	서버실 출입관리 미흡
37	17	SRV-005	불필요한 SMTP 서비스 실행
38	17	SRV-007	보안 정책 미흡
39	17	SRV-008	서버실 출입관리 미흡
40	18	SRV-005	불필요한 SMTP 서비스 실행
41	18	SRV-007	보안 정책 미흡
42	18	SRV-008	서버실 출입관리 미흡
43	19	SRV-005	불필요한 SMTP 서비스 실행
44	19	SRV-007	보안 정책 미흡
45	19	SRV-008	서버실 출입관리 미흡
46	20	SRV-005	불필요한 SMTP 서비스 실행
47	20	SRV-007	보안 정책 미흡
48	20	SRV-008	서버실 출입관리 미흡
49	21	SRV-005	불필요한 SMTP 서비스 실행
50	21	SRV-007	보안 정책 미흡
51	21	SRV-008	서버실 출입관리 미흡
52	22	SRV-005	불필요한 SMTP 서비스 실행
53	22	SRV-007	보안 정책 미흡
54	22	SRV-008	서버실 출입관리 미흡
55	23	SRV-005	불필요한 SMTP 서비스 실행
56	23	SRV-007	보안 정책 미흡
57	23	SRV-008	서버실 출입관리 미흡
58	24	SRV-005	불필요한 SMTP 서비스 실행
59	24	SRV-007	보안 정책 미흡
60	24	SRV-008	서버실 출입관리 미흡
61	25	SRV-005	불필요한 SMTP 서비스 실행
62	25	SRV-007	보안 정책 미흡
63	25	SRV-008	서버실 출입관리 미흡
64	26	SRV-005	불필요한 SMTP 서비스 실행
65	26	SRV-007	보안 정책 미흡
66	26	SRV-008	서버실 출입관리 미흡
67	27	SRV-005	불필요한 SMTP 서비스 실행
68	27	SRV-007	보안 정책 미흡
69	27	SRV-008	서버실 출입관리 미흡
70	28	SRV-005	불필요한 SMTP 서비스 실행
71	28	SRV-007	보안 정책 미흡
72	28	SRV-008	서버실 출입관리 미흡
73	29	SRV-005	불필요한 SMTP 서비스 실행
74	29	SRV-007	보안 정책 미흡
75	29	SRV-008	서버실 출입관리 미흡
76	30	SRV-005	불필요한 SMTP 서비스 실행
77	30	SRV-007	보안 정책 미흡
78	30	SRV-008	서버실 출입관리 미흡
79	31	SRV-005	불필요한 SMTP 서비스 실행
80	31	SRV-007	보안 정책 미흡
81	31	SRV-008	서버실 출입관리 미흡
82	32	SRV-005	불필요한 SMTP 서비스 실행
83	32	SRV-007	보안 정책 미흡
84	32	SRV-008	서버실 출입관리 미흡
85	33	SRV-005	불필요한 SMTP 서비스 실행
86	33	SRV-007	보안 정책 미흡
87	33	SRV-008	서버실 출입관리 미흡
88	34	SRV-005	불필요한 SMTP 서비스 실행
89	34	SRV-007	보안 정책 미흡
90	34	SRV-008	서버실 출입관리 미흡
91	35	SRV-005	불필요한 SMTP 서비스 실행
92	35	SRV-007	보안 정책 미흡
93	35	SRV-008	서버실 출입관리 미흡
94	36	SRV-005	불필요한 SMTP 서비스 실행
95	36	SRV-007	보안 정책 미흡
96	36	SRV-008	서버실 출입관리 미흡
97	37	SRV-005	불필요한 SMTP 서비스 실행
98	37	SRV-007	보안 정책 미흡
99	37	SRV-008	서버실 출입관리 미흡
100	38	SRV-005	불필요한 SMTP 서비스 실행
101	38	SRV-007	보안 정책 미흡
102	38	SRV-008	서버실 출입관리 미흡
\.


--
-- Data for Name: templatesum; Type: TABLE DATA; Schema: public; Owner: goagent
--

COPY public.templatesum (templateid, assess_score, assess_vuln, assess_pass, assess_date) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password_hash, name, email, role, is_active, last_login, created_at, updated_at) FROM stdin;
2	user01	userpass123	사용자	user01@example.com	user	t	\N	2025-05-30 16:29:44.37745	2025-05-30 16:29:44.37745
3	auditor01	auditorpass123	감사자	auditor01@example.com	auditor	t	\N	2025-05-30 16:29:44.385656	2025-05-30 16:29:44.385656
1	admin01	$2b$12$3IhPdyV7GydZE6JAew5t9ufJ9fFQBUswzHyWaZdzqZLjF7Ej9uBee	관리자	admin01@example.com	admin	t	\N	2025-05-30 16:29:44.345947	2025-05-30 16:46:45.632818
4	test	$2b$10$3EE52gvLIVR0WNeLLIZVj.o0iPs5QvpvwhftscZ5FNC4QqGjk7Stq	test	test@naver.com	user	t	\N	2025-05-30 17:03:09.76156	2025-05-30 17:03:09.76156
\.


--
-- Data for Name: vulnerability; Type: TABLE DATA; Schema: public; Owner: goagent
--

COPY public.vulnerability (vul_id, category, control_area, control_type_large, control_type_medium, vul_name, risk_level, details, target_system, basis, basis_financial, basis_critical_info, target_aix, target_hp_ux, target_linux, target_solaris, target_win, target_webservice, target_apache, target_webtob, target_iis, target_tomcat, target_jeus, target_type) FROM stdin;
SRV-005	기술적 보안	5. 운영 관리	5.3 정보처리시스템 보호대책	5.3.2 보안 관리	불필요한 SMTP 서비스 실행	3	이 서비스는 어쩌구	\N	\N	o	o	o	o	o	o	o	o	 	 	 	 	 	Server
SRV-006	기술적 보안	5. 운영 관리	5.4 네트워크 보안	5.4.1 접근통제	방화벽 정책 설정 미흡	2	방화벽 설정이 미흡하여 외부 침입 가능성이 존재	\N	\N	o	 	o	 	o	 	 	 	 	 	 	 	 	Server
SRV-007	관리적 보안	6. 보안 정책	6.1 정책 수립	6.1.2 정책 관리	보안 정책 미흡	1	보안 정책이 문서화되어 있지 않음	\N	\N	 	o	 	 	 	o	o	 	o	 	 	 	 	Server
SRV-008	물리적 보안	7. 출입 통제	7.1 물리적 접근	7.1.1 출입 관리	서버실 출입관리 미흡	3	서버실 출입 로그가 관리되지 않음	\N	\N	o	o	 	 	 	 	 	o	 	 	o	 	o	Server
\.


--
-- Name: asset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.asset_id_seq', 24, true);


--
-- Name: audit_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: goagent
--

SELECT pg_catalog.setval('public.audit_log_log_id_seq', 1, false);


--
-- Name: evaluation_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: goagent
--

SELECT pg_catalog.setval('public.evaluation_results_id_seq', 198, true);


--
-- Name: pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pages_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 1, false);


--
-- Name: template_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.template_template_id_seq', 38, true);


--
-- Name: template_vuln_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.template_vuln_id_seq', 102, true);


--
-- Name: templatesum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.templatesum_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: vul_temp vul_temp_pkey; Type: CONSTRAINT; Schema: goagent_schema; Owner: goagent
--

ALTER TABLE ONLY goagent_schema.vul_temp
    ADD CONSTRAINT vul_temp_pkey PRIMARY KEY (vul_id);


--
-- Name: asset asset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (log_id);


--
-- Name: evaluation_results evaluation_results_pkey; Type: CONSTRAINT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.evaluation_results
    ADD CONSTRAINT evaluation_results_pkey PRIMARY KEY (id);


--
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: pages pages_url_path_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_url_path_key UNIQUE (url_path);


--
-- Name: role_page_access role_page_access_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_page_access
    ADD CONSTRAINT role_page_access_pkey PRIMARY KEY (role_id, page_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_role_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_name_key UNIQUE (role_name);


--
-- Name: template template_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template
    ADD CONSTRAINT template_pkey PRIMARY KEY (template_id);


--
-- Name: template_vuln template_vuln_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.template_vuln
    ADD CONSTRAINT template_vuln_pkey PRIMARY KEY (id);


--
-- Name: templatesum templatesum_pkey; Type: CONSTRAINT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.templatesum
    ADD CONSTRAINT templatesum_pkey PRIMARY KEY (templateid);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: vulnerability vulnerability_pkey; Type: CONSTRAINT; Schema: public; Owner: goagent
--

ALTER TABLE ONLY public.vulnerability
    ADD CONSTRAINT vulnerability_pkey PRIMARY KEY (vul_id);


--
-- Name: role_page_access role_page_access_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_page_access
    ADD CONSTRAINT role_page_access_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id);


--
-- Name: role_page_access role_page_access_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_page_access
    ADD CONSTRAINT role_page_access_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO goagent;


--
-- Name: TABLE asset; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.asset TO goagent;


--
-- Name: SEQUENCE asset_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.asset_id_seq TO goagent;


--
-- Name: TABLE pages; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.pages TO goagent;


--
-- Name: SEQUENCE pages_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON SEQUENCE public.pages_id_seq TO goagent;


--
-- Name: TABLE role_page_access; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.role_page_access TO goagent;


--
-- Name: TABLE roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.roles TO goagent;


--
-- Name: SEQUENCE roles_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON SEQUENCE public.roles_id_seq TO goagent;


--
-- Name: TABLE template; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.template TO goagent;


--
-- Name: SEQUENCE template_template_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.template_template_id_seq TO goagent;


--
-- Name: TABLE template_vuln; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.template_vuln TO goagent;


--
-- Name: SEQUENCE template_vuln_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.template_vuln_id_seq TO goagent;


--
-- Name: SEQUENCE templatesum_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON SEQUENCE public.templatesum_id_seq TO goagent;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.users TO goagent;


--
-- Name: SEQUENCE users_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.users_id_seq TO goagent;


--
-- PostgreSQL database dump complete
--

