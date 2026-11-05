-- PostgreSQL 17 schema migration: iot -> mes_iot
-- Baseline: iot.sql (pg_dump 17.6), target: mes_iot.sql (pg_dump 17.11)
-- Only execute against database mes_iot; do NOT run on iot.
-- This script DOES NOT INSERT/COPY business data from iot; only changes schema.
-- Carefully review all changes. Stop application writes / back up mes_iot first.
-- Assumes the exact schema captured in the supplied target dump (one-time migration).
-- All statements execute as one transaction: on errors transaction rolls back.

BEGIN;
SET LOCAL lock_timeout = '15s';
SET LOCAL check_function_bodies = false;

DO $preflight$
BEGIN
    IF current_database() <> 'mes_iot' THEN
        RAISE EXCEPTION 'Wrong database: %, only mes_iot is allowed', current_database();
    END IF;

    -- iot has UNIQUE (device_code, stat_date) instead of UNIQUE (...,shift_type).
    -- Distinct day/night records can collide. Do NOT silently merge/delete them.
    IF EXISTS (
        SELECT 1 FROM public.device_daily_stats
        GROUP BY device_code, stat_date
        HAVING count(*) > 1
    ) THEN
        RAISE EXCEPTION 'device_daily_stats contains duplicate (device_code,stat_date) pairs; resolve before changing unique constraint';
    END IF;

    IF EXISTS (
        SELECT 1 FROM public.device_changeover_log
        WHERE duration_seconds > 2147483647 OR duration_seconds < -2147483648
    ) THEN
        RAISE EXCEPTION 'device_changeover_log.duration_seconds contains out-of-range bigint values';
    END IF;

    IF EXISTS (
        SELECT 1 FROM public.sys_tasks WHERE char_length(jobparams) > 1000
    ) THEN
        RAISE EXCEPTION 'sys_tasks.jobparams contains values longer than 1000 characters';
    END IF;
END;
$preflight$;

-- ==========================================================================
-- 01. CREATE missing tables (5)
-- ==========================================================================

-- TABLE eq_test_report
CREATE TABLE public.eq_test_report (
    id bigint NOT NULL,
    report_type character varying(50) NOT NULL,
    result character varying(50),
    uni_code character varying(100),
    equipment_code character varying(50) NOT NULL,
    wo_no character varying(50),
    track character varying(50),
    operator character varying(50),
    pcb_side character varying(10),
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    raw_payload jsonb,
    created_time timestamp without time zone DEFAULT now() NOT NULL
);

-- TABLE eq_test_report_item
CREATE TABLE public.eq_test_report_item (
    id bigint NOT NULL,
    report_id bigint NOT NULL,
    item_key character varying(100) NOT NULL,
    item_value character varying(200),
    item_remark character varying(200),
    value_type character varying(20),
    created_time timestamp without time zone DEFAULT now() NOT NULL
);

-- TABLE llm_usage
CREATE TABLE public.llm_usage (
    id bigint NOT NULL,
    project_name character varying(64) NOT NULL,
    node_name character varying(64) NOT NULL,
    prompt_tokens integer NOT NULL,
    completion_tokens integer NOT NULL,
    latency_s integer NOT NULL,
    created_at timestamp without time zone NOT NULL
);

-- TABLE mc_pcb_board
CREATE TABLE public.mc_pcb_board (
    id bigint NOT NULL,
    part_number character varying(64) NOT NULL,
    specification character varying(255),
    version character varying(32) NOT NULL,
    plugin_silk_screen_img character varying(255),
    smt_silk_screen_img character varying(255),
    remark text,
    created_at timestamp without time zone NOT NULL
);

