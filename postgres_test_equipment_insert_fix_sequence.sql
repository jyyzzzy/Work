-- Generated from uploaded equipment insert script.
-- Purpose: insert rows into public.postgres_test_equipment without requiring a unique index.
-- Rule: if the target table already has the same equipment_code, skip that row.

-- Reset any aborted transaction first. Harmless if no transaction is active.
ROLLBACK;

BEGIN;

-- Fix id auto-increment sequence before inserting.
-- This prevents duplicate key error on primary key id.
SELECT setval(
    pg_get_serial_sequence('public.postgres_test_equipment', 'id'),
    COALESCE((SELECT MAX(id) FROM public.postgres_test_equipment), 0) + 1,
    false
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200155',
    '一部二楼 AA_SMT_01 松下贴片机',
    null,
    'SMT',
    'AA_SMT_01',
    'AA_SMT_01',
    'AASMT01_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200155'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200214',
    '一部二楼 AA_SMT_07 思泰克SPI',
    'SPI',
    'SMT',
    'AA_SMT_07',
    'AA_SMT_07',
    'AASMT07_03',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200214'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200216',
    '一部二楼 AA_SMT_07 松下贴片机',
    null,
    'SMT',
    'AA_SMT_07B',
    'AA_SMT_07B',
    'AASMT_07B',
    NULL,
    '21109',
    'B',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200216'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200042',
    '二部二楼 AB_SMT_01 松下贴片机',
    null,
    'SMT',
    'AB_SMT_01',
    'AB_SMT_01',
    'ABAMT01_04',
    NULLIF(REPLACE('172.16.26.228', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200042'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200041',
    '二部二楼 AB_SMT_01 松下贴片机',
    null,
    'SMT',
    'AB_SMT_01B',
    'AB_SMT_01B',
    'ABAMT01B_11',
    NULLIF(REPLACE('172.16.26.227', ' ', ''), ''),
    '21124',
    'B',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200041'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200042',
    '二部二楼 AB_SMT_01 松下贴片机',
    null,
    'SMT',
    'AB_SMT_01B',
    'AB_SMT_01B',
    'ABAMT01B_04',
    NULLIF(REPLACE('172.16.26.228', ' ', ''), ''),
    '21124',
    'B',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200042'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200045',
    '二部二楼 AB_SMT_02B 思泰克SPI',
    'SPI',
    'SMT',
    'AB_SMT_02B',
    'AB_SMT_02B',
    'ABAMT02B_03',
    NULLIF(REPLACE('172.16.26.48', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200045'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200063',
    '二部二楼 AB_SMT_04 松下贴片机',
    null,
    'SMT',
    'AB_SMT_04',
    'AB_SMT_04',
    'ABAMT04_04',
    NULLIF(REPLACE('172.16.26.220', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200063'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200419',
    '二部三楼 AB_SMT_09 英尚双轨SPI',
    'SPI',
    'AI',
    'AB_SMT_09',
    'AB_SMT_09',
    'ABAMT09_03',
    NULL,
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200419'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200425',
    '二部三楼 AB_SMT_10 英尚双轨SPI',
    'SPI',
    'AI',
    'AB_SMT_10',
    'AB_SMT_10',
    'ABAMT10_03',
    NULL,
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200425'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200002',
    '三部四楼 AE_SMT_02松下贴片机/02',
    null,
    'SMT',
    'AE_SMT_02',
    'AE_SMT_02',
    'AESMT02_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200002'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200298',
    '三部四楼 AE_SMT_02 思泰克SPI',
    'SPI',
    'SMT',
    'AE_SMT_02',
    'AE_SMT_02',
    'AESMT02_03',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200298'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200306',
    '三部四楼 AE_SMT_05 英尚AOI',
    'AOI',
    'SMT',
    'AE_SMT_05',
    'AE_SMT_05',
    'AESMT05_06',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200306'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200143',
    '二部二楼 D4 自研板FCT',
    'FCT',
    'DIP',
    'D04',
    'D04',
    'DIP-D4-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200143'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200453',
    '二部 D08 派捷ICT',
    'ICT',
    'AI',
    'D08',
    'D08',
    'DIP-D8-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200453'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200458',
    '二部 D09 派捷ICT',
    'ICT',
    'AI',
    'D09',
    'D09',
    'DIP-D9-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200458'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ3401011',
    'FCT',
    'FCT',
    null,
    'D10',
    'D10',
    'DIP-D10-27',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ3401011'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200106',
    '二部二楼 D11 自研板FCT',
    'FCT',
    'DIP',
    'D11',
    'D11',
    'DIP-D11-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200106'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200104',
    '二部二楼 D11 赫立AOI',
    'AOI',
    'DIP',
    'D11',
    'D11',
    'DIP-D11-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200104'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200105',
    '二部二楼 D11 派捷ICT',
    'ICT',
    'DIP',
    'D11',
    'D11',
    'DIP-D11-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200105'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200470',
    '二部 D12 自研板FCT',
    'FCT',
    'AI',
    'D12',
    'D12',
    'DIP-D12-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200470'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200484',
    '二部 D15 自研板FCT',
    'FCT',
    'AI',
    'D15',
    'D15',
    'DIP-D15-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200484'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ3401014',
    'FCT',
    'FCT',
    null,
    'D21',
    'D21',
    'DIP-D21-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ3401014'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ3401009',
    'ICT',
    'ICT',
    null,
    'D21',
    'D21',
    'DIP-D21-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ3401009'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ3401010',
    'ICT',
    'ICT',
    null,
    'D25',
    'D25',
    'DIP-D25-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ3401010'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200248',
    '三部四楼 P1 伍洲AOI',
    'AOI',
    'DIP',
    'P01',
    'P01',
    'P01-17',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200248'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200355',
    '三部四楼 P1 自研FCT',
    'FCT',
    'DIP',
    'P01',
    'P01',
    'P01-52',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200355'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200359',
    '三部四楼 P5 自研FCT',
    'FCT',
    'DIP',
    'P05',
    'P05',
    'P05-20',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200359'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200274',
    '三部四楼 P6 派捷ICT',
    'ICT',
    'DIP',
    'P06',
    'P06',
    'P06-61',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200274'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200272',
    '三部四楼 P6 伍洲AOI',
    'AOI',
    'DIP',
    'P06',
    'P06',
    'P06-17',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200272'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200393',
    '三部GFP11功能测试',
    'AOI',
    null,
    'P11',
    'P11',
    'P11-19',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200393'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200014',
    '一部二楼 R01 派捷ICT',
    'ICT',
    'DIP',
    'R01',
    'R01',
    'R01-14',
    NULLIF(REPLACE('172.16.12.49', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200014'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200174',
    '一部二楼 R04 自主研发FCT',
    'FCT',
    'DIP',
    'R04',
    'R04',
    'R04-18',
    NULLIF(REPLACE('172.16.12.22', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200174'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200012',
    '一部二楼 R05 镭晨AOI',
    'AOI',
    'DIP',
    'R05',
    'R05',
    'R05-15',
    NULLIF(REPLACE('172.16.12.157', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200012'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200004',
    '一部二楼 R07 镭晨AOI',
    'AOI',
    'DIP',
    'R07',
    'R07',
    'R07-15',
    NULLIF(REPLACE('172.16.12.84', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200004'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200031',
    '一部二楼 R09 派捷ICT',
    'ICT',
    'DIP',
    'R09',
    'R09',
    'R09-14',
    NULLIF(REPLACE('172.16.12.70', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200031'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200336',
    '一部三楼 R12 自主研发FCT',
    'FCT',
    'DIP',
    'R12',
    'R12',
    'R12-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200336'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200331',
    '一部二楼 R14 自主研发FCT',
    'FCT',
    'DIP',
    'R14',
    'R14',
    'R14-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200331'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200379',
    '一部四楼R18派捷ICT',
    'ICT',
    null,
    'R18',
    'R18',
    'R18-14',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200379'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200154',
    '一部二楼 AA_SMT_01 松下贴片机',
    null,
    'SMT',
    'AA_SMT_01',
    'AA_SMT_01',
    'AASMT01_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200154'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200161',
    '一部二楼 AA_SMT_02 松下贴片机',
    null,
    'SMT',
    'AA_SMT_02',
    'AA_SMT_02',
    'AASMT02_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200161'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200160',
    '一部二楼 AA_SMT_02 松下贴片机',
    null,
    'SMT',
    'AA_SMT_02',
    'AA_SMT_02',
    'AASMT02_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200160'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200165',
    '一部二楼 AA_SMT_03 和田古德SPI',
    'SPI',
    'SMT',
    'AA_SMT_03',
    'AA_SMT_03',
    'AASMT03_10',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200165'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200163',
    '一部二楼 AA_SMT_03 劲拓回流焊',
    null,
    'SMT',
    'AA_SMT_03',
    'AA_SMT_03',
    'AASMT03_12',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200163'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200186',
    '一部二楼 AA_SMT_04 和田古德SPI',
    'SPI',
    'SMT',
    'AA_SMT_04',
    'AA_SMT_04',
    'AASMT04_03',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200186'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200195',
    '一部二楼 AA_SMT_05 松下贴片机',
    null,
    'SMT',
    'AA_SMT_05',
    'AA_SMT_05',
    'AASMT05_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200195'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200198',
    '一部二楼 AA_SMT_05 松下贴片机',
    null,
    'SMT',
    'AA_SMT_05',
    'AA_SMT_05',
    'AASMT05_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200198'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200196',
    '一部二楼 AA_SMT_05 松下贴片机',
    null,
    'SMT',
    'AA_SMT_05',
    'AA_SMT_05',
    'AASMT05_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200196'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200197',
    '一部二楼 AA_SMT_05 松下贴片机',
    null,
    'SMT',
    'AA_SMT_05',
    'AA_SMT_05',
    'AASMT05_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200197'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200200',
    '一部二楼AA_SMT_05B 思泰克SPI',
    'SPI',
    'SMT',
    'AA_SMT_05B',
    'AA_SMT_05B',
    'AASMT05B_03',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200200'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200207',
    '一部二楼 AA_SMT_06 松下贴片机',
    null,
    'SMT',
    'AA_SMT_06',
    'AA_SMT_06',
    'AASMT06_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200207'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200038',
    '二部二楼 AB_SMT_01 劲拓回流焊',
    null,
    'SMT',
    'AB_SMT_01',
    'AB_SMT_01',
    'ABAMT01_12',
    NULLIF(REPLACE('172.16.26.61', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200038'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200050',
    '二部二楼 AB_SMT_02 松下贴片机',
    null,
    'SMT',
    'AB_SMT_02B',
    'AB_SMT_02B',
    'ABAMT02B_04',
    NULLIF(REPLACE('172.16.26.226', ' ', ''), ''),
    '21124',
    'B',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200050'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200056',
    '二部二楼 AB_SMT_03 松下贴片机',
    null,
    'SMT',
    'AB_SMT_03',
    'AB_SMT_03',
    'ABAMT03_11',
    NULLIF(REPLACE('172.16.26.222', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200056'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200059',
    '二部二楼 AB_SMT_04 镭晨AOI',
    'AOI',
    'SMT',
    'AB_SMT_04',
    'AB_SMT_04',
    'ABAMT04_06',
    NULLIF(REPLACE('172.16.26.26', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200059'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200060',
    '二部二楼 AB_SMT_04 劲拓回流焊',
    null,
    'SMT',
    'AB_SMT_04',
    'AB_SMT_04',
    'ABAMT04_05',
    NULLIF(REPLACE('172.16.26.64', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200060'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200296',
    '三部四楼 AE_SMT_01 英尚AOI',
    'AOI',
    'SMT',
    'AE_SMT_01',
    'AE_SMT_01',
    'AESMT01_06',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200296'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200396',
    '三部四楼 AE_SMT_02 快克AOI',
    'AOI',
    'AI',
    'AE_SMT_02',
    'AE_SMT_02',
    'AESMT02_06',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200396'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200303',
    '三部四楼 AE_SMT_03 松下贴片机/01',
    null,
    'SMT',
    'AE_SMT_03',
    'AE_SMT_03',
    'AESMT03_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200303'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200366',
    '三部五楼 AE_SMT_03 SPI',
    'SPI',
    'AI',
    'AE_SMT_03',
    'AE_SMT_03',
    'AESMT03_03',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200366'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200007',
    '三部四楼 AE_SMT_06松下贴片机/02',
    null,
    'SMT',
    'AE_SMT_06',
    'AE_SMT_06',
    'AESMT06-06',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200007'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ360111',
    '放电老化柜',
    null,
    null,
    'C2',
    'C2',
    'C2-17',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ360111'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ3401006',
    'ICT',
    'ICT',
    null,
    'D01',
    'D01',
    'DIP-D1-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ3401006'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200102',
    '二部二楼 D3 自研板FCT',
    'FCT',
    'DIP',
    'D03',
    'D03',
    'DIP-D3-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200102'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200100',
    '二部二楼 D3 派捷ICT',
    'ICT',
    'DIP',
    'D03',
    'D03',
    'DIP-D3-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200100'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200101',
    '二部二楼 D3 自研板FCT',
    'FCT',
    'DIP',
    'D03',
    'D03',
    'DIP-D3-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200101'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200442',
    '二部二楼 D06 赫立AOI',
    'AOI',
    'AI',
    'D06',
    'D06',
    'DIP-D6-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200442'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200444',
    '二部 D06 自研板FCT',
    'FCT',
    'AI',
    'D06',
    'D06',
    'DIP-D6-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200444'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200450',
    '二部 D07 自研板FCT',
    'FCT',
    'AI',
    'D07',
    'D07',
    'DIP-D7-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200450'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200447',
    '二部二楼 D07 赫立AOI',
    'AOI',
    'AI',
    'D07',
    'D07',
    'DIP-D7-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200447'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200452',
    '二部二楼 D08 赫立AOI',
    'AOI',
    'AI',
    'D08',
    'D08',
    'DIP-D8-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200452'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200465',
    '二部 D10 自研板FCT',
    'FCT',
    'AI',
    'D10',
    'D10',
    'DIP-D10-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200465'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200473',
    '二部 D13 派捷ICT',
    'ICT',
    'AI',
    'D13',
    'D13',
    'DIP-D13-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200473'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200480',
    '二部 D14 自研板FCT',
    'FCT',
    'AI',
    'D14',
    'D14',
    'DIP-D14-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200480'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200477',
    '二部二楼 D14 赫立AOI',
    'AOI',
    'AI',
    'D14',
    'D14',
    'DIP-D14-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200477'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200478',
    '二部 D14 派捷ICT',
    'ICT',
    'AI',
    'D14',
    'D14',
    'DIP-D14-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200478'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200119',
    '二部二楼 D18 派捷ICT',
    'ICT',
    'DIP',
    'D18',
    'D18',
    'DIP-D18-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200119'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200118',
    '二部二楼 D18 赫立AOI',
    'AOI',
    'DIP',
    'D18',
    'D18',
    'DIP-D18-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200118'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200093',
    '二部二楼 D19 派捷ICT',
    'ICT',
    'DIP',
    'D19',
    'D19',
    'DIP-D19-12',
    NULLIF(REPLACE('172.16.25.44', ' ', ''), ''),
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200093'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200095',
    '二部二楼 D19 自研板FCT',
    'FCT',
    'DIP',
    'D19',
    'D19',
    'DIP-D19-14',
    NULLIF(REPLACE('172.16.25.110', ' ', ''), ''),
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200095'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200127',
    '二部二楼 D20 自研板FCT',
    'FCT',
    'DIP',
    'D20',
    'D20',
    'DIP-D20-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200127'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200273',
    '三部四楼 P6 自研板FCT',
    'FCT',
    'DIP',
    'P06',
    'P06',
    'P06-19',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200273'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200276',
    '三部四楼 P7 伍洲AOI',
    'AOI',
    'DIP',
    'P07',
    'P07',
    'P07-17',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200276'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200278',
    '三部四楼 P7 派捷ICT',
    'ICT',
    'DIP',
    'P07',
    'P07',
    'P07-52',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200278'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200285',
    '三部四楼 P9 伍洲AOI',
    'AOI',
    'DIP',
    'P09',
    'P09',
    'P09-17',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200285'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200287',
    '三部四楼 P9 派捷ICT',
    'ICT',
    'DIP',
    'P09',
    'P09',
    'P09-16',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200287'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200286',
    '三部四楼 P9 自研板FCT',
    'FCT',
    'DIP',
    'P09',
    'P09',
    'P09-19',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200286'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200023',
    '一部二楼 R02 派捷ICT',
    'ICT',
    'DIP',
    'R02',
    'R02',
    'R02-14',
    NULLIF(REPLACE('172.16.12.96', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200023'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200025',
    '一部二楼 R02 镭晨AOI',
    'AOI',
    'DIP',
    'R02',
    'R02',
    'R02-15',
    NULLIF(REPLACE('172.16.12.116', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200025'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200007',
    '一部二楼 R03 自主研发FCT',
    'FCT',
    'DIP',
    'R03',
    'R03',
    'R03-18',
    NULLIF(REPLACE('172.16.12.104', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200007'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200019',
    '一部二楼 R04 派捷ICT',
    'ICT',
    'DIP',
    'R04',
    'R04',
    'R04-14',
    NULLIF(REPLACE('172.16.15.88', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200019'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200387',
    '一部四楼R6赫立AO1',
    'AOI',
    null,
    'R06',
    'R06',
    'R06-15',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200387'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200032',
    '一部二楼 R09 自主研发FCT',
    'FCT',
    'DIP',
    'R09',
    'R09',
    'R09-18',
    NULLIF(REPLACE('172.16.12.100', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200032'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200335',
    '一部三楼 R12 自主研发FCT',
    'FCT',
    'DIP',
    'R12',
    'R12',
    'R12-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200335'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200342',
    '一部三楼 R13 赫立AOI',
    'AOI',
    'DIP',
    'R13',
    'R13',
    'R13-15',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200342'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200346',
    '一部三楼 R17 自主研发FCT',
    'FCT',
    'DIP',
    'R17',
    'R17',
    'R17-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200346'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200153',
    '一部二楼 AA_SMT_01 松下贴片机',
    null,
    'SMT',
    'AA_SMT_01',
    'AA_SMT_01',
    'AASMT01_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200153'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200201',
    '一部二楼 AA_SMT_06 镭晨AOI',
    'AOI',
    'SMT',
    'AA_SMT_06',
    'AA_SMT_06',
    'AASMT06_06',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200201'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200217',
    '一部二楼 AA_SMT_07 松下贴片机',
    null,
    'SMT',
    'AA_SMT_07',
    'AA_SMT_07',
    'AASMT07_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200217'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200185',
    '一部二楼 AA_SMT_07赫立AOI',
    'AOI',
    'SMT',
    'AA_SMT_07',
    'AA_SMT_07',
    'AASMT07_06',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200185'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200492',
    '一部二楼 AA_SMT_08 松下贴片机',
    null,
    null,
    'AA_SMT_08',
    'AA_SMT_08',
    'AASMT08_06',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200492'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200043',
    '二部二楼 AB_SMT_02 镭晨AOI',
    'AOI',
    'SMT',
    'AB_SMT_02',
    'AB_SMT_02',
    'ABAMT02_06',
    NULLIF(REPLACE('172.16.26.22', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200043'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200077',
    '二部二楼 AB_SMT_07 松下贴片机',
    null,
    'SMT',
    'AB_SMT_07',
    'AB_SMT_07',
    'ABAMT07_04',
    NULLIF(REPLACE('172.16.26.233', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200077'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200299',
    '三部四楼 AE_SMT_02 松下贴片机/01',
    null,
    'SMT',
    'AE_SMT_02',
    'AE_SMT_02',
    'AESMT02_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200299'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200315',
    '三部四楼 AE_SMT_05 松下贴片机/01',
    null,
    'SMT',
    'AE_SMT_05',
    'AE_SMT_05',
    'AESMT05_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200315'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200491',
    '三部四楼AESMT_07劲拓回流焊',
    null,
    null,
    'AE_SMT_07',
    'AE_SMT_07',
    'AESMT07-03',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200491'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200440',
    '二部 D01 自研板FCT',
    'FCT',
    'AI',
    'D01',
    'D01',
    'DIP-D1-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200440'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200147',
    '二部二楼 D2 赫立AOI',
    'AOI',
    'DIP',
    'D02',
    'D02',
    'DIP-D2-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200147'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200149',
    '二部二楼 D2 自研板FCT',
    'FCT',
    'DIP',
    'D02',
    'D02',
    'DIP-D2-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200149'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200099',
    '二部二楼 D3 赫立AOI',
    'AOI',
    'DIP',
    'D03',
    'D03',
    'DIP-D3-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200099'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200137',
    '二部二楼 D5 自研板FCT',
    'FCT',
    'DIP',
    'D05',
    'D05',
    'DIP-D5-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200137'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200443',
    '二部 D06 派捷ICT',
    'ICT',
    'AI',
    'D06',
    'D06',
    'DIP-D6-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200443'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200454',
    '二部 D08 自研板FCT',
    'FCT',
    'AI',
    'D08',
    'D08',
    'DIP-D8-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200454'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200111',
    '二部二楼 D16 赫立AOI',
    'AOI',
    'DIP',
    'D16',
    'D16',
    'DIP-D16-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200111'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200133',
    '二部二楼 D22 自研板FCT',
    'FCT',
    'DIP',
    'D22',
    'D22',
    'DIP-D22-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200133'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ3401015',
    'FCT',
    'FCT',
    null,
    'D25',
    'D25',
    'DIP-D25-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ3401015'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200249',
    '三部四楼 P1 派捷ICT',
    'ICT',
    'DIP',
    'P01',
    'P01',
    'P01-53',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200249'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200265',
    '三部四楼 P4 派捷ICT',
    'ICT',
    'DIP',
    'P04',
    'P04',
    'P04-16',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200265'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200277',
    '三部四楼 P7 自研板FCT',
    'FCT',
    'DIP',
    'P07',
    'P07',
    'P07-19',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200277'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200361',
    '三部四楼 P7 自研FCT',
    'FCT',
    'DIP',
    'P07',
    'P07',
    'P07-51',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200361'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200282',
    '三部四楼 P8 自研板FCT',
    'FCT',
    'DIP',
    'P08',
    'P08',
    'P08-55',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200282'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200290',
    '三部四楼 P10 自研板FCT',
    'FCT',
    'DIP',
    'P10',
    'P10',
    'P10-20',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200290'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200289',
    '三部四楼 P10 伍洲AOI',
    'AOI',
    'DIP',
    'P10',
    'P10',
    'P10-17',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200289'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200176',
    '一部二楼 R11 自主研发FCT',
    'FCT',
    'DIP',
    'R11',
    'R11',
    'R11-18',
    NULLIF(REPLACE('172.16.12.28', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200176'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200027',
    '一部二楼 R11派捷ICT',
    'ICT',
    'DIP',
    'R11',
    'R11',
    'R11-14',
    NULLIF(REPLACE('172.16.12.16', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200027'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200337',
    '一部三楼 R12 赫立AOI',
    'AOI',
    'DIP',
    'R12',
    'R12',
    'R12-15',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200337'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200348',
    '一部三楼 R14 赫立AOI',
    'AOI',
    'DIP',
    'R14',
    'R14',
    'R14-15',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200348'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200382',
    '一部四楼R18赫立AOI',
    'AOI',
    null,
    'R18',
    'R18',
    'R18-15',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200382'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200392',
    '一部四楼R19赫立AO1',
    'AOI',
    null,
    'R19',
    'R19',
    'R19-46',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200392'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200160',
    '一部二楼 AA_SMT_02 松下贴片机',
    null,
    'SMT',
    'AA_SMT_02B',
    'AA_SMT_02B',
    'AASMT02B_04',
    NULL,
    '21109',
    'B',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200160'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200182',
    '一部二楼 AA_SMT_03 松下贴片机',
    null,
    'SMT',
    'AA_SMT_03',
    'AA_SMT_03',
    'AASMT03_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200182'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200188',
    '一部二楼 AA_SMT_04 松下贴片机',
    null,
    'SMT',
    'AA_SMT_04',
    'AA_SMT_04',
    'AASMT04_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200188'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200053',
    '二部二楼 AB_SMT_03 和田古德双轨SPI',
    'SPI',
    'SMT',
    'AB_SMT_03',
    'AB_SMT_03',
    'ABAMT03_03',
    NULLIF(REPLACE('172.16.26.54', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200053'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200056',
    '二部二楼 AB_SMT_03 松下贴片机',
    null,
    'SMT',
    'AB_SMT_03B',
    'AB_SMT_03B',
    'ABAMT03B_11',
    NULLIF(REPLACE('172.16.26.222', ' ', ''), ''),
    '21124',
    'B',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200056'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200064',
    '二部二楼 AB_SMT_04 松下贴片机',
    null,
    'SMT',
    'AB_SMT_04',
    'AB_SMT_04',
    'ABAMT04_04',
    NULLIF(REPLACE('172.16.26.221', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200064'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200070',
    '二部二楼 AB_SMT_05 松下贴片机',
    null,
    'SMT',
    'AB_SMT_05B',
    'AB_SMT_05B',
    'ABAMT05B_04',
    NULLIF(REPLACE('172.16.26.230', ' ', ''), ''),
    '21124',
    'B',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200070'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200421',
    '二部三楼 AB_SMT_09 松下贴片机',
    null,
    'AI',
    'AB_SMT_09',
    'AB_SMT_09',
    'ABAMT09_04',
    NULL,
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200421'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200001',
    '三部四楼 AE_SMT_01松下贴片机/01',
    null,
    'SMT',
    'AE_SMT_01',
    'AE_SMT_01',
    'AESMT01_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200001'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200293',
    '三部四楼 AE_SMT_01 振华兴科技SPI',
    'SPI',
    'SMT',
    'AE_SMT_01',
    'AE_SMT_01',
    'AESMT01_03',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200293'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200301',
    '三部四楼 AE_SMT_02 振华兴科技AOI',
    'AOI',
    'SMT',
    'AE_SMT_02',
    'AE_SMT_02',
    'AESMT02_06',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200301'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200305',
    '三部四楼 AE_SMT_03 路远回流焊/01',
    null,
    'SMT',
    'AE_SMT_03',
    'AE_SMT_03',
    'AESMT03_05',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200305'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200316',
    '三部四楼 AE_SMT_05 松下贴片机/02',
    null,
    'SMT',
    'AE_SMT_05',
    'AE_SMT_05',
    'AESMT05_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200316'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200005',
    '三部四楼 AE_SMT_05松下贴片机/03',
    null,
    'SMT',
    'AE_SMT_05',
    'AE_SMT_05',
    'AESMT05_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200005'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200006',
    '三部四楼 AE_SMT_06松下贴片机/01',
    null,
    'SMT',
    'AE_SMT_06',
    'AE_SMT_06',
    'AESMT06-06',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200006'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200438',
    '二部 D01 派捷ICT',
    'ICT',
    'AI',
    'D01',
    'D01',
    'DIP-D1-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200438'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200142',
    '二部二楼 D4 派捷ICT',
    'ICT',
    'DIP',
    'D04',
    'D04',
    'DIP-D4-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200142'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200135',
    '二部二楼 D5 赫立AOI',
    'AOI',
    'DIP',
    'D05',
    'D05',
    'DIP-D5-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200135'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200138',
    '二部二楼 D5 自研板FCT',
    'FCT',
    'DIP',
    'D05',
    'D05',
    'DIP-D5-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200138'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200464',
    '二部 D10 自研板FCT',
    'FCT',
    'AI',
    'D10',
    'D10',
    'DIP-D10-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200464'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200107',
    '二部二楼 D11 自研板FCT',
    'FCT',
    'DIP',
    'D11',
    'D11',
    'DIP-D11-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200107'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200467',
    '二部二楼 D12 赫立AOI',
    'AOI',
    'AI',
    'D12',
    'D12',
    'DIP-D12-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200467'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200468',
    '二部 D12 派捷ICT',
    'ICT',
    'AI',
    'D12',
    'D12',
    'DIP-D12-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200468'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200469',
    '二部 D12 自研板FCT',
    'FCT',
    'AI',
    'D12',
    'D12',
    'DIP-D12-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200469'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200121',
    '二部二楼 D18 自研板FCT',
    'FCT',
    'DIP',
    'D18',
    'D18',
    'DIP-D18-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200121'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200124',
    '二部二楼 D20 赫立AOI',
    'AOI',
    'DIP',
    'D20',
    'D20',
    'DIP-D20-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200124'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200131',
    '二部二楼 D22 派捷ICT',
    'ICT',
    'DIP',
    'D22',
    'D22',
    'DIP-D22-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200131'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200269',
    '三部四楼 P5 派捷ICT',
    'ICT',
    null,
    'P05',
    'P05',
    'P05-16',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200269'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200364',
    '三部四楼 P10 自研FCT',
    'FCT',
    'DIP',
    'P10',
    'P10',
    'P10-20',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200364'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200180',
    '一部二楼 R01 派捷ICT',
    'ICT',
    'DIP',
    'R01',
    'R01',
    'R01-14',
    NULLIF(REPLACE('172.16.12.12', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200180'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200011',
    '一部二楼 R05 自主研发FCT',
    'FCT',
    'DIP',
    'R05',
    'R05',
    'R05-18',
    NULLIF(REPLACE('172.16.12.94', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200011'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200384',
    '一部四楼R06派捷ICT',
    'ICT',
    null,
    'R06',
    'R06',
    'R06-14',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200384'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200170',
    '一部二楼 R07 自主研发FCT',
    'FCT',
    'DIP',
    'R07',
    'R07',
    'R07-18',
    NULLIF(REPLACE('172.16.12.60', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200170'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200002',
    '一部二楼 R07 派捷ICT',
    'ICT',
    'DIP',
    'R07',
    'R07',
    'R07-14',
    NULLIF(REPLACE('172.16.12.59', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200002'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200177',
    '一部二楼 R09 自主研发FCT',
    'FCT',
    'DIP',
    'R09',
    'R09',
    'R09-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200177'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200178',
    '一部二楼 R10 自主研发FCT',
    'FCT',
    'DIP',
    'R10',
    'R10',
    'R10-18',
    NULLIF(REPLACE('172.16.12.85', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200178'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200028',
    '一部二楼 R11 自主研发FCT',
    'FCT',
    'DIP',
    'R11',
    'R11',
    'R11-18',
    NULLIF(REPLACE('172.16.12.29', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200028'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200029',
    '一部二楼 R11 镭晨AOI',
    'AOI',
    'DIP',
    'R11',
    'R11',
    'R11-15',
    NULLIF(REPLACE('172.16.12.92', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200029'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200354',
    '一部三楼 R16 赫立AOI',
    'AOI',
    'DIP',
    'R16',
    'R16',
    'R16-15',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200354'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200352',
    '一部三楼 R16 自主研发FCT',
    'FCT',
    'DIP',
    'R16',
    'R16',
    'R16-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200352'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200351',
    '一部三楼 R16 派捷ICT',
    'ICT',
    'DIP',
    'R16',
    'R16',
    'R16-14',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200351'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200329',
    '一部三楼 R17 派捷ICT',
    'ICT',
    'DIP',
    'R17',
    'R17',
    'R17-14',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200329'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200380',
    '一部四楼 R18 自主研发FCT',
    'FCT',
    null,
    'R18',
    'R18',
    'R18-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200380'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200389',
    '一部四楼R19派捷ICT',
    'ICT',
    null,
    'R19',
    'R19',
    'R19-45',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200389'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200151',
    '一部二楼 AA_SMT_01 日东回流焊',
    null,
    'SMT',
    'AA_SMT_01',
    'AA_SMT_01',
    'AASMT01_12',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200151'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200157',
    '一部二楼 AA_SMT_02 日东回流焊',
    null,
    'SMT',
    'AA_SMT_02',
    'AA_SMT_02',
    'AASMT02_12',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200157'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200167',
    '一部二楼 AA_SMT_03 松下贴片机',
    null,
    'SMT',
    'AA_SMT_03',
    'AA_SMT_03',
    'AASMT03_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200167'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200184',
    '一部二楼 AA_SMT_04 日东回流焊',
    null,
    'SMT',
    'AA_SMT_04',
    'AA_SMT_04',
    'AASMT04_05',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200184'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200211',
    '一部二楼 AA_SMT_04 雷晨AOI',
    'AOI',
    'SMT',
    'AA_SMT_04',
    'AA_SMT_04',
    'AASMT04_06',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200211'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200193',
    '一部二楼AA_SMT_05 思泰克SPI',
    'SPI',
    'SMT',
    'AA_SMT_05',
    'AA_SMT_05',
    'AASMT05_03',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200193'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200205',
    '一部二楼 AA_SMT_06 松下贴片机',
    null,
    'SMT',
    'AA_SMT_06',
    'AA_SMT_06',
    'AASMT06_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200205'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200204',
    '一部二楼 AA_SMT_06 思泰克SPI',
    'SPI',
    'SMT',
    'AA_SMT_06',
    'AA_SMT_06',
    'AASMT06_03',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200204'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200210',
    '一部二楼 AA_SMT_06B 思泰克SPI',
    'SPI',
    'SMT',
    'AA_SMT_06B',
    'AA_SMT_06B',
    'AASMT06B_03',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200210'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200052',
    '二部二楼 AB_SMT_01 镭晨AOI',
    'AOI',
    'SMT',
    'AB_SMT_01',
    'AB_SMT_01',
    'ABAMT01_06',
    NULLIF(REPLACE('172.16.26.24', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200052'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200046',
    '二部二楼 AB_SMT_02 劲拓回流焊',
    null,
    'SMT',
    'AB_SMT_02',
    'AB_SMT_02',
    'ABAMT02_05',
    NULLIF(REPLACE('172.16.26.71', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200046'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200058',
    '二部二楼 AB_SMT_03 松下贴片机',
    null,
    'SMT',
    'AB_SMT_03',
    'AB_SMT_03',
    'ABAMT03_04',
    NULLIF(REPLACE('172.16.26.224', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200058'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200061',
    '二部二楼 AB_SMT_04 思泰克SPI',
    'SPI',
    'SMT',
    'AB_SMT_04',
    'AB_SMT_04',
    'ABAMT04_03',
    NULLIF(REPLACE('172.16.26.10', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200061'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200070',
    '二部二楼 AB_SMT_05 松下贴片机',
    null,
    'SMT',
    'AB_SMT_05',
    'AB_SMT_05',
    'ABAMT05_04',
    NULLIF(REPLACE('172.16.26.230', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200070'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200072',
    '二部二楼 AB_SMT_06 劲拓回流焊',
    null,
    'SMT',
    'AB_SMT_06',
    'AB_SMT_06',
    'ABAMT06_05',
    NULLIF(REPLACE('172.16.26.60', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200072'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200075',
    '二部二楼 AB_SMT_06 松下贴片机',
    null,
    'SMT',
    'AB_SMT_06',
    'AB_SMT_06',
    'ABAMT06_11',
    NULLIF(REPLACE('172.16.26.232', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200075'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200417',
    '二部 三楼AB_SMT_09 路远回流焊',
    null,
    'AI',
    'AB_SMT_09',
    'AB_SMT_09',
    'ABAMT09_05',
    NULL,
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200417'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200003',
    '三部四楼 AE_SMT_03松下贴片机/03',
    null,
    'SMT',
    'AE_SMT_03',
    'AE_SMT_03',
    'AESMT03_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200003'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200004',
    '三部四楼 AE_SMT_04松下贴片机/03',
    null,
    'SMT',
    'AE_SMT_04',
    'AE_SMT_04',
    'AESMT04_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200004'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200010',
    '三部四楼 AE_SMT_07松下贴片机/02',
    null,
    'SMT',
    'AE_SMT_07',
    'AE_SMT_07',
    'AESMT07-04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200010'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200312',
    '三部四楼 AE_SMT_07 英尚AOI',
    'AOI',
    'SMT',
    'AE_SMT_07',
    'AE_SMT_07',
    'AESMT07-05',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200312'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2400002',
    '三部四楼 AE_SMT_08松下贴片机',
    null,
    null,
    'AE_SMT_08',
    'AE_SMT_08',
    'AESMT08-03',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2400002'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'LAO_HUA_EQ002',
    '九源-老化02',
    null,
    'AI',
    'C2',
    'C2',
    'C2-17',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'LAO_HUA_EQ002'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200148',
    '二部二楼 D2 派捷ICT',
    'ICT',
    'DIP',
    'D02',
    'D02',
    'DIP-D2-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200148'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200141',
    '二部二楼 D4 赫立AOI',
    'AOI',
    'DIP',
    'D04',
    'D04',
    'DIP-D4-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200141'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200449',
    '二部 D07 自研板FCT',
    'FCT',
    'AI',
    'D07',
    'D07',
    'DIP-D7-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200449'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200455',
    '二部 D08 自研板FCT',
    'FCT',
    'AI',
    'D08',
    'D08',
    'DIP-D8-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200455'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ3401007',
    'ICT',
    'ICT',
    null,
    'D08',
    'D08',
    'DIP-D8-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ3401007'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200457',
    '二部二楼 D09 赫立AOI',
    'AOI',
    'AI',
    'D09',
    'D09',
    'DIP-D9-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200457'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200368',
    '二部三楼D04 自主研发FCT',
    'FCT',
    'DIP',
    'D10',
    'D10',
    'DIP-D10-27',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200368'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200474',
    '二部 D13 自研板FCT',
    'FCT',
    'AI',
    'D13',
    'D13',
    'DIP-D13-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200474'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ3401012',
    'FCT',
    'FCT',
    null,
    'D13',
    'D13',
    'DIP-D13-27',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ3401012'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200114',
    '二部二楼 D16 自研板FCT',
    'FCT',
    'DIP',
    'D16',
    'D16',
    'DIP-D16-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200114'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200130',
    '二部二楼 D22 赫立AOI',
    'AOI',
    'DIP',
    'D22',
    'D22',
    'DIP-D22-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200130'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200255',
    '三部四楼 P2 派捷ICT',
    'ICT',
    'DIP',
    'P02',
    'P02',
    'P02-16',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200255'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200356',
    '三部四楼 P2 自研FCT',
    'FCT',
    'DIP',
    'P02',
    'P02',
    'P02-20',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200356'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200357',
    '三部四楼 P3 自研FCT',
    'FCT',
    'DIP',
    'P03',
    'P03',
    'P03-19',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200357'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200263',
    '三部四楼 P4 伍洲AOI',
    'AOI',
    'DIP',
    'P04',
    'P04',
    'P04-17',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200263'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200360',
    '三部四楼 P6 自研FCT',
    'FCT',
    'DIP',
    'P06',
    'P06',
    'P06-62',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200360'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200363',
    '三部四楼 P9 自研FCT',
    'FCT',
    'DIP',
    'P09',
    'P09',
    'P09-20',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200363'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200365',
    '三部P11功能测试',
    'AOI',
    'DIP',
    'P11',
    'P11',
    'P11-19',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200365'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200024',
    '一部二楼 R02 自主研发FCT',
    'FCT',
    'DIP',
    'R02',
    'R02',
    'R02-18',
    NULLIF(REPLACE('172.16 .12.50', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200024'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200171',
    '一部二楼 R03自主研发FCT',
    'FCT',
    'DIP',
    'R03',
    'R03',
    'R03-18',
    NULLIF(REPLACE('172.16.12.105', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200171'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200021',
    '一部二楼 R04 镭晨AOI',
    'AOI',
    'DIP',
    'R04',
    'R04',
    'R04-15',
    NULLIF(REPLACE('172.16.12.91', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200021'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200020',
    '一部二楼 R04 自主研发FCT',
    'FCT',
    'DIP',
    'R04',
    'R04',
    'R04-18',
    NULLIF(REPLACE('172.16.12.39', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200020'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200010',
    '一部二楼 R05 派捷ICT',
    'ICT',
    'DIP',
    'R05',
    'R05',
    'R05-14',
    NULLIF(REPLACE('172.16.12.73', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200010'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200386',
    '一部四楼 R06 自主研发FCT',
    'FCT',
    null,
    'R06',
    'R06',
    'R06-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200386'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200033',
    '一部二楼 R09 镭晨AOI',
    'AOI',
    'DIP',
    'R09',
    'R09',
    'R09-15',
    NULLIF(REPLACE('172.16.12.76', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200033'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200037',
    '一部二楼 R10 镭晨AOI',
    'AOI',
    'DIP',
    'R10',
    'R10',
    'R10-15',
    NULLIF(REPLACE('172.16.12.103', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200037'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200330',
    '一部二楼 R14 自主研发FCT',
    'FCT',
    'DIP',
    'R14',
    'R14',
    'R14-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200330'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200332',
    '一部三楼 R17 赫立AOI',
    'AOI',
    'DIP',
    'R17',
    'R17',
    'R17-15',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200332'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200347',
    '一部三楼 R17 自主研发FCT',
    'FCT',
    'DIP',
    'R17',
    'R17',
    'R17-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200347'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200391',
    '一部四楼 R19 自主研发FCT',
    'FCT',
    null,
    'R19',
    'R19',
    'R19-49',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200391'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200189',
    '一部二楼 AA_SMT_04 松下贴片机',
    null,
    'SMT',
    'AA_SMT_04',
    'AA_SMT_04',
    'AASMT04_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200189'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200198',
    '一部二楼 AA_SMT_05 松下贴片机',
    null,
    'SMT',
    'AA_SMT_05B',
    'AA_SMT_05B',
    'AASMT05B_04',
    NULL,
    '21109',
    'B',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200198'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200206',
    '一部二楼 AA_SMT_06 松下贴片机',
    null,
    'SMT',
    'AA_SMT_06',
    'AA_SMT_06',
    'AASMT06_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200206'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200215',
    '一部二楼 AA_SMT_07 松下贴片机',
    null,
    'SMT',
    'AA_SMT_07',
    'AA_SMT_07',
    'AASMT07_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200215'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200041',
    '二部二楼 AB_SMT_01 松下贴片机',
    null,
    'SMT',
    'AB_SMT_01',
    'AB_SMT_01',
    'ABAMT01_11',
    NULLIF(REPLACE('172.16.26.227', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200041'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200069',
    '二部二楼 AB_SMT_05 松下贴片机',
    null,
    'SMT',
    'AB_SMT_05B',
    'AB_SMT_05B',
    'ABAMT05B_04',
    NULLIF(REPLACE('172.16.26.229', ' ', ''), ''),
    '21124',
    'B',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200069'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200071',
    '二部二楼 AB_SMT_06 镭晨AOI',
    'AOI',
    'SMT',
    'AB_SMT_06',
    'AB_SMT_06',
    'ABAMT06_06',
    NULLIF(REPLACE('172.16.26.21', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200071'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200418',
    '二部二楼 AB_SMT_09 赫立AOI',
    'AOI',
    'AI',
    'AB_SMT_09',
    'AB_SMT_09',
    'ABAMT09_06',
    NULL,
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200418'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200295',
    '三部四楼 AE_SMT_01 劲拓回流焊/01',
    null,
    'SMT',
    'AE_SMT_01',
    'AE_SMT_01',
    'AESMT01_05',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200295'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200304',
    '三部四楼 AE_SMT_03 松下贴片机/02',
    null,
    'SMT',
    'AE_SMT_03',
    'AE_SMT_03',
    'AESMT03_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200304'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200310',
    '三部四楼 AE_SMT_04 松下贴片机/02',
    null,
    'SMT',
    'AE_SMT_04',
    'AE_SMT_04',
    'AESMT04_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200310'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200311',
    '三部四楼 AE_SMT_04路远回流焊/01',
    null,
    'SMT',
    'AE_SMT_04',
    'AE_SMT_04',
    'AESMT04_12',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200311'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200411',
    '二部 三楼AB_SMT_08 路远回流焊',
    null,
    null,
    'AE_SMT_06',
    'AE_SMT_06',
    'AESMT06-05',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200411'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200437',
    '二部二楼 D01 赫立AOI',
    'AOI',
    'AI',
    'D01',
    'D01',
    'DIP-D1-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200437'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200439',
    '二部 D01 自研板FCT',
    'FCT',
    'AI',
    'D01',
    'D01',
    'DIP-D1-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200439'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200144',
    '二部二楼 D4 自研板FCT',
    'FCT',
    'DIP',
    'D04',
    'D04',
    'DIP-D4-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200144'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200459',
    '二部 D09 自研板FCT',
    'FCT',
    'AI',
    'D09',
    'D09',
    'DIP-D9-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200459'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200460',
    '二部 D09 自研板FCT',
    'FCT',
    'AI',
    'D09',
    'D09',
    'DIP-D9-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200460'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200479',
    '二部 D14 自研板FCT',
    'FCT',
    'AI',
    'D14',
    'D14',
    'DIP-D14-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200479'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200485',
    '二部 D15 自研板FCT',
    'FCT',
    'AI',
    'D15',
    'D15',
    'DIP-D15-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200485'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200487',
    '二部二楼 D17 赫立AOI',
    'AOI',
    'AI',
    'D17',
    'D17',
    'DIP-D17-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200487'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200369',
    '二部三楼D01 自主研发FCT',
    'FCT',
    null,
    'D17',
    'D17',
    'DIP-D17-27',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200369'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200096',
    '二部二楼 D19 自研板FCT',
    'FCT',
    'DIP',
    'D19',
    'D19',
    'DIP-D19-14',
    NULLIF(REPLACE('172.16.25.128', ' ', ''), ''),
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200096'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200094',
    '二部二楼 D19 派捷ICT',
    'ICT',
    'DIP',
    'D19',
    'D19',
    'DIP-D19-12',
    NULLIF(REPLACE('172.16.25.63', ' ', ''), ''),
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200094'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200125',
    '二部二楼 D20 派捷ICT',
    'ICT',
    'DIP',
    'D20',
    'D20',
    'DIP-D20-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200125'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200254',
    '三部四楼 P2 自研FCT',
    'FCT',
    'DIP',
    'P02',
    'P02',
    'P02-20',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200254'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200264',
    '三部四楼 P4 自研板FCT',
    'FCT',
    'DIP',
    'P04',
    'P04',
    'P04-20',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200264'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200362',
    '三部四楼 P8 自研FCT',
    'FCT',
    'DIP',
    'P08',
    'P08',
    'P08-55',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200362'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200281',
    '三部四楼 P8 伍洲AOI',
    'AOI',
    'DIP',
    'P08',
    'P08',
    'P08-17',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200281'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200394',
    '三部GF功能测试备用设备',
    'AOI',
    null,
    'P11',
    'P11',
    'P11-19',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200394'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200008',
    '一部二楼 R03 镭晨AOI',
    'AOI',
    'DIP',
    'R03',
    'R03',
    'R03-15',
    NULLIF(REPLACE('172.16.12.81', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200008'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200172',
    '一部二楼 R05 自主研发FCT',
    'FCT',
    'DIP',
    'R05',
    'R05',
    'R05-18',
    NULLIF(REPLACE('172.16.12.82', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200172'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200179',
    '一部二楼 R05 派捷ICT',
    'ICT',
    'DIP',
    'R05',
    'R05',
    'R05-14',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200179'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200385',
    '一部四楼 R06 自主研发FCT',
    'FCT',
    null,
    'R06',
    'R06',
    'R06-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200385'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200035',
    '一部二楼 R10 派捷ICT',
    'ICT',
    'DIP',
    'R10',
    'R10',
    'R10-14',
    NULLIF(REPLACE('172.16.12.89', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200035'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200339',
    '一部三楼 R13 派捷ICT',
    'ICT',
    'DIP',
    'R13',
    'R13',
    'R13-14',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200339'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200353',
    '一部三楼 R16 自主研发FCT',
    'FCT',
    'DIP',
    'R16',
    'R16',
    'R16-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200353'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200381',
    '一部四楼 R18 自主研发FCT',
    'FCT',
    null,
    'R18',
    'R18',
    'R18-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200381'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200390',
    '一部四楼 R19 自主研发FCT',
    'FCT',
    null,
    'R19',
    'R19',
    'R19-49',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200390'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200182',
    '一部二楼 AA_SMT_03 松下贴片机',
    null,
    'SMT',
    '一部SMT_03B',
    '一部SMT_03B',
    'AASMT03B_04',
    NULL,
    '21109',
    'B',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200182'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200164',
    '一部二楼 AA_SMT_03 赫立AOI',
    'AOI',
    'SMT',
    'AA_SMT_03',
    'AA_SMT_03',
    'AASMT03_13',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200164'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200191',
    '一部二楼 AA_SMT_05 劲拓回流焊',
    null,
    'SMT',
    'AA_SMT_05',
    'AA_SMT_05',
    'AASMT05_05',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200191'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200208',
    '一部二楼 AA_SMT_06 松下贴片机',
    null,
    'SMT',
    'AA_SMT_06B',
    'AA_SMT_06B',
    'AASMT06B_11',
    NULL,
    '21109',
    'B',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200208'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200216',
    '一部二楼 AA_SMT_07 松下贴片机',
    null,
    'SMT',
    'AA_SMT_07',
    'AA_SMT_07',
    'AASMT07_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200216'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200212',
    '一部二楼 AA_SMT_07 劲拓回流焊',
    null,
    'SMT',
    'AA_SMT_07',
    'AA_SMT_07',
    'AASMT07_12',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200212'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200049',
    '二部二楼 AB_SMT_02 松下贴片机',
    null,
    'SMT',
    'AB_SMT_02',
    'AB_SMT_02',
    'ABAMT02_04',
    NULLIF(REPLACE('172.16.26.225', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200049'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200367',
    '二部二楼 AB_SMT_03 神州视觉3DAOI',
    '3DAOI',
    'SMT',
    'AB_SMT_03',
    'AB_SMT_03',
    'ABAMT03_06',
    NULL,
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200367'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200057',
    '二部二楼 AB_SMT_03 松下贴片机',
    null,
    'SMT',
    'AB_SMT_03B',
    'AB_SMT_03B',
    'ABAMT03B_11',
    NULLIF(REPLACE('172.16.26.223', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200057'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200069',
    '二部二楼 AB_SMT_05 松下贴片机',
    null,
    'SMT',
    'AB_SMT_05',
    'AB_SMT_05',
    'ABAMT05_04',
    NULLIF(REPLACE('172.16.26.229', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200069'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200395',
    '三部四楼 AE_SMT_01 快克AOI',
    'AOI',
    'AI',
    'AE_SMT_01',
    'AE_SMT_01',
    'AESMT01_06',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200395'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200397',
    '三部四楼 AE_SMT_03 快克AOI',
    'AOI',
    'AI',
    'AE_SMT_03',
    'AE_SMT_03',
    'AESMT03_06',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200397'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200309',
    '三部四楼 AE_SMT_04 松下贴片机/01',
    null,
    'SMT',
    'AE_SMT_04',
    'AE_SMT_04',
    'AESMT04_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200309'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200317',
    '三部四楼 AE_SMT_05 路远回流焊/01',
    null,
    'SMT',
    'AE_SMT_05',
    'AE_SMT_05',
    'AESMT05_05',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200317'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200008',
    '三部四楼 AE_SMT_06松下贴片机/03',
    null,
    'SMT',
    'AE_SMT_06',
    'AE_SMT_06',
    'AESMT06-06',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200008'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ220401',
    '三部四楼AESMT_06/02',
    null,
    null,
    'AE_SMT_06',
    'AE_SMT_06',
    'AESMT06-05',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ220401'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ360121',
    '充放电一体老化柜',
    null,
    null,
    'C2',
    'C2',
    'C2-17',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ360121'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200150',
    '二部二楼 D2 自研板FCT',
    'FCT',
    'DIP',
    'D02',
    'D02',
    'DIP-D2-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200150'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200448',
    '二部 D07 派捷ICT',
    'ICT',
    'AI',
    'D07',
    'D07',
    'DIP-D7-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200448'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ3401013',
    'FCT',
    'FCT',
    null,
    'D09',
    'D09',
    'DIP-D9-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ3401013'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ3401008',
    'ICT',
    'ICT',
    null,
    'D09',
    'D09',
    'DIP-D9-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ3401008'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200483',
    '二部 D15 派捷ICT',
    'ICT',
    'AI',
    'D15',
    'D15',
    'DIP-D15-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200483'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200113',
    '二部二楼 D16 自研板FCT',
    'FCT',
    'DIP',
    'D16',
    'D16',
    'DIP-D16-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200113'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200488',
    '二部 D17 派捷ICT',
    'ICT',
    'AI',
    'D17',
    'D17',
    'DIP-D17-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200488'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200120',
    '二部二楼 D18 自研板FCT',
    'FCT',
    'DIP',
    'D18',
    'D18',
    'DIP-D18-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200120'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200092',
    '二部二楼 D19 赫立AOI',
    'AOI',
    'DIP',
    'D19',
    'D19',
    'DIP-D19-13',
    NULLIF(REPLACE('172.16.25.45', ' ', ''), ''),
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200092'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200126',
    '二部二楼 D20 自研板FCT',
    'FCT',
    'DIP',
    'D20',
    'D20',
    'DIP-D20-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200126'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200250',
    '三部四楼 P1 自研FCT',
    'FCT',
    'DIP',
    'P01',
    'P01',
    'P01-52',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200250'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200253',
    '三部四楼 P2 伍洲AOI',
    'AOI',
    'DIP',
    'P02',
    'P02',
    'P02-17',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200253'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200260',
    '三部四楼 P3 派捷ICT',
    'ICT',
    'DIP',
    'P03',
    'P03',
    'P03-88',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200260'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200267',
    '三部四楼 P5 伍洲AOI',
    'AOI',
    'DIP',
    'P05',
    'P05',
    'P05-17',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200267'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200283',
    '三部四楼 P8 派捷ICT',
    'ICT',
    'DIP',
    'P08',
    'P08',
    'P08-54',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200283'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200016',
    '一部二楼 R01 镭晨AOI',
    'AOI',
    'DIP',
    'R01',
    'R01',
    'R01-15',
    NULLIF(REPLACE('172.16.12.57', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200016'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200006',
    '一部二楼 R03 派捷ICT',
    'ICT',
    'DIP',
    'R03',
    'R03',
    'R03-14',
    NULLIF(REPLACE('172.16.12.77', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200006'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200334',
    '一部三楼 R12 派捷ICT',
    'ICT',
    'DIP',
    'R12',
    'R12',
    'R12-14',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200334'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200341',
    '一部三楼 R13 自主研发FCT',
    'FCT',
    'DIP',
    'R13',
    'R13',
    'R13-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200341'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200345',
    '一部三楼 R14 派捷ICT',
    'ICT',
    'DIP',
    'R14',
    'R14',
    'R14-14',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200345'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200155',
    '一部二楼 AA_SMT_01 松下贴片机',
    null,
    'SMT',
    'AA_SMT_01B',
    'AA_SMT_01B',
    'AASMT01B_04',
    NULL,
    '21109',
    'B',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200155'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200159',
    '一部二楼 AA_SMT_02 松下贴片机',
    null,
    'SMT',
    'AA_SMT_02',
    'AA_SMT_02',
    'AASMT02_04',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200159'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200188',
    '一部二楼 AA_SMT_04 松下贴片机',
    null,
    'SMT',
    'AA_SMT_04B',
    'AA_SMT_04B',
    'AASMT04B_03',
    NULL,
    '21109',
    'B',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200188'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200190',
    '一部二楼 AA_SMT_05 镭晨AOI',
    'AOI',
    'SMT',
    'AA_SMT_05',
    'AA_SMT_05',
    'AASMT05_06',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200190'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200202',
    '一部二楼 AA_SMT_06 劲拓回流焊',
    null,
    'SMT',
    'AA_SMT_06',
    'AA_SMT_06',
    'AASMT06_12',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200202'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200208',
    '一部二楼 AA_SMT_06 松下贴片机',
    null,
    'SMT',
    'AA_SMT_06',
    'AA_SMT_06',
    'AASMT06_11',
    NULL,
    '21109',
    'A',
    'AA_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200208'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200044',
    '二部二楼 AB_SMT_02 思泰克SPI',
    'SPI',
    'SMT',
    'AB_SMT_02',
    'AB_SMT_02',
    'ABAMT02_03',
    NULLIF(REPLACE('172.16.26.14', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200044'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200050',
    '二部二楼 AB_SMT_02 松下贴片机',
    null,
    'SMT',
    'AB_SMT_02',
    'AB_SMT_02',
    'ABAMT02_04',
    NULLIF(REPLACE('172.16.26.226', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200050'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200051',
    '二部二楼 AB_SMT_03 劲拓回流焊',
    null,
    'SMT',
    'AB_SMT_03',
    'AB_SMT_03',
    'ABAMT03_12',
    NULLIF(REPLACE('172.16.26.56', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200051'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200058',
    '二部二楼 AB_SMT_03 松下贴片机',
    null,
    'SMT',
    'AB_SMT_03B',
    'AB_SMT_03B',
    'ABAMT03B_04',
    NULLIF(REPLACE('172.16.26.224', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200058'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200066',
    '二部二楼 AB_SMT_05 劲拓回流焊',
    null,
    'SMT',
    'AB_SMT_05',
    'AB_SMT_05',
    'ABAMT05_05',
    NULLIF(REPLACE('172.16.26.58', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200066'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200065',
    '二部二楼 AB_SMT_05 镭晨AOI',
    'AOI',
    'SMT',
    'AB_SMT_05',
    'AB_SMT_05',
    'ABAMT05_06',
    NULLIF(REPLACE('172.16.26.25', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200065'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200074',
    '二部二楼 AB_SMT_06 松下贴片机',
    null,
    'SMT',
    'AB_SMT_06',
    'AB_SMT_06',
    'ABAMT06_04',
    NULLIF(REPLACE('172.16.26.231', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200074'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200078',
    '二部二楼 AB_SMT_07 松下贴片机',
    null,
    'SMT',
    'AB_SMT_07',
    'AB_SMT_07',
    'ABAMT07_04',
    NULLIF(REPLACE('172.16.26.234', ' ', ''), ''),
    '21124',
    'A',
    'AB_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200078'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200294',
    '三部四楼 AE_SMT_01 松下贴片机/02',
    null,
    'SMT',
    'AE_SMT_01',
    'AE_SMT_01',
    'AESMT01_04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200294'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200300',
    '三部四楼 AE_SMT_02 劲拓回流焊/01',
    null,
    'SMT',
    'AE_SMT_02',
    'AE_SMT_02',
    'AESMT02_12',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200300'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200009',
    '三部四楼 AE_SMT_07松下贴片机/01',
    null,
    'SMT',
    'AE_SMT_07',
    'AE_SMT_07',
    'AESMT07-04',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200009'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'SB2200011',
    '三部四楼 AE_SMT_08松下贴片机/01',
    null,
    'SMT',
    'AE_SMT_08',
    'AE_SMT_08',
    'AESMT08-03',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'SB2200011'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2400003',
    '三部四楼AESMT-08回流焊/01',
    null,
    null,
    'AE_SMT_08',
    'AE_SMT_08',
    'AESMT08-4',
    NULL,
    '21130',
    'A',
    'AE_SMT'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2400003'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'LAO_HUA_EQ001',
    '九源-老化01',
    null,
    'AI',
    'C2',
    'C2',
    'C2-17',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'LAO_HUA_EQ001'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ360101',
    '充电老化柜',
    null,
    null,
    'C2',
    'C2',
    'C2-17',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ360101'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200136',
    '二部二楼 D5 派捷ICT',
    'ICT',
    'DIP',
    'D05',
    'D05',
    'DIP-D5-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200136'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200445',
    '二部 D06 自研板FCT',
    'FCT',
    'AI',
    'D06',
    'D06',
    'DIP-D6-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200445'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200463',
    '二部 D10 派捷ICT',
    'ICT',
    'AI',
    'D10',
    'D10',
    'DIP-D10-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200463'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200462',
    '二部二楼 D10 赫立AOI',
    'AOI',
    'AI',
    'D10',
    'D10',
    'DIP-D10-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200462'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200475',
    '二部 D13 自研板FCT',
    'FCT',
    'AI',
    'D13',
    'D13',
    'DIP-D13-27',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200475'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200472',
    '二部二楼 D13 赫立AOI',
    'AOI',
    'AI',
    'D13',
    'D13',
    'DIP-D13-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200472'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200482',
    '二部二楼 D15 赫立AOI',
    'AOI',
    'AI',
    'D15',
    'D15',
    'DIP-D15-13',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200482'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200112',
    '二部二楼 D16 派捷ICT',
    'ICT',
    'DIP',
    'D16',
    'D16',
    'DIP-D16-12',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200112'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200132',
    '二部二楼 D22 自研板FCT',
    'FCT',
    'DIP',
    'D22',
    'D22',
    'DIP-D22-14',
    NULL,
    'AB_DIP',
    'A',
    'AB_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200132'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200258',
    '三部四楼 P3 伍洲AOI',
    'AOI',
    'DIP',
    'P03',
    'P03',
    'P03-17',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200258'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200259',
    '三部四楼 P3 自研板FCT',
    'FCT',
    'DIP',
    'P03',
    'P03',
    'P03-89',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200259'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200358',
    '三部四楼 P4 自研FCT',
    'FCT',
    'DIP',
    'P04',
    'P04',
    'P04-20',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200358'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200268',
    '三部四楼 P5 自研板FCT',
    'FCT',
    'DIP',
    'P05',
    'P05',
    'P05-20',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200268'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200291',
    '三部四楼 P10 派捷ICT',
    'ICT',
    'DIP',
    'P10',
    'P10',
    'P10-16',
    NULL,
    'AE_DIP',
    'A',
    'AE_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200291'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200173',
    '一部二楼 R01 自主研发FCT',
    'FCT',
    'DIP',
    'R01',
    'R01',
    'R01-18',
    NULLIF(REPLACE('172.16.12.34', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200173'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200015',
    '一部二楼 R01 自主研发FCT',
    'FCT',
    'DIP',
    'R01',
    'R01',
    'R01-18',
    NULLIF(REPLACE('172.16.12.24', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200015'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200175',
    '一部二楼 R02 自主研发FCT',
    'FCT',
    'DIP',
    'R02',
    'R02',
    'R02-18',
    NULLIF(REPLACE('172.16 .12.48', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200175'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200181',
    '一部二楼 R04 派捷ICT',
    'ICT',
    'DIP',
    'R04',
    'R04',
    'R04-14',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200181'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200003',
    '一部二楼 R07 自主研发FCT',
    'FCT',
    'DIP',
    'R07',
    'R07',
    'R07-18',
    NULLIF(REPLACE('172.16.12.32', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200003'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200036',
    '一部二楼 R10 自主研发FCT',
    'FCT',
    'DIP',
    'R10',
    'R10',
    'R10-18',
    NULLIF(REPLACE('172.16.12.19', ' ', ''), ''),
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200036'
);

INSERT INTO public.postgres_test_equipment (
    equipment_code,
    equipment_name,
    equipment_type,
    process_type,
    line_code,
    line_name,
    station_code,
    ip_address,
    department_owner,
    track_name,
    workshop_name
)
SELECT
    'EQ2200340',
    '一部三楼 R13 自主研发FCT',
    'FCT',
    'DIP',
    'R13',
    'R13',
    'R13-18',
    NULL,
    'AA_DIP',
    'A',
    'AA_DIP'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.postgres_test_equipment t
    WHERE t.equipment_code = 'EQ2200340'
);


COMMIT;
