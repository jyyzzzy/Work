SELECT COPTD.*
FROM COPTD
    JOIN CMSMQ
        ON TD001 = MQ001
    JOIN MOCTA ON TA026 = TD001 AND TA027 = TD002 AND TA028 = TD003
WHERE COPTD.TD016 = 'N'
AND MQ002 = N'客户订单'
AND TA011 NOT IN ('Y','y')
AND COPTD.UDF05 >= '20260401'
AND COPTD.UDF05 <= '20260430'
ORDER BY CREATE_DATE
;WITH ProductRoot AS
(
    SELECT 
        TRIM(TD004) AS ProductNo,
        SUM(TD008-TD009) QTY
    FROM COPTD
        JOIN CMSMQ
        ON TD001 = MQ001
    WHERE ISNULL(TRIM(TD004), '') <> ''
    AND COPTD.TD016 = 'N'
    AND MQ002 = N'客户订单'
    AND COPTD.UDF05 >= '20260401'
    AND COPTD.UDF05 <= '20260430'
GROUP BY TRIM(TD004)
),
BomToSemi AS
(
    -- 从产品开始，递归展开整棵 BOM
    SELECT
        P.ProductNo,
        B.MD001 AS ParentNo,
        B.MD003 AS ItemNo,
        1 AS Lvl,
        CAST('>' + P.ProductNo + '>' + B.MD003 + '>' AS VARCHAR(MAX)) AS BomPath
    FROM ProductRoot P
    INNER JOIN BOMMD B
        ON B.MD001 = P.ProductNo

    UNION ALL

    SELECT
        R.ProductNo,
        B.MD001,
        B.MD003,
        R.Lvl + 1,
        CAST(R.BomPath + B.MD003 + '>' AS VARCHAR(MAX)) AS BomPath
    FROM BomToSemi R
    INNER JOIN BOMMD B
        ON B.MD001 = R.ItemNo
    WHERE CHARINDEX('>' + B.MD003 + '>', R.BomPath) = 0
)--SELECT * FROM BomToSemi
,
SemiProduct AS
(
    -- 找出产品下面所有 2 开头的半成品
    SELECT DISTINCT
        ProductNo,
        ItemNo AS SemiNo
    FROM BomToSemi
    WHERE LEFT(ItemNo, 1) = '2'
),
SemiToMaterial AS
(
    -- 以半成品为起点继续递归展开
    SELECT
        S.ProductNo,
        S.SemiNo,
        B.MD001 AS ParentNo,
        B.MD003 AS ItemNo,
        1 AS Lvl,
        CAST('>' + S.SemiNo + '>' + B.MD003 + '>' AS VARCHAR(MAX)) AS BomPath
    FROM SemiProduct S
    INNER JOIN BOMMD B
        ON B.MD001 = S.SemiNo

    UNION ALL

    SELECT
        R.ProductNo,
        R.SemiNo,
        B.MD001,
        B.MD003,
        R.Lvl + 1,
        CAST(R.BomPath + B.MD003 + '>' AS VARCHAR(MAX)) AS BomPath
    FROM SemiToMaterial R
    INNER JOIN BOMMD B
        ON B.MD001 = R.ItemNo
    WHERE CHARINDEX('>' + B.MD003 + '>', R.BomPath) = 0
),ProductPoint AS (
    SELECT
        MD.MD001,
        MD.MD009,
        SUM(
            CONVERT(float, RTRIM(
                CASE ISNULL(MB3.MB180, '')
                    WHEN '' THEN '-99999'
                    ELSE MB3.MB180
                END
            ), 0) * MD006 / MD007
        ) AS Point
    FROM SDRD.dbo.BOMMD AS MD
    JOIN SDRD.dbo.INVMB AS MB3
        ON MD.MD003 = MB3.MB001
    WHERE MD006 > 0
      AND MD007 >= 1
      AND MB3.MB006 <> '220'
      AND LEFT(MD.MD003, 1) NOT IN ('A', '1', '2', '5', 'P')
    GROUP BY MD.MD001, MD.MD009
)
SELECT DISTINCT
    STM.ProductNo                    AS 产品品号,
    PROD.MB002                       AS 产品品名,
    PROD.MB003                       AS 产品规格,

    STM.SemiNo                       AS 半成品品号,
    SEMI.MB002                       AS 半成品品名,
    SEMI.MB003                       AS 半成品规格,

    STM.ItemNo                       AS 材料品号,
    MAT.MB002                        AS 材料品名,
    MAT.MB003                        AS 材料规格,

    CASE
            WHEN PP.Point IS NULL THEN -1
            WHEN PP.Point >= 0 THEN PP.Point
            ELSE -1
        END 自动化点数,
        PP.MD009 工艺,
        PR.QTY