-- TABLE stock_snapshot
CREATE TABLE public.stock_snapshot (
    base character varying(20) DEFAULT NULL::character varying,
    prod_category character varying(50) DEFAULT NULL::character varying,
    prod_name character varying(200) DEFAULT NULL::character varying,
    prod_spec character varying(200) DEFAULT NULL::character varying,
    cust_code character varying(50) DEFAULT NULL::character varying,
    cust_short_name character varying(200) DEFAULT NULL::character varying,
    dept_code character varying(50) DEFAULT NULL::character varying,
    dept_name character varying(100) DEFAULT NULL::character varying,
    salesperson character varying(100) DEFAULT NULL::character varying,
    stock numeric(18,6) DEFAULT NULL::numeric,
    std_price numeric(18,6) DEFAULT NULL::numeric,
    amount numeric(18,6) DEFAULT NULL::numeric,
    rt_stock numeric(18,6) DEFAULT NULL::numeric,
    rt_amount numeric(18,6) DEFAULT NULL::numeric,
    stock_date character varying(10) DEFAULT NULL::character varying,
    biz_date character varying(10) DEFAULT NULL::character varying,
    aging integer,
    warehouse character varying(100) DEFAULT NULL::character varying,
    material_status character varying(20) DEFAULT NULL::character varying,
    order_no character varying(50) DEFAULT NULL::character varying,
    orig_delivery character varying(50) DEFAULT NULL::character varying,
    pc_delivery character varying(50) DEFAULT NULL::character varying,
    mc_delivery character varying(50) DEFAULT NULL::character varying,
    purchase_delivery character varying(50) DEFAULT NULL::character varying,
    prod_code character varying(50) DEFAULT NULL::character varying,
    cust_item_no character varying(50) DEFAULT NULL::character varying,
    cust_full_name character varying(200) DEFAULT NULL::character varying,
    dept_code2 character varying(50) DEFAULT NULL::character varying,
    category_name character varying(100) DEFAULT NULL::character varying,
    biz_division character varying(100) DEFAULT NULL::character varying,
    cust_name character varying(200) DEFAULT NULL::character varying,
    analysis_reason character varying(500) DEFAULT NULL::character varying,
    sync_time timestamp without time zone
);


-- ==========================================================================
-- 02. CREATE missing sequences (4)
-- ==========================================================================

-- SEQUENCE eq_test_report_id_seq
CREATE SEQUENCE public.eq_test_report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- SEQUENCE eq_test_report_item_id_seq
CREATE SEQUENCE public.eq_test_report_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- SEQUENCE llm_usage_id_seq
CREATE SEQUENCE public.llm_usage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- SEQUENCE mc_pcb_board_id_seq
CREATE SEQUENCE public.mc_pcb_board_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


-- ==========================================================================
-- 03. ALTER existing tables (preserve extra columns)
-- ==========================================================================

-- agent_version: missing column
ALTER TABLE public.agent_version ADD COLUMN device_type character varying(20);

-- device_changeover_log: bigint -> integer (preflight checks all existing values)
ALTER TABLE public.device_changeover_log ALTER COLUMN duration_seconds TYPE integer;

-- device_daily_stats: integer -> bigint; deliberately retain extra shift_type column in safe migration
ALTER TABLE public.device_daily_stats ALTER COLUMN total_stop_events TYPE bigint;

-- postgres_test_equipment: 3 missing columns
ALTER TABLE public.postgres_test_equipment
    ADD COLUMN department_owner character varying(80),
    ADD COLUMN track_name character varying(10),
    ADD COLUMN workshop_name character varying(240);

-- sys_tasks: varchar(1024) -> varchar(1000) (preflight checks lengths)
ALTER TABLE public.sys_tasks ALTER COLUMN jobparams TYPE character varying(1000);

-- device_event.id: default is already nextval(...) in BOTH dumps, do not change.


-- ==========================================================================
-- 04. SEQUENCE ownership + DEFAULT for NEW tables
-- ==========================================================================

-- SEQUENCE OWNED BY eq_test_report_id_seq
ALTER SEQUENCE public.eq_test_report_id_seq OWNED BY public.eq_test_report.id;

-- SEQUENCE OWNED BY eq_test_report_item_id_seq
ALTER SEQUENCE public.eq_test_report_item_id_seq OWNED BY public.eq_test_report_item.id;

-- SEQUENCE OWNED BY llm_usage_id_seq
ALTER SEQUENCE public.llm_usage_id_seq OWNED BY public.llm_usage.id;

-- SEQUENCE OWNED BY mc_pcb_board_id_seq
ALTER SEQUENCE public.mc_pcb_board_id_seq OWNED BY public.mc_pcb_board.id;

-- DEFAULT eq_test_report id
ALTER TABLE ONLY public.eq_test_report ALTER COLUMN id SET DEFAULT nextval('public.eq_test_report_id_seq'::regclass);

-- DEFAULT eq_test_report_item id
ALTER TABLE ONLY public.eq_test_report_item ALTER COLUMN id SET DEFAULT nextval('public.eq_test_report_item_id_seq'::regclass);

-- DEFAULT llm_usage id
ALTER TABLE ONLY public.llm_usage ALTER COLUMN id SET DEFAULT nextval('public.llm_usage_id_seq'::regclass);

-- DEFAULT mc_pcb_board id
ALTER TABLE ONLY public.mc_pcb_board ALTER COLUMN id SET DEFAULT nextval('public.mc_pcb_board_id_seq'::regclass);


-- ==========================================================================
-- 05. Update existing unique constraint
-- ==========================================================================

