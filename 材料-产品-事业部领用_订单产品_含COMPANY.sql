USE SDRD;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#ISSUE_AGG') IS NOT NULL DROP TABLE #ISSUE_AGG;
IF OBJECT_ID('tempdb..#INVMB') IS NOT NULL DROP TABLE #INVMB;

------------------------------------------------------------
-- 1. 四账套领退料汇总
--    日期：2025-12-01 至 2026-06-30
--    领用量：领料 54 - 退料 56
--    产品：工单来源订单 -> COPTD.TD004
------------------------------------------------------------
SELECT
    COMPANY,
    MATL,
    PROD,
    ISNULL(NULLIF(事业部, ''), '未取到') AS 事业部,
    SUM(领用量) AS 总领用量
INTO #ISSUE_AGG
FROM
(
    SELECT
        'SDRD' AS COMPANY,
        E.TE004 AS MATL,
        TD.TD004 AS PROD,
        CASE
            WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                THEN LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)
            ELSE MD.MD011
        END AS 事业部,
        CASE
            WHEN LEFT(E.TE001, 2) = '54'
                THEN CAST(ISNULL(E.TE005, 0) AS DECIMAL(38, 8))
            ELSE
                -CAST(ISNULL(E.TE005, 0) AS DECIMAL(38, 8))
        END AS 领用量
    FROM SDRD..MOCTE E
    INNER JOIN SDRD..MOCTC C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN SDRD..MOCTA TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    INNER JOIN SDRD..COPTD TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = TA.TA028
    LEFT JOIN SDRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20251201'
      AND C.TC003 <  '20260701'
      AND LEFT(E.TE004, 1) IN ('3', '5', '6', '7')
      AND ISNULL(TD.TD004, '') <> ''

    UNION ALL

    SELECT
        'ZJRD',
        E.TE004,
        TD.TD004,
        CASE
            WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                THEN LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)
            ELSE MD.MD011
        END,
        CASE
            WHEN LEFT(E.TE001, 2) = '54'
                THEN CAST(ISNULL(E.TE005, 0) AS DECIMAL(38, 8))
            ELSE
                -CAST(ISNULL(E.TE005, 0) AS DECIMAL(38, 8))
        END
    FROM ZJRD..MOCTE E
    INNER JOIN ZJRD..MOCTC C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN ZJRD..MOCTA TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    INNER JOIN ZJRD..COPTD TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = TA.TA028
    LEFT JOIN ZJRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20251201'
      AND C.TC003 <  '20260701'
      AND LEFT(E.TE004, 1) IN ('3', '5', '6', '7')
      AND ISNULL(TD.TD004, '') <> ''

    UNION ALL

    SELECT
        'AHRD',
        E.TE004,
        TD.TD004,
        CASE
            WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                THEN LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)
            ELSE MD.MD011
        END,
        CASE
            WHEN LEFT(E.TE001, 2) = '54'
                THEN CAST(ISNULL(E.TE005, 0) AS DECIMAL(38, 8))
            ELSE
                -CAST(ISNULL(E.TE005, 0) AS DECIMAL(38, 8))
        END
    FROM AHRD..MOCTE E
    INNER JOIN AHRD..MOCTC C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN AHRD..MOCTA TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    INNER JOIN AHRD..COPTD TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = TA.TA028
    LEFT JOIN AHRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20251201'
      AND C.TC003 <  '20260701'
      AND LEFT(E.TE004, 1) IN ('3', '5', '6', '7')
      AND ISNULL(TD.TD004, '') <> ''

    UNION ALL

    SELECT
        'YNRD',
        E.TE004,
        TD.TD004,
        CASE
            WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                THEN LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)
            ELSE MD.MD011
        END,
        CASE
            WHEN LEFT(E.TE001, 2) = '54'
                THEN CAST(ISNULL(E.TE005, 0) AS DECIMAL(38, 8))
            ELSE
                -CAST(ISNULL(E.TE005, 0) AS DECIMAL(38, 8))
        END
    FROM YNRD..MOCTE E
    INNER JOIN YNRD..MOCTC C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN YNRD..MOCTA TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    INNER JOIN YNRD..COPTD TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = TA.TA028
    LEFT JOIN YNRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20251201'
      AND C.TC003 <  '20260701'
      AND LEFT(E.TE004, 1) IN ('3', '5', '6', '7')
      AND ISNULL(TD.TD004, '') <> ''
) X
GROUP BY
    COMPANY,
    MATL,
    PROD,
    ISNULL(NULLIF(事业部, ''), '未取到')
HAVING SUM(领用量) <> 0;

------------------------------------------------------------
-- 2. 四账套物料资料
------------------------------------------------------------
SELECT
    COMPANY,
    ITEMNO,
    MB002,
    MB003
INTO #INVMB
FROM
(
    SELECT
        'SDRD' AS COMPANY,
        MB001 AS ITEMNO,
        MB002,
        MB003
    FROM SDRD..INVMB

    UNION ALL

    SELECT
        'ZJRD',
        MB001,
        MB002,
        MB003
    FROM ZJRD..INVMB

    UNION ALL

    SELECT
        'AHRD',
        MB001,
        MB002,
        MB003
    FROM AHRD..INVMB

    UNION ALL

    SELECT
        'YNRD',
        MB001,
        MB002,
        MB003
    FROM YNRD..INVMB
) X;

------------------------------------------------------------
-- 3. 最终结果
------------------------------------------------------------
SELECT
    IA.MATL AS 材料品号,
    MATL.MB002 AS 材料品名,
    MATL.MB003 AS 材料规格,
    IA.PROD AS 产品品号,
    PROD.MB002 AS 产品品名,
    PROD.MB003 AS 产品规格,
    IA.事业部,
    IA.总领用量,
    IA.COMPANY
FROM #ISSUE_AGG IA
LEFT JOIN #INVMB MATL
    ON MATL.COMPANY = IA.COMPANY
   AND MATL.ITEMNO = IA.MATL
LEFT JOIN #INVMB PROD
    ON PROD.COMPANY = IA.COMPANY
   AND PROD.ITEMNO = IA.PROD
ORDER BY
    IA.COMPANY,
    IA.事业部,
    IA.MATL,
    IA.PROD;