FROM SemiToMaterial STM
INNER JOIN INVMB MAT
    ON MAT.MB001 = STM.ItemNo
LEFT JOIN INVMB PROD
    ON PROD.MB001 = STM.ProductNo
LEFT JOIN INVMB SEMI
    ON SEMI.MB001 = STM.SemiNo
LEFT JOIN ProductPoint PP ON STM.SemiNo = PP.MD001
LEFT JOIN ProductRoot PR ON PR.ProductNo = STM.ProductNo
WHERE ISNULL(MAT.MB002, '') LIKE N'%集成电路%'
ORDER BY
    STM.ProductNo,
    STM.SemiNo,
    STM.ItemNo
OPTION (MAXRECURSION 0);

;WITH ProductRoot AS
(
    SELECT 
        TRIM(TD004) AS ProductNo,
        SUM(TD008 - TD009) AS QTY
    FROM COPTD
    INNER JOIN CMSMQ
        ON TD001 = MQ001
    WHERE ISNULL(TRIM(TD004), '') <> ''
      AND COPTD.TD016 = 'N'
      AND MQ002 = N'客户订单'
      AND COPTD.UDF05 >= '20260401'
      AND COPTD.UDF05 <= '20260430'
    GROUP BY TRIM(TD004)
),
BomToSemi AS
(
    -- 从产品开始，递归展开整棵 BOM，找所有 2 开头半成品
    SELECT
        P.ProductNo,
        B.MD001 AS ParentNo,
        B.MD003 AS ItemNo,
        1 AS Lvl,
        CAST('>' + P.ProductNo + '>' + B.MD003 + '>' AS VARCHAR(MAX)) AS BomPath
    FROM ProductRoot P
    INNER JOIN BOMMD B
        ON B.MD001 = P.ProductNo

    UNION ALL

    SELECT
        R.ProductNo,
        B.MD001,
        B.MD003,
        R.Lvl + 1,
        CAST(R.BomPath + B.MD003 + '>' AS VARCHAR(MAX)) AS BomPath
    FROM BomToSemi R
    INNER JOIN BOMMD B
        ON B.MD001 = R.ItemNo
    WHERE CHARINDEX('>' + B.MD003 + '>', R.BomPath) = 0
),
SemiProduct AS
(
    -- 产品下所有 2 开头半成品
    SELECT DISTINCT
        ProductNo,
        ItemNo AS SemiNo
    FROM BomToSemi
    WHERE LEFT(ItemNo, 1) = '2'
),
SemiToMaterial AS
(
    -- 以半成品为起点继续展开
    SELECT
        S.ProductNo,
        S.SemiNo,
        B.MD001 AS ParentNo,
        B.MD003 AS ItemNo,
        1 AS Lvl,
        CAST('>' + S.SemiNo + '>' + B.MD003 + '>' AS VARCHAR(MAX)) AS BomPath
    FROM SemiProduct S
    INNER JOIN BOMMD B
        ON B.MD001 = S.SemiNo

    UNION ALL

    SELECT
        R.ProductNo,
        R.SemiNo,
        B.MD001,
        B.MD003,
        R.Lvl + 1,
        CAST(R.BomPath + B.MD003 + '>' AS VARCHAR(MAX)) AS BomPath
    FROM SemiToMaterial R
    INNER JOIN BOMMD B
        ON B.MD001 = R.ItemNo
    WHERE CHARINDEX('>' + B.MD003 + '>', R.BomPath) = 0
),
ProductPoint AS
(
    -- 半成品对应工艺及自动化点数
    SELECT
        MD.MD001,
        MD.MD009,
        SUM(
            CONVERT(float,
                RTRIM(
                    CASE ISNULL(MB3.MB180, '')
                        WHEN '' THEN '-99999'
                        ELSE MB3.MB180
                    END
                ),
            0) * MD006 / MD007
        ) AS Point
    FROM SDRD.dbo.BOMMD AS MD
    INNER JOIN SDRD.dbo.INVMB AS MB3
        ON MD.MD003 = MB3.MB001
    WHERE MD006 > 0
      AND MD007 >= 1
      AND MB3.MB006 <> '220'
      AND LEFT(MD.MD003, 1) NOT IN ('A', '1', '2', '5', 'P')
    GROUP BY MD.MD001, MD.MD009
),
SemiBase AS
(
    -- 主体结果：产品 + 半成品 + 工艺 + 点数 + QTY
    SELECT
        SP.ProductNo AS 产品品号,
        PROD.MB002   AS 产品品名,
        PROD.MB003   AS 产品规格,

        SP.SemiNo    AS 半成品品号,
        SEMI.MB002   AS 半成品品名,
        SEMI.MB003   AS 半成品规格,

        CASE
            WHEN PP.Point IS NULL THEN -1
            WHEN PP.Point >= 0 THEN PP.Point
            ELSE -1
        END AS 自动化点数,

        PP.MD009 AS 工艺,
        PR.QTY   AS QTY
    FROM SemiProduct SP
    LEFT JOIN INVMB PROD
        ON PROD.MB001 = SP.ProductNo
    LEFT JOIN INVMB SEMI
        ON SEMI.MB001 = SP.SemiNo
    LEFT JOIN ProductPoint PP
        ON PP.MD001 = SP.SemiNo
    LEFT JOIN ProductRoot PR
        ON PR.ProductNo = SP.ProductNo
),
ICMaterial AS
(
    -- 半成品下所有“集成电路”材料
    SELECT DISTINCT
        STM.ProductNo,
        STM.SemiNo,
        STM.ItemNo AS 材料品号,
        MAT.MB002  AS 材料品名,
        MAT.MB003  AS 材料规格
    FROM SemiToMaterial STM
    INNER JOIN INVMB MAT
        ON MAT.MB001 = STM.ItemNo
    WHERE ISNULL(MAT.MB002, '') LIKE N'%集成电路%'
)
SELECT
    SB.产品品号,
    SB.产品品名,
    SB.产品规格,
    SB.半成品品号,
    SB.半成品品名,
    SB.半成品规格,
    SB.自动化点数,
    SB.工艺,
    CMSMW.MW002,
    SB.QTY,
    IC.材料品号,
    IC.材料品名,
    IC.材料规格