-- NOTE: this narrows uniqueness from (device_code,stat_date,shift_type) to (device_code,stat_date).
ALTER TABLE ONLY public.device_daily_stats
    DROP CONSTRAINT device_daily_stats_device_code_stat_date_key;
ALTER TABLE ONLY public.device_daily_stats
    ADD CONSTRAINT device_daily_stats_device_code_stat_date_key UNIQUE (device_code, stat_date);


-- ==========================================================================
-- 06. PRIMARY KEY and FOREIGN KEY for new tables
-- ==========================================================================

-- CONSTRAINT eq_test_report_item eq_test_report_item_pkey
ALTER TABLE ONLY public.eq_test_report_item
    ADD CONSTRAINT eq_test_report_item_pkey PRIMARY KEY (id);

-- CONSTRAINT eq_test_report eq_test_report_pkey
ALTER TABLE ONLY public.eq_test_report
    ADD CONSTRAINT eq_test_report_pkey PRIMARY KEY (id);

-- CONSTRAINT llm_usage llm_usage_pkey
ALTER TABLE ONLY public.llm_usage
    ADD CONSTRAINT llm_usage_pkey PRIMARY KEY (id);

-- CONSTRAINT mc_pcb_board mc_pcb_board_pkey
ALTER TABLE ONLY public.mc_pcb_board
    ADD CONSTRAINT mc_pcb_board_pkey PRIMARY KEY (id);

-- FK CONSTRAINT eq_test_report_item eq_test_report_item_report_id_fkey
ALTER TABLE ONLY public.eq_test_report_item
    ADD CONSTRAINT eq_test_report_item_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.eq_test_report(id) ON DELETE CASCADE;


-- ==========================================================================
-- 07. Update functions and stored procedures (2)
-- ==========================================================================

-- FUNCTION parse_cycle_time(text)
CREATE OR REPLACE FUNCTION public.parse_cycle_time(cycle_str text) RETURNS numeric
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    seconds NUMERIC;
    colon_pos INT;
    minutes_part TEXT;
    seconds_part TEXT;
    val NUMERIC;
BEGIN
    IF cycle_str IS NULL OR cycle_str = '' THEN
        RETURN NULL;
    END IF;
    
    -- 去除首尾空白，并去掉末尾的 's' 或 'S'
    cycle_str := TRIM(TRAILING 's' FROM TRIM(TRAILING 'S' FROM TRIM(cycle_str)));
    
    colon_pos := POSITION(':' IN cycle_str);
    IF colon_pos > 0 THEN
        -- 格式为 "分:秒" → 直接计算秒数
        minutes_part := SUBSTRING(cycle_str, 1, colon_pos-1);
        seconds_part := SUBSTRING(cycle_str, colon_pos+1);
        seconds := minutes_part::NUMERIC * 60 + seconds_part::NUMERIC;
    ELSE
        -- 纯数字：旧数据可能为秒（通常 < 60），新数据为毫秒（通常 ≥ 60）
        val := cycle_str::NUMERIC;
        IF val < 60 THEN
            seconds := val;          -- 视为秒
        ELSE
            seconds := val / 1000;   -- 视为毫秒，转换为秒
        END IF;
    END IF;
    
    RETURN seconds;
END;
$$;

-- PROCEDURE sp_calc_device_daily_stats()
CREATE OR REPLACE PROCEDURE public.sp_calc_device_daily_stats()
    LANGUAGE plpgsql
    AS $$
BEGIN
-- ============================================================
-- 合并统计：产量、不良、停机、换线、节拍
-- 执行一次即可更新 device_shift_stats 的所有指标
-- ============================================================

WITH
-- 1. 产量与时间统计（基于 device_data）
shift_data_raw AS (
    SELECT
        device_code,
        created_at,
        production_count,
        production_point_count,
        CASE
            WHEN EXTRACT(HOUR FROM created_at) >= 8 AND EXTRACT(HOUR FROM created_at) < 20 THEN '白班'
            ELSE '夜班'
        END AS shift_type,
        CASE
            WHEN EXTRACT(HOUR FROM created_at) >= 20 THEN DATE(created_at)
            WHEN EXTRACT(HOUR FROM created_at) < 8 THEN DATE(created_at) - INTERVAL '1 day'
            ELSE DATE(created_at)
        END AS shift_date
    FROM device_data
    WHERE created_at >= CURRENT_DATE - INTERVAL '2 days' and device_type in ('AI','RI')  -- 确保夜班完整
),
ranked AS (
    SELECT
        device_code, shift_date, shift_type, created_at,
        production_count, production_point_count,
        LAG(created_at) OVER (PARTITION BY device_code, shift_date, shift_type ORDER BY created_at) AS prev_created_at
    FROM shift_data_raw
),
downtime_calc AS (
    SELECT
        device_code, shift_date, shift_type,
        COUNT(production_count) AS total_boards,
        SUM(production_point_count) AS total_points,
        SUM(
            CASE
                WHEN prev_created_at IS NOT NULL
                     AND EXTRACT(EPOCH FROM (created_at - prev_created_at)) > 180
                THEN EXTRACT(EPOCH FROM (created_at - prev_created_at))
                ELSE 0
            END
        )::INT AS downtime_seconds,
        EXTRACT(EPOCH FROM (MAX(created_at) - MIN(created_at)))::INT AS data_span_seconds
    FROM ranked
    GROUP BY device_code, shift_date, shift_type
),
shift_stats AS (
    SELECT
        device_code, shift_date, shift_type,
        total_boards, total_points,
        downtime_seconds, data_span_seconds,
        GREATEST(data_span_seconds - downtime_seconds, 0) AS running_seconds
    FROM downtime_calc
),

