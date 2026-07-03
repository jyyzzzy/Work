SELECT MB001 AS 品号,
	MB002 AS 品名,
	MB003 AS 规格,
	INVMB.UDF52 AS 采购参考周期
FROM INVMB 
WHERE MB008 IN ('414','416') 
ORDER BY INVMB.MB001 ASC

USE SDRD;
SET NOCOUNT ON;

------------------------------------------------------------
-- 日期规则
-- 1. 领用量：过去12个完整月份
--    当前7月时：过去第1月=6月，过去第12月=去年7月
-- 2. 样板订单：订单日期从当前月往前2个月的月初到今天
--    当前7月时：订单日期 >= 5月1日 且 <= 今天
------------------------------------------------------------
DECLARE @ThisMonthStart DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

DECLARE @BeginDate CHAR(8) = CONVERT(CHAR(8), DATEADD(MONTH, -12, @ThisMonthStart), 112);
DECLARE @ThisMonthStartChar CHAR(8) = CONVERT(CHAR(8), @ThisMonthStart, 112);

DECLARE @OrderBeginDate CHAR(8) = CONVERT(CHAR(8), DATEADD(MONTH, -2, @ThisMonthStart), 112);
DECLARE @TodayChar CHAR(8) = CONVERT(CHAR(8), GETDATE(), 112);

IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#STOCK') IS NOT NULL DROP TABLE #STOCK;
IF OBJECT_ID('tempdb..#ONWAY') IS NOT NULL DROP TABLE #ONWAY;
IF OBJECT_ID('tempdb..#ALLOC') IS NOT NULL DROP TABLE #ALLOC;
IF OBJECT_ID('tempdb..#ISSUE_DETAIL') IS NOT NULL DROP TABLE #ISSUE_DETAIL;
IF OBJECT_ID('tempdb..#ISSUE') IS NOT NULL DROP TABLE #ISSUE;
IF OBJECT_ID('tempdb..#SALE_INFO') IS NOT NULL DROP TABLE #SALE_INFO;
IF OBJECT_ID('tempdb..#PRODUCT') IS NOT NULL DROP TABLE #PRODUCT;

------------------------------------------------------------
-- 1. 基础物料：414 / 416
------------------------------------------------------------
SELECT
    MB001 AS 品号,
    MB002 AS 品名,
    MB003 AS 规格,
    MB004 AS 单位,
    INVMB.UDF52 AS 采购参考周期
INTO #ITEM
FROM INVMB WITH(NOLOCK)
WHERE MB008 IN ('414', '416');

CREATE UNIQUE CLUSTERED INDEX IX_ITEM_品号 ON #ITEM(品号);

------------------------------------------------------------
-- 2. 库存：纳入库存仓库汇总
------------------------------------------------------------
SELECT
    INVMC.MC001 AS 品号,
    SUM(ISNULL(INVMC.MC007, 0)) AS 库存数量
INTO #STOCK
FROM INVMC WITH(NOLOCK)
INNER JOIN CMSMC WITH(NOLOCK)
    ON CMSMC.MC001 = INVMC.MC002
INNER JOIN #ITEM I
    ON I.品号 = INVMC.MC001
WHERE CMSMC.MC005 = 'Y'
GROUP BY INVMC.MC001;

CREATE UNIQUE CLUSTERED INDEX IX_STOCK_品号 ON #STOCK(品号);

------------------------------------------------------------
-- 3. 在途：采购单未结束且已审核
------------------------------------------------------------
SELECT
    TD004 AS 品号,
    SUM(ISNULL(TD008, 0) - ISNULL(TD015, 0)) AS 在途数量
INTO #ONWAY
FROM PURTD WITH(NOLOCK)
INNER JOIN #ITEM I
    ON I.品号 = TD004
WHERE TD016 = 'N'
  AND TD018 = 'Y'
  AND ISNULL(TD008, 0) - ISNULL(TD015, 0) > 0
GROUP BY TD004;

CREATE UNIQUE CLUSTERED INDEX IX_ONWAY_品号 ON #ONWAY(品号);

------------------------------------------------------------
-- 4. 分配：已审核、未完工工单材料未领数量
------------------------------------------------------------
SELECT
    TB003 AS 品号,
    SUM(
        CASE 
            WHEN ISNULL(TB004, 0) - ISNULL(TB005, 0) <= 0 THEN 0
            ELSE ISNULL(TB004, 0) - ISNULL(TB005, 0)
        END
    ) AS 分配数量
