/*
用途：查询指定材料对应客户的实际领料、退料、净领料数量（四账套）

修正点：
1. MOCTE -> MOCTC -> MOCTA 使用 INNER JOIN，确保领退料与工单事实有效。
2. MOCTA -> COPTC -> COPMA 使用 LEFT JOIN，避免工单未直接挂销售订单时把领退料记录过滤掉。
3. 不关联 COPTD，避免订单单身一对多造成领料数量放大。
4. ITEMTMP 只作为材料过滤条件，使用 EXISTS，避免重复材料造成数量放大。
5. 单据性质仍按领退料单别 TE001 前两位判断：54=领料，56=退料。
6. 最终按：帐套 + 事业部 + 材料品号 + 客户 汇总。
*/

USE SDRD;
SET NOCOUNT ON;

DECLARE @StartDate CHAR(8) = '20260701';
DECLARE @EndDate   CHAR(8) = '20260731';

IF OBJECT_ID('tempdb..#ISSUE') IS NOT NULL
    DROP TABLE #ISSUE;

------------------------------------------------------------
-- 1. 四账套实际领退料
------------------------------------------------------------
SELECT
    X.帐套,
    X.事业部,
    X.材料品号,
    X.客户编号,
    X.客户,
    CAST(SUM(X.领料数量) AS DECIMAL(38,6)) AS 领料数量,
    CAST(SUM(X.退料数量) AS DECIMAL(38,6)) AS 退料数量,
    CAST(SUM(X.领料数量 - X.退料数量) AS DECIMAL(38,6)) AS 净领料数量