-- 2. 不良统计（defect_detail）
ng_stats AS (
    SELECT
        device_code,
        CASE
            WHEN EXTRACT(HOUR FROM created_at) >= 20 THEN DATE(created_at)
            WHEN EXTRACT(HOUR FROM created_at) < 8 THEN DATE(created_at) - INTERVAL '1 day'
            ELSE DATE(created_at)
        END AS shift_date,
        CASE
            WHEN EXTRACT(HOUR FROM created_at) >= 8 AND EXTRACT(HOUR FROM created_at) < 20 THEN '白班'
            ELSE '夜班'
        END AS shift_type,
        COUNT(DISTINCT data_id) AS total_ng_boards,
        SUM(ng_count) AS total_ng_points
    FROM defect_detail
    WHERE created_at >= CURRENT_DATE - INTERVAL '2 days'
    GROUP BY device_code, shift_date, shift_type
),

-- 3. 停机次数统计（device_stop_detail）
stop_stats AS (
    SELECT
        device_code,
        CASE
            WHEN EXTRACT(HOUR FROM created_at) >= 20 THEN DATE(created_at)
            WHEN EXTRACT(HOUR FROM created_at) < 8 THEN DATE(created_at) - INTERVAL '1 day'
            ELSE DATE(created_at)
        END AS shift_date,
        CASE
            WHEN EXTRACT(HOUR FROM created_at) >= 8 AND EXTRACT(HOUR FROM created_at) < 20 THEN '白班'
            ELSE '夜班'
        END AS shift_type,
        COUNT(*) AS total_stop_events
    FROM device_stop_detail
    WHERE created_at >= CURRENT_DATE - INTERVAL '2 days'
    GROUP BY device_code, shift_date, shift_type
),

-- 4. 换线统计（device_changeover_log）
changeover_stats AS (
    SELECT
        device_code,
        CASE
            WHEN EXTRACT(HOUR FROM start_time) >= 20 THEN DATE(start_time)
            WHEN EXTRACT(HOUR FROM start_time) < 8 THEN DATE(start_time) - INTERVAL '1 day'
            ELSE DATE(start_time)
        END AS shift_date,
        CASE
            WHEN EXTRACT(HOUR FROM start_time) >= 8 AND EXTRACT(HOUR FROM start_time) < 20 THEN '白班'
            ELSE '夜班'
        END AS shift_type,
        COUNT(*) AS changeover_count,
        COALESCE(SUM(duration_seconds), 0) AS changeover_seconds
    FROM device_changeover_log
    WHERE start_time >= CURRENT_DATE - INTERVAL '1 day' - INTERVAL '12 hours'
      AND start_time < CURRENT_DATE + INTERVAL '12 hours'
    GROUP BY device_code, shift_date, shift_type
),

-- 5. 理论节拍（按设备+日期，不分班次）
cycle_data AS (
    SELECT 
        device_code,
        DATE(created_at) AS stat_date,
        parse_cycle_time(cycle_time) AS actual_seconds,
        NTILE(10) OVER (PARTITION BY device_code, DATE(created_at) ORDER BY parse_cycle_time(cycle_time)) AS percentile
    FROM device_data
    WHERE     device_type in ('AI','RI')  and cycle_time IS NOT NULL
      AND parse_cycle_time(cycle_time) > 0
),
cycle_theoretical AS (
    SELECT 
        device_code,
        stat_date,
        AVG(actual_seconds) + 8 AS theoretical_cycle_seconds
    FROM cycle_data
    WHERE percentile = 1
    GROUP BY device_code, stat_date
),

