--
-- PostgreSQL database dump
--

\restrict JhpQVRQhQ61WJeC6jT2qmSlSdCj6yef8P71TU2gAIzPwffdYLMwE7bbdcxZc5XQ

-- Dumped from database version 14.20 (Homebrew)
-- Dumped by pg_dump version 18.0

-- Started on 2026-01-21 18:55:03 +07

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: dusitmuangmee
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO dusitmuangmee;

--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: dusitmuangmee
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 237 (class 1255 OID 16498)
-- Name: log_pdu_outlet_status(); Type: FUNCTION; Schema: public; Owner: dusitmuangmee
--

CREATE FUNCTION public.log_pdu_outlet_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.status IS DISTINCT FROM OLD.status THEN
        INSERT INTO pdu_outlet_log
        (
            pdu_id,
            outlet_no,
            old_status,
            new_status,
            changed_by,
            changed_ip,
            changed_reason,
            session_id,
            request_id,
            before_snapshot,
            after_snapshot
        )
        VALUES
        (
            OLD.pdu_id,
            OLD.outlet_no,
            OLD.status,
            NEW.status,
            COALESCE(NEW.changed_by, 'system'),
            COALESCE(NEW.changed_ip, 'unknown'),
            COALESCE(NEW.changed_reason, 'unspecified'),
            NEW.session_id,
            NEW.request_id,

            -- 🔹 Snapshot ก่อนเปลี่ยน
            jsonb_build_object(
                'status', OLD.status,
                'current', OLD.current,
                'name', OLD.name
            ),

            -- 🔹 Snapshot หลังเปลี่ยน
            jsonb_build_object(
                'status', NEW.status,
                'current', NEW.current,
                'name', NEW.name
            )
        );
    END IF;

    -- ล้างค่าชั่วคราว
    NEW.changed_by := NULL;
    NEW.changed_ip := NULL;
    NEW.changed_reason := NULL;
    NEW.session_id := NULL;
    NEW.request_id := NULL;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_pdu_outlet_status() OWNER TO dusitmuangmee;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 210 (class 1259 OID 16438)
-- Name: pdu; Type: TABLE; Schema: public; Owner: dusitmuangmee
--

CREATE TABLE public.pdu (
    id integer NOT NULL,
    name character varying(100),
    model character varying(100),
    ip_address character varying(50),
    location character varying(100),
    status character varying(20),
    uptime character varying(50),
    last_seen timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    brand character varying(50)
);


ALTER TABLE public.pdu OWNER TO dusitmuangmee;

--
-- TOC entry 216 (class 1259 OID 16473)
-- Name: pdu_alarm; Type: TABLE; Schema: public; Owner: dusitmuangmee
--