INTO #ALLOC
FROM MOCTB WITH(NOLOCK)
INNER JOIN MOCTA WITH(NOLOCK)
    ON TA001 = TB001
   AND TA002 = TB002
INNER JOIN #ITEM I
    ON I.品号 = TB003
WHERE TA013 = 'Y'
  AND TA011 IN ('1', '2', '3')
GROUP BY TB003;

CREATE UNIQUE CLUSTERED INDEX IX_ALLOC_品号 ON #ALLOC(品号);

------------------------------------------------------------
-- 5. 显式创建领用明细表
--    避免 SELECT INTO 旧结构缓存导致无效列名
------------------------------------------------------------
CREATE TABLE #ISSUE_DETAIL
(
    品号 NVARCHAR(40) NOT NULL,

    客户编号 NVARCHAR(40) NOT NULL,
    客户简称 NVARCHAR(200) NOT NULL,
    客户全称 NVARCHAR(300) NOT NULL,

    销售部门 NVARCHAR(200) NOT NULL,
    业务员 NVARCHAR(200) NOT NULL,

    成品品号 NVARCHAR(40) NOT NULL,
    成品品名 NVARCHAR(300) NOT NULL,
    成品规格 NVARCHAR(500) NOT NULL,

    领用日期 CHAR(8) NOT NULL,
    使用量 DECIMAL(38, 10) NOT NULL
);

------------------------------------------------------------
-- 6. 插入过去12个月领用明细
--    只取样板订单：
--    COPTC.TC001 = CMSMQ.MQ001
--    CMSMQ.MQ002 = '样板订单'
--    COPTC.TC003 between @OrderBeginDate and @TodayChar
------------------------------------------------------------
INSERT INTO #ISSUE_DETAIL
(
    品号,
    客户编号,
    客户简称,
    客户全称,
    销售部门,
    业务员,
    成品品号,
    成品品名,
    成品规格,
    领用日期,
    使用量
)
SELECT
    LA.LA001 AS 品号,

    ISNULL(NULLIF(TC.TC004, ''), '') AS 客户编号,
    ISNULL(NULLIF(COPMA.MA002, ''), ISNULL(TC.TC004, '')) AS 客户简称,
    ISNULL(NULLIF(COPMA.MA003, ''), '') AS 客户全称,

    ISNULL(NULLIF(CMSME.ME002, ''), ISNULL(TC.TC005, '')) AS 销售部门,
    ISNULL(NULLIF(CMSMV.MV002, ''), ISNULL(TC.TC006, '')) AS 业务员,

    ISNULL(NULLIF(TD.TD004, ''), ISNULL(TA.TA006, '')) AS 成品品号,
    ISNULL(PROD.MB002, '') AS 成品品名,
    ISNULL(PROD.MB003, '') AS 成品规格,

    LA.LA004 AS 领用日期,
    CONVERT(DECIMAL(38, 10), -1 * ISNULL(LA.LA011, 0) * ISNULL(LA.LA005, 0)) AS 使用量
FROM INVLA LA WITH(NOLOCK)
INNER JOIN #ITEM I
    ON I.品号 = LA.LA001

LEFT JOIN MOCTE TE WITH(NOLOCK)
    ON TE.TE001 = LA.LA006
   AND TE.TE002 = LA.LA007
   AND TE.TE003 = LA.LA008

LEFT JOIN MOCTA TA WITH(NOLOCK)
    ON TA.TA001 = TE.TE011
   AND TA.TA002 = TE.TE012

LEFT JOIN COPTD TD WITH(NOLOCK)
    ON TD.TD001 = TA.TA026
   AND TD.TD002 = TA.TA027
   AND TD.TD003 = TA.TA028

LEFT JOIN COPTC TC WITH(NOLOCK)
    ON TC.TC001 = TD.TD001
   AND TC.TC002 = TD.TD002

INNER JOIN CMSMQ WITH(NOLOCK)
    ON CMSMQ.MQ001 = TC.TC001
   AND CMSMQ.MQ002 = '样板订单'

LEFT JOIN COPMA WITH(NOLOCK)
    ON COPMA.MA001 = TC.TC004

LEFT JOIN CMSME WITH(NOLOCK)
    ON CMSME.ME001 = TC.TC005

LEFT JOIN CMSMV WITH(NOLOCK)
    ON CMSMV.MV001 = TC.TC006

LEFT JOIN INVMB PROD WITH(NOLOCK)
    ON PROD.MB001 = ISNULL(NULLIF(TD.TD004, ''), TA.TA006)

