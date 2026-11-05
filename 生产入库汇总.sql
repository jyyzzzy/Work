SET NOCOUNT ON;

DECLARE @StartDate CHAR(8) = '20260901',
        @EndDate   CHAR(8) = '20260930';

DECLARE @StartMonth CHAR(6) = LEFT(@StartDate, 6),
        @NextMonth CHAR(6) = CONVERT(CHAR(6),
            DATEADD(MONTH, 1, CONVERT(DATE, @EndDate, 112)), 112);

DROP TABLE IF EXISTS #Base, #PriceKeys, #Price, #Cost, #Rate;

-- 1. 生产入库明细
SELECT G.TG001, G.TG002, G.TG003, G.TG004, G.TG005,
       G.TG006, G.TG007, G.TG010, G.TG013, G.TG014, G.TG015,
       F.TF003, F.TF011, LEFT(F.TF003, 6) AS MonthNo,
       RTRIM(G.TG001) + '-' + RTRIM(G.TG002) + '-' + RTRIM(G.TG003) AS DocKey
INTO #Base
FROM SDRD.dbo.MOCTF F
JOIN SDRD.dbo.MOCTG G ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
WHERE F.TF003 BETWEEN @StartDate AND @EndDate
  AND F.TF006 = 'Y'
  AND G.TG022 = 'Y'
  AND G.TG001 LIKE '58%'
  AND G.TG014 LIKE '5101%'
  AND (G.TG004 LIKE '1%' OR G.TG004 LIKE 'A%');

-- 2. 客户商品价格匹配条件
SELECT DISTINCT O.TC004 AS CustomerNo, B.TG004 AS ItemNo,
       B.TF003 AS ProdDate,
       ISNULL(NULLIF(RTRIM(O.TC008), ''), 'RMB') AS CurrencyNo
INTO #PriceKeys
FROM #Base B
JOIN SDRD.dbo.MOCTA A ON B.TG014 = A.TA001 AND B.TG015 = A.TA002
JOIN SDRD.dbo.COPTC O ON A.TA026 = O.TC001 AND A.TA027 = O.TC002
WHERE O.TC004 IS NOT NULL AND O.TC004 <> '';

-- 3. 系统定价：生产当日有效客户商品价格
SELECT CustomerNo, ItemNo, ProdDate, CurrencyNo, Price
INTO #Price
FROM (
    SELECT K.*, Q.MB008 AS Price,
           ROW_NUMBER() OVER (
               PARTITION BY K.CustomerNo, K.ItemNo, K.ProdDate, K.CurrencyNo
               ORDER BY Q.MB017 DESC, Q.MB018 DESC, Q.MB008 DESC
           ) AS RN
    FROM #PriceKeys K
    JOIN SDRD.dbo.COPMB Q
      ON Q.MB001 = K.CustomerNo AND Q.MB002 = K.ItemNo
     AND Q.MB004 = K.CurrencyNo
     AND Q.MB017 IS NOT NULL AND Q.MB017 <> ''
     AND Q.MB017 <= K.ProdDate
     AND (Q.MB018 IS NULL OR Q.MB018 = '' OR Q.MB018 >= K.ProdDate)
) X
WHERE RN = 1;

-- 4. 实际材料成本：最近交易记录
SELECT LA001, LA006, LA007, LA008, LA017
INTO #Cost
FROM (
    SELECT L.LA001, L.LA006, L.LA007, L.LA008, L.LA017,
           ROW_NUMBER() OVER (
               PARTITION BY L.LA006, L.LA007, L.LA008, L.LA001
               ORDER BY L.LA004 DESC
           ) AS RN
    FROM SDRD.dbo.INVLA L
    JOIN #Base B ON L.LA001 = B.TG004 AND L.LA006 = B.TG001
                AND L.LA007 = B.TG002 AND L.LA008 = B.TG003
    WHERE L.LA006 LIKE '58%'
) X
WHERE RN = 1;

-- 5. 月份汇率
SELECT MG001, MonthNo, MG003
INTO #Rate
FROM (
    SELECT R.MG001, LEFT(R.MG002, 6) AS MonthNo, R.MG003,
           ROW_NUMBER() OVER (
               PARTITION BY R.MG001, LEFT(R.MG002, 6)
               ORDER BY R.MG002
           ) AS RN
    FROM SDRD.dbo.CMSMG R
    WHERE R.MG002 >= @StartMonth AND R.MG002 < @NextMonth
) X
WHERE RN = 1;

