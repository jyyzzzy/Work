DELETE FROM LSSJ..ITEMTMP
--="INSERT INTO LSSJ..ITEMTMP(ITEMNO) VALUES('"&&"');"

IF OBJECT_ID('tempdb..#tbMC') IS NOT NULL DROP TABLE #tbMC;
IF OBJECT_ID('tempdb..#BCPXJ') IS NOT NULL DROP TABLE #BCPXJ;

-- 产品品号来源：LSSJ..ITEMTMP
SELECT DISTINCT 
    RTRIM(ITEMNO) AS MB01
INTO #tbMC
FROM LSSJ..ITEMTMP
WHERE ISNULL(RTRIM(ITEMNO), '') <> '';

-- BOM展开结果临时表
SELECT 
    B.MB001 AS MB01,
    B.MB001 AS 材料品号,
    B.MB002 AS 材料品名,
    B.MB003 AS 材料规格,
    B.MB050 AS 物料用量
INTO #BCPXJ
FROM INVMB B
WHERE 1 = 2;

--DECLARE @CLPH VARCHAR(30);
DECLARE @CLPH VARCHAR(15);

WHILE (SELECT COUNT(*) FROM #tbMC) > 0
BEGIN
    SELECT TOP 1
        @CLPH = RTRIM(MB01)
    FROM #tbMC;

    INSERT INTO #BCPXJ
    (
        MB01,
        材料品号,
        材料品名,
        材料规格,
        物料用量
    )
    SELECT
        MB01,
        MD03 AS 材料品号,
        B.MB002 AS 材料品名,
        B.MB003 AS 材料规格,
        CASE
            WHEN (
                    (MD01 LIKE '4%' AND MD13 = 'Y')
                    OR MD01 NOT LIKE '4%'
                 )
            THEN MD06 / MD07
            ELSE 0
        END AS 物料用量
    FROM SDRD.dbo.Fn_GetBOMIDs_YL(@CLPH),
         #tbMC,
         INVMB B
    WHERE MB01 = @CLPH
      AND MD03 = B.MB001
      AND MD07 > 0;

    DELETE FROM #tbMC
    WHERE RTRIM(MB01) = RTRIM(@CLPH);
END;

-- 最终结果：只取SDRD，且只保留产品信息、材料信息、库存数量、库存金额
SELECT 
    TRIM(SI.MB001) AS 产品品号,
    SI.MB002 AS 产品品名,
    SI.MB003 AS 产品规格,
    TRIM(B.材料品号) AS 材料品号,
    B.材料品名,
    B.材料规格,
    ISNULL(INV.MB064, 0) AS 库存数量,
    ISNULL(INV.MB065, 0) AS 库存金额
FROM #BCPXJ B
INNER JOIN INVMB SI
    ON RTRIM(SI.MB001) = RTRIM(B.MB01)
LEFT JOIN INVMB INV
    ON RTRIM(INV.MB001) = RTRIM(B.材料品号)
WHERE LEFT(B.材料品号, 1) IN ('3', '5', '6', '7')
  AND B.物料用量 > 0
ORDER BY 
    TRIM(SI.MB001),
    TRIM(B.材料品号);