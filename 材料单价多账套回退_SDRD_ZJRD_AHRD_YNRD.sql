DECLARE @Today CHAR(8) = CONVERT(CHAR(8), GETDATE(), 112);
DECLARE @YM    CHAR(6) = '202510';

IF OBJECT_ID('tempdb..#BCPXJ_BASE') IS NOT NULL DROP TABLE #BCPXJ_BASE;
IF OBJECT_ID('tempdb..#PURMB_SRC') IS NOT NULL DROP TABLE #PURMB_SRC;
IF OBJECT_ID('tempdb..#PUR_YX') IS NOT NULL DROP TABLE #PUR_YX;
IF OBJECT_ID('tempdb..#PUR_WX') IS NOT NULL DROP TABLE #PUR_WX;
IF OBJECT_ID('tempdb..#PUR_WX2') IS NOT NULL DROP TABLE #PUR_WX2;
IF OBJECT_ID('tempdb..#COPMB_SRC') IS NOT NULL DROP TABLE #COPMB_SRC;
IF OBJECT_ID('tempdb..#COP_ACTIVE') IS NOT NULL DROP TABLE #COP_ACTIVE;
IF OBJECT_ID('tempdb..#COP_INACTIVE') IS NOT NULL DROP TABLE #COP_INACTIVE;
IF OBJECT_ID('tempdb..#SALES_PRICE') IS NOT NULL DROP TABLE #SALES_PRICE;
IF OBJECT_ID('tempdb..#DELIVERY_PRICE') IS NOT NULL DROP TABLE #DELIVERY_PRICE;

------------------------------------------------------------
-- 1. 先把主表中要反复 TRIM 的字段清洗一次
------------------------------------------------------------
SELECT
    TRIM(MB01)     AS 产品品号,
    TRIM(MD01)     AS 元件品号,
    TRIM(材料品号) AS 材料品号,
    材料品名,
    材料规格,
    物料用量
INTO #BCPXJ_BASE
FROM #BCPXJ;

------------------------------------------------------------
-- 2. PURMB 来源一次性落地（SDRD -> ZJRD -> AHRD -> YNRD）
------------------------------------------------------------
SELECT
    P.MB001,
    P.MB002,
    M.MA002,
    P.MB003,
    P.MB004,
    CAST(P.MB011 AS DECIMAL(18,6)) AS MB011,
    P.MB014,
    P.MB015,
    1 AS DBPriority,
    'SDRD' AS DBName
INTO #PURMB_SRC
FROM SDRD.dbo.PURMB AS P
JOIN SDRD.dbo.PURMA AS M
    ON M.MA001 = P.MB002

UNION ALL

SELECT
    P.MB001,
    P.MB002,
    M.MA002,
    P.MB003,
    P.MB004,
    CAST(P.MB011 AS DECIMAL(18,6)) AS MB011,
    P.MB014,
    P.MB015,
    2 AS DBPriority,
    'ZJRD' AS DBName
FROM ZJRD.dbo.PURMB AS P
JOIN ZJRD.dbo.PURMA AS M
    ON M.MA001 = P.MB002

UNION ALL

SELECT
    P.MB001,
    P.MB002,
    M.MA002,
    P.MB003,
    P.MB004,
    CAST(P.MB011 AS DECIMAL(18,6)) AS MB011,
    P.MB014,
    P.MB015,
    3 AS DBPriority,
    'AHRD' AS DBName
FROM AHRD.dbo.PURMB AS P
JOIN AHRD.dbo.PURMA AS M
    ON M.MA001 = P.MB002

UNION ALL

SELECT
    P.MB001,
    P.MB002,
    M.MA002,
    P.MB003,
    P.MB004,
    CAST(P.MB011 AS DECIMAL(18,6)) AS MB011,
    P.MB014,
    P.MB015,
    4 AS DBPriority,
    'YNRD' AS DBName
FROM YNRD.dbo.PURMB AS P
JOIN YNRD.dbo.PURMA AS M
    ON M.MA001 = P.MB002;

