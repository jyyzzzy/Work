USE AHRD;
SET NOCOUNT ON;

DECLARE @StartDate CHAR(8) = '20260101';
DECLARE @EndDate   CHAR(8) = '20260701';

IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#ISSUE') IS NOT NULL DROP TABLE #ISSUE;
IF OBJECT_ID('tempdb..#BOM') IS NOT NULL DROP TABLE #BOM;
IF OBJECT_ID('tempdb..#BOM_USE') IS NOT NULL DROP TABLE #BOM_USE;

------------------------------------------------------------
-- 1. 材料清单
--    品号从 LSSJ..ITEMTMP 取，品名、规格从 AHRD..INVMB 取
------------------------------------------------------------
SELECT
    T.材料品号,
    LTRIM(RTRIM(M.MB002)) AS 材料品名,
    LTRIM(RTRIM(M.MB003)) AS 材料规格
INTO #ITEM
FROM
(
    SELECT DISTINCT
        LTRIM(RTRIM(ITEMNO)) COLLATE DATABASE_DEFAULT AS 材料品号
    FROM LSSJ..ITEMTMP
    WHERE ISNULL(LTRIM(RTRIM(ITEMNO)), '') <> ''
) T
INNER JOIN AHRD..INVMB M
    ON LTRIM(RTRIM(M.MB001)) COLLATE DATABASE_DEFAULT = T.材料品号;

CREATE UNIQUE CLUSTERED INDEX IX_ITEM
ON #ITEM(材料品号);

------------------------------------------------------------
-- 2. 安徽三厂领退料
--    54：领料
--    56：退料
--    产品品号沿用原脚本口径：工单关联销售订单单身 TD004
--    汇总维度：材料品号 + 产品品号 + 事业部
------------------------------------------------------------
SELECT
    I.材料品号,
    LTRIM(RTRIM(TD.TD004)) COLLATE DATABASE_DEFAULT AS 产品品号,
    B.事业部,
    SUM(
        CASE
            WHEN LEFT(E.TE001, 2) = '54'
                THEN CAST(E.TE005 AS DECIMAL(38, 8))
            WHEN LEFT(E.TE001, 2) = '56'
                THEN -CAST(E.TE005 AS DECIMAL(38, 8))
            ELSE 0
        END
    ) AS 总领用量
INTO #ISSUE
FROM AHRD..MOCTE E
INNER JOIN AHRD..MOCTC C
    ON C.TC001 = E.TE001
   AND C.TC002 = E.TE002
INNER JOIN #ITEM I
    ON I.材料品号 = LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT
INNER JOIN AHRD..MOCTA A
    ON A.TA001 = E.TE011
   AND A.TA002 = E.TE012
INNER JOIN AHRD..CMSMD D
    ON D.MD001 = A.TA021
INNER JOIN AHRD..COPTD TD
    ON TD.TD001 = A.TA026
   AND TD.TD002 = A.TA027
   AND TD.TD003 = A.TA028
CROSS APPLY
(
    SELECT
        CASE
            WHEN CHARINDEX('-', ISNULL(D.MD011, '')) > 0
                THEN LTRIM(RTRIM(
                    LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
                ))
            ELSE LTRIM(RTRIM(ISNULL(D.MD011, '')))
        END COLLATE DATABASE_DEFAULT AS 事业部
) B
WHERE LEFT(E.TE001, 2) IN ('54', '56')
  AND C.TC003 >= @StartDate
  AND C.TC003 <  @EndDate
  AND E.TE019 = 'Y'
  AND B.事业部 = N'安徽三厂' COLLATE DATABASE_DEFAULT
  AND ISNULL(LTRIM(RTRIM(TD.TD004)), '') <> ''
GROUP BY
    I.材料品号,
    LTRIM(RTRIM(TD.TD004)) COLLATE DATABASE_DEFAULT,
    B.事业部;

CREATE CLUSTERED INDEX IX_ISSUE
ON #ISSUE(产品品号, 材料品号, 事业部);

