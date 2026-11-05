USE [SDRD]
GO

/****** 对象:  View [dbo].[vw_ProdOutputReport]    脚本日期: 2026/10/16 14:48:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vw_ProdOutputReport]
AS
WITH CTE_Base AS (
    --1.生产入库明细
    SELECT 
        G.TG001, G.TG002, G.TG003, G.TG004, G.TG005,
        G.TG006, G.TG007, G.TG010, G.TG013, G.TG014, G.TG015,
        F.TF003, F.TF011, 
        LEFT(F.TF003, 6) AS MonthNo,
        RTRIM(G.TG001) + '-' + RTRIM(G.TG002) + '-' + RTRIM(G.TG003) AS DocKey
    FROM SDRD.dbo.MOCTF F WITH(NOLOCK)
    JOIN SDRD.dbo.MOCTG G WITH(NOLOCK) 
        ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
    WHERE 
        --日期条件移到视图外部，这里不写日期
        F.TF006 = 'Y'
        AND G.TG022 = 'Y'
        AND G.TG001 LIKE '58%'
        AND G.TG014 LIKE '5101%'
        AND (G.TG004 LIKE '1%' OR G.TG004 LIKE 'A%')
),
CTE_PriceKeys AS (
    --2.客户商品价格匹配条件
    SELECT DISTINCT 
        O.TC004 AS CustomerNo, 
        B.TG004 AS ItemNo,
        B.TF003 AS ProdDate,
        ISNULL(NULLIF(RTRIM(O.TC008), ''), 'RMB') AS CurrencyNo
    FROM CTE_Base B
    JOIN SDRD.dbo.MOCTA A WITH(NOLOCK) 
        ON B.TG014 = A.TA001 AND B.TG015 = A.TA002
    JOIN SDRD.dbo.COPTC O WITH(NOLOCK) 
        ON A.TA026 = O.TC001 AND A.TA027 = O.TC002
    WHERE O.TC004 IS NOT NULL AND O.TC004 <> ''
),
CTE_Price AS (
    --3.系统定价：生产当日有效客户商品价格
    SELECT CustomerNo, ItemNo, ProdDate, CurrencyNo, Price
    FROM (
        SELECT 
            K.*, 
            Q.MB008 AS Price,
            ROW_NUMBER() OVER (
                PARTITION BY K.CustomerNo, K.ItemNo, K.ProdDate, K.CurrencyNo
                ORDER BY Q.MB017 DESC, Q.MB018 DESC, Q.MB008 DESC
            ) AS RN
        FROM CTE_PriceKeys K
        JOIN SDRD.dbo.COPMB Q WITH(NOLOCK)
            ON Q.MB001 = K.CustomerNo 
            AND Q.MB002 = K.ItemNo
            AND Q.MB004 = K.CurrencyNo
            AND Q.MB017 IS NOT NULL AND Q.MB017 <> ''
            AND Q.MB017 <= K.ProdDate
            AND (Q.MB018 IS NULL OR Q.MB018 = '' OR Q.MB018 >= K.ProdDate)
    ) X WHERE RN = 1 AND Price >= 0.01
),
CTE_Cost AS (
    --4.实际材料成本：最近交易记录
    SELECT LA001, LA006, LA007, LA008, LA017
    FROM (
        SELECT 
            L.LA001, L.LA006, L.LA007, L.LA008, L.LA017,
            ROW_NUMBER() OVER (
                PARTITION BY L.LA006, L.LA007, L.LA008, L.LA001
                ORDER BY L.LA004 DESC
            ) AS RN
        FROM SDRD.dbo.INVLA L WITH(NOLOCK)
        JOIN CTE_Base B 
            ON L.LA001 = B.TG004 
            AND L.LA006 = B.TG001
            AND L.LA007 = B.TG002 
            AND L.LA008 = B.TG003
        WHERE L.LA006 LIKE '58%'
    ) X WHERE RN =1
),
CTE_Rate AS (
    --5.月份汇率
    SELECT MG001, MonthNo, MG003
    FROM (
        SELECT 
            R.MG001, 
            LEFT(R.MG002, 6) AS MonthNo, 
            R.MG003,
            ROW_NUMBER() OVER (
                PARTITION BY R.MG001, LEFT(R.MG002, 6)
                ORDER BY R.MG002
            ) AS RN
        FROM SDRD.dbo.CMSMG R WITH(NOLOCK)
    ) X WHERE RN =1
)
--6.最终产值报表
SELECT
    'SDRD' AS [基地/公司别],
    RTRIM(B.TG001) AS [入库单别],
    RTRIM(B.TG002) AS [入库单号],
    RTRIM(B.TG003) AS [入库序号],
    B.TF003 AS [入库日期],
    B.DocKey AS [入库单别-单号-序号],
    B.TG004 AS [产品品号],
    B.TG005 AS [品名],
    B.TG006 AS [规格],
    O.TC004 AS [客户编码],
    CM.MA002 AS [客户],
    CASE WHEN CM.MA002 IS NULL THEN NULL ELSE RTRIM(CM.MA002) + '+' + ISNULL(RTRIM(C3.MA003), '') END AS [客户+类别],
    B.TG007 AS [单位],
    CU.CurrencyNo AS [币种],
    CAST(O.TC009 AS FLOAT) AS [汇率],
    CAST(B.TG013 AS FLOAT) AS [验收数量],
    PR.Price   AS [单价],
    CAST(V.产值/CTE_Rate2.MG003 AS FLOAT) AS [产值],
    CAST(T.不含税产值/CTE_Rate2.MG003 AS FLOAT) AS [不含税产值],
    CAST(ISNULL(MB.MB057, 0)/CTE_Rate2.MG003 AS FLOAT) AS [单位标准材料成本],
    B.TF011 AS [工作中心],
    D.MD002 AS [工作中心名称],
    CASE WHEN D.MD011 IS NULL THEN '顺德瑞德'  ELSE LEFT(D.MD011, CHARINDEX('-', D.MD011 + '-') - 1)  END AS [事业部],
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
    MB.MB008 AS [品号分类四],
    C4.MA003 AS [品号类别名称],
    C3.MA003 AS [商品类别],
    PR.PriceSource AS [备注],
    ISNULL(MB.MB096, 0) AS [工时底数],
    CAST(ISNULL(MB.MB096, 0) * 100.0 / 3600 * B.TG013 AS DECIMAL(24, 10)) AS [定额工时],
     CAST(U.UnitMaterial/CTE_Rate2.MG003 AS FLOAT)AS [单位材料],
     CAST(ISNULL(L.LA017, 0)/CTE_Rate2.MG003 AS FLOAT)AS [材料成本],
     CASE WHEN ISNULL(T.不含税产值, 0) = 0 THEN '0.00%' ELSE CONCAT(CAST(ISNULL(L.LA017, 0) * 100.0 / NULLIF(T.不含税产值, 0) AS DECIMAL(15, 2)), '%') END AS [材料占比],
    0 AS [材料剔除],
    CASE WHEN O.TC008 = 'USD' OR CM.MA001 = '10000059'  THEN 'Y' ELSE 'N' END AS [外销]      
FROM CTE_Base B
LEFT JOIN SDRD.dbo.MOCTA A WITH(NOLOCK) 
    ON B.TG014 = A.TA001 AND B.TG015 = A.TA002
LEFT JOIN SDRD.dbo.COPTC O WITH(NOLOCK) 
    ON A.TA026 = O.TC001 AND A.TA027 = O.TC002
LEFT JOIN SDRD.dbo.COPTD OD WITH(NOLOCK) 
    ON OD.TD001 = A.TA026 AND OD.TD002 = A.TA027
    AND OD.TD003 = A.TA028 AND OD.TD004 = B.TG004
LEFT JOIN SDRD.dbo.COPMA CM WITH(NOLOCK) 
    ON O.TC004 = CM.MA001
LEFT JOIN SDRD.dbo.INVMB MB WITH(NOLOCK) 
    ON B.TG004 = MB.MB001
LEFT JOIN SDRD.dbo.INVMA C4 WITH(NOLOCK) 
    ON MB.MB008 = C4.MA002
LEFT JOIN SDRD.dbo.INVMA C3 WITH(NOLOCK) 
    ON MB.MB007 = C3.MA002
LEFT JOIN SDRD.dbo.CMSMD D WITH(NOLOCK) 
    ON B.TF011 = D.MD001

CROSS APPLY (
    SELECT ISNULL(NULLIF(RTRIM(O.TC008), ''), 'RMB') AS CurrencyNo
) CU

LEFT JOIN CTE_Price P 
    ON P.CustomerNo = O.TC004 AND P.ItemNo = B.TG004
    AND P.ProdDate = B.TF003 AND P.CurrencyNo = CU.CurrencyNo

LEFT JOIN CTE_Cost L 
    ON B.TG004 = L.LA001 AND B.TG001 = L.LA006
    AND B.TG002 = L.LA007 AND B.TG003 = L.LA008

LEFT JOIN CTE_Rate R 
    ON R.MG001 = CU.CurrencyNo AND R.MonthNo = B.MonthNo

--第三优先级：从 LSSJ 已计算的月度 BOM 价格表取价，代替实时拆分
OUTER APPLY (
    SELECT TOP (1) BP.UnitPrice AS KitPrice
    FROM LSSJ.dbo.BOM_MONTH_PRICE BP
    WHERE BP.CompanyNo = 'SDRD'
      AND BP.PriceMonth = B.MonthNo
      AND BP.CustomerNo = RTRIM(O.TC004)
      AND BP.CurrencyNo = CU.CurrencyNo
      AND BP.ItemNo = RTRIM(B.TG004)
      AND BP.LevelNo > 0
      AND BP.UnitPrice > 0
      AND (OD.TD011 IS NULL OR OD.TD011 < 0.01)
      AND P.Price IS NULL
    ORDER BY
        CASE WHEN EXISTS (
            SELECT 1 FROM SDRD.dbo.COPTD OD2 WITH(NOLOCK)
            WHERE OD2.TD001 = A.TA026
              AND OD2.TD002 = A.TA027
              AND OD2.TD004 = BP.RootItemNo
        ) THEN 0 ELSE 1 END,
        BP.LevelNo, BP.RootItemNo, BP.TreePath
) KIT

--税率系数
CROSS APPLY (
    SELECT CAST(
        CASE WHEN O.TC008 = 'USD' OR CM.MA001 = '10000059' OR O.TC016 IN ('3', '4', '9')
             THEN 1.0 ELSE 1.0 + ISNULL(CAST(O.TC041 AS DECIMAL(18, 6)), 0.13)
        END AS DECIMAL(18, 6)
    ) AS TaxFactor
) TX

--四级取价（订单/系统价低于0.01视为无效）
CROSS APPLY (
    SELECT
        CAST(
            CASE 
                 WHEN OD.TD011 >= 0.01 THEN OD.TD011
                 WHEN P.Price >= 0.01 THEN P.Price
                 WHEN KIT.KitPrice IS NOT NULL THEN KIT.KitPrice
                 WHEN L.LA017 > 0 AND B.TG013 > 0 THEN CAST(L.LA017 AS DECIMAL(24, 6))/ NULLIF(CAST(B.TG013 AS DECIMAL(24, 6)), 0) / 0.6 * TX.TaxFactor
                 ELSE 0
            END AS DECIMAL(24, 8)
        ) AS Price,
         CAST(
            CASE 
                 WHEN OD.TD011 >= 0.01 THEN OD.TD011*O.TC009
                 WHEN P.Price >= 0.01 THEN P.Price*O.TC009
                 WHEN KIT.KitPrice IS NOT NULL THEN KIT.KitPrice*O.TC009
                 WHEN L.LA017 > 0 AND B.TG013 > 0 THEN CAST(L.LA017 AS DECIMAL(24, 6))/ NULLIF(CAST(B.TG013 AS DECIMAL(24, 6)), 0) / 0.6 * TX.TaxFactor
                 ELSE 0
            END AS DECIMAL(24, 8)
        ) AS RMBPrice,
        CASE 
             WHEN OD.TD011 >= 0.01 THEN '订单价格'
             WHEN P.Price >= 0.01 THEN '系统定价'
             WHEN KIT.KitPrice IS NOT NULL THEN '系统套件拆分'
             WHEN L.LA017 > 0 AND B.TG013 > 0 THEN '按60%材料折算'
             ELSE ''
        END AS PriceSource
) PR

CROSS APPLY (
    SELECT CAST(B.TG013 * PR.RMBPrice AS DECIMAL(24, 4)) AS 产值
) V

CROSS APPLY (
    SELECT CAST(V.产值 / NULLIF(TX.TaxFactor, 0)
                AS DECIMAL(24, 4)) AS 不含税产值
) T

CROSS APPLY (
    SELECT ISNULL(CAST(ISNULL(L.LA017, 0) / NULLIF(B.TG013, 0)
                       AS DECIMAL(24, 9)), 0) AS UnitMaterial
) U
CROSS APPLY (
  SELECT MG001, MonthNo, MG003
    FROM (
        SELECT 
            R.MG001, 
            LEFT(R.MG002, 6) AS MonthNo, 
            R.MG003,
            ROW_NUMBER() OVER (
                PARTITION BY R.MG001 
                ORDER BY R.MG002
            ) AS RN
        FROM SDRD.dbo.CMSMG R WITH(NOLOCK) where MG001='RMB'
    ) X WHERE RN =1
)CTE_Rate2
GO