INTO #ISSUE
FROM
(
    ------------------------------------------------------------
    -- SDRD
    ------------------------------------------------------------
    SELECT
        'SDRD' COLLATE DATABASE_DEFAULT AS 帐套,

        CASE
            WHEN CHARINDEX('-', ISNULL(CMSMD.MD011, '')) > 0
                THEN LTRIM(RTRIM(
                    LEFT(CMSMD.MD011, CHARINDEX('-', CMSMD.MD011) - 1)
                ))
            WHEN ISNULL(LTRIM(RTRIM(CMSMD.MD011)), '') <> ''
                THEN LTRIM(RTRIM(CMSMD.MD011))
            ELSE '顺德瑞德'
        END COLLATE DATABASE_DEFAULT AS 事业部,

        LTRIM(RTRIM(MOCTE.TE004))
            COLLATE DATABASE_DEFAULT AS 材料品号,

        ISNULL(LTRIM(RTRIM(COPTC.TC004)), '')
            COLLATE DATABASE_DEFAULT AS 客户编号,

        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(COPMA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(COPMA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT AS 客户,

        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '54'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38,6))
            ELSE CAST(0 AS DECIMAL(38,6))
        END AS 领料数量,

        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '56'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38,6))
            ELSE CAST(0 AS DECIMAL(38,6))
        END AS 退料数量

    FROM SDRD..MOCTE

    INNER JOIN SDRD..MOCTC
        ON MOCTC.TC001 = MOCTE.TE001
       AND MOCTC.TC002 = MOCTE.TE002

    INNER JOIN SDRD..MOCTA
        ON MOCTA.TA001 = MOCTE.TE011
       AND MOCTA.TA002 = MOCTE.TE012

    LEFT JOIN SDRD..COPTC
        ON COPTC.TC001 = MOCTA.TA026
       AND COPTC.TC002 = MOCTA.TA027

    LEFT JOIN SDRD..COPMA
        ON COPMA.MA001 = COPTC.TC004

    LEFT JOIN SDRD..CMSMD
        ON CMSMD.MD001 = MOCTA.TA021

    WHERE LEFT(MOCTE.TE001, 2) IN ('54', '56')
      AND MOCTC.TC003 >= @StartDate
      AND MOCTC.TC003 <= @EndDate
      AND EXISTS
      (
          SELECT 1
          FROM LSSJ..ITEMTMP
          WHERE ISNULL(LTRIM(RTRIM(ITEMTMP.ITEMNO)), '') <> ''
            AND LTRIM(RTRIM(ITEMTMP.ITEMNO)) COLLATE DATABASE_DEFAULT
                = LTRIM(RTRIM(MOCTE.TE004)) COLLATE DATABASE_DEFAULT
      )

    UNION ALL

    ------------------------------------------------------------
    -- ZJRD
    ------------------------------------------------------------
    SELECT
        'ZJRD' COLLATE DATABASE_DEFAULT,

        '浙江瑞德' COLLATE DATABASE_DEFAULT,

        LTRIM(RTRIM(MOCTE.TE004))
            COLLATE DATABASE_DEFAULT,

        ISNULL(LTRIM(RTRIM(COPTC.TC004)), '')
            COLLATE DATABASE_DEFAULT,

        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(COPMA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(COPMA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT,

        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '54'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38,6))
            ELSE CAST(0 AS DECIMAL(38,6))
        END,

        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '56'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38,6))
            ELSE CAST(0 AS DECIMAL(38,6))
        END

    FROM ZJRD..MOCTE

    INNER JOIN ZJRD..MOCTC
        ON MOCTC.TC001 = MOCTE.TE001
       AND MOCTC.TC002 = MOCTE.TE002

    INNER JOIN ZJRD..MOCTA
        ON MOCTA.TA001 = MOCTE.TE011
       AND MOCTA.TA002 = MOCTE.TE012

    LEFT JOIN ZJRD..COPTC
        ON COPTC.TC001 = MOCTA.TA026
       AND COPTC.TC002 = MOCTA.TA027

    LEFT JOIN ZJRD..COPMA
        ON COPMA.MA001 = COPTC.TC004

    WHERE LEFT(MOCTE.TE001, 2) IN ('54', '56')
      AND MOCTC.TC003 >= @StartDate
      AND MOCTC.TC003 <= @EndDate
      AND EXISTS
      (
          SELECT 1
          FROM LSSJ..ITEMTMP
          WHERE ISNULL(LTRIM(RTRIM(ITEMTMP.ITEMNO)), '') <> ''
            AND LTRIM(RTRIM(ITEMTMP.ITEMNO)) COLLATE DATABASE_DEFAULT
                = LTRIM(RTRIM(MOCTE.TE004)) COLLATE DATABASE_DEFAULT
      )

    UNION ALL

    ------------------------------------------------------------
    -- AHRD
    ------------------------------------------------------------
    SELECT
        'AHRD' COLLATE DATABASE_DEFAULT,

        CASE
            WHEN CHARINDEX('-', ISNULL(CMSMD.MD011, '')) > 0
                THEN LTRIM(RTRIM(
                    LEFT(CMSMD.MD011, CHARINDEX('-', CMSMD.MD011) - 1)
                ))
            WHEN ISNULL(LTRIM(RTRIM(CMSMD.MD011)), '') <> ''
                THEN LTRIM(RTRIM(CMSMD.MD011))
            ELSE '安徽瑞德'
        END COLLATE DATABASE_DEFAULT,

        LTRIM(RTRIM(MOCTE.TE004))
            COLLATE DATABASE_DEFAULT,

        ISNULL(LTRIM(RTRIM(COPTC.TC004)), '')
            COLLATE DATABASE_DEFAULT,

        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(COPMA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(COPMA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT,

        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '54'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38,6))
            ELSE CAST(0 AS DECIMAL(38,6))
        END,

        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '56'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38,6))
            ELSE CAST(0 AS DECIMAL(38,6))
        END

    FROM AHRD..MOCTE

    INNER JOIN AHRD..MOCTC
        ON MOCTC.TC001 = MOCTE.TE001
       AND MOCTC.TC002 = MOCTE.TE002

    INNER JOIN AHRD..MOCTA
        ON MOCTA.TA001 = MOCTE.TE011
       AND MOCTA.TA002 = MOCTE.TE012

    LEFT JOIN AHRD..COPTC
        ON COPTC.TC001 = MOCTA.TA026
       AND COPTC.TC002 = MOCTA.TA027

    LEFT JOIN AHRD..COPMA
        ON COPMA.MA001 = COPTC.TC004

    LEFT JOIN AHRD..CMSMD
        ON CMSMD.MD001 = MOCTA.TA021

    WHERE LEFT(MOCTE.TE001, 2) IN ('54', '56')
      AND MOCTC.TC003 >= @StartDate
      AND MOCTC.TC003 <= @EndDate
      AND EXISTS
      (
          SELECT 1
          FROM LSSJ..ITEMTMP
          WHERE ISNULL(LTRIM(RTRIM(ITEMTMP.ITEMNO)), '') <> ''
            AND LTRIM(RTRIM(ITEMTMP.ITEMNO)) COLLATE DATABASE_DEFAULT
                = LTRIM(RTRIM(MOCTE.TE004)) COLLATE DATABASE_DEFAULT
      )

    UNION ALL

    ------------------------------------------------------------
    -- YNRD
    ------------------------------------------------------------
    SELECT
        'YNRD' COLLATE DATABASE_DEFAULT,

        '越南瑞德' COLLATE DATABASE_DEFAULT,

        LTRIM(RTRIM(MOCTE.TE004))
            COLLATE DATABASE_DEFAULT,

        ISNULL(LTRIM(RTRIM(COPTC.TC004)), '')
            COLLATE DATABASE_DEFAULT,

        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(COPMA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(COPMA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT,

        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '54'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38,6))
            ELSE CAST(0 AS DECIMAL(38,6))
        END,

        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '56'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38,6))
            ELSE CAST(0 AS DECIMAL(38,6))
        END

    FROM YNRD..MOCTE

    INNER JOIN YNRD..MOCTC
        ON MOCTC.TC001 = MOCTE.TE001
       AND MOCTC.TC002 = MOCTE.TE002

    INNER JOIN YNRD..MOCTA
        ON MOCTA.TA001 = MOCTE.TE011
       AND MOCTA.TA002 = MOCTE.TE012

    LEFT JOIN YNRD..COPTC
        ON COPTC.TC001 = MOCTA.TA026
       AND COPTC.TC002 = MOCTA.TA027

    LEFT JOIN YNRD..COPMA
        ON COPMA.MA001 = COPTC.TC004

    WHERE LEFT(MOCTE.TE001, 2) IN ('54', '56')
      AND MOCTC.TC003 >= @StartDate
      AND MOCTC.TC003 <= @EndDate
      AND EXISTS
      (
          SELECT 1
          FROM LSSJ..ITEMTMP
          WHERE ISNULL(LTRIM(RTRIM(ITEMTMP.ITEMNO)), '') <> ''
            AND LTRIM(RTRIM(ITEMTMP.ITEMNO)) COLLATE DATABASE_DEFAULT
                = LTRIM(RTRIM(MOCTE.TE004)) COLLATE DATABASE_DEFAULT
      )

) AS X

GROUP BY
    X.帐套,
    X.事业部,
    X.材料品号,
    X.客户编号,
    X.客户;


------------------------------------------------------------
-- 2. 最终结果
------------------------------------------------------------
SELECT
    材料品号,
    事业部,
    客户编号,
    客户,
    领料数量,
    退料数量,
    净领料数量,
    帐套
FROM #ISSUE
ORDER BY
    材料品号,
    事业部,
    客户编号,
    帐套;


------------------------------------------------------------
-- 3. 诊断：查看无法对应客户的领退料汇总
--    如果这里有数据，说明工单 TA026/TA027 未直接对应销售订单，
--    后续需要再通过 TA024/TA025 追溯源工单。
------------------------------------------------------------
SELECT
    帐套,
    事业部,
    材料品号,
    领料数量,
    退料数量,
    净领料数量
FROM #ISSUE
WHERE ISNULL(客户编号, '') = ''
ORDER BY
    帐套,
    材料品号;