FROM SemiBase SB
INNER JOIN CMSMW ON MW001 = SB.工艺
LEFT JOIN ICMaterial IC
    ON IC.ProductNo = SB.产品品号
   AND IC.SemiNo    = SB.半成品品号
ORDER BY
    SB.产品品号,
    SB.半成品品号,
    SB.工艺,
    IC.材料品号
OPTION (MAXRECURSION 0);



IF OBJECT_ID('tempdb..#ProductRoot') IS NOT NULL DROP TABLE #ProductRoot;
IF OBJECT_ID('tempdb..#BomBase') IS NOT NULL DROP TABLE #BomBase;
IF OBJECT_ID('tempdb..#Frontier') IS NOT NULL DROP TABLE #Frontier;
IF OBJECT_ID('tempdb..#NextFrontier') IS NOT NULL DROP TABLE #NextFrontier;
IF OBJECT_ID('tempdb..#Seen') IS NOT NULL DROP TABLE #Seen;
IF OBJECT_ID('tempdb..#SemiProduct') IS NOT NULL DROP TABLE #SemiProduct;
IF OBJECT_ID('tempdb..#ICMaterial') IS NOT NULL DROP TABLE #ICMaterial;
IF OBJECT_ID('tempdb..#ProductPoint') IS NOT NULL DROP TABLE #ProductPoint;

------------------------------------------------------------
-- 1. 根产品
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(TD004)) AS ProductNo,
    SUM(TD008 - TD009) AS QTY
