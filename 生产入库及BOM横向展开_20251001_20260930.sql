/*
用途：导出 2025-10-01 至 2026-09-30 四地生产入库数量及 BOM 材料
账套：SDRD、ZJRD、AHRD、YNRD
BOM：统一使用 SDRD 当前标准 BOM（非历史版本）
展开规则：
    1. 第一阶 BOM 材料全部保留，包括品号以 4 开头的虚拟件。
    2. 仅当第一阶材料品号以 4 开头时，横向关联其第二阶 BOM。
    3. 虚拟件子材料的默认选择取第二阶 BOMMD.MD013，不按 Y/N 过滤。
    4. 普通材料的第二阶字段为空；虚拟件有多个子材料时第一阶记录重复显示。
入库数量：MOCTG.TG011，按账套/产品/生产部门/客户汇总。
注意：每条子材料结果均重复显示其所属产品入库总数量，不能直接对结果整列求和。
注意：WITH(NOLOCK) 可能读取到未提交/不一致数据。
*/

SET NOCOUNT ON;

DECLARE @StartDate CHAR(8) = '20251001';
DECLARE @EndDate   CHAR(8) = '20261001'; -- 不包含，覆盖到 2026-09-30

DROP TABLE IF EXISTS #ReceiptRaw;
DROP TABLE IF EXISTS #Receipt;
DROP TABLE IF EXISTS #BOMMaterial;

------------------------------------------------------------
-- 1. 汇总四地生产入库明细
------------------------------------------------------------
CREATE TABLE #ReceiptRaw
(
    账套         VARCHAR(4),
    产品品号     NVARCHAR(20),
    产品品名     NVARCHAR(100),
    产品规格     NVARCHAR(100),
    生产部门     NVARCHAR(100),
    客户编码     NVARCHAR(20),
    客户简称     NVARCHAR(100),
    入库数量     DECIMAL(28, 6)
);

DECLARE @DB VARCHAR(4);
DECLARE @SQL NVARCHAR(MAX);

DECLARE DB_CUR CURSOR LOCAL FAST_FORWARD FOR
SELECT DBName
FROM (VALUES ('SDRD'), ('ZJRD'), ('AHRD'), ('YNRD')) AS T(DBName);