------------------------------------------------------------
-- 3. 最新有效采购价
-- 规则：先按账套优先级回退，再按你原来的价格/日期规则取1条
------------------------------------------------------------
SELECT
    MB001, MB002, MA002, MB003, MB004, MB011, MB014, MB015, DBName
INTO #PUR_YX
FROM (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY MB001
            ORDER BY DBPriority, MB011, MB015 DESC, MB014
        ) AS RN,
        MB001, MB002, MA002, MB003, MB004, MB011, MB014, MB015, DBName
    FROM #PURMB_SRC
    WHERE MB015 = '' OR MB015 >= @Today
) AS X
WHERE RN = 1;

------------------------------------------------------------
-- 4. 最新失效采购价
-- 规则：先按账套优先级回退，再取该账套内最近失效记录
------------------------------------------------------------
SELECT
    MB001, MB002, MA002, MB003, MB004, MB011, MB014, MB015, DBName
INTO #PUR_WX
FROM (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY MB001
            ORDER BY DBPriority, MB015 DESC, MB011, MB014
        ) AS RN,
        MB001, MB002, MA002, MB003, MB004, MB011, MB014, MB015, DBName
    FROM #PURMB_SRC
    WHERE MB015 <> ''
      AND MB015 < @Today
) AS X
WHERE RN = 1;

------------------------------------------------------------
-- 5. 202510 对应采购价
-- 规则：先按账套优先级回退，再按你原来的日期规则取1条
------------------------------------------------------------
SELECT
    MB001, MB002, MA002, MB003, MB004, MB011, MB014, MB015, DBName
INTO #PUR_WX2
FROM (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY MB001
            ORDER BY DBPriority, MB015 DESC, MB011, MB014
        ) AS RN,
        MB001, MB002, MA002, MB003, MB004, MB011, MB014, MB015, DBName
    FROM #PURMB_SRC
    WHERE LEFT(ISNULL(MB015,''), 6) <= @YM
       OR (
            LEFT(ISNULL(MB014,''), 6) <= @YM
        AND LEFT(ISNULL(MB015,''), 6) >= @YM
       )
) AS X
WHERE RN = 1;

------------------------------------------------------------
-- 6. COPMB 来源一次性落地
------------------------------------------------------------
SELECT
    MB001,
    MB002,
    MB003,
    MB004,
    CAST(MB008 AS DECIMAL(18,6)) AS MB008,
    MB017,
    MB018
INTO #COPMB_SRC
FROM COPMB;

------------------------------------------------------------
-- 7. 最新有效销售底价
------------------------------------------------------------
SELECT
    MB001, MB002, MB003, MB004, MB008, MB017, MB018
INTO #COP_ACTIVE
FROM (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY MB002
            ORDER BY MB008, MB018 DESC, MB017
        ) AS RN,
        MB001, MB002, MB003, MB004, MB008, MB017, MB018
    FROM #COPMB_SRC
    WHERE MB018 = '' OR MB018 >= @Today
) AS X
WHERE RN = 1;

------------------------------------------------------------
-- 8. 最新失效销售底价
------------------------------------------------------------
SELECT
    MB001, MB002, MB003, MB004, MB008, MB017, MB018
INTO #COP_INACTIVE
FROM (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY MB002
            ORDER BY MB018 DESC, MB017
        ) AS RN,
        MB001, MB002, MB003, MB004, MB008, MB017, MB018
    FROM #COPMB_SRC
    WHERE MB018 <> ''
      AND MB018 < @Today
) AS X
WHERE RN = 1;

------------------------------------------------------------
-- 9. 客户订单最近单价
------------------------------------------------------------
SELECT
    TD004,
    CAST(TD011 AS DECIMAL(18,6)) AS TD011
INTO #SALES_PRICE
FROM (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY TD004
            ORDER BY IIF(MQ002 = N'客户订单',1,2), TC003
        ) AS RN,
        COPTD.TD004,
        COPTD.TD011
    FROM COPTD
    JOIN COPTC
        ON TC001 = TD001
       AND TC002 = TD002
    JOIN CMSMQ
        ON TD001 = MQ001
    WHERE -- MQ002 = N'客户订单'
          TC027 = 'Y'
) AS X
WHERE RN = 1;

