/*========================================================
  先清理旧临时表
========================================================*/
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#Material') IS NOT NULL DROP TABLE #Material;
IF OBJECT_ID('tempdb..#BomEdge') IS NOT NULL DROP TABLE #BomEdge;
IF OBJECT_ID('tempdb..#Frontier') IS NOT NULL DROP TABLE #Frontier;
IF OBJECT_ID('tempdb..#Next') IS NOT NULL DROP TABLE #Next;
IF OBJECT_ID('tempdb..#RawResult') IS NOT NULL DROP TABLE #RawResult;

GO

/*========================================================
  参数：最大上展层级
========================================================*/
DECLARE @MaxLevel INT = 20;
DECLARE @Rows INT;


/*========================================================
  1. 材料清单
========================================================*/
CREATE TABLE #Material
(
    MaterialNo NVARCHAR(40) NOT NULL PRIMARY KEY
);

INSERT INTO #Material(MaterialNo)
SELECT DISTINCT
    LTRIM(RTRIM(ITEMNO)) AS MaterialNo
FROM LSSJ..ITEMTMP WITH(NOLOCK)
WHERE ISNULL(LTRIM(RTRIM(ITEMNO)), '') <> '';


/*========================================================
  2. BOM 边表：子件 -> 上阶主件
========================================================*/
CREATE TABLE #BomEdge
(
    ChildNo NVARCHAR(40) NOT NULL,
    ParentNo NVARCHAR(40) NOT NULL,
    Qty DECIMAL(28,10) NOT NULL,
    BaseQty DECIMAL(28,10) NOT NULL
);

INSERT INTO #BomEdge
(
    ChildNo,
    ParentNo,
    Qty,
    BaseQty
)
SELECT DISTINCT
    LTRIM(RTRIM(MD003)) AS ChildNo,
    LTRIM(RTRIM(MD001)) AS ParentNo,
    CAST(ISNULL(MD006, 0) AS DECIMAL(28,10)) AS Qty,
    CAST(
        CASE 
            WHEN ISNULL(MD007, 0) = 0 THEN 1 
            ELSE MD007 
        END AS DECIMAL(28,10)
    ) AS BaseQty
FROM BOMMD WITH(NOLOCK)
WHERE ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
  AND ISNULL(LTRIM(RTRIM(MD001)), '') <> '';

CREATE CLUSTERED INDEX IX_BomEdge_ChildNo
ON #BomEdge(ChildNo, ParentNo);


/*========================================================
  3. 当前层
========================================================*/
CREATE TABLE #Frontier
(
    MaterialNo NVARCHAR(40) NOT NULL,
    CurrentNo NVARCHAR(40) NOT NULL,
    LevelNo INT NOT NULL,
    CumQty DECIMAL(38,12) NOT NULL,
    BomPath NVARCHAR(MAX) NOT NULL
);

CREATE NONCLUSTERED INDEX IX_Frontier_CurrentNo
ON #Frontier(CurrentNo);


/*========================================================
  4. 下一层
========================================================*/
CREATE TABLE #Next
(
    MaterialNo NVARCHAR(40) NOT NULL,
    CurrentNo NVARCHAR(40) NOT NULL,
    LevelNo INT NOT NULL,
    LayerQty DECIMAL(28,10) NOT NULL,
    LayerBaseQty DECIMAL(28,10) NOT NULL,
    CumQty DECIMAL(38,12) NOT NULL,
    BomPath NVARCHAR(MAX) NOT NULL
);

CREATE NONCLUSTERED INDEX IX_Next_CurrentNo
ON #Next(CurrentNo);


/*========================================================
  5. 原始结果表
     不设主键，允许同一材料到同一成品存在多条路径
========================================================*/
CREATE TABLE #RawResult
(
    FinishedNo NVARCHAR(40) NOT NULL,
    MaterialNo NVARCHAR(40) NOT NULL,
    LevelNo INT NOT NULL,
    LayerQty DECIMAL(28,10) NOT NULL,
    LayerBaseQty DECIMAL(28,10) NOT NULL,
    CumQty DECIMAL(38,12) NOT NULL
);