-- 6. 最终产值报表
SELECT
    'SDRD' AS [公司别],
    RTRIM(B.TG001) AS [入库单别],
    RTRIM(B.TG002) AS [入库单号],
    RTRIM(B.TG003) AS [入库序号],
    B.TF003 AS [入库日期],
    B.DocKey AS [入库单别-单号-序号],
    B.TG004 AS [产品品号],
    B.TG005 AS [品名],
    B.TG006 AS [规格],
    CM.MA002 AS [客户],
    CASE WHEN CM.MA002 IS NULL THEN NULL
         ELSE RTRIM(CM.MA002) + '+' + ISNULL(RTRIM(C3.MA003), '')
    END AS [客户+类别],
    B.TG007 AS [单位],
    CU.CurrencyNo AS [币种],
    CASE WHEN CU.CurrencyNo = 'RMB' THEN 1
         ELSE ISNULL(R.MG003, 1) END AS [汇率],
    B.TG013 AS [验收数量],
    PR.Price AS [单价],
    V.产值 AS [产值],
    T.不含税产值 AS [不含税产值],
    ISNULL(MB.MB057, 0) AS [单位标准材料成本],
    ISNULL(MB.MB050, 0) AS [最近进价成本],
    B.TF011 AS [工作中心],
    D.MD002 AS [工作中心名称],
    CASE WHEN D.MD011 IS NULL THEN '顺德瑞德'
         ELSE LEFT(D.MD011, CHARINDEX('-', D.MD011 + '-') - 1)
    END AS [事业部],
    B.TG010 AS [仓库],
    B.TG014 AS [工单单别],
    B.TG015 AS [工单单号],
    A.TA026 AS [订单单别],
    A.TA027 AS [订单单号],
    CASE WHEN ISNULL(A.TA026, '') = '' OR ISNULL(A.TA027, '') = ''
         THEN NULL
         ELSE RTRIM(A.TA026) + '-' + RTRIM(A.TA027)
    END AS [客户订单],
    A.TA028 AS [订单序号],
    O.TC004 AS [客户编码],
    CM.MA002 AS [客户],
    MB.MB008 AS [品号分类四],
    C4.MA003 AS [品号类别名称],
    C3.MA003 AS [商品类别],
    PR.PriceSource AS [备注],
    ISNULL(MB.MB096, 0) AS [工时底数],
    CAST(ISNULL(MB.MB096, 0) * 100.0 / 3600 * B.TG013
         AS DECIMAL(24, 10)) AS [定额工时],
    U.UnitMaterial AS [单位材料],
    ISNULL(L.LA017, 0) AS [材料成本],
    CASE WHEN ISNULL(T.不含税产值, 0) = 0 THEN '0.00%'
         ELSE CONCAT(CAST(ISNULL(L.LA017, 0) * 100.0 /
                     NULLIF(T.不含税产值, 0) AS DECIMAL(15, 2)), '%')
    END AS [材料占比],
    U.UnitMaterial AS [原单位材料],
    CAST('' AS VARCHAR(50)) AS [材料剔除],
    CASE WHEN O.TC008 = 'USD' OR CM.MA001 = '10000059'
         THEN 'Y' ELSE 'N' END AS [外销]

FROM #Base B
LEFT JOIN SDRD.dbo.MOCTA A ON B.TG014 = A.TA001 AND B.TG015 = A.TA002
LEFT JOIN SDRD.dbo.COPTC O ON A.TA026 = O.TC001 AND A.TA027 = O.TC002
LEFT JOIN SDRD.dbo.COPTD OD ON OD.TD001 = A.TA026 AND OD.TD002 = A.TA027
                            AND OD.TD003 = A.TA028 AND OD.TD004 = B.TG004
LEFT JOIN SDRD.dbo.COPMA CM ON O.TC004 = CM.MA001
LEFT JOIN SDRD.dbo.INVMB MB ON B.TG004 = MB.MB001
LEFT JOIN SDRD.dbo.INVMA C4 ON MB.MB008 = C4.MA002
LEFT JOIN SDRD.dbo.INVMA C3 ON MB.MB007 = C3.MA002
LEFT JOIN SDRD.dbo.CMSMD D ON B.TF011 = D.MD001

CROSS APPLY (
    SELECT ISNULL(NULLIF(RTRIM(O.TC008), ''), 'RMB') AS CurrencyNo
) CU

LEFT JOIN #Price P ON P.CustomerNo = O.TC004 AND P.ItemNo = B.TG004
                  AND P.ProdDate = B.TF003 AND P.CurrencyNo = CU.CurrencyNo

LEFT JOIN #Cost L ON B.TG004 = L.LA001 AND B.TG001 = L.LA006
                 AND B.TG002 = L.LA007 AND B.TG003 = L.LA008

LEFT JOIN #Rate R ON R.MG001 = CU.CurrencyNo AND R.MonthNo = B.MonthNo

