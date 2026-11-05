USE SDRD;
SET NOCOUNT ON;
--="INSERT INTO LSSJ..ITEMTMP(ITEMNO) VALUES('"&&"');"
--DELETE FROM LSSJ..ITEMTMP
IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#ISSUE_BASE') IS NOT NULL DROP TABLE #ISSUE_BASE;
IF OBJECT_ID('tempdb..#ISSUE_AGG') IS NOT NULL DROP TABLE #ISSUE_AGG;
IF OBJECT_ID('tempdb..#INVMB') IS NOT NULL DROP TABLE #INVMB;

------------------------------------------------------------
-- 1. 材料清单
------------------------------------------------------------
SELECT DISTINCT
    LTRIM(RTRIM(ITEMNO)) COLLATE DATABASE_DEFAULT AS ITEMNO
INTO #ITEM
FROM LSSJ..ITEMTMP
WHERE ISNULL(LTRIM(RTRIM(ITEMNO)), '') <> '';

CREATE UNIQUE CLUSTERED INDEX IX_ITEM_ITEMNO ON #ITEM(ITEMNO);

------------------------------------------------------------
-- 2. 四账套领退料基础数据
--    材料-产品关系：MOCTE.TE004 -> MOCTA.TA006
--    事业部：MOCTA.TA021 -> CMSMD.MD001，取 CMSMD.MD011 到 '-' 前
--    客户信息：MOCTA.TA026/TA027/TA028 -> COPTD -> COPTC -> COPMA
--    客户信息全部 LEFT JOIN，查不到留空
------------------------------------------------------------
SELECT
    X.MATL,
    X.PROD,
    X.事业部,
    X.客户编号,
    X.客户名称,
    X.领退料日期,
    X.领用量