WHERE LA.LA004 >= @BeginDate
  AND LA.LA004 <  @ThisMonthStartChar
  AND LEFT(LA.LA006, 2) IN ('54', '56')
  AND TC.TC003 >= @OrderBeginDate
  AND TC.TC003 <= @TodayChar;

CREATE NONCLUSTERED INDEX IX_ISSUE_DETAIL_KEY 
ON #ISSUE_DETAIL(品号, 客户编号, 客户简称, 客户全称, 成品品号);

------------------------------------------------------------
-- 7. 按 物料 + 客户 汇总过去12个月使用量
--    一个客户一行
------------------------------------------------------------
SELECT
    品号,
    客户编号,
    客户简称,
    客户全称,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -1, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH,  0, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第1月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -2, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -1, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第2月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -3, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -2, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第3月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -4, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -3, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第4月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -5, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -4, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第5月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -6, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -5, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第6月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -7, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -6, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第7月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -8, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -7, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第8月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -9, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -8, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第9月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -10, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -9, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第10月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -11, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -10, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第11月使用量,

    SUM(CASE 
        WHEN 领用日期 >= CONVERT(CHAR(8), DATEADD(MONTH, -12, @ThisMonthStart), 112)
         AND 领用日期 <  CONVERT(CHAR(8), DATEADD(MONTH, -11, @ThisMonthStart), 112)
        THEN 使用量 ELSE 0 END
    ) AS 过去第12月使用量

INTO #ISSUE
FROM #ISSUE_DETAIL
GROUP BY
    品号,
    客户编号,
    客户简称,
    客户全称;

CREATE UNIQUE CLUSTERED INDEX IX_ISSUE_KEY 
ON #ISSUE(品号, 客户编号, 客户简称, 客户全称);