-- 第四优先级：系统套件拆分
OUTER APPLY (
    SELECT TOP (1)
        CAST(
            CAST(COALESCE(PP.MB008, PO.TD011) AS DECIMAL(20, 8))
            * CAST(MB.MB057 AS DECIMAL(20, 8))
            / NULLIF(BC.TotalMaterialCost, 0)
            AS DECIMAL(24, 8)
        ) AS KitPrice
    FROM SDRD.dbo.BOMMD K

    CROSS APPLY (
        SELECT SUM(
            CAST(ISNULL(MI.MB057, 0) AS DECIMAL(20, 8))
            * CAST(J.MD006 AS DECIMAL(20, 8))
            / NULLIF(CAST(J.MD007 AS DECIMAL(20, 8)), 0)
        ) AS TotalMaterialCost
        FROM SDRD.dbo.BOMMD J
        LEFT JOIN SDRD.dbo.INVMB MI ON J.MD003 = MI.MB001
        WHERE J.MD001 = K.MD001
          AND ISNULL(J.MD007, 0) <> 0
          AND (J.MD011 IS NULL OR J.MD011 = '' OR J.MD011 <= B.TF003)
          AND (J.MD012 IS NULL OR J.MD012 = '' OR J.MD012 >= B.TF003)
          AND (J.MD001 NOT LIKE '4%' OR J.MD013 = 'Y')
    ) BC

    OUTER APPLY (
        SELECT TOP (1) Q.MB008, Q.MB017
        FROM SDRD.dbo.COPMB Q
        WHERE Q.MB001 = O.TC004 AND Q.MB002 = K.MD001
          AND Q.MB004 = CU.CurrencyNo
          AND Q.MB017 IS NOT NULL AND Q.MB017 <> ''
          AND Q.MB017 <= B.TF003
          AND (Q.MB018 IS NULL OR Q.MB018 = '' OR Q.MB018 >= B.TF003)
        ORDER BY Q.MB017 DESC, Q.MB018 DESC, Q.MB008 DESC
    ) PP

    OUTER APPLY (
        SELECT TOP (1) TD011
        FROM SDRD.dbo.COPTD
        WHERE TD001 = A.TA026 AND TD002 = A.TA027
          AND TD004 = K.MD001
        ORDER BY TD003
    ) PO

    WHERE K.MD003 = B.TG004
      AND ISNULL(K.MD007, 0) <> 0
      AND (K.MD011 IS NULL OR K.MD011 = '' OR K.MD011 <= B.TF003)
      AND (K.MD012 IS NULL OR K.MD012 = '' OR K.MD012 >= B.TF003)
      AND (K.MD001 NOT LIKE '4%' OR K.MD013 = 'Y')
      AND P.Price IS NULL
      AND OD.TD011 IS NULL
      AND (L.LA017 IS NULL OR L.LA017 <= 0 OR B.TG013 <= 0)
      AND MB.MB057 > 0
      AND BC.TotalMaterialCost > 0
      AND COALESCE(PP.MB008, PO.TD011) IS NOT NULL
    ORDER BY CASE WHEN PO.TD011 IS NOT NULL THEN 0 ELSE 1 END,
             PP.MB017 DESC, K.MD001
) KIT

-- 税率系数
CROSS APPLY (
    SELECT CAST(
        CASE WHEN O.TC008 = 'USD' OR CM.MA001 = '10000059'
                   OR O.TC016 IN ('3', '4', '9')
             THEN 1.0
             ELSE 1.0 + ISNULL(CAST(O.TC041 AS DECIMAL(18, 6)), 0.13)
        END AS DECIMAL(18, 6)
    ) AS TaxFactor
) TX

-- 四级取价
CROSS APPLY (
    SELECT
        CAST(
            CASE WHEN P.Price IS NOT NULL THEN P.Price
                 WHEN OD.TD011 IS NOT NULL THEN OD.TD011
                 WHEN L.LA017 > 0 AND B.TG013 > 0
                      THEN CAST(L.LA017 AS DECIMAL(24, 6))
                           / NULLIF(CAST(B.TG013 AS DECIMAL(24, 6)), 0)
                           / 0.6 * TX.TaxFactor
                 WHEN KIT.KitPrice IS NOT NULL THEN KIT.KitPrice
                 ELSE 0
            END AS DECIMAL(24, 8)
        ) AS Price,
        CASE WHEN P.Price IS NOT NULL THEN '系统定价'
             WHEN OD.TD011 IS NOT NULL THEN '订单估价'
             WHEN L.LA017 > 0 AND B.TG013 > 0 THEN '按材料占比'
             WHEN KIT.KitPrice IS NOT NULL THEN '系统套件拆分'
             ELSE ''
        END AS PriceSource
) PR

CROSS APPLY (
    SELECT CAST(B.TG013 * PR.Price AS DECIMAL(24, 4)) AS 产值
) V

CROSS APPLY (
    SELECT CAST(V.产值 / NULLIF(TX.TaxFactor, 0)
                AS DECIMAL(24, 4)) AS 不含税产值
) T

CROSS APPLY (
    SELECT ISNULL(CAST(ISNULL(L.LA017, 0) / NULLIF(B.TG013, 0)
                       AS DECIMAL(24, 9)), 0) AS UnitMaterial
) U

ORDER BY B.TF003, B.TG001, B.TG002, B.TG003;

DROP TABLE IF EXISTS #Base, #PriceKeys, #Price, #Cost, #Rate;