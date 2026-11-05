USE SDRD;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#BOM') IS NOT NULL DROP TABLE #BOM;

------------------------------------------------------------
-- 成品
------------------------------------------------------------
SELECT DISTINCT
    LTRIM(RTRIM(ITEMNO)) COLLATE DATABASE_DEFAULT AS 品号
INTO #ITEM
FROM LSSJ..ITEMTMP
WHERE ISNULL(LTRIM(RTRIM(ITEMNO)), '') <> '';

------------------------------------------------------------
-- BOM：先清洗、去重、聚合，避免递归爆炸
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT AS 父件品号,
    LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT AS 材料品号,
SUM(
    CASE
        WHEN (MD001 LIKE '4%' AND MD013 = 'Y')
          OR MD001 NOT LIKE '4%'
        THEN
            CAST(MD006 AS DECIMAL(38,12)) /
            CAST(ISNULL(NULLIF(MD007, 0), 1) AS DECIMAL(38,12))
        ELSE 0
    END
) AS 单位用量
INTO #BOM
FROM BOMMD
WHERE ISNULL(LTRIM(RTRIM(MD001)), '') <> ''
  AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
GROUP BY
    LTRIM(RTRIM(MD001)),
    LTRIM(RTRIM(MD003));

CREATE INDEX IX_BOM_父件 ON #BOM(父件品号);
CREATE INDEX IX_BOM_材料 ON #BOM(材料品号);

------------------------------------------------------------
-- BOM 下展
------------------------------------------------------------
;WITH R AS
(
    SELECT
        I.品号 AS 成品品号,
        B.材料品号,
        CAST(B.单位用量 AS DECIMAL(38,12)) AS 单位用量,
        1 AS 层级,
        CAST('|' + I.品号 + '|' + B.材料品号 + '|' AS VARCHAR(MAX)) AS 路径
    FROM #ITEM I
    JOIN #BOM B
        ON B.父件品号 = I.品号

    UNION ALL

    SELECT
        R.成品品号,
        B.材料品号,
        CAST(R.单位用量 * B.单位用量 AS DECIMAL(38,12)) AS 单位用量,
        R.层级 + 1 AS 层级,
        CAST(R.路径 + B.材料品号 + '|' AS VARCHAR(MAX)) AS 路径
    FROM R
    JOIN #BOM B
        ON B.父件品号 = R.材料品号
    WHERE R.层级 < 30
      AND CHARINDEX('|' + B.材料品号 + '|', R.路径) = 0
)

SELECT
    R.成品品号,
    CP.MB002 AS 成品品名,
    CP.MB003 AS 成品规格,
    R.材料品号,
    CL.MB002 AS 材料品名,
    CL.MB003 AS 材料规格,
    SUM(R.单位用量) AS 单位用量
FROM R
LEFT JOIN INVMB CP
    ON CP.MB001 = R.成品品号
LEFT JOIN INVMB CL
    ON CL.MB001 = R.材料品号
WHERE NOT EXISTS
(
    SELECT 1
    FROM #BOM B
    WHERE B.父件品号 = R.材料品号
      AND CHARINDEX('|' + B.材料品号 + '|', R.路径) = 0
)
GROUP BY
    R.成品品号,
    CP.MB002,
    CP.MB003,
    R.材料品号,
    CL.MB002,
    CL.MB003
ORDER BY
    R.成品品号,
    R.材料品号
OPTION (MAXRECURSION 30);