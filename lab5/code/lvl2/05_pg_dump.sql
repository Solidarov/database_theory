--
-- PostgreSQL database dump
--

\restrict UONamfANUezr1eTgXHCq4tWAyXeg0p2ChGQSgsItMGDINSsgUEOs5MPNjVZrOa9

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

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
-- Name: check_event_time(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.check_event_time() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    buffer_interval INTERVAL := '2 hours';
BEGIN
    IF EXISTS 
    (
        SELECT 1
        FROM doc_events
        WHERE stage_id = NEW.stage_id -- шукаємо івент на тій самій сцені
            -- виключаємо з перевірки вже існуючий івент, якщо хочемо просто оновити його час
            AND (event_id != NEW.event_id OR NEW.event_id IS NULL) 
            -- перевіряємо, чи початок старого івенту, не накладається на 
            -- кінець нового + 2 години після
            AND start_time < (NEW.end_time + buffer_interval)
            -- перевіряємо, чи не накладається кінцевий час попереднього івенту, 
            -- на початковий час наступного + 2 години до початку
            AND end_time > (NEW.start_time - buffer_interval)
    ) THEN   
        RAISE EXCEPTION 'Please, change the time of event. It conflicts with another event at the same stage';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_event_time() OWNER TO root;

--
-- Name: check_ticket_zone(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.check_ticket_zone() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN
    IF NOT EXISTS 
    (
        SELECT 1
        FROM doc_events e
        JOIN cat_zones z ON e.stage_id = z.stage_id
        WHERE z.zone_id = NEW.zone_id
            AND e.event_id = NEW.event_id
    ) THEN
        RAISE EXCEPTION 'Data Mismatch: Zone % does not belong to Stage at Event %', NEW.zone_id, NEW.event_id; 
    END IF;

    RETURN NEW;

END;
$$;


ALTER FUNCTION public.check_ticket_zone() OWNER TO root;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cat_artists; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.cat_artists (
    artist_id integer NOT NULL,
    artist_name character varying(75) NOT NULL,
    genre character varying(50),
    artist_description text
);


ALTER TABLE public.cat_artists OWNER TO root;

--
-- Name: cat_artists_artist_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.cat_artists_artist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cat_artists_artist_id_seq OWNER TO root;

--
-- Name: cat_artists_artist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.cat_artists_artist_id_seq OWNED BY public.cat_artists.artist_id;


--
-- Name: cat_customers; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.cat_customers (
    customer_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(64) NOT NULL,
    is_stuff boolean DEFAULT false NOT NULL
);


ALTER TABLE public.cat_customers OWNER TO root;

--
-- Name: cat_customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.cat_customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cat_customers_customer_id_seq OWNER TO root;

--
-- Name: cat_customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.cat_customers_customer_id_seq OWNED BY public.cat_customers.customer_id;


--
-- Name: cat_stages; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.cat_stages (
    stage_id integer NOT NULL,
    stage_name character varying(50) NOT NULL
);


ALTER TABLE public.cat_stages OWNER TO root;

--
-- Name: cat_stages_stage_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.cat_stages_stage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cat_stages_stage_id_seq OWNER TO root;

--
-- Name: cat_stages_stage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.cat_stages_stage_id_seq OWNED BY public.cat_stages.stage_id;


--
-- Name: cat_zones; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.cat_zones (
    zone_id integer NOT NULL,
    stage_id integer NOT NULL,
    zone_name character varying(50) NOT NULL,
    capacity integer NOT NULL,
    CONSTRAINT cat_zones_capacity_check CHECK ((capacity > 0))
);


ALTER TABLE public.cat_zones OWNER TO root;

--
-- Name: cat_zones_zone_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.cat_zones_zone_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cat_zones_zone_id_seq OWNER TO root;

--
-- Name: cat_zones_zone_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.cat_zones_zone_id_seq OWNED BY public.cat_zones.zone_id;


--
-- Name: doc_events; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.doc_events (
    event_id integer NOT NULL,
    event_name character varying(100) NOT NULL,
    stage_id integer NOT NULL,
    artist_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    event_status character varying(30) DEFAULT 'Upcoming'::character varying NOT NULL,
    CONSTRAINT doc_events_check CHECK ((start_time < end_time)),
    CONSTRAINT doc_events_event_status_check CHECK (((event_status)::text = ANY ((ARRAY['Upcoming'::character varying, 'Ended'::character varying, 'Canceled'::character varying, 'Rescheduled'::character varying])::text[])))
);


ALTER TABLE public.doc_events OWNER TO root;

--
-- Name: doc_events_event_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.doc_events_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.doc_events_event_id_seq OWNER TO root;

--
-- Name: doc_events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.doc_events_event_id_seq OWNED BY public.doc_events.event_id;


--
-- Name: doc_ticket_prices; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.doc_ticket_prices (
    event_id integer NOT NULL,
    zone_id integer NOT NULL,
    price integer NOT NULL,
    CONSTRAINT doc_ticket_prices_price_check CHECK ((price >= 0))
);


ALTER TABLE public.doc_ticket_prices OWNER TO root;

--
-- Name: doc_tickets; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.doc_tickets (
    ticket_id integer NOT NULL,
    order_id integer NOT NULL,
    event_id integer NOT NULL,
    zone_id integer NOT NULL,
    price_at_purchase integer NOT NULL,
    ticket_status character varying(30) DEFAULT 'Inactive'::character varying,
    CONSTRAINT doc_tickets_ticket_status_check CHECK (((ticket_status)::text = ANY ((ARRAY['Inactive'::character varying, 'Active'::character varying, 'Canceled'::character varying, 'Used'::character varying])::text[])))
);


ALTER TABLE public.doc_tickets OWNER TO root;

--
-- Name: doc_tickets_ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.doc_tickets_ticket_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.doc_tickets_ticket_id_seq OWNER TO root;

--
-- Name: doc_tickets_ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.doc_tickets_ticket_id_seq OWNED BY public.doc_tickets.ticket_id;


--
-- Name: op_ticket_orders; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.op_ticket_orders (
    order_id integer NOT NULL,
    customer_id integer NOT NULL,
    purchase_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ticket_quantity integer NOT NULL,
    total_amount integer NOT NULL,
    payment_status character varying(30) DEFAULT 'Pending'::character varying,
    CONSTRAINT op_ticket_orders_payment_status_check CHECK (((payment_status)::text = ANY ((ARRAY['Pending'::character varying, 'Paid'::character varying, 'Refunded'::character varying, 'Failed'::character varying, 'Abandoned'::character varying])::text[]))),
    CONSTRAINT op_ticket_orders_ticket_quantity_check CHECK ((ticket_quantity > 0)),
    CONSTRAINT op_ticket_orders_total_amount_check CHECK ((total_amount > 0))
);


ALTER TABLE public.op_ticket_orders OWNER TO root;

--
-- Name: op_ticket_orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.op_ticket_orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.op_ticket_orders_order_id_seq OWNER TO root;

--
-- Name: op_ticket_orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.op_ticket_orders_order_id_seq OWNED BY public.op_ticket_orders.order_id;


--
-- Name: cat_artists artist_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.cat_artists ALTER COLUMN artist_id SET DEFAULT nextval('public.cat_artists_artist_id_seq'::regclass);


--
-- Name: cat_customers customer_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.cat_customers ALTER COLUMN customer_id SET DEFAULT nextval('public.cat_customers_customer_id_seq'::regclass);


--
-- Name: cat_stages stage_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.cat_stages ALTER COLUMN stage_id SET DEFAULT nextval('public.cat_stages_stage_id_seq'::regclass);


--
-- Name: cat_zones zone_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.cat_zones ALTER COLUMN zone_id SET DEFAULT nextval('public.cat_zones_zone_id_seq'::regclass);


--
-- Name: doc_events event_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_events ALTER COLUMN event_id SET DEFAULT nextval('public.doc_events_event_id_seq'::regclass);


--
-- Name: doc_tickets ticket_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_tickets ALTER COLUMN ticket_id SET DEFAULT nextval('public.doc_tickets_ticket_id_seq'::regclass);


--
-- Name: op_ticket_orders order_id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.op_ticket_orders ALTER COLUMN order_id SET DEFAULT nextval('public.op_ticket_orders_order_id_seq'::regclass);


--
-- Data for Name: cat_artists; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.cat_artists (artist_id, artist_name, genre, artist_description) FROM stdin;
1	Okean Elzy	Rock / Indie Pop	The most iconic Ukrainian rock band, led by Svyatoslav Vakarchuk. Known for emotional lyrics, unique vocals, and filling stadiums for over 25 years.
2	The Hardkiss	Alternative Rock / Synthpop	A progressive band known for their striking visual style, heavy electronic influence, and the powerful vocals of frontwoman Julia Sanina.
3	DakhaBrakha	Ethno-Chaos	A world-music quartet from Kyiv that creates a unique style called "ethno-chaos," combining Ukrainian folk music with rhythms and instruments from around the globe.
4	Kalush Orchestra	Folk Hip-Hop	A group that blends modern hip-hop and rap with traditional Ukrainian folk motifs and instruments like the sopilka. Winners of Eurovision 2022.
5	Onuka	Electro-Folk	A project that organically combines modern electronic sound with traditional Ukrainian instruments like the bandura, sopilka, and trembita.
6	Boombox	Funk / Hip-Hop / Rock	A band known for their funky groove, soulful lyrics, and the distinctive scratchy vocals of leader Andriy Khlyvnyuk. Highly influential in the 2000s and 2010s.
7	Jamala	Jazz / Soul / World	A virtuoso singer who fuses jazz, soul, and Crimean Tatar folk traditions. She gained international fame after winning Eurovision 2016 with her song "1944".
8	Antytila	Pop-Rock	One of the most popular modern pop-rock bands in Ukraine, known for their melodic songs, stadium tours, and active civil and volunteer position.
9	Go_A	Electro-Folklore	A band that specializes in the modern retelling of traditional Ukrainian stories, combining electronic dance beats with the ancient "white voice" singing technique.
10	Alyona Alyona	Hip-Hop / Rap	A breakout rap star known for her rapid-flow delivery, body positivity, and socially conscious lyrics that challenge stereotypes.
\.


--
-- Data for Name: cat_customers; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.cat_customers (customer_id, first_name, last_name, email, password_hash, is_stuff) FROM stdin;
1	Ivan	Petrenko	ivan.petrenko@gmail.com	944f24f6044262738f07d2809cf03d8f7ab36a24ab18e12189c738a0fc1edc54	f
2	Oksana	Kovalenko	oksana.kovalenko95@ukr.net	2f97272ea674482ac33f32131c77181b09f9ba9036ea62878707dc6ff50de6e7	f
3	John	Smith	john.smith.music@yahoo.com	c775e7b757ede630cd0aa1113bd102661ab38829ca52a6422ab782862f268646	f
4	Maria	Shevchenko	maria.sheva@outlook.com	5e5241b8f0d8cb401b469460376d1f8b8c68aa16f7a364d091ff6f673e94bd54	f
5	Andriy	Melnyk	andriy.melnyk@tech-company.ua	0eb71d3c6f3119709240b84a8644d3e74f41aee9fb61e71a37b097dc0a9e0929	f
6	Sophie	Dubois	s.dubois@france-mail.fr	944f24f6044262738f07d2809cf03d8f7ab36a24ab18e12189c738a0fc1edc54	f
7	Dmytro	Bondar	dbondar_official@gmail.com	2f97272ea674482ac33f32131c77181b09f9ba9036ea62878707dc6ff50de6e7	f
8	Anna	Kowalska	anna.kowalska@wp.pl	c775e7b757ede630cd0aa1113bd102661ab38829ca52a6422ab782862f268646	f
9	Serhiy	Tkachenko	serhiy.tkachenko@protonmail.com	5e5241b8f0d8cb401b469460376d1f8b8c68aa16f7a364d091ff6f673e94bd54	f
10	Julia	Roberts	not.that.julia@example.com	0eb71d3c6f3119709240b84a8644d3e74f41aee9fb61e71a37b097dc0a9e0929	f
\.


--
-- Data for Name: cat_stages; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.cat_stages (stage_id, stage_name) FROM stdin;
1	Main Stage
2	Light Stage
3	Dark Stage
4	Underground Stage
5	Reggae stage
\.


--
-- Data for Name: cat_zones; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.cat_zones (zone_id, stage_id, zone_name, capacity) FROM stdin;
1	1	Golden Circle (Fan Pit)	500
2	1	General Admission	2500
3	1	VIP Box A	50
4	2	Dance Floor	800
5	2	Upper Balcony	150
6	3	The Mosh Pit	300
7	3	Side Bar Seating	40
8	4	Main Floor	150
9	5	Green Lawn	400
10	5	Comfort Lounge	30
\.


--
-- Data for Name: doc_events; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.doc_events (event_id, event_name, stage_id, artist_id, start_time, end_time, event_status) FROM stdin;
1	Okean Elzy: 31 Years Together	1	1	2026-06-20 20:00:00	2026-06-20 22:00:00	Upcoming
2	The Hardkiss: Iron Tour	3	2	2026-06-21 19:00:00	2026-06-21 21:30:00	Upcoming
3	DakhaBrakha: Ethno Chaos	2	3	2026-06-22 18:00:00	2026-06-22 20:00:00	Upcoming
4	Kalush Vibes Open Air	5	4	2026-06-21 16:00:00	2026-06-21 18:00:00	Upcoming
5	Onuka: Electro Experience	2	5	2026-06-23 20:00:00	2026-06-23 22:00:00	Upcoming
6	Boombox: Secret Code	1	6	2026-07-01 19:30:00	2026-07-01 21:30:00	Upcoming
7	Jamala: Jazz Night	2	7	2026-07-02 19:00:00	2026-07-02 21:00:00	Upcoming
8	Antytila: Stadium Show	1	8	2026-07-05 20:00:00	2026-07-05 22:30:00	Upcoming
9	Go_A: Shum Rave	4	9	2026-07-05 20:00:00	2026-07-05 23:00:00	Upcoming
10	Alyona Alyona: Rap Session	4	10	2026-07-06 21:00:00	2026-07-06 23:00:00	Upcoming
\.


--
-- Data for Name: doc_ticket_prices; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.doc_ticket_prices (event_id, zone_id, price) FROM stdin;
1	1	150000
1	2	80000
1	3	300000
2	6	60000
2	7	120000
3	4	50000
3	5	90000
4	9	55000
4	10	150000
5	4	60000
5	5	100000
6	1	120000
6	2	70000
6	3	250000
7	4	80000
7	5	120000
8	1	110000
8	2	65000
8	3	220000
9	8	45000
10	8	40000
\.


--
-- Data for Name: doc_tickets; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.doc_tickets (ticket_id, order_id, event_id, zone_id, price_at_purchase, ticket_status) FROM stdin;
2	1	1	1	150000	Active
5	3	3	4	50000	Active
6	3	3	4	50000	Active
9	5	6	2	70000	Canceled
11	6	9	8	45000	Active
12	6	9	8	45000	Active
13	6	9	8	45000	Active
15	7	10	8	40000	Active
16	7	10	8	40000	Active
17	7	10	8	40000	Active
18	7	10	8	40000	Active
19	7	10	8	40000	Active
20	7	10	8	40000	Active
21	7	10	8	40000	Active
22	7	10	8	40000	Active
23	7	10	8	40000	Active
25	8	7	4	80000	Inactive
26	9	8	3	220000	Active
27	10	4	10	150000	Active
28	11	1	3	300000	Active
29	11	1	3	300000	Active
30	12	7	5	120000	Inactive
1	1	1	1	149000	Active
3	2	2	6	59000	Active
4	3	3	4	49000	Active
7	4	5	5	99000	Inactive
8	5	6	2	69000	Canceled
10	6	9	8	44000	Active
14	7	10	8	39000	Active
24	8	7	4	79000	Inactive
\.


--
-- Data for Name: op_ticket_orders; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.op_ticket_orders (order_id, customer_id, purchase_time, ticket_quantity, total_amount, payment_status) FROM stdin;
1	1	2025-05-10 10:15:00	2	300000	Paid
2	2	2025-05-11 14:30:00	1	60000	Paid
3	3	2025-05-12 09:00:00	3	150000	Paid
4	4	2025-05-12 09:05:00	1	100000	Failed
5	5	2025-05-15 18:45:00	2	140000	Refunded
6	6	2025-05-20 12:00:00	4	180000	Paid
7	7	2025-05-22 11:20:00	10	400000	Paid
8	8	2025-05-25 23:50:00	2	160000	Abandoned
9	9	2025-06-01 08:30:00	1	220000	Paid
10	10	2025-06-02 16:10:00	1	150000	Paid
11	1	2025-06-05 10:00:00	2	600000	Paid
12	2	2025-11-23 22:51:07.965703	1	120000	Pending
\.


--
-- Name: cat_artists_artist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.cat_artists_artist_id_seq', 33, true);


--
-- Name: cat_customers_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.cat_customers_customer_id_seq', 33, true);


--
-- Name: cat_stages_stage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.cat_stages_stage_id_seq', 33, true);


--
-- Name: cat_zones_zone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.cat_zones_zone_id_seq', 33, true);


--
-- Name: doc_events_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.doc_events_event_id_seq', 33, true);


--
-- Name: doc_tickets_ticket_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.doc_tickets_ticket_id_seq', 33, true);


--
-- Name: op_ticket_orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.op_ticket_orders_order_id_seq', 33, true);


--
-- Name: cat_artists cat_artists_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.cat_artists
    ADD CONSTRAINT cat_artists_pkey PRIMARY KEY (artist_id);


--
-- Name: cat_customers cat_customers_email_key; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.cat_customers
    ADD CONSTRAINT cat_customers_email_key UNIQUE (email);


--
-- Name: cat_customers cat_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.cat_customers
    ADD CONSTRAINT cat_customers_pkey PRIMARY KEY (customer_id);


--
-- Name: cat_stages cat_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.cat_stages
    ADD CONSTRAINT cat_stages_pkey PRIMARY KEY (stage_id);


--
-- Name: cat_zones cat_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.cat_zones
    ADD CONSTRAINT cat_zones_pkey PRIMARY KEY (zone_id);


--
-- Name: doc_events doc_events_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_events
    ADD CONSTRAINT doc_events_pkey PRIMARY KEY (event_id);


--
-- Name: doc_ticket_prices doc_ticket_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_ticket_prices
    ADD CONSTRAINT doc_ticket_prices_pkey PRIMARY KEY (event_id, zone_id);


--
-- Name: doc_tickets doc_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_tickets
    ADD CONSTRAINT doc_tickets_pkey PRIMARY KEY (ticket_id);


--
-- Name: op_ticket_orders op_ticket_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.op_ticket_orders
    ADD CONSTRAINT op_ticket_orders_pkey PRIMARY KEY (order_id);


--
-- Name: doc_events change_create_event_time_trg; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER change_create_event_time_trg BEFORE INSERT OR UPDATE ON public.doc_events FOR EACH ROW EXECUTE FUNCTION public.check_event_time();


--
-- Name: doc_ticket_prices create_update_ticket_prices; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER create_update_ticket_prices BEFORE INSERT OR UPDATE ON public.doc_ticket_prices FOR EACH ROW EXECUTE FUNCTION public.check_ticket_zone();


--
-- Name: cat_zones cat_zones_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.cat_zones
    ADD CONSTRAINT cat_zones_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.cat_stages(stage_id) ON DELETE CASCADE;


--
-- Name: doc_events doc_events_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_events
    ADD CONSTRAINT doc_events_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.cat_artists(artist_id) ON DELETE RESTRICT;


--
-- Name: doc_events doc_events_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_events
    ADD CONSTRAINT doc_events_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.cat_stages(stage_id) ON DELETE RESTRICT;


--
-- Name: doc_ticket_prices doc_ticket_prices_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_ticket_prices
    ADD CONSTRAINT doc_ticket_prices_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.doc_events(event_id) ON DELETE RESTRICT;


--
-- Name: doc_ticket_prices doc_ticket_prices_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_ticket_prices
    ADD CONSTRAINT doc_ticket_prices_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.cat_zones(zone_id) ON DELETE RESTRICT;


--
-- Name: doc_tickets doc_tickets_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_tickets
    ADD CONSTRAINT doc_tickets_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.doc_events(event_id) ON DELETE RESTRICT;


--
-- Name: doc_tickets doc_tickets_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_tickets
    ADD CONSTRAINT doc_tickets_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.op_ticket_orders(order_id) ON DELETE CASCADE;


--
-- Name: doc_tickets doc_tickets_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.doc_tickets
    ADD CONSTRAINT doc_tickets_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.cat_zones(zone_id) ON DELETE RESTRICT;


--
-- Name: op_ticket_orders op_ticket_orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.op_ticket_orders
    ADD CONSTRAINT op_ticket_orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.cat_customers(customer_id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict UONamfANUezr1eTgXHCq4tWAyXeg0p2ChGQSgsItMGDINSsgUEOs5MPNjVZrOa9

