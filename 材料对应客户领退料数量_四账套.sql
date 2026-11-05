/*
用途：查询指定材料对应客户的实际领料、退料、净领料数量。

业务关系：
客户 -> 销售订单(COPTC) -> 多个工单(MOCTA) -> 多个领/退料单(MOCTC/MOCTE)

数量口径：
1. 54* 单据：领料，TE005 计入领料数量。
2. 56* 单据：退料，TE005 计入退料数量。
3. 净领料数量 = 领料数量 - 退料数量。

防重复原则：
1. 不关联 COPTD，避免订单单身造成一对多放大。
2. ITEMTMP 仅作为材料筛选条件，使用 EXISTS，不参与 JOIN 放大行数。
3. MOCTE 是数量事实表，每笔领退料明细只进入汇总一次。
*/

USE SDRD;
SET NOCOUNT ON;

DECLARE @StartDate CHAR(8) = '20260701';
DECLARE @EndDate   CHAR(8) = '20260731';

IF OBJECT_ID('tempdb..#ISSUE') IS NOT NULL DROP TABLE #ISSUE;

------------------------------------------------------------
-- 1. 汇总四账套实际领退料
------------------------------------------------------------
SELECT
    X.帐套,
    X.事业部,
    X.材料品号,
    X.客户编号,
    X.客户,
    CAST(SUM(X.领料数量) AS DECIMAL(38, 6)) AS 领料数量,
    CAST(SUM(X.退料数量) AS DECIMAL(38, 6)) AS 退料数量,
    CAST(SUM(X.领料数量 - X.退料数量) AS DECIMAL(38, 6)) AS 净领料数量
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
                THEN LTRIM(RTRIM(LEFT(CMSMD.MD011, CHARINDEX('-', CMSMD.MD011) - 1)))
            WHEN ISNULL(LTRIM(RTRIM(CMSMD.MD011)), '') <> ''
                THEN LTRIM(RTRIM(CMSMD.MD011))
            ELSE '顺德瑞德'
        END COLLATE DATABASE_DEFAULT AS 事业部,
        LTRIM(RTRIM(MOCTE.TE004)) COLLATE DATABASE_DEFAULT AS 材料品号,
        LTRIM(RTRIM(COPTC.TC004)) COLLATE DATABASE_DEFAULT AS 客户编号,
        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(COPMA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(COPMA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT AS 客户,
        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '54'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38, 6))
            ELSE CAST(0 AS DECIMAL(38, 6))
        END AS 领料数量,
        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '56'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38, 6))
            ELSE CAST(0 AS DECIMAL(38, 6))
        END AS 退料数量
    FROM SDRD..MOCTE
    INNER JOIN SDRD..MOCTC
        ON MOCTC.TC001 = MOCTE.TE001
       AND MOCTC.TC002 = MOCTE.TE002
    INNER JOIN SDRD..MOCTA
        ON MOCTA.TA001 = MOCTE.TE011
       AND MOCTA.TA002 = MOCTE.TE012
    INNER JOIN SDRD..COPTC
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
        LTRIM(RTRIM(MOCTE.TE004)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(COPTC.TC004)) COLLATE DATABASE_DEFAULT,
        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(COPMA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(COPMA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT,
        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '54'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38, 6))
            ELSE CAST(0 AS DECIMAL(38, 6))
        END,
        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '56'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38, 6))
            ELSE CAST(0 AS DECIMAL(38, 6))
        END
    FROM ZJRD..MOCTE
    INNER JOIN ZJRD..MOCTC
        ON MOCTC.TC001 = MOCTE.TE001
       AND MOCTC.TC002 = MOCTE.TE002
    INNER JOIN ZJRD..MOCTA
        ON MOCTA.TA001 = MOCTE.TE011
       AND MOCTA.TA002 = MOCTE.TE012
    INNER JOIN ZJRD..COPTC
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
                THEN LTRIM(RTRIM(LEFT(CMSMD.MD011, CHARINDEX('-', CMSMD.MD011) - 1)))
            WHEN ISNULL(LTRIM(RTRIM(CMSMD.MD011)), '') <> ''
                THEN LTRIM(RTRIM(CMSMD.MD011))
            ELSE '安徽瑞德'
        END COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(MOCTE.TE004)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(COPTC.TC004)) COLLATE DATABASE_DEFAULT,
        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(COPMA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(COPMA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT,
        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '54'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38, 6))
            ELSE CAST(0 AS DECIMAL(38, 6))
        END,
        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '56'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38, 6))
            ELSE CAST(0 AS DECIMAL(38, 6))
        END
    FROM AHRD..MOCTE
    INNER JOIN AHRD..MOCTC
        ON MOCTC.TC001 = MOCTE.TE001
       AND MOCTC.TC002 = MOCTE.TE002
    INNER JOIN AHRD..MOCTA
        ON MOCTA.TA001 = MOCTE.TE011
       AND MOCTA.TA002 = MOCTE.TE012
    INNER JOIN AHRD..COPTC
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
        LTRIM(RTRIM(MOCTE.TE004)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(COPTC.TC004)) COLLATE DATABASE_DEFAULT,
        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(COPMA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(COPMA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT,
        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '54'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38, 6))
            ELSE CAST(0 AS DECIMAL(38, 6))
        END,
        CASE
            WHEN LEFT(MOCTE.TE001, 2) = '56'
                THEN CAST(ISNULL(MOCTE.TE005, 0) AS DECIMAL(38, 6))
            ELSE CAST(0 AS DECIMAL(38, 6))
        END
    FROM YNRD..MOCTE
    INNER JOIN YNRD..MOCTC
        ON MOCTC.TC001 = MOCTE.TE001
       AND MOCTC.TC002 = MOCTE.TE002
    INNER JOIN YNRD..MOCTA
        ON MOCTA.TA001 = MOCTE.TE011
       AND MOCTA.TA002 = MOCTE.TE012
    INNER JOIN YNRD..COPTC
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

/*
------------------------------------------------------------
-- 可选校验：检查某材料/客户对应的原始领退料明细
-- 使用时取消注释，并修改材料品号、客户编号。
------------------------------------------------------------
SELECT
    MOCTE.TE001 AS 领退料单别,
    MOCTE.TE002 AS 领退料单号,
    MOCTE.TE003 AS 序号,
    MOCTC.TC003 AS 单据日期,
    MOCTE.TE011 AS 工单单别,
    MOCTE.TE012 AS 工单单号,
    MOCTA.TA026 AS 订单单别,
    MOCTA.TA027 AS 订单单号,
    COPTC.TC004 AS 客户编号,
    MOCTE.TE004 AS 材料品号,
    MOCTE.TE005 AS 数量
FROM SDRD..MOCTE
INNER JOIN SDRD..MOCTC
    ON MOCTC.TC001 = MOCTE.TE001
   AND MOCTC.TC002 = MOCTE.TE002
INNER JOIN SDRD..MOCTA
    ON MOCTA.TA001 = MOCTE.TE011
   AND MOCTA.TA002 = MOCTE.TE012
INNER JOIN SDRD..COPTC
    ON COPTC.TC001 = MOCTA.TA026
   AND COPTC.TC002 = MOCTA.TA027
WHERE LEFT(MOCTE.TE001, 2) IN ('54', '56')
  AND MOCTC.TC003 BETWEEN @StartDate AND @EndDate
  AND MOCTE.TE004 = '材料品号'
  AND COPTC.TC004 = '客户编号'
ORDER BY
    MOCTC.TC003,
    MOCTE.TE001,
    MOCTE.TE002,
    MOCTE.TE003;
*/