OPEN DB_CUR;
FETCH NEXT FROM DB_CUR INTO @DB;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = N'
        INSERT INTO #ReceiptRaw
        (
            账套, 产品品号, 产品品名, 产品规格,
            生产部门, 客户编码, 客户简称, 入库数量
        )
        SELECT
            @Company,
            RTRIM(G.TG004),
            RTRIM(G.TG005),
            RTRIM(G.TG006),
            ISNULL(NULLIF(RTRIM(W.MD002), ''''), RTRIM(F.TF011)),
            RTRIM(C.TC004),
            RTRIM(MA.MA002),
            ISNULL(G.TG011, 0)
        FROM ' + QUOTENAME(@DB) + N'.dbo.MOCTG AS G WITH (NOLOCK)
        INNER JOIN ' + QUOTENAME(@DB) + N'.dbo.MOCTF AS F WITH (NOLOCK)
            ON G.TG001 = F.TF001
           AND G.TG002 = F.TF002
        LEFT JOIN ' + QUOTENAME(@DB) + N'.dbo.MOCTA AS A WITH (NOLOCK)
            ON G.TG014 = A.TA001
           AND G.TG015 = A.TA002
        LEFT JOIN ' + QUOTENAME(@DB) + N'.dbo.COPTC AS C WITH (NOLOCK)
            ON A.TA026 = C.TC001
           AND A.TA027 = C.TC002
        LEFT JOIN ' + QUOTENAME(@DB) + N'.dbo.COPMA AS MA WITH (NOLOCK)
            ON C.TC004 = MA.MA001
        LEFT JOIN ' + QUOTENAME(@DB) + N'.dbo.CMSMD AS W WITH (NOLOCK)
            ON F.TF011 = W.MD001
        WHERE F.TF003 >= @StartDate
          AND F.TF003 < @EndDate
          AND F.TF006 = ''Y''
          AND G.TG022 = ''Y''
          AND G.TG001 LIKE ''58%''
          AND G.TG009 = 1
          AND (G.TG004 LIKE ''1%'' OR G.TG004 LIKE ''A%'');';

    EXEC sys.sp_executesql
        @SQL,
        N'@Company VARCHAR(4), @StartDate CHAR(8), @EndDate CHAR(8)',
        @Company = @DB,
        @StartDate = @StartDate,
        @EndDate = @EndDate;

    FETCH NEXT FROM DB_CUR INTO @DB;
END;

CLOSE DB_CUR;
DEALLOCATE DB_CUR;

------------------------------------------------------------
-- 2. 按账套、产品、生产部门、客户汇总入库数量
------------------------------------------------------------
SELECT
    账套,
    产品品号,
    MAX(产品品名) AS 产品品名,
    MAX(产品规格) AS 产品规格,
    生产部门,
    客户编码,
    MAX(客户简称) AS 客户简称,
    SUM(入库数量) AS 入库总数量
INTO #Receipt
FROM #ReceiptRaw
GROUP BY
    账套,
    产品品号,
    生产部门,
    客户编码;

------------------------------------------------------------
-- 3. BOM 横向展开：第一阶完整保留，4 开头时关联第二阶
--    第二阶 MD013（默认选择）不参与过滤
------------------------------------------------------------
SELECT
    P.产品品号,

    -- 第一阶（包含虚拟件本身）
    B.MD003 AS 材料品号,
    B.MD009 AS 工艺编码,
    B.MD019 AS 插件位置,
    CAST(
        CAST(B.MD006 AS DECIMAL(28, 10))
        / NULLIF(CAST(B.MD007 AS DECIMAL(28, 10)), 0)
        AS DECIMAL(28, 10)
    ) AS 单位用量,

    -- 第二阶（仅当第一阶品号 4 开头时填充）
    V.MD003 AS 虚拟件子材料品号,
    V.MD009 AS 虚拟件工艺编码,
    V.MD019 AS 虚拟件插件位置,
    V.MD013 AS 虚拟件默认选择,
    CAST(
        CAST(V.MD006 AS DECIMAL(28, 10))
        / NULLIF(CAST(V.MD007 AS DECIMAL(28, 10)), 0)
        AS DECIMAL(28, 10)
    ) AS 虚拟件单位用量,
    CAST(
        (CAST(B.MD006 AS DECIMAL(28, 10))
         / NULLIF(CAST(B.MD007 AS DECIMAL(28, 10)), 0))
        *
        (CAST(V.MD006 AS DECIMAL(28, 10))
         / NULLIF(CAST(V.MD007 AS DECIMAL(28, 10)), 0))
        AS DECIMAL(28, 10)
    ) AS 虚拟件折算单位用量
INTO #BOMMaterial
FROM
(
    SELECT DISTINCT 产品品号
    FROM #Receipt
) AS P
INNER JOIN SDRD.dbo.BOMMD AS B WITH (NOLOCK)
    ON P.产品品号 = B.MD001
LEFT JOIN SDRD.dbo.BOMMD AS V WITH (NOLOCK)
    ON B.MD003 = V.MD001
   AND B.MD003 LIKE '4%'
   AND V.MD006 > 0
   AND V.MD007 > 0
WHERE B.MD006 > 0
  AND B.MD007 > 0;

------------------------------------------------------------
-- 4. 最终结果：第二阶虚拟件材料信息位于最右侧
------------------------------------------------------------
SELECT
    R.账套,
    R.产品品号,
    R.产品品名,
    R.产品规格,
    R.生产部门,
    R.客户编码,
    R.客户简称,
    R.入库总数量,

    -- 第一阶 BOM（包括 4 开头的虚拟件）
    B.材料品号,
    M.MB002 AS 材料品名,
    M.MB003 AS 材料规格,
    M.MB004 AS 材料单位,
    B.工艺编码,
    W.MW002 AS 工艺名称,
    B.插件位置,
    B.单位用量,

    -- 第二阶 BOM（只在第一阶是 4 开头虚拟件时有值）
    B.虚拟件子材料品号,
    VM.MB002 AS 虚拟件子材料品名,
    VM.MB003 AS 虚拟件子材料规格,
    VM.MB004 AS 虚拟件子材料单位,
    B.虚拟件工艺编码,
    VW.MW002 AS 虚拟件工艺名称,
    B.虚拟件插件位置,
    B.虚拟件默认选择,
    B.虚拟件单位用量,
    B.虚拟件折算单位用量
FROM #Receipt AS R
LEFT JOIN #BOMMaterial AS B
    ON R.产品品号 = B.产品品号
LEFT JOIN SDRD.dbo.INVMB AS M WITH (NOLOCK)
    ON B.材料品号 = M.MB001
LEFT JOIN SDRD.dbo.CMSMW AS W WITH (NOLOCK)
    ON B.工艺编码 = W.MW001
LEFT JOIN SDRD.dbo.INVMB AS VM WITH (NOLOCK)
    ON B.虚拟件子材料品号 = VM.MB001
LEFT JOIN SDRD.dbo.CMSMW AS VW WITH (NOLOCK)
    ON B.虚拟件工艺编码 = VW.MW001
ORDER BY
    R.账套,
    R.产品品号,
    R.生产部门,
    R.客户编码,
    B.材料品号,
    B.虚拟件子材料品号;