INTO #ISSUE_BASE
FROM
(
    ------------------------------------------------------------
    -- SDRD
    ------------------------------------------------------------
    SELECT
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT AS MATL,
        LTRIM(RTRIM(TA.TA006)) COLLATE DATABASE_DEFAULT AS PROD,

        NULLIF(LTRIM(RTRIM(
            CASE
                WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                    THEN LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)
                ELSE ISNULL(MD.MD011, '')
            END
        )), '') COLLATE DATABASE_DEFAULT AS 事业部,

        ISNULL(LTRIM(RTRIM(TC.TC004)), '') COLLATE DATABASE_DEFAULT AS 客户编号,

        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(MA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT AS 客户名称,

        LEFT(C.TC003, 8) AS 领退料日期,

        CASE
            WHEN LEFT(E.TE001, 2) = '54'
                THEN CAST(ISNULL(E.TE005, 0) AS DECIMAL(38,8))
            WHEN LEFT(E.TE001, 2) = '56'
                THEN -1 * CAST(ISNULL(E.TE005, 0) AS DECIMAL(38,8))
            ELSE 0
        END AS 领用量
    FROM SDRD..MOCTE E
    INNER JOIN #ITEM I
        ON I.ITEMNO = LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT
    INNER JOIN SDRD..MOCTC C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN SDRD..MOCTA TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    LEFT JOIN SDRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    LEFT JOIN SDRD..COPTD TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN SDRD..COPTC TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN SDRD..COPMA MA
        ON MA.MA001 = TC.TC004
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20260101'
      AND C.TC003 <  '20270101'
      AND ISNULL(LTRIM(RTRIM(TA.TA006)), '') <> ''

    UNION ALL

    ------------------------------------------------------------
    -- ZJRD
    ------------------------------------------------------------
    SELECT
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT AS MATL,
        LTRIM(RTRIM(TA.TA006)) COLLATE DATABASE_DEFAULT AS PROD,

        NULLIF(LTRIM(RTRIM(
            CASE
                WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                    THEN LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)
                ELSE ISNULL(MD.MD011, '')
            END
        )), '') COLLATE DATABASE_DEFAULT AS 事业部,

        ISNULL(LTRIM(RTRIM(TC.TC004)), '') COLLATE DATABASE_DEFAULT AS 客户编号,

        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(MA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT AS 客户名称,

        LEFT(C.TC003, 8) AS 领退料日期,

        CASE
            WHEN LEFT(E.TE001, 2) = '54'
                THEN CAST(ISNULL(E.TE005, 0) AS DECIMAL(38,8))
            WHEN LEFT(E.TE001, 2) = '56'
                THEN -1 * CAST(ISNULL(E.TE005, 0) AS DECIMAL(38,8))
            ELSE 0
        END AS 领用量
    FROM ZJRD..MOCTE E
    INNER JOIN #ITEM I
        ON I.ITEMNO = LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT
    INNER JOIN ZJRD..MOCTC C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN ZJRD..MOCTA TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    LEFT JOIN ZJRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    LEFT JOIN ZJRD..COPTD TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN ZJRD..COPTC TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN ZJRD..COPMA MA
        ON MA.MA001 = TC.TC004
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20260101'
      AND C.TC003 <  '20270101'
      AND ISNULL(LTRIM(RTRIM(TA.TA006)), '') <> ''

    UNION ALL

    ------------------------------------------------------------
    -- AHRD
    ------------------------------------------------------------
    SELECT
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT AS MATL,
        LTRIM(RTRIM(TA.TA006)) COLLATE DATABASE_DEFAULT AS PROD,

        NULLIF(LTRIM(RTRIM(
            CASE
                WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                    THEN LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)
                ELSE ISNULL(MD.MD011, '')
            END
        )), '') COLLATE DATABASE_DEFAULT AS 事业部,

        ISNULL(LTRIM(RTRIM(TC.TC004)), '') COLLATE DATABASE_DEFAULT AS 客户编号,

        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(MA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT AS 客户名称,

        LEFT(C.TC003, 8) AS 领退料日期,

        CASE
            WHEN LEFT(E.TE001, 2) = '54'
                THEN CAST(ISNULL(E.TE005, 0) AS DECIMAL(38,8))
            WHEN LEFT(E.TE001, 2) = '56'
                THEN -1 * CAST(ISNULL(E.TE005, 0) AS DECIMAL(38,8))
            ELSE 0
        END AS 领用量
    FROM AHRD..MOCTE E
    INNER JOIN #ITEM I
        ON I.ITEMNO = LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT
    INNER JOIN AHRD..MOCTC C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN AHRD..MOCTA TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    LEFT JOIN AHRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    LEFT JOIN AHRD..COPTD TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN AHRD..COPTC TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN AHRD..COPMA MA
        ON MA.MA001 = TC.TC004
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20260101'
      AND C.TC003 <  '20270101'
      AND ISNULL(LTRIM(RTRIM(TA.TA006)), '') <> ''

    UNION ALL

    ------------------------------------------------------------
    -- YNRD
    ------------------------------------------------------------
    SELECT
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT AS MATL,
        LTRIM(RTRIM(TA.TA006)) COLLATE DATABASE_DEFAULT AS PROD,

        NULLIF(LTRIM(RTRIM(
            CASE
                WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                    THEN LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)
                ELSE ISNULL(MD.MD011, '')
            END
        )), '') COLLATE DATABASE_DEFAULT AS 事业部,

        ISNULL(LTRIM(RTRIM(TC.TC004)), '') COLLATE DATABASE_DEFAULT AS 客户编号,

        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(MA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT AS 客户名称,

        LEFT(C.TC003, 8) AS 领退料日期,

        CASE
            WHEN LEFT(E.TE001, 2) = '54'
                THEN CAST(ISNULL(E.TE005, 0) AS DECIMAL(38,8))
            WHEN LEFT(E.TE001, 2) = '56'
                THEN -1 * CAST(ISNULL(E.TE005, 0) AS DECIMAL(38,8))
            ELSE 0
        END AS 领用量
    FROM YNRD..MOCTE E
    INNER JOIN #ITEM I
        ON I.ITEMNO = LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT
    INNER JOIN YNRD..MOCTC C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN YNRD..MOCTA TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    LEFT JOIN YNRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    LEFT JOIN YNRD..COPTD TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN YNRD..COPTC TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN YNRD..COPMA MA
        ON MA.MA001 = TC.TC004
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20260101'
      AND C.TC003 <  '20270101'
      AND ISNULL(LTRIM(RTRIM(TA.TA006)), '') <> ''
) X;

