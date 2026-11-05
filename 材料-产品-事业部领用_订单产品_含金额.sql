USE SDRD;
SET NOCOUNT ON;

DECLARE @StartDate CHAR(8) = '20251201';
DECLARE @EndDate   CHAR(8) = '20260630';

IF OBJECT_ID('tempdb..#ISSUE') IS NOT NULL DROP TABLE #ISSUE;
IF OBJECT_ID('tempdb..#INVLA_AMOUNT') IS NOT NULL DROP TABLE #INVLA_AMOUNT;
IF OBJECT_ID('tempdb..#ISSUE_AGG') IS NOT NULL DROP TABLE #ISSUE_AGG;
IF OBJECT_ID('tempdb..#INVMB') IS NOT NULL DROP TABLE #INVMB;

------------------------------------------------------------
-- 1. 四账套领退料明细
--    产品品号：工单来源订单 -> COPTD.TD004
--    事业部：
--      SDRD 未取到 -> 广东瑞德
--      ZJRD 全部   -> 浙江瑞德
--      AHRD 未取到 -> 安徽瑞德
--      YNRD 全部   -> 越南瑞德
------------------------------------------------------------
SELECT *
INTO #ISSUE
FROM
(
    SELECT
        'SDRD' AS COMPANY,
        E.TE004 AS MATL,
        TD.TD004 AS PROD,
        COALESCE(
            NULLIF(
                CASE
                    WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                        THEN LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)
                    ELSE MD.MD011
                END,
                ''
            ),
            '广东瑞德'
        ) AS 事业部,
        E.TE001,
        E.TE002,
        E.TE003,
        CAST(
            CASE
                WHEN LEFT(E.TE001, 2) = '54' THEN E.TE005
                ELSE -E.TE005
            END
            AS DECIMAL(38, 8)
        ) AS 领用量
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
    WHERE C.TC003 BETWEEN @StartDate AND @EndDate
      AND E.TE019 = 'Y'
      AND LEFT(E.TE001, 2) IN ('54', '56')
      AND LEFT(E.TE004, 1) IN ('3', '5', '6', '7')
      AND ISNULL(TD.TD004, '') <> ''

    UNION ALL

    SELECT
        'ZJRD',
        E.TE004,
        TD.TD004,
        '浙江瑞德',
        E.TE001,
        E.TE002,
        E.TE003,
        CAST(
            CASE
                WHEN LEFT(E.TE001, 2) = '54' THEN E.TE005
                ELSE -E.TE005
            END
            AS DECIMAL(38, 8)
        )
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
    WHERE C.TC003 BETWEEN @StartDate AND @EndDate
      AND E.TE019 = 'Y'
      AND LEFT(E.TE001, 2) IN ('54', '56')
      AND LEFT(E.TE004, 1) IN ('3', '5', '6', '7')
      AND ISNULL(TD.TD004, '') <> ''

    UNION ALL

    SELECT
        'AHRD',
        E.TE004,
        TD.TD004,
        COALESCE(
            NULLIF(
                CASE
                    WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                        THEN LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)
                    ELSE MD.MD011
                END,
                ''
            ),
            '安徽瑞德'
        ),
        E.TE001,
        E.TE002,
        E.TE003,
        CAST(
            CASE
                WHEN LEFT(E.TE001, 2) = '54' THEN E.TE005
                ELSE -E.TE005
            END
            AS DECIMAL(38, 8)
        )
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
    WHERE C.TC003 BETWEEN @StartDate AND @EndDate
      AND E.TE019 = 'Y'
      AND LEFT(E.TE001, 2) IN ('54', '56')
      AND LEFT(E.TE004, 1) IN ('3', '5', '6', '7')
      AND ISNULL(TD.TD004, '') <> ''

    UNION ALL

    SELECT
        'YNRD',
        E.TE004,
        TD.TD004,
        '越南瑞德',
        E.TE001,
        E.TE002,
        E.TE003,
        CAST(
            CASE
                WHEN LEFT(E.TE001, 2) = '54' THEN E.TE005
                ELSE -E.TE005
            END
            AS DECIMAL(38, 8)
        )
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
    WHERE C.TC003 BETWEEN @StartDate AND @EndDate
      AND E.TE019 = 'Y'
      AND LEFT(E.TE001, 2) IN ('54', '56')
      AND LEFT(E.TE004, 1) IN ('3', '5', '6', '7')
      AND ISNULL(TD.TD004, '') <> ''
) X;