CREATE TABLE public.pdu_alarm (
    id integer NOT NULL,
    pdu_id integer,
    has_alarm boolean,
    severity character varying(20),
    message character varying(255),
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.pdu_alarm OWNER TO dusitmuangmee;

--
-- TOC entry 215 (class 1259 OID 16472)
-- Name: pdu_alarm_id_seq; Type: SEQUENCE; Schema: public; Owner: dusitmuangmee
--

CREATE SEQUENCE public.pdu_alarm_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pdu_alarm_id_seq OWNER TO dusitmuangmee;

--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 215
-- Name: pdu_alarm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dusitmuangmee
--

ALTER SEQUENCE public.pdu_alarm_id_seq OWNED BY public.pdu_alarm.id;


--
-- TOC entry 225 (class 1259 OID 16532)
-- Name: pdu_event_action_log; Type: TABLE; Schema: public; Owner: dusitmuangmee
--

CREATE TABLE public.pdu_event_action_log (
    id integer NOT NULL,
    event_id integer NOT NULL,
    action character varying(20) NOT NULL,
    action_by character varying(20) DEFAULT 'system'::character varying,
    action_ip character varying(45),
    action_reason text,
    action_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.pdu_event_action_log OWNER TO dusitmuangmee;

--
-- TOC entry 224 (class 1259 OID 16531)
-- Name: pdu_event_action_log_id_seq; Type: SEQUENCE; Schema: public; Owner: dusitmuangmee
--

CREATE SEQUENCE public.pdu_event_action_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pdu_event_action_log_id_seq OWNER TO dusitmuangmee;

--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 224
-- Name: pdu_event_action_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dusitmuangmee
--

ALTER SEQUENCE public.pdu_event_action_log_id_seq OWNED BY public.pdu_event_action_log.id;


--
-- TOC entry 221 (class 1259 OID 16512)
-- Name: pdu_event_log; Type: TABLE; Schema: public; Owner: dusitmuangmee
--

CREATE TABLE public.pdu_event_log (
    id integer NOT NULL,
    pdu_id integer NOT NULL,
    outlet_no integer,
    event_type character varying(30) NOT NULL,
    event_level character varying(20),
    event_code character varying(50),
    event_message text,
    event_value jsonb,
    source character varying(20),
    source_ip character varying(45),
    occurred_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    cleared_at timestamp without time zone,
    acknowledged_at timestamp without time zone,
    acknowledged_by character varying(20),
    acknowledged_ip character varying(45),
    acknowledged_reason text,
    cleared_by character varying(20),
    cleared_ip character varying(45),
    cleared_reason text
);


ALTER TABLE public.pdu_event_log OWNER TO dusitmuangmee;

--
-- TOC entry 220 (class 1259 OID 16511)
-- Name: pdu_event_log_id_seq; Type: SEQUENCE; Schema: public; Owner: dusitmuangmee
--

CREATE SEQUENCE public.pdu_event_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pdu_event_log_id_seq OWNER TO dusitmuangmee;

--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 220
-- Name: pdu_event_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dusitmuangmee
--

ALTER SEQUENCE public.pdu_event_log_id_seq OWNED BY public.pdu_event_log.id;


--
-- TOC entry 209 (class 1259 OID 16437)
-- Name: pdu_id_seq; Type: SEQUENCE; Schema: public; Owner: dusitmuangmee
--

CREATE SEQUENCE public.pdu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pdu_id_seq OWNER TO dusitmuangmee;

--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 209
-- Name: pdu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dusitmuangmee
--

ALTER SEQUENCE public.pdu_id_seq OWNED BY public.pdu.id;


--
-- TOC entry 214 (class 1259 OID 16460)
-- Name: pdu_outlet; Type: TABLE; Schema: public; Owner: dusitmuangmee
--

CREATE TABLE public.pdu_outlet (
    id integer NOT NULL,
    pdu_id integer,
    outlet_no integer,
    name character varying(50),
    status character varying(10),
    current numeric(6,2),
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    changed_by character varying(20),
    changed_ip character varying(45),
    changed_reason text,
    session_id character varying(64),
    request_id character varying(64)
);


ALTER TABLE public.pdu_outlet OWNER TO dusitmuangmee;

--
-- TOC entry 213 (class 1259 OID 16459)
-- Name: pdu_outlet_id_seq; Type: SEQUENCE; Schema: public; Owner: dusitmuangmee
--

CREATE SEQUENCE public.pdu_outlet_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pdu_outlet_id_seq OWNER TO dusitmuangmee;

--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 213
-- Name: pdu_outlet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dusitmuangmee
--

ALTER SEQUENCE public.pdu_outlet_id_seq OWNED BY public.pdu_outlet.id;


--
-- TOC entry 219 (class 1259 OID 16491)
-- Name: pdu_outlet_log; Type: TABLE; Schema: public; Owner: dusitmuangmee
--

CREATE TABLE public.pdu_outlet_log (
    id integer NOT NULL,
    pdu_id integer NOT NULL,
    outlet_no integer NOT NULL,
    old_status character varying(10),
    new_status character varying(10),
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    changed_by character varying(20) DEFAULT 'system'::character varying,
    changed_ip character varying(45),
    changed_reason text,
    session_id character varying(64),
    request_id character varying(64),
    before_snapshot jsonb,
    after_snapshot jsonb
);


ALTER TABLE public.pdu_outlet_log OWNER TO dusitmuangmee;

--
-- TOC entry 218 (class 1259 OID 16490)
-- Name: pdu_outlet_log_id_seq; Type: SEQUENCE; Schema: public; Owner: dusitmuangmee
--

CREATE SEQUENCE public.pdu_outlet_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pdu_outlet_log_id_seq OWNER TO dusitmuangmee;

--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 218
-- Name: pdu_outlet_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dusitmuangmee
--

ALTER SEQUENCE public.pdu_outlet_log_id_seq OWNED BY public.pdu_outlet_log.id;


--
-- TOC entry 212 (class 1259 OID 16447)
-- Name: pdu_power_status; Type: TABLE; Schema: public; Owner: dusitmuangmee
--

CREATE TABLE public.pdu_power_status (
    id integer NOT NULL,
    pdu_id integer,
    current numeric(6,2),
    max_current numeric(6,2),
    load_percent numeric(6,2),
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.pdu_power_status OWNER TO dusitmuangmee;

--
-- TOC entry 211 (class 1259 OID 16446)
-- Name: pdu_power_status_id_seq; Type: SEQUENCE; Schema: public; Owner: dusitmuangmee
--

CREATE SEQUENCE public.pdu_power_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pdu_power_status_id_seq OWNER TO dusitmuangmee;

--
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 211
-- Name: pdu_power_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dusitmuangmee
--

ALTER SEQUENCE public.pdu_power_status_id_seq OWNED BY public.pdu_power_status.id;


--
-- TOC entry 222 (class 1259 OID 16521)
-- Name: v_active_alarms; Type: VIEW; Schema: public; Owner: dusitmuangmee
--

CREATE VIEW public.v_active_alarms AS
 SELECT e.id,
    e.pdu_id,
    p.name AS pdu_name,
    p.ip_address,
    p.location,
    e.outlet_no,
    e.event_level,
    e.event_code,
    e.event_message,
    e.event_value,
    e.source,
    e.source_ip,
    e.occurred_at
   FROM (public.pdu_event_log e
     LEFT JOIN public.pdu p ON ((p.id = e.pdu_id)))
  WHERE (((e.event_type)::text = ANY ((ARRAY['alarm'::character varying, 'overload'::character varying, 'breaker'::character varying])::text[])) AND (e.cleared_at IS NULL))
  ORDER BY e.occurred_at DESC;


ALTER VIEW public.v_active_alarms OWNER TO dusitmuangmee;

--
-- TOC entry 223 (class 1259 OID 16526)
-- Name: v_pdu_alarm_summary; Type: VIEW; Schema: public; Owner: dusitmuangmee
--

CREATE VIEW public.v_pdu_alarm_summary AS
 SELECT p.id AS pdu_id,
    p.name AS pdu_name,
    p.ip_address,
    p.location,
    count(a.id) AS active_alarm_count,
        CASE
            WHEN (sum(
            CASE
                WHEN ((a.event_level)::text = 'critical'::text) THEN 1
                ELSE 0
            END) > 0) THEN 'critical'::text
            WHEN (sum(
            CASE
                WHEN ((a.event_level)::text = 'warning'::text) THEN 1
                ELSE 0
            END) > 0) THEN 'warning'::text
            WHEN (count(a.id) > 0) THEN 'info'::text
            ELSE 'none'::text
        END AS worst_level,
    max(a.occurred_at) AS last_alarm_time
   FROM (public.pdu p
     LEFT JOIN public.pdu_event_log a ON (((a.pdu_id = p.id) AND (a.cleared_at IS NULL) AND ((a.event_type)::text = ANY ((ARRAY['alarm'::character varying, 'overload'::character varying, 'breaker'::character varying])::text[])))))
  GROUP BY p.id, p.name, p.ip_address, p.location;


ALTER VIEW public.v_pdu_alarm_summary OWNER TO dusitmuangmee;

--
-- TOC entry 217 (class 1259 OID 16485)
-- Name: v_pdu_dashboard; Type: VIEW; Schema: public; Owner: dusitmuangmee
--

CREATE VIEW public.v_pdu_dashboard AS
 SELECT p.id AS pdu_id,
    p.name AS pdu_name,
    p.model,
    p.ip_address,
    p.location,
    p.status,
    p.uptime,
    ps.current,
    ps.max_current,
    ps.load_percent,
    a.has_alarm,
    a.severity,
    a.message,
    p.last_seen,
    p.updated_at
   FROM ((public.pdu p
     LEFT JOIN public.pdu_power_status ps ON ((ps.pdu_id = p.id)))
     LEFT JOIN public.pdu_alarm a ON ((a.pdu_id = p.id)));


ALTER VIEW public.v_pdu_dashboard OWNER TO dusitmuangmee;

--
-- TOC entry 3703 (class 2604 OID 16441)
-- Name: pdu id; Type: DEFAULT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu ALTER COLUMN id SET DEFAULT nextval('public.pdu_id_seq'::regclass);


--
-- TOC entry 3710 (class 2604 OID 16476)
-- Name: pdu_alarm id; Type: DEFAULT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_alarm ALTER COLUMN id SET DEFAULT nextval('public.pdu_alarm_id_seq'::regclass);


--
-- TOC entry 3717 (class 2604 OID 16535)
-- Name: pdu_event_action_log id; Type: DEFAULT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_event_action_log ALTER COLUMN id SET DEFAULT nextval('public.pdu_event_action_log_id_seq'::regclass);


--
-- TOC entry 3715 (class 2604 OID 16515)
-- Name: pdu_event_log id; Type: DEFAULT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_event_log ALTER COLUMN id SET DEFAULT nextval('public.pdu_event_log_id_seq'::regclass);


--
-- TOC entry 3708 (class 2604 OID 16463)
-- Name: pdu_outlet id; Type: DEFAULT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_outlet ALTER COLUMN id SET DEFAULT nextval('public.pdu_outlet_id_seq'::regclass);


--
-- TOC entry 3712 (class 2604 OID 16494)
-- Name: pdu_outlet_log id; Type: DEFAULT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_outlet_log ALTER COLUMN id SET DEFAULT nextval('public.pdu_outlet_log_id_seq'::regclass);


--
-- TOC entry 3706 (class 2604 OID 16450)
-- Name: pdu_power_status id; Type: DEFAULT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_power_status ALTER COLUMN id SET DEFAULT nextval('public.pdu_power_status_id_seq'::regclass);


--
-- TOC entry 3882 (class 0 OID 16438)
-- Dependencies: 210
-- Data for Name: pdu; Type: TABLE DATA; Schema: public; Owner: dusitmuangmee
--

COPY public.pdu (id, name, model, ip_address, location, status, uptime, last_seen, created_at, updated_at, brand) FROM stdin;
1	PDU-ICT-1	APC Rack PDU	10.220.71.34	ห้อง ICT-1	online	\N	\N	2026-01-21 17:57:11.675805	2026-01-21 17:57:11.675805	APC
\.


--
-- TOC entry 3888 (class 0 OID 16473)
-- Dependencies: 216
-- Data for Name: pdu_alarm; Type: TABLE DATA; Schema: public; Owner: dusitmuangmee
--

COPY public.pdu_alarm (id, pdu_id, has_alarm, severity, message, "timestamp") FROM stdin;
1	1	f	info	ไม่มีสัญญาณเตือนภัย	2026-01-21 17:59:08.309873
\.


--
-- TOC entry 3894 (class 0 OID 16532)
-- Dependencies: 225
-- Data for Name: pdu_event_action_log; Type: TABLE DATA; Schema: public; Owner: dusitmuangmee
--

COPY public.pdu_event_action_log (id, event_id, action, action_by, action_ip, action_reason, action_at) FROM stdin;
1	1	acknowledge	user	192.168.1.50	checked by operator	2026-01-21 18:37:17.807624
2	1	clear	user	192.168.1.50	issue resolved	2026-01-21 18:37:23.638728
\.


--
-- TOC entry 3892 (class 0 OID 16512)
-- Dependencies: 221
-- Data for Name: pdu_event_log; Type: TABLE DATA; Schema: public; Owner: dusitmuangmee
--

COPY public.pdu_event_log (id, pdu_id, outlet_no, event_type, event_level, event_code, event_message, event_value, source, source_ip, occurred_at, cleared_at, acknowledged_at, acknowledged_by, acknowledged_ip, acknowledged_reason, cleared_by, cleared_ip, cleared_reason) FROM stdin;
2	1	\N	breaker	critical	breaker_trip	Main breaker tripped	\N	apc	10.220.71.34	2026-01-21 18:32:07.058567	\N	\N	\N	\N	\N	\N	\N	\N
3	1	2	alarm	warning	temperature_high	Outlet temperature above normal	\N	apc	10.220.71.34	2026-01-21 18:32:13.511377	2026-01-21 18:32:21.771209	\N	\N	\N	\N	\N	\N	\N
4	1	2	alarm	warning	temperature_high	Outlet temperature above normal	\N	apc	10.220.71.34	2026-01-21 18:35:05.988248	\N	\N	\N	\N	\N	\N	\N	\N
1	1	3	overload	critical	current_over_limit	Current exceeds threshold	{"unit": "A", "current": 12.5, "threshold": 10.0}	system	127.0.0.1	2026-01-21 18:31:59.476965	2026-01-21 18:37:23.638728	2026-01-21 18:37:17.807624	user	192.168.1.50	checked by operator	user	192.168.1.50	issue resolved
\.


--
-- TOC entry 3886 (class 0 OID 16460)
-- Dependencies: 214
-- Data for Name: pdu_outlet; Type: TABLE DATA; Schema: public; Owner: dusitmuangmee
--

COPY public.pdu_outlet (id, pdu_id, outlet_no, name, status, current, updated_at, changed_by, changed_ip, changed_reason, session_id, request_id) FROM stdin;
5	1	5	Outlet 5	on	0.75	2026-01-21 17:58:47.569458	\N	\N	\N	\N	\N
6	1	6	Outlet 6	on	0.70	2026-01-21 17:58:47.569458	\N	\N	\N	\N	\N
7	1	7	Outlet 7	on	0.95	2026-01-21 17:58:47.569458	\N	\N	\N	\N	\N
8	1	8	Outlet 8	on	0.88	2026-01-21 17:58:47.569458	\N	\N	\N	\N	\N
4	1	4	Outlet 4	off	0.00	2026-01-21 17:58:47.569458	apc	10.220.71.34	apc auto shutdown	\N	\N
2	1	2	Outlet 2	off	0.85	2026-01-21 17:58:47.569458	user	192.168.1.50	manual control	sess-9fa31	req-20260121-001
3	1	3	Outlet 3	off	0.90	2026-01-21 17:58:47.569458	user	192.168.1.50	manual control	sess-9fa31	req-20260121-001
1	1	1	Outlet 1	on	0.90	2026-01-21 17:58:47.569458	user	192.168.1.50	snapshot test	sess-test	req-test
\.


--
-- TOC entry 3890 (class 0 OID 16491)
-- Dependencies: 219
-- Data for Name: pdu_outlet_log; Type: TABLE DATA; Schema: public; Owner: dusitmuangmee
--

COPY public.pdu_outlet_log (id, pdu_id, outlet_no, old_status, new_status, changed_at, changed_by, changed_ip, changed_reason, session_id, request_id, before_snapshot, after_snapshot) FROM stdin;
1	1	2	on	off	2026-01-21 18:10:56.78283	system	\N	\N	\N	\N	\N	\N
2	1	1	off	on	2026-01-21 18:15:09.413004	system	\N	\N	\N	\N	\N	\N
3	1	1	on	off	2026-01-21 18:17:17.194037	user	\N	\N	\N	\N	\N	\N
4	1	3	on	off	2026-01-21 18:17:30.675897	apc	\N	\N	\N	\N	\N	\N
5	1	1	off	on	2026-01-21 18:26:33.387433	user	192.168.1.50	snapshot test	sess-test	req-test	{"name": "Outlet 1", "status": "off", "current": 0.00}	{"name": "Outlet 1", "status": "on", "current": 0.90}
\.


--
-- TOC entry 3884 (class 0 OID 16447)
-- Dependencies: 212
-- Data for Name: pdu_power_status; Type: TABLE DATA; Schema: public; Owner: dusitmuangmee
--

COPY public.pdu_power_status (id, pdu_id, current, max_current, load_percent, "timestamp") FROM stdin;
1	1	6.30	20.00	31.50	2026-01-21 17:58:25.784928
\.


--
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 215
-- Name: pdu_alarm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dusitmuangmee
--

SELECT pg_catalog.setval('public.pdu_alarm_id_seq', 1, true);


--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 224
-- Name: pdu_event_action_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dusitmuangmee
--

SELECT pg_catalog.setval('public.pdu_event_action_log_id_seq', 2, true);


--
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 220
-- Name: pdu_event_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dusitmuangmee
--

SELECT pg_catalog.setval('public.pdu_event_log_id_seq', 4, true);


--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 209
-- Name: pdu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dusitmuangmee
--

SELECT pg_catalog.setval('public.pdu_id_seq', 1, true);


--
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 213
-- Name: pdu_outlet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dusitmuangmee
--

SELECT pg_catalog.setval('public.pdu_outlet_id_seq', 8, true);


--
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 218
-- Name: pdu_outlet_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dusitmuangmee
--

SELECT pg_catalog.setval('public.pdu_outlet_log_id_seq', 5, true);


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 211
-- Name: pdu_power_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dusitmuangmee
--

SELECT pg_catalog.setval('public.pdu_power_status_id_seq', 1, true);


--
-- TOC entry 3727 (class 2606 OID 16479)
-- Name: pdu_alarm pdu_alarm_pkey; Type: CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_alarm
    ADD CONSTRAINT pdu_alarm_pkey PRIMARY KEY (id);


--
-- TOC entry 3733 (class 2606 OID 16541)
-- Name: pdu_event_action_log pdu_event_action_log_pkey; Type: CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_event_action_log
    ADD CONSTRAINT pdu_event_action_log_pkey PRIMARY KEY (id);


--
-- TOC entry 3731 (class 2606 OID 16520)
-- Name: pdu_event_log pdu_event_log_pkey; Type: CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_event_log
    ADD CONSTRAINT pdu_event_log_pkey PRIMARY KEY (id);


--
-- TOC entry 3729 (class 2606 OID 16497)
-- Name: pdu_outlet_log pdu_outlet_log_pkey; Type: CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_outlet_log
    ADD CONSTRAINT pdu_outlet_log_pkey PRIMARY KEY (id);


--
-- TOC entry 3725 (class 2606 OID 16466)
-- Name: pdu_outlet pdu_outlet_pkey; Type: CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_outlet
    ADD CONSTRAINT pdu_outlet_pkey PRIMARY KEY (id);


--
-- TOC entry 3721 (class 2606 OID 16445)
-- Name: pdu pdu_pkey; Type: CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu
    ADD CONSTRAINT pdu_pkey PRIMARY KEY (id);


--
-- TOC entry 3723 (class 2606 OID 16453)
-- Name: pdu_power_status pdu_power_status_pkey; Type: CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_power_status
    ADD CONSTRAINT pdu_power_status_pkey PRIMARY KEY (id);


--
-- TOC entry 3738 (class 2620 OID 16510)
-- Name: pdu_outlet trg_log_pdu_outlet; Type: TRIGGER; Schema: public; Owner: dusitmuangmee
--

CREATE TRIGGER trg_log_pdu_outlet AFTER UPDATE ON public.pdu_outlet FOR EACH ROW EXECUTE FUNCTION public.log_pdu_outlet_status();


--
-- TOC entry 3736 (class 2606 OID 16480)
-- Name: pdu_alarm pdu_alarm_pdu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_alarm
    ADD CONSTRAINT pdu_alarm_pdu_id_fkey FOREIGN KEY (pdu_id) REFERENCES public.pdu(id) ON DELETE CASCADE;


--
-- TOC entry 3737 (class 2606 OID 16542)
-- Name: pdu_event_action_log pdu_event_action_log_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_event_action_log
    ADD CONSTRAINT pdu_event_action_log_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.pdu_event_log(id) ON DELETE CASCADE;


--
-- TOC entry 3735 (class 2606 OID 16467)
-- Name: pdu_outlet pdu_outlet_pdu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_outlet
    ADD CONSTRAINT pdu_outlet_pdu_id_fkey FOREIGN KEY (pdu_id) REFERENCES public.pdu(id) ON DELETE CASCADE;


--
-- TOC entry 3734 (class 2606 OID 16454)
-- Name: pdu_power_status pdu_power_status_pdu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dusitmuangmee
--

ALTER TABLE ONLY public.pdu_power_status
    ADD CONSTRAINT pdu_power_status_pdu_id_fkey FOREIGN KEY (pdu_id) REFERENCES public.pdu(id) ON DELETE CASCADE;


--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: dusitmuangmee
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2026-01-21 18:55:03 +07

--
-- PostgreSQL database dump complete
--

\unrestrict JhpQVRQhQ61WJeC6jT2qmSlSdCj6yef8P71TU2gAIzPwffdYLMwE7bbdcxZc5XQ