-- 6. 合并所有指标（FULL OUTER JOIN 确保没有数据的班次也能被创建或保留原值）
combined AS (
    SELECT
        COALESCE(s.device_code, n.device_code, t.device_code, c.device_code) AS device_code,
        COALESCE(s.shift_date, n.shift_date, t.shift_date, c.shift_date) AS shift_date,
        COALESCE(s.shift_type, n.shift_type, t.shift_type, c.shift_type) AS shift_type,
        s.total_boards,
        s.total_points,
        s.downtime_seconds,
        s.data_span_seconds,
        s.running_seconds,
        n.total_ng_boards ,
        n.total_ng_points,
        t.total_stop_events,
        c.changeover_count,
        c.changeover_seconds,
        ct.theoretical_cycle_seconds,
        NOW() AS updated_at
    FROM shift_stats s
    FULL OUTER JOIN ng_stats n USING (device_code, shift_date, shift_type)
    FULL OUTER JOIN stop_stats t USING (device_code, shift_date, shift_type)
    FULL OUTER JOIN changeover_stats c USING (device_code, shift_date, shift_type)
    LEFT JOIN cycle_theoretical ct ON ct.device_code = COALESCE(s.device_code, n.device_code, t.device_code, c.device_code)
                                  AND ct.stat_date = COALESCE(s.shift_date, n.shift_date, t.shift_date, c.shift_date)
)

-- 7. 插入或更新目标表
INSERT INTO device_shift_stats (
    device_code, shift_date, shift_type,
    total_boards, total_points,
    downtime_seconds, data_span_seconds, running_seconds,
    total_ng_boards, total_ng_points,
    total_stop_events,
    changeover_count, changeover_seconds,
    theoretical_cycle_seconds,
    updated_at
)
SELECT
    device_code, shift_date, shift_type,
    total_boards, total_points,
    downtime_seconds, data_span_seconds, running_seconds,
    total_ng_boards, total_ng_points,
    total_stop_events,
    changeover_count, changeover_seconds,
    theoretical_cycle_seconds,
    updated_at
FROM combined
ON CONFLICT (device_code, shift_date, shift_type) DO UPDATE SET
    total_boards = EXCLUDED.total_boards,
    total_points = EXCLUDED.total_points,
    downtime_seconds = EXCLUDED.downtime_seconds,
    data_span_seconds = EXCLUDED.data_span_seconds,
    running_seconds = EXCLUDED.running_seconds,
    total_ng_boards = EXCLUDED.total_ng_boards,
    total_ng_points = EXCLUDED.total_ng_points,
    total_stop_events = EXCLUDED.total_stop_events,
    changeover_count = EXCLUDED.changeover_count,
    changeover_seconds = EXCLUDED.changeover_seconds,
    theoretical_cycle_seconds = EXCLUDED.theoretical_cycle_seconds,
    updated_at = EXCLUDED.updated_at;

   END;
$$;


-- ==========================================================================
-- 08. CREATE missing views (2)
-- ==========================================================================

-- VIEW v_production_stats_by_shift_date
CREATE VIEW public.v_production_stats_by_shift_date AS
 WITH base AS (
         SELECT d.device_code,
            di.line_body,
            di.workshop,
            di.factory,
            d.current_program,
            d.production_count,
            d.production_point_count,
            public.parse_cycle_time((d.cycle_time)::text) AS actual_seconds,
                CASE
                    WHEN (EXTRACT(hour FROM d.created_at) >= (20)::numeric) THEN (d.created_at)::date
                    WHEN (EXTRACT(hour FROM d.created_at) < (8)::numeric) THEN ((d.created_at - '1 day'::interval))::date
                    ELSE (d.created_at)::date
                END AS shift_date
           FROM (public.device_data d
             LEFT JOIN public.device_info di ON (((d.device_code)::text = (di.device_code)::text)))
          WHERE ((d.production_count IS NOT NULL) AND (d.production_count > 0))
        )
 SELECT device_code,
    line_body,
    workshop,
    factory,
    current_program,
    shift_date,
    (date_trunc('week'::text, (shift_date)::timestamp with time zone))::date AS week_start,
    to_char((shift_date)::timestamp with time zone, 'IYYY-IW'::text) AS week_iso,
    (date_trunc('month'::text, (shift_date)::timestamp with time zone))::date AS month_start,
    to_char((shift_date)::timestamp with time zone, 'YYYY-MM'::text) AS month,
    count(production_count) AS total_boards,
    sum(production_point_count) AS total_points,
    round(min(actual_seconds), 2) AS cycle_time
   FROM base
  GROUP BY device_code, line_body, workshop, factory, current_program, shift_date, (date_trunc('week'::text, (shift_date)::timestamp with time zone)), (to_char((shift_date)::timestamp with time zone, 'IYYY-IW'::text)), (date_trunc('month'::text, (shift_date)::timestamp with time zone)), (to_char((shift_date)::timestamp with time zone, 'YYYY-MM'::text));

