USE SDRD;
GO

SET NOCOUNT ON;

DROP TABLE IF EXISTS #tbMC;
DROP TABLE IF EXISTS #BCPXJ;

DECLARE @Level INT = 1, @Rows INT;

-- 一、从 SDRD 物料主档获取规格包含 HS 的成品
SELECT MB001 AS MB01
INTO #tbMC
FROM SDRD.dbo.INVMB WITH(NOLOCK)
WHERE MB003 LIKE 'HS%'
  AND (MB001 LIKE '1%' OR MB001 LIKE 'A%')
  AND LEN(MB001) = 12;

-- 二、批量展开第一层 BOM
SELECT
    P.MB01,
    D.MD001 AS MD01,
    D.MD002 AS MD02,
    D.MD003 AS 材料品号,
    CAST(D.MD006 AS DECIMAL(28,6)) AS 累计用量,
    D.MD007,
    CAST(1 AS INT) AS 层级,
    D.MD013,
    D.MD019,
    D.MD009
INTO #BCPXJ
FROM #tbMC P
JOIN SDRD.dbo.BOMMD D WITH(NOLOCK)
  ON P.MB01 = D.MD001;

SET @Rows = @@ROWCOUNT;

-- 三、按层级批量展开剩余 BOM
WHILE @Rows > 0
BEGIN
    SET @Level = @Level + 1;

    -- 防止循环 BOM 导致无限展开
    IF @Level > 50
        THROW 50001, N'BOM 超过50层，可能存在循环引用', 1;

    INSERT INTO #BCPXJ
    (
        MB01, MD01, MD02, 材料品号,
        累计用量, MD007, 层级,
        MD013, MD019, MD009
    )
    SELECT
        B.MB01,
        D.MD001,
        D.MD002,
        D.MD003,
        CAST(D.MD006 * B.累计用量 AS DECIMAL(28,6)),
        D.MD007,
        @Level,
        D.MD013,
        D.MD019,
        D.MD009
    FROM #BCPXJ B
    JOIN SDRD.dbo.BOMMD D WITH(NOLOCK)
      ON B.材料品号 = D.MD001
    WHERE B.层级 = @Level - 1;

    SET @Rows = @@ROWCOUNT;
END;

-- 四、统一关联 SDRD 物料与工艺信息
SELECT
    RTRIM(X.MB01) AS 产品品号,
    B.MB002 AS 产品名称,
    B.MB003 AS 产品规格,
    B.MB109 AS 产品关闭,

    RTRIM(X.MD01) AS 元件品号,
    C.MB002 AS 元件名称,
    C.MB003 AS 元件规格,
    C.MB109 AS 元件关闭,

    RTRIM(X.材料品号) AS 材料品号,
    D.MB002 AS 材料品名,
    D.MB003 AS 材料规格,

    CASE
        WHEN (X.MD01 LIKE '4%' AND X.MD013 = 'Y')
          OR X.MD01 NOT LIKE '4%'
        THEN CAST(
            X.累计用量 / NULLIF(X.MD007, 0)
            AS DECIMAL(28,8)
        )
        ELSE CAST(0 AS DECIMAL(28,8))
    END AS 物料用量,

    D.MB109 AS 材料关闭,
    D.MB433 AS 拼板数,
    X.MD019 AS 插件位置,
    MW.MW002 AS 工艺
FROM #BCPXJ X
JOIN SDRD.dbo.INVMB B WITH(NOLOCK)
  ON X.MB01 = B.MB001
JOIN SDRD.dbo.INVMB C WITH(NOLOCK)
  ON X.MD01 = C.MB001
JOIN SDRD.dbo.INVMB D WITH(NOLOCK)
  ON X.材料品号 = D.MB001
LEFT JOIN SDRD.dbo.CMSMW MW WITH(NOLOCK)
  ON X.MD009 = MW.MW001
WHERE X.MD007 > 0
OPTION(RECOMPILE);