------------------------------------------------------------
-- 10. 订单出货最近单价
------------------------------------------------------------
SELECT
    TH004,
    CAST(TH012 AS DECIMAL(18,6)) AS TH012
INTO #DELIVERY_PRICE
FROM (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY TH004
            ORDER BY IIF(MQ002 = N'订单出货',1,2), TG003 DESC
        ) AS RN,
        COPTH.TH004,
        COPTH.TH012
    FROM COPTH
    JOIN COPTG
        ON TG001 = TH001
       AND TG002 = TH002
    JOIN CMSMQ
        ON TH001 = MQ001
    WHERE -- MQ002 = N'订单出货'
          TG023 = 'Y'
) AS X
WHERE RN = 1;

------------------------------------------------------------
-- 11. 最终查询
------------------------------------------------------------
SELECT
    A.产品品号,
    B.MB002 AS 产品名称,
    B.MB003 AS 产品规格,
    B.MB109 AS 产品关闭,
    CAST(
        ISNULL(CA.MB008,
            ISNULL(CI.MB008,
                ISNULL(SP.TD011, DP.TH012)
            )
        ) AS DECIMAL(15,6)
    ) AS 销售价格,
    A.元件品号,
    C.MB002 AS 元件名称,
    C.MB003 AS 元件规格,
    C.MB109 AS 元件关闭,
    A.材料品号,
    A.材料品名,
    A.材料规格,
    CAST(A.物料用量 AS DECIMAL(38,8)) AS 物料用量,
    D.MB109 AS 材料关闭,
    CAST(D.MB433 AS DECIMAL(18,6)) AS 拼板数,
    MD.MD019 AS 插件位置,
    MW.MW002 AS 工艺,
    ISNULL(YX.MB002, WX.MB002) AS 最新单价供应商编号,
    ISNULL(YX.MA002, WX.MA002) AS 最新单价供应商名称,
    ISNULL(YX.MB003, WX.MB003) AS 最新单价币种,
    ISNULL(YX.MB011, WX.MB011) AS 最新单价,
    ISNULL(YX.MB014, WX.MB014) AS 最新单价有效期开始,
    ISNULL(YX.MB015, WX.MB015) AS 最新单价有效期结束,
    WX2.MB002 AS [202510单价供应商编号],
    WX2.MA002 AS [202510单价供应商名称],
    WX2.MB003 AS [202510单价币种],
    WX2.MB011 AS [202510单价],
    WX2.MB014 AS [202510单价有效期开始],
    WX2.MB015 AS [202510单价有效期结束],
    ISNULL(YX.MB011, WX.MB011) - WX2.MB011 AS 材料价差
FROM #BCPXJ_BASE AS A
JOIN SDRD..INVMB AS B
    ON A.产品品号 = B.MB001
JOIN INVMB AS C
    ON A.元件品号 = C.MB001
JOIN INVMB AS D
    ON A.材料品号 = D.MB001
JOIN BOMMD AS MD
    ON A.元件品号 = MD.MD001
   AND MD.MD002 = MD.MD002
   AND A.材料品号 = MD.MD003
LEFT JOIN CMSMW AS MW
    ON MD.MD009 = MW.MW001
LEFT JOIN #PUR_YX AS YX
    ON A.材料品号 = YX.MB001
LEFT JOIN #PUR_WX AS WX
    ON A.材料品号 = WX.MB001
LEFT JOIN #PUR_WX2 AS WX2
    ON A.材料品号 = WX2.MB001
LEFT JOIN #COP_ACTIVE AS CA
    ON A.产品品号 = CA.MB002
LEFT JOIN #COP_INACTIVE AS CI
    ON A.产品品号 = CI.MB002
LEFT JOIN #SALES_PRICE AS SP
    ON A.产品品号 = SP.TD004
LEFT JOIN #DELIVERY_PRICE AS DP
    ON A.产品品号 = DP.TH004
ORDER BY A.产品品号, A.元件品号, A.材料品号;