INTO #ProductRoot
FROM COPTD
INNER JOIN CMSMQ
    ON COPTD.TD001 = CMSMQ.MQ001
INNER JOIN CMSMC ON CMSMC.MC001 = COPTD.TD007
WHERE ISNULL(LTRIM(RTRIM(TD004)), '') <> ''
  AND COPTD.TD016 = 'N'
  AND CMSMQ.MQ002 = N'客户订单'
  AND COPTD.UDF05 >= '20260401'
  AND COPTD.UDF05 <= '20260430'
  AND LEFT(CMSMC.UDF01,4) = '事业一部'
GROUP BY LTRIM(RTRIM(TD004));

------------------------------------------------------------
-- 2. 只保留 BOM 需要的字段，减少后续反复扫宽表
------------------------------------------------------------
SELECT
    MD001 AS ParentNo,
    MD003 AS ItemNo
INTO #BomBase
FROM BOMMD
WHERE ISNULL(MD001, '') <> ''
  AND ISNULL(MD003, '') <> '';

------------------------------------------------------------
-- 3. 层级展开缓存表
-- CurrentSemiNo：当前已经命中的 2 开头半成品
------------------------------------------------------------
CREATE TABLE #Frontier
(
    ProductNo     NVARCHAR(60),
    ItemNo        NVARCHAR(60),
    CurrentSemiNo NVARCHAR(60) NULL,
    Lvl           INT
);

CREATE TABLE #NextFrontier
(
    ProductNo     NVARCHAR(60),
    ItemNo        NVARCHAR(60),
    CurrentSemiNo NVARCHAR(60) NULL,
    Lvl           INT
);

CREATE TABLE #Seen
(
    ProductNo     NVARCHAR(60),
    ItemNo        NVARCHAR(60),
    CurrentSemiNo NVARCHAR(60) NULL,
    Lvl           INT
);

------------------------------------------------------------
-- 4. 第一层：产品直接下阶
------------------------------------------------------------
INSERT INTO #Frontier (ProductNo, ItemNo, CurrentSemiNo, Lvl)
SELECT DISTINCT
    P.ProductNo,
    B.ItemNo,
    CASE WHEN LEFT(B.ItemNo, 1) = '2' THEN B.ItemNo ELSE NULL END AS CurrentSemiNo,
    1 AS Lvl
FROM #ProductRoot P
INNER JOIN #BomBase B
    ON B.ParentNo = P.ProductNo;

INSERT INTO #Seen (ProductNo, ItemNo, CurrentSemiNo, Lvl)
SELECT
    ProductNo, ItemNo, CurrentSemiNo, Lvl
FROM #Frontier;

------------------------------------------------------------
-- 5. 逐层展开
-- 无回环前提下，不做路径字符串
-- 只去重 (ProductNo, ItemNo, CurrentSemiNo)
------------------------------------------------------------
DECLARE @Lvl INT = 1;
DECLARE @MaxLvl INT = 30;
DECLARE @Rows INT;

WHILE EXISTS (SELECT 1 FROM #Frontier) AND @Lvl < @MaxLvl
BEGIN
    DELETE FROM #NextFrontier;

    INSERT INTO #NextFrontier (ProductNo, ItemNo, CurrentSemiNo, Lvl)
    SELECT DISTINCT
        F.ProductNo,
        B.ItemNo,
        CASE
            WHEN LEFT(B.ItemNo, 1) = '2' THEN B.ItemNo
            ELSE F.CurrentSemiNo
        END AS CurrentSemiNo,
        @Lvl + 1 AS Lvl
    FROM #Frontier F
    INNER JOIN #BomBase B
        ON B.ParentNo = F.ItemNo
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM #Seen S
        WHERE S.ProductNo = F.ProductNo
          AND S.ItemNo = B.ItemNo
          AND ISNULL(S.CurrentSemiNo, '') =
              ISNULL(CASE WHEN LEFT(B.ItemNo, 1) = '2' THEN B.ItemNo ELSE F.CurrentSemiNo END, '')
    );

    SET @Rows = @@ROWCOUNT;
    IF @Rows = 0 BREAK;

    INSERT INTO #Seen (ProductNo, ItemNo, CurrentSemiNo, Lvl)
    SELECT
        ProductNo, ItemNo, CurrentSemiNo, Lvl
    FROM #NextFrontier;

    DELETE FROM #Frontier;

    INSERT INTO #Frontier (ProductNo, ItemNo, CurrentSemiNo, Lvl)
    SELECT
        ProductNo, ItemNo, CurrentSemiNo, Lvl
    FROM #NextFrontier;

    SET @Lvl = @Lvl + 1;