CREATE INDEX IX_ISSUE_BASE_1
ON #ISSUE_BASE(MATL, PROD, 事业部, 客户编号, 领退料日期);

------------------------------------------------------------
-- 3. 按 材料 + 产品 + 事业部 + 客户 汇总 2026 / 2027 领用量
------------------------------------------------------------
SELECT
    MATL,
    PROD,
    ISNULL(事业部, '未取到') AS 事业部,
    ISNULL(客户编号, '') AS 客户编号,
    MAX(ISNULL(客户名称, '')) AS 客户名称,

    SUM(CASE
            WHEN 领退料日期 >= '20260101' AND 领退料日期 < '20270101'
            THEN ISNULL(领用量, 0)
            ELSE 0
        END) AS [2026年领用量],

    SUM(CASE
            WHEN 领退料日期 >= '20270101' AND 领退料日期 < '20270101'
            THEN ISNULL(领用量, 0)
            ELSE 0
        END) AS [2027年领用量]
INTO #ISSUE_AGG
FROM #ISSUE_BASE
GROUP BY
    MATL,
    PROD,
    ISNULL(事业部, '未取到'),
    ISNULL(客户编号, '')
HAVING
    SUM(CASE
            WHEN 领退料日期 >= '20260101' AND 领退料日期 < '20270101'
            THEN ISNULL(领用量, 0)
            ELSE 0
        END)
  + SUM(CASE
            WHEN 领退料日期 >= '20270101' AND 领退料日期 < '20270101'
            THEN ISNULL(领用量, 0)
            ELSE 0
        END) <> 0;

CREATE UNIQUE CLUSTERED INDEX IX_ISSUE_AGG
ON #ISSUE_AGG(MATL, PROD, 事业部, 客户编号);

------------------------------------------------------------
-- 4. 物料资料
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(MB001)) COLLATE DATABASE_DEFAULT AS ITEMNO,
    MB002,
    MB003
INTO #INVMB
FROM SDRD..INVMB
WHERE EXISTS
(
    SELECT 1
    FROM #ISSUE_AGG A
    WHERE A.MATL = LTRIM(RTRIM(MB001)) COLLATE DATABASE_DEFAULT
       OR A.PROD = LTRIM(RTRIM(MB001)) COLLATE DATABASE_DEFAULT
);

CREATE UNIQUE CLUSTERED INDEX IX_INVMB_ITEMNO ON #INVMB(ITEMNO);

------------------------------------------------------------
-- 5. 最终输出
------------------------------------------------------------
SELECT
    IA.MATL AS 材料品号,
    MATL.MB002 AS 材料品名,
    MATL.MB003 AS 材料规格,

    IA.PROD AS 产品品号,
    PROD.MB002 AS 产品品名,
    PROD.MB003 AS 产品规格,

    IA.事业部,
    IA.客户编号,
    IA.客户名称,

    IA.[2026年领用量],
    IA.[2027年领用量]
FROM #ISSUE_AGG IA
LEFT JOIN #INVMB MATL
    ON MATL.ITEMNO = IA.MATL
LEFT JOIN #INVMB PROD
    ON PROD.ITEMNO = IA.PROD
ORDER BY
    IA.事业部,
    IA.MATL,
    IA.PROD,
    IA.客户编号;