------------------------------------------------------------
-- 3. AHRD 当前 BOM
--    单位用量 = MD006 / MD007
--    父件为 4 开头时，仅保留 MD013 = 'Y'
--    相同父件、子件先聚合，避免递归时重复放大
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT AS 父件品号,
    LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT AS 子件品号,
    CAST(
        SUM(
            CAST(MD006 AS DECIMAL(38, 12)) /
            CAST(ISNULL(NULLIF(MD007, 0), 1) AS DECIMAL(38, 12))
        )
        AS DECIMAL(38, 12)
    ) AS 单位用量
INTO #BOM
FROM AHRD..BOMMD
WHERE ISNULL(LTRIM(RTRIM(MD001)), '') <> ''
  AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
  AND
  (
        (LEFT(LTRIM(RTRIM(MD001)), 1) = '4' AND MD013 = 'Y')
        OR LEFT(LTRIM(RTRIM(MD001)), 1) <> '4'
  )
GROUP BY
    LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT,
    LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT;

CREATE CLUSTERED INDEX IX_BOM_PARENT
ON #BOM(父件品号, 子件品号);

------------------------------------------------------------
-- 4. 从产品向下展开 BOM，计算材料累计单位用量
--    路径字段用于阻止循环 BOM
------------------------------------------------------------
;WITH BOM_EXPAND AS
(
    SELECT
        P.产品品号,
        B.子件品号 AS 当前品号,
        CAST(B.单位用量 AS DECIMAL(38, 12)) AS 累计单位用量,
        CAST(
            '>' + P.产品品号 + '>' + B.子件品号 + '>'
            AS VARCHAR(MAX)
        ) AS 展开路径,
        1 AS 层级
    FROM
    (
        SELECT DISTINCT 产品品号
        FROM #ISSUE
    ) P
    INNER JOIN #BOM B
        ON B.父件品号 = P.产品品号

    UNION ALL

    SELECT
        E.产品品号,
        B.子件品号,
        CAST(
            E.累计单位用量 * B.单位用量
            AS DECIMAL(38, 12)
        ) AS 累计单位用量,
        CAST(
            E.展开路径 + B.子件品号 + '>'
            AS VARCHAR(MAX)
        ) AS 展开路径,
        E.层级 + 1
    FROM BOM_EXPAND E
    INNER JOIN #BOM B
        ON B.父件品号 = E.当前品号
    WHERE E.层级 < 30
      AND CHARINDEX(
            '>' + B.子件品号 + '>',
            E.展开路径
          ) = 0
)
SELECT
    E.产品品号,
    E.当前品号 AS 材料品号,
    CAST(SUM(E.累计单位用量) AS DECIMAL(38, 12)) AS 单位用量
INTO #BOM_USE
FROM BOM_EXPAND E
INNER JOIN #ITEM I
    ON I.材料品号 = E.当前品号
GROUP BY
    E.产品品号,
    E.当前品号
OPTION (MAXRECURSION 100);

CREATE UNIQUE CLUSTERED INDEX IX_BOM_USE
ON #BOM_USE(产品品号, 材料品号);

------------------------------------------------------------
-- 5. 最终结果
--    一行：材料品号 + 产品品号 + 安徽三厂
------------------------------------------------------------
SELECT
    I.材料品号,
    I.材料品名,
    I.材料规格,
    ISNULL(U.单位用量, 0) AS 单位用量,
    S.总领用量,
    S.产品品号,
    LTRIM(RTRIM(P.MB002)) AS 产品品名,
    LTRIM(RTRIM(P.MB003)) AS 产品规格,
    S.事业部
FROM #ISSUE S
INNER JOIN #ITEM I
    ON I.材料品号 = S.材料品号
INNER JOIN AHRD..INVMB P
    ON LTRIM(RTRIM(P.MB001)) COLLATE DATABASE_DEFAULT = S.产品品号
LEFT JOIN #BOM_USE U
    ON U.产品品号 = S.产品品号
   AND U.材料品号 = S.材料品号
ORDER BY
    S.产品品号,
    I.材料品号;