END;

------------------------------------------------------------
-- 6. 产品下所有命中的半成品
------------------------------------------------------------
SELECT DISTINCT
    ProductNo,
    CurrentSemiNo AS SemiNo
INTO #SemiProduct
FROM #Seen
WHERE ISNULL(CurrentSemiNo, '') <> '';

------------------------------------------------------------
-- 7. 半成品下所有“集成电路”材料
-- 这里只保留 产品 + 半成品 + 材料
------------------------------------------------------------
SELECT DISTINCT
    S.ProductNo,
    S.CurrentSemiNo AS SemiNo,
    S.ItemNo AS MaterialNo
INTO #ICMaterial
FROM #Seen S
INNER JOIN INVMB MAT
    ON MAT.MB001 = S.ItemNo
WHERE ISNULL(S.CurrentSemiNo, '') <> ''
  AND ISNULL(MAT.MB002, '') LIKE N'%集成电路%';

------------------------------------------------------------
-- 8. 只针对实际命中的半成品计算自动化点数/工艺
------------------------------------------------------------
SELECT
    MD.MD001 AS SemiNo,
    MD.MD009 AS 工艺,
    SUM(
        CONVERT(FLOAT,
            RTRIM(
                CASE ISNULL(MB3.MB180, '')
                    WHEN '' THEN '-99999'
                    ELSE MB3.MB180
                END
            ),
        0) * MD.MD006 / MD.MD007
    ) AS Point
INTO #ProductPoint
FROM SDRD.dbo.BOMMD AS MD
INNER JOIN SDRD.dbo.INVMB AS MB3
    ON MD.MD003 = MB3.MB001
INNER JOIN
(
    SELECT DISTINCT SemiNo
    FROM #SemiProduct
) AS SP
    ON SP.SemiNo = MD.MD001
WHERE MD.MD006 > 0
  AND MD.MD007 >= 1
  AND MB3.MB006 <> '220'
  AND LEFT(MD.MD003, 1) NOT IN ('A', '1', '2', '5', 'P')
GROUP BY
    MD.MD001,
    MD.MD009;

------------------------------------------------------------
-- 9. 最终结果
-- 主体字段必须保留
-- 材料字段左连接
------------------------------------------------------------
SELECT
    SP.ProductNo AS 产品品号,
    PROD.MB002   AS 产品品名,
    PROD.MB003   AS 产品规格,

    SP.SemiNo    AS 半成品品号,
    SEMI.MB002   AS 半成品品名,
    SEMI.MB003   AS 半成品规格,

    CASE
        WHEN PP.Point IS NULL THEN -1
        WHEN PP.Point >= 0 THEN PP.Point
        ELSE -1
    END AS 自动化点数,

    PP.工艺,
    CMSMW.MW002,
    PR.QTY,

    IC.MaterialNo AS 材料品号,
    MAT.MB002     AS 材料品名,
    MAT.MB003     AS 材料规格
FROM #SemiProduct SP

LEFT JOIN INVMB PROD
    ON PROD.MB001 = SP.ProductNo
LEFT JOIN INVMB SEMI
    ON SEMI.MB001 = SP.SemiNo
LEFT JOIN #ProductPoint PP
    ON PP.SemiNo = SP.SemiNo
    INNER JOIN CMSMW ON MW001 = PP.工艺
LEFT JOIN #ProductRoot PR
    ON PR.ProductNo = SP.ProductNo
LEFT JOIN #ICMaterial IC
    ON IC.ProductNo = SP.ProductNo
   AND IC.SemiNo    = SP.SemiNo
LEFT JOIN INVMB MAT
    ON MAT.MB001 = IC.MaterialNo
ORDER BY
    SP.ProductNo,
    SP.SemiNo,
    PP.工艺,
    IC.MaterialNo;