------------------------------------------------------------
-- 2. INVLA领退料金额
--    金额口径：-LA005 * LA013
------------------------------------------------------------
SELECT
    COMPANY,
    LA001,
    LA006,
    LA007,
    LA008,
    SUM(CAST(-LA005 * LA013 AS DECIMAL(38, 8))) AS 金额
INTO #INVLA_AMOUNT
FROM
(
    SELECT
        'SDRD' AS COMPANY,
        LA001,
        LA006,
        LA007,
        LA008,
        LA005,
        LA013
    FROM SDRD..INVLA
    WHERE LA004 BETWEEN @StartDate AND @EndDate
      AND LEFT(LA006, 2) IN ('54', '56')

    UNION ALL

    SELECT
        'ZJRD',
        LA001,
        LA006,
        LA007,
        LA008,
        LA005,
        LA013
    FROM ZJRD..INVLA
    WHERE LA004 BETWEEN @StartDate AND @EndDate
      AND LEFT(LA006, 2) IN ('54', '56')

    UNION ALL

    SELECT
        'AHRD',
        LA001,
        LA006,
        LA007,
        LA008,
        LA005,
        LA013
    FROM AHRD..INVLA
    WHERE LA004 BETWEEN @StartDate AND @EndDate
      AND LEFT(LA006, 2) IN ('54', '56')

    UNION ALL

    SELECT
        'YNRD',
        LA001,
        LA006,
        LA007,
        LA008,
        LA005,
        LA013
    FROM YNRD..INVLA
    WHERE LA004 BETWEEN @StartDate AND @EndDate
      AND LEFT(LA006, 2) IN ('54', '56')
) L
GROUP BY
    COMPANY,
    LA001,
    LA006,
    LA007,
    LA008;

------------------------------------------------------------
-- 3. 按账套、材料、订单产品、事业部汇总
------------------------------------------------------------
SELECT
    I.COMPANY,
    I.MATL,
    I.PROD,
    I.事业部,
    SUM(I.领用量) AS 总领用量,
    CAST(SUM(ISNULL(L.金额, 0)) AS DECIMAL(38, 2)) AS 金额
INTO #ISSUE_AGG
FROM #ISSUE I
LEFT JOIN #INVLA_AMOUNT L
    ON L.COMPANY = I.COMPANY
   AND L.LA001 = I.MATL
   AND L.LA006 = I.TE001
   AND L.LA007 = I.TE002
   AND L.LA008 = I.TE003
GROUP BY
    I.COMPANY,
    I.MATL,
    I.PROD,
    I.事业部
HAVING
       SUM(I.领用量) <> 0
    OR SUM(ISNULL(L.金额, 0)) <> 0;

------------------------------------------------------------
-- 4. 四账套物料资料
------------------------------------------------------------
SELECT *
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
-- 5. 最终结果
------------------------------------------------------------
SELECT
    RTRIM(IA.MATL) AS 材料品号,
    MATL.MB002 AS 材料品名,
    MATL.MB003 AS 材料规格,
    RTRIM(IA.PROD) AS 产品品号,
    PROD.MB002 AS 产品品名,
    PROD.MB003 AS 产品规格,
    IA.事业部,
    IA.总领用量,
    IA.金额,
    IA.COMPANY
FROM #ISSUE_AGG IA
LEFT JOIN #INVMB MATL
    ON MATL.COMPANY = IA.COMPANY
   AND MATL.ITEMNO = IA.MATL
LEFT JOIN #INVMB PROD
    ON PROD.COMPANY = IA.COMPANY
   AND PROD.ITEMNO = IA.PROD
ORDER BY

    IA.MATL,
    IA.PROD,    IA.COMPANY,
    IA.事业部;
