USE SDRD;
SET NOCOUNT ON;

--DELETE FROM LSSJ..ITEMTMP
--="INSERT INTO LSSJ..ITEMTMP(ITEMNO) VALUES('"&"')"
IF OBJECT_ID('tempdb..#ISSUE') IS NOT NULL DROP TABLE #ISSUE;
IF OBJECT_ID('tempdb..#INVMB') IS NOT NULL DROP TABLE #INVMB;

------------------------------------------------------------
-- 材料清单：从 LSSJ..ITEMTMP 取
-- 物料资料：从安徽瑞德 INVMB 取
------------------------------------------------------------
SELECT
    T.ITEMNO,
    M.MB002,
    M.MB003,
    M.MB004,
    M.MB109
INTO #INVMB
FROM
(
    SELECT DISTINCT
        LTRIM(RTRIM(ITEMNO)) COLLATE DATABASE_DEFAULT AS ITEMNO
    FROM LSSJ..ITEMTMP
    WHERE ISNULL(LTRIM(RTRIM(ITEMNO)), '') <> ''
) T
LEFT JOIN AHRD..INVMB M
    ON LTRIM(RTRIM(M.MB001)) COLLATE DATABASE_DEFAULT = T.ITEMNO;

------------------------------------------------------------
-- 安徽瑞德领退料
-- 时间：2026-01-01 至 2026-06-30
-- 54：领料
-- 56：退料
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT AS MATL,
    SUM(
        CASE
            WHEN LEFT(E.TE001, 2) = '54'
                THEN CAST(E.TE005 AS DECIMAL(38, 8))
            WHEN LEFT(E.TE001, 2) = '56'
                THEN -CAST(E.TE005 AS DECIMAL(38, 8))
            ELSE 0
        END
    ) AS QTY
INTO #ISSUE
FROM AHRD..MOCTE E
INNER JOIN AHRD..MOCTC C
    ON C.TC001 = E.TE001
   AND C.TC002 = E.TE002
WHERE LEFT(E.TE001, 2) IN ('54', '56')
  AND C.TC003 >= '20260101'
  AND C.TC003 <  '20260701'
GROUP BY
    LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT;

------------------------------------------------------------
-- 最终结果
------------------------------------------------------------
SELECT
    I.ITEMNO AS 材料品号,
    I.MB002 AS 品名,
    I.MB003 AS 规格,
    I.MB004 AS 单位,
    I.MB109 AS 核准状况,
    ISNULL(S.QTY, 0) AS [2026年1至6月领用量]
FROM #INVMB I
LEFT JOIN #ISSUE S
    ON S.MATL = I.ITEMNO
ORDER BY
    I.ITEMNO;