-- VIEW v_testresult_fct_hour
CREATE VIEW public.v_testresult_fct_hour AS
 SELECT
        CASE
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'D'::text) THEN '广东基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'R'::text) THEN '广东基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'P'::text) THEN '广东基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'Z'::text) THEN '浙江基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'A'::text) THEN '安徽基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'L'::text) THEN '安徽基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'V'::text) THEN '越南基地'::text
            ELSE '其他基地'::text
        END AS productionbase,
        CASE
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'D'::text) THEN '事业二三部'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'R'::text) THEN '事业一部'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'P'::text) THEN '事业二三部'::text
            WHEN ("substring"((p.line_name)::text, 1, 2) = 'AA'::text) THEN '事业一部'::text
            WHEN ("substring"((p.line_name)::text, 1, 2) = 'AB'::text) THEN '事业二三部'::text
            WHEN ("substring"((p.line_name)::text, 1, 2) = 'AE'::text) THEN '事业二三部'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'Z'::text) THEN '浙江工厂'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'A'::text) THEN '安徽一厂'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'L'::text) THEN '安徽三厂'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'V'::text) THEN '越南工厂'::text
            ELSE '其他'::text
        END AS factory,
    p.line_name AS line,
    edl.equipment_code AS equipmentcode,
    edl.type AS testtype,
    to_char(edl.ts, 'YYYY-MM-DD'::text) AS testday,
    EXTRACT(hour FROM edl.ts) AS testhour,
    sum(
        CASE edl.result
            WHEN 'OK'::text THEN 1
            ELSE 0
        END) AS okqty,
    sum(
        CASE edl.result
            WHEN 'NG'::text THEN 1
            ELSE 0
        END) AS ngqty,
    count(1) AS totalqty,
    round((((sum(
        CASE edl.result
            WHEN 'OK'::text THEN 1
            ELSE 0
        END))::numeric * 100.0) / (count(1))::numeric), 4) AS yieid,
    avg((edl.yieid)::double precision) AS deviceyieid,
    min(edl.ts) AS firsttesttime,
    max(edl.ts) AS lasttesttime,
    (array_agg(edl.result ORDER BY edl.ts DESC))[1] AS lasttestresult
   FROM (public.equipment_data_latest edl
     LEFT JOIN public.postgres_test_equipment p ON (((edl.equipment_code)::text = (p.equipment_code)::text)))
  WHERE ((edl.type)::text = 'FCT'::text)
  GROUP BY p.line_name, edl.equipment_code, edl.type, (to_char(edl.ts, 'YYYY-MM-DD'::text)), (EXTRACT(hour FROM edl.ts));


-- ==========================================================================
-- 09. Update existing views (2)
-- ==========================================================================

-- VIEW v_testresult_hour
CREATE OR REPLACE VIEW public.v_testresult_hour AS
 WITH a AS (
         SELECT edl.equipment_code AS equipmentcode,
            edl.type AS testtype,
            to_char(edl.ts, 'YYYY-MM-DD'::text) AS testday,
            EXTRACT(hour FROM edl.ts) AS testhour,
            edl.ts,
            edl.created,
            edl.endtime,
            edl.result AS testresult,
            (edl.yieid)::double precision AS yieid
           FROM public.equipment_data_latest edl
          WHERE ((edl.type)::text = ANY (ARRAY[('ICT'::character varying)::text, ('FCT'::character varying)::text]))
        ), g AS (
         SELECT a.equipmentcode,
            a.testtype,
            a.testday,
            a.testhour,
            sum(
                CASE a.testresult
                    WHEN 'OK'::text THEN 1
                    ELSE 0
                END) AS okqty,
            sum(
                CASE a.testresult
                    WHEN 'NG'::text THEN 1
                    ELSE 0
                END) AS ngqty,
            count(1) AS totalqty,
            round((((sum(
                CASE a.testresult
                    WHEN 'OK'::text THEN 1
                    ELSE 0
                END))::numeric * 100.0) / (count(1))::numeric), 4) AS yieid,
            avg(a.yieid) AS deviceyieid,
            min(a.ts) AS firsttesttime,
            max(a.ts) AS lasttesttime,
            (array_agg((a.testresult)::text ORDER BY a.ts DESC))[1] AS lasttestresult
           FROM a
          GROUP BY a.equipmentcode, a.testtype, a.testday, a.testhour
        )
 SELECT
        CASE
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'D'::text) THEN '广东基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'R'::text) THEN '广东基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'P'::text) THEN '广东基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'Z'::text) THEN '浙江基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'A'::text) THEN '安徽基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'L'::text) THEN '安徽基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'V'::text) THEN '越南基地'::text
            ELSE '其他基地'::text
        END AS productionbase,
        CASE
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'D'::text) THEN '事业二三部'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'R'::text) THEN '事业一部'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'P'::text) THEN '事业二三部'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'Z'::text) THEN '浙江工厂'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'A'::text) THEN '安徽一厂'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'L'::text) THEN '安徽三厂'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'V'::text) THEN '越南工厂'::text
            ELSE '其他'::text
        END AS factory,
    p.line_name AS line,
    g.equipmentcode,
    g.testtype,
    g.testday,
    g.testhour,
    g.okqty,
    g.ngqty,
    g.totalqty,
    g.yieid,
    g.deviceyieid,
    g.firsttesttime,
    g.lasttesttime,
    g.lasttestresult
   FROM (g
     LEFT JOIN public.postgres_test_equipment p ON (((g.equipmentcode)::text = (p.equipment_code)::text)));