CREATE NONCLUSTERED INDEX IX_RawResult_FinishedNo_MaterialNo
ON #RawResult(FinishedNo, MaterialNo);


/*========================================================
  6. 初始化
========================================================*/
INSERT INTO #Frontier
(
    MaterialNo,
    CurrentNo,
    LevelNo,
    CumQty,
    BomPath
)
SELECT
    MaterialNo,
    MaterialNo AS CurrentNo,
    0 AS LevelNo,
    CAST(1 AS DECIMAL(38,12)) AS CumQty,
    CAST('>' + MaterialNo + '>' AS NVARCHAR(MAX)) AS BomPath
FROM #Material;


/*========================================================
  7. 循环向上展开
========================================================*/
WHILE 1 = 1
BEGIN
    TRUNCATE TABLE #Next;

    INSERT INTO #Next
    (
        MaterialNo,
        CurrentNo,
        LevelNo,
        LayerQty,
        LayerBaseQty,
        CumQty,
        BomPath
    )
    SELECT
        F.MaterialNo,
        B.ParentNo AS CurrentNo,
        F.LevelNo + 1 AS LevelNo,
        B.Qty AS LayerQty,
        B.BaseQty AS LayerBaseQty,
        CONVERT(
            DECIMAL(38,12),
            CONVERT(FLOAT, F.CumQty) * CONVERT(FLOAT, B.Qty) / NULLIF(CONVERT(FLOAT, B.BaseQty), 0)
        ) AS CumQty,
        CAST(F.BomPath + B.ParentNo + '>' AS NVARCHAR(MAX)) AS BomPath
    FROM #Frontier F
    INNER JOIN #BomEdge B
        ON B.ChildNo = F.CurrentNo
    WHERE F.LevelNo < @MaxLevel
      AND CHARINDEX('>' + B.ParentNo + '>', F.BomPath) = 0;

    SET @Rows = @@ROWCOUNT;

    IF @Rows = 0
        BREAK;


    INSERT INTO #RawResult
    (
        FinishedNo,
        MaterialNo,
        LevelNo,
        LayerQty,
        LayerBaseQty,
        CumQty
    )
    SELECT
        CurrentNo AS FinishedNo,
        MaterialNo,
        LevelNo,
        LayerQty,
        LayerBaseQty,
        CumQty
    FROM #Next
    WHERE CurrentNo LIKE '1%';


    TRUNCATE TABLE #Frontier;

    INSERT INTO #Frontier
    (
        MaterialNo,
        CurrentNo,
        LevelNo,
        CumQty,
        BomPath
    )
    SELECT
        MaterialNo,
        CurrentNo,
        LevelNo,
        CumQty,
        BomPath
    FROM #Next;
END;


/*========================================================
  8. 最终输出
========================================================*/
SELECT
     R.FinishedNo AS 成品品号
    ,PROD.MB002 AS 成品品名
    ,PROD.MB003 AS 成品规格

    ,R.MaterialNo AS 材料品号
    ,MATL.MB002 AS 材料品名
    ,MATL.MB003 AS 材料规格

    ,SUM(R.CumQty) AS 组成用量
FROM #RawResult R
LEFT JOIN INVMB PROD WITH(NOLOCK)
    ON PROD.MB001 = R.FinishedNo
LEFT JOIN INVMB MATL WITH(NOLOCK)
    ON MATL.MB001 = R.MaterialNo
GROUP BY
     R.FinishedNo
    ,PROD.MB002
    ,PROD.MB003
    ,R.MaterialNo
    ,MATL.MB002
    ,MATL.MB003
ORDER BY
     R.FinishedNo
    ,R.MaterialNo;