------------------------------------------------------------
-- 8. 销售部门、业务员合并
------------------------------------------------------------
SELECT
    C.品号,
    C.客户编号,
    C.客户简称,
    C.客户全称,

    STUFF((
        SELECT DISTINCT '、' + D.销售部门
        FROM #ISSUE_DETAIL D
        WHERE D.品号 = C.品号
          AND D.客户编号 = C.客户编号
          AND D.客户简称 = C.客户简称
          AND D.客户全称 = C.客户全称
          AND ISNULL(D.销售部门, '') <> ''
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS 销售部门,

    STUFF((
        SELECT DISTINCT '、' + D.业务员
        FROM #ISSUE_DETAIL D
        WHERE D.品号 = C.品号
          AND D.客户编号 = C.客户编号
          AND D.客户简称 = C.客户简称
          AND D.客户全称 = C.客户全称
          AND ISNULL(D.业务员, '') <> ''
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS 业务员

INTO #SALE_INFO
FROM (
    SELECT DISTINCT
        品号,
        客户编号,
        客户简称,
        客户全称
    FROM #ISSUE_DETAIL
) C;

CREATE UNIQUE CLUSTERED INDEX IX_SALE_INFO_KEY 
ON #SALE_INFO(品号, 客户编号, 客户简称, 客户全称);

------------------------------------------------------------
-- 9. 成品去重并编号
------------------------------------------------------------
SELECT
    品号,
    客户编号,
    客户简称,
    客户全称,
    成品品号,
    成品品名,
    成品规格,
    ROW_NUMBER() OVER (
        PARTITION BY 品号, 客户编号, 客户简称, 客户全称
        ORDER BY 成品品号
    ) AS rn
INTO #PRODUCT
FROM (
    SELECT DISTINCT
        品号,
        客户编号,
        客户简称,
        客户全称,
        成品品号,
        成品品名,
        成品规格
    FROM #ISSUE_DETAIL
    WHERE ISNULL(成品品号, '') <> ''
) X;

CREATE NONCLUSTERED INDEX IX_PRODUCT_KEY 
ON #PRODUCT(品号, 客户编号, 客户简称, 客户全称, rn);

------------------------------------------------------------
-- 10. 用 FOR XML PATH 动态生成成品列
------------------------------------------------------------
DECLARE @ProductCols NVARCHAR(MAX) = N'';
DECLARE @SQL NVARCHAR(MAX);

SELECT @ProductCols =
(
    SELECT
        CHAR(13) + CHAR(10) +
        ', ISNULL(MAX(CASE WHEN P.rn = ' + CAST(R.rn AS VARCHAR(10)) + ' THEN P.成品品号 END), '''') AS ' + QUOTENAME('成品品号' + CAST(R.rn AS VARCHAR(10))) +
        ', ISNULL(MAX(CASE WHEN P.rn = ' + CAST(R.rn AS VARCHAR(10)) + ' THEN P.成品品名 END), '''') AS ' + QUOTENAME('成品品名' + CAST(R.rn AS VARCHAR(10))) +
        ', ISNULL(MAX(CASE WHEN P.rn = ' + CAST(R.rn AS VARCHAR(10)) + ' THEN P.成品规格 END), '''') AS ' + QUOTENAME('成品规格' + CAST(R.rn AS VARCHAR(10)))
    FROM (
        SELECT DISTINCT rn
        FROM #PRODUCT
    ) R
    ORDER BY R.rn
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)');

SET @ProductCols = ISNULL(@ProductCols, N'');

------------------------------------------------------------
-- 11. 最终结果
------------------------------------------------------------
SET @SQL = N'
SELECT
    I.品号,
    I.品名,
    I.规格,
    I.单位,
    I.采购参考周期,
    ISNULL(S.库存数量, 0) AS 库存数量,
    ISNULL(O.在途数量, 0) AS 在途数量,
    ISNULL(A.分配数量, 0) AS 分配数量,
    ISNULL(U.过去第1月使用量, 0) AS 过去第1月使用量,
    ISNULL(U.过去第2月使用量, 0) AS 过去第2月使用量,
    ISNULL(U.过去第3月使用量, 0) AS 过去第3月使用量,
    ISNULL(U.过去第4月使用量, 0) AS 过去第4月使用量,
    ISNULL(U.过去第5月使用量, 0) AS 过去第5月使用量,
    ISNULL(U.过去第6月使用量, 0) AS 过去第6月使用量,
    ISNULL(U.过去第7月使用量, 0) AS 过去第7月使用量,
    ISNULL(U.过去第8月使用量, 0) AS 过去第8月使用量,
    ISNULL(U.过去第9月使用量, 0) AS 过去第9月使用量,
    ISNULL(U.过去第10月使用量, 0) AS 过去第10月使用量,
    ISNULL(U.过去第11月使用量, 0) AS 过去第11月使用量,
    ISNULL(U.过去第12月使用量, 0) AS 过去第12月使用量,
    ISNULL(U.客户编号, '''') AS 客户编号,
    ISNULL(U.客户简称, '''') AS 客户简称,
    ISNULL(U.客户全称, '''') AS 客户全称,
    ISNULL(SI.销售部门, '''') AS 销售部门,
    ISNULL(SI.业务员, '''') AS 业务员
    ' + @ProductCols + N'





FROM #ITEM I

LEFT JOIN #ISSUE U
    ON U.品号 = I.品号

LEFT JOIN #SALE_INFO SI
    ON SI.品号 = U.品号
   AND SI.客户编号 = U.客户编号
   AND SI.客户简称 = U.客户简称
   AND SI.客户全称 = U.客户全称

LEFT JOIN #PRODUCT P
    ON P.品号 = U.品号
   AND P.客户编号 = U.客户编号
   AND P.客户简称 = U.客户简称
   AND P.客户全称 = U.客户全称

LEFT JOIN #STOCK S
    ON S.品号 = I.品号

LEFT JOIN #ONWAY O
    ON O.品号 = I.品号

LEFT JOIN #ALLOC A
    ON A.品号 = I.品号

GROUP BY
    I.品号,
    I.品名,
    I.规格,
    I.单位,
    I.采购参考周期,

    ISNULL(U.客户编号, ''''),
    ISNULL(U.客户简称, ''''),
    ISNULL(U.客户全称, ''''),
    ISNULL(SI.销售部门, ''''),
    ISNULL(SI.业务员, ''''),

    ISNULL(S.库存数量, 0),
    ISNULL(O.在途数量, 0),
    ISNULL(A.分配数量, 0),

    ISNULL(U.过去第1月使用量, 0),
    ISNULL(U.过去第2月使用量, 0),
    ISNULL(U.过去第3月使用量, 0),
    ISNULL(U.过去第4月使用量, 0),
    ISNULL(U.过去第5月使用量, 0),
    ISNULL(U.过去第6月使用量, 0),
    ISNULL(U.过去第7月使用量, 0),
    ISNULL(U.过去第8月使用量, 0),
    ISNULL(U.过去第9月使用量, 0),
    ISNULL(U.过去第10月使用量, 0),
    ISNULL(U.过去第11月使用量, 0),
    ISNULL(U.过去第12月使用量, 0)

ORDER BY
    I.品号 ASC,
    ISNULL(U.客户简称, '''');
';

EXEC sp_executesql @SQL;