-- VIEW v_testresult_ict_hour
CREATE OR REPLACE VIEW public.v_testresult_ict_hour AS
 WITH a AS (
         SELECT edl.equipment_code AS equipmentcode,
            edl.type AS testtype,
            to_char(edl.ts, 'YYYY-MM-DD'::text) AS testday,
            EXTRACT(hour FROM edl.ts) AS testhour,
            edl.ts,
            edl.starttime,
            edl.endtime,
            edl.result AS testresult,
            (edl.yieid)::double precision AS yieid
           FROM public.equipment_data_latest edl
          WHERE ((edl.type)::text = 'ICT'::text)
        ), g AS (
         SELECT a.equipmentcode,
            a.testtype,
            a.testday,
            a.testhour,
            sum(
                CASE a.testresult
                    WHEN 'OK'::text THEN 1
                    ELSE 0
                END) AS okqty,
            sum(
                CASE a.testresult
                    WHEN 'NG'::text THEN 1
                    ELSE 0
                END) AS ngqty,
            count(1) AS totalqty,
            round((((sum(
                CASE a.testresult
                    WHEN 'OK'::text THEN 1
                    ELSE 0
                END))::numeric * 100.0) / (count(1))::numeric), 4) AS yieid,
            avg(a.yieid) AS deviceyieid,
            min(a.ts) AS firsttesttime,
            max(a.ts) AS lasttesttime,
            (array_agg((a.testresult)::text ORDER BY a.ts DESC))[1] AS lasttestresult
           FROM a
          GROUP BY a.equipmentcode, a.testtype, a.testday, a.testhour
        )
 SELECT
        CASE
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'D'::text) THEN '广东基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'R'::text) THEN '广东基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'P'::text) THEN '广东基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'Z'::text) THEN '浙江基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'A'::text) THEN '安徽基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'L'::text) THEN '安徽基地'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'V'::text) THEN '越南基地'::text
            ELSE '其他基地'::text
        END AS productionbase,
        CASE
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'D'::text) THEN '事业二三部'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'R'::text) THEN '事业一部'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'P'::text) THEN '事业二三部'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'Z'::text) THEN '浙江工厂'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'A'::text) THEN '安徽一厂'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'L'::text) THEN '安徽三厂'::text
            WHEN ("substring"((p.line_name)::text, 0, 2) = 'V'::text) THEN '越南工厂'::text
            ELSE '其他'::text
        END AS factory,
    p.line_name AS line,
    g.equipmentcode,
    g.testtype,
    g.testday,
    g.testhour,
    g.okqty,
    g.ngqty,
    g.totalqty,
    g.yieid,
    g.deviceyieid,
    g.firsttesttime,
    g.lasttesttime,
    g.lasttestresult
   FROM (g
     LEFT JOIN public.postgres_test_equipment p ON (((g.equipmentcode)::text = (p.equipment_code)::text)));


-- ==========================================================================
-- 10. Add missing indexes (17)
-- ==========================================================================

-- INDEX idx_base
CREATE INDEX idx_base ON public.stock_snapshot USING btree (base);

-- INDEX idx_created
CREATE INDEX idx_created ON public.llm_usage USING btree (created_at);

-- INDEX idx_created_at
CREATE INDEX idx_created_at ON public.mc_pcb_board USING btree (created_at);

-- INDEX idx_cust_code
CREATE INDEX idx_cust_code ON public.stock_snapshot USING btree (cust_code);

-- INDEX idx_device_data_prod_stats
CREATE INDEX idx_device_data_prod_stats ON public.device_data USING btree (created_at, device_code, current_program);

-- INDEX idx_eq_test_report_eq_time
CREATE INDEX idx_eq_test_report_eq_time ON public.eq_test_report USING btree (equipment_code, start_time);

-- INDEX idx_eq_test_report_item_key
CREATE INDEX idx_eq_test_report_item_key ON public.eq_test_report_item USING btree (item_key);

-- INDEX idx_eq_test_report_item_report
CREATE INDEX idx_eq_test_report_item_report ON public.eq_test_report_item USING btree (report_id);

-- INDEX idx_eq_test_report_wo
CREATE INDEX idx_eq_test_report_wo ON public.eq_test_report USING btree (wo_no);

-- INDEX idx_equipment_latest_hour_agg
CREATE INDEX idx_equipment_latest_hour_agg ON public.equipment_data_latest USING btree (type, equipment_code, date(created), EXTRACT(hour FROM created)) INCLUDE (result, yieid, created, endtime);

-- INDEX idx_node_created
CREATE INDEX idx_node_created ON public.llm_usage USING btree (node_name, created_at);

-- INDEX idx_part_number
CREATE INDEX idx_part_number ON public.mc_pcb_board USING btree (part_number);

-- INDEX idx_part_version
CREATE INDEX idx_part_version ON public.mc_pcb_board USING btree (part_number, version);

-- INDEX idx_prod_code
CREATE INDEX idx_prod_code ON public.stock_snapshot USING btree (prod_code);

-- INDEX idx_project_created
CREATE INDEX idx_project_created ON public.llm_usage USING btree (project_name, created_at);

-- INDEX idx_specification
CREATE INDEX idx_specification ON public.mc_pcb_board USING btree (specification);

-- INDEX idx_stock_date
CREATE INDEX idx_stock_date ON public.stock_snapshot USING btree (stock_date);


-- ==========================================================================
-- 11. Add missing table/column comments (20)
-- ==========================================================================

-- COMMENT COLUMN agent_version.device_type
COMMENT ON COLUMN public.agent_version.device_type IS '设备类型：SMT=贴片机，AI=卧式插件机，RI=立式插件机';

-- COMMENT TABLE device_changeover_log
COMMENT ON TABLE public.device_changeover_log IS '设备换线记录表';

-- COMMENT TABLE device_daily_stats
COMMENT ON TABLE public.device_daily_stats IS '设备生产日报统计表';

-- COMMENT TABLE device_status_interval
COMMENT ON TABLE public.device_status_interval IS '设备业务状态变化区间表';

-- COMMENT TABLE llm_usage
COMMENT ON TABLE public.llm_usage IS '大模型用量统计表';

-- COMMENT COLUMN llm_usage.project_name
COMMENT ON COLUMN public.llm_usage.project_name IS '项目名';

-- COMMENT COLUMN llm_usage.node_name
COMMENT ON COLUMN public.llm_usage.node_name IS '消耗节点名';

-- COMMENT COLUMN llm_usage.prompt_tokens
COMMENT ON COLUMN public.llm_usage.prompt_tokens IS '输入token数';

-- COMMENT COLUMN llm_usage.completion_tokens
COMMENT ON COLUMN public.llm_usage.completion_tokens IS '输出token数';

-- COMMENT COLUMN llm_usage.latency_s
COMMENT ON COLUMN public.llm_usage.latency_s IS '秒';

-- COMMENT COLUMN llm_usage.created_at
COMMENT ON COLUMN public.llm_usage.created_at IS '创建时间';

-- COMMENT TABLE mc_pcb_board
COMMENT ON TABLE public.mc_pcb_board IS '制造中心PCB板数据表';

-- COMMENT COLUMN mc_pcb_board.part_number
COMMENT ON COLUMN public.mc_pcb_board.part_number IS '料号';

-- COMMENT COLUMN mc_pcb_board.specification
COMMENT ON COLUMN public.mc_pcb_board.specification IS '规格';

-- COMMENT COLUMN mc_pcb_board.version
COMMENT ON COLUMN public.mc_pcb_board.version IS '版本号';

-- COMMENT COLUMN mc_pcb_board.plugin_silk_screen_img
COMMENT ON COLUMN public.mc_pcb_board.plugin_silk_screen_img IS '插件面丝印图片路径';

-- COMMENT COLUMN mc_pcb_board.smt_silk_screen_img
COMMENT ON COLUMN public.mc_pcb_board.smt_silk_screen_img IS '贴片面丝印图片路径';

-- COMMENT COLUMN mc_pcb_board.remark
COMMENT ON COLUMN public.mc_pcb_board.remark IS '备注';

-- COMMENT COLUMN mc_pcb_board.created_at
COMMENT ON COLUMN public.mc_pcb_board.created_at IS '创建时间';

COMMIT;
