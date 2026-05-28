SELECT TOP (1000) [custNo]
      ,[custShortName]
      ,[custFullName]
      ,[salesRepNo]
      ,[salesRepName]
      ,[deptNo]
      ,[deptName]
  FROM [LSSJ].[dbo].[CustomerBasic]

DELETE FROM LSSJ..CustomerBasic
DELETE FROM LSSJ..ITEMTMP
--="INSERT INTO LSSJ..ITEMTMP(ITEMNO) VALUES('"&&"');"
SELECT * FROM LSSJ..ITEMTMP
SELECT DISTINCT MA001,MA002,MA003 FROM LSSJ..CustomerBasic C 
INNER JOIN (
    SELECT *  FROM SDRD..COPMA
    UNION ALL
    SELECT * FROM ZJRD..COPMA
    UNION ALL
    SELECT * FROM AHRD..COPMA
    UNION ALL
    SELECT * FROM YNRD..COPMA

)
COPMA
ON MA002 LIKE '%'+C.custShortName +'%'
ORDER BY MA002


SELECT 
    DISTINCT 
    COP.MA001 客户编号
    ,COP.MA002 客户简称
    , COP.MA003 客户全称
    ,COP.TC003 最新订单日期
    ,COP.TD004 品号
    ,COP.TD005 品名
    ,COP.TD006 规格
    ,COP.COPMPANY 订单公司
INTO #CustomerOrderInfo
FROM LSSJ..CustomerBasic C
INNER JOIN (
    SELECT 'SDRD' COPMPANY,MA001,MA002,MA003,TC003,TD004,TD005,TD006,ROW_NUMBER() OVER (PARTITION BY MA001,TD004 ORDER BY TC003 DESC) RN FROM SDRD..COPMA
    INNER JOIN SDRD..COPTC ON TC004 = MA001
    INNER JOIN SDRD..COPTD ON TC001 = TD001 AND TC002 = TD002
    WHERE TC027 = 'Y' AND TD021 = 'Y'
    UNION ALL
    SELECT 'ZJRD' COPMPANY,MA001,MA002,MA003,TC003,TD004,TD005,TD006,ROW_NUMBER() OVER (PARTITION BY MA001,TD004 ORDER BY TC003 DESC) RN FROM ZJRD..COPMA
    INNER JOIN ZJRD..COPTC ON TC004 = MA001
    INNER JOIN ZJRD..COPTD ON TC001 = TD001 AND TC002 = TD002
    WHERE TC027 = 'Y' AND TD021 = 'Y'
    UNION ALL
    SELECT 'AHRD' COPMPANY,MA001,MA002,MA003,TC003,TD004,TD005,TD006,ROW_NUMBER() OVER (PARTITION BY MA001,TD004 ORDER BY TC003 DESC) RN FROM AHRD..COPMA
    INNER JOIN AHRD..COPTC ON TC004 = MA001
    INNER JOIN AHRD..COPTD ON TC001 = TD001 AND TC002 = TD002
    WHERE TC027 = 'Y' AND TD021 = 'Y'
    UNION ALL
    SELECT 'YNRD' COPMPANY,MA001,MA002,MA003,TC003,TD004,TD005,TD006,ROW_NUMBER() OVER (PARTITION BY MA001,TD004 ORDER BY TC003 DESC) RN FROM YNRD..COPMA
    INNER JOIN YNRD..COPTC ON TC004 = MA001
    INNER JOIN YNRD..COPTD ON TC001 = TD001 AND TC002 = TD002
    WHERE TC027 = 'Y' AND TD021 = 'Y'
) COP ON COP.MA002 LIKE '%'+C.custShortName +'%' AND RN = 1
ORDER BY TD004 
--DROP TABLE #tbMC
SELECT * FROM #CustomerOrderInfo O

="INSERT INTO LSSJ..CustomerOrderInfo(品号) VALUES('"&&"');"

SELECT 品号 MB01 INTO #tbMC
FROM #CustomerOrderInfo
WHERE 品号 IS NOT NULL
SELECT DISTINCT ITEMNO MB01 INTO #tbMC
FROM LSSJ..ITEMTMP
WHERE ITEMNO IS NOT NULL
SELECT 
    B.MB001 AS MB01,
    B.MB001 AS 材料品号,
    B.MB002 AS 材料品名,
    B.MB003 AS 材料规格,
    B.MB050 AS 物料用量
INTO #BCPXJ
FROM SDRD..INVMB B
WHERE 1 = 2;


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
         SDRD..INVMB B
    WHERE MB01 = @CLPH
      AND MD03 = B.MB001
      AND MD07 > 0;

    DELETE FROM #tbMC
    WHERE RTRIM(MB01) = RTRIM(@CLPH);
END;


SELECT 
    TRIM(SI.MB001) AS 产品品号,
    SI.MB002 AS 产品品名,
    SI.MB003 AS 产品规格,
    TRIM(B.材料品号) AS 材料品号,
    B.材料品名,
    B.材料规格,
    ISNULL(PUR.可制单剩余数量,0) AS 在途数量,
    INV.MB064 AS 库存数量,
    INV.COPMPANY AS 公司别,
    R.MB011
FROM #BCPXJ B
INNER JOIN #CustomerOrderInfo O 
    ON RTRIM(O.品号) = RTRIM(B.MB01)
INNER JOIN (
    SELECT 'SDRD' AS COPMPANY, MB001, MB002, MB003, MB064 FROM SDRD..INVMB
    UNION ALL
    SELECT 'ZJRD' AS COPMPANY, MB001, MB002, MB003, MB064 FROM ZJRD..INVMB
    UNION ALL
    SELECT 'AHRD' AS COPMPANY, MB001, MB002, MB003, MB064 FROM AHRD..INVMB
    UNION ALL
    SELECT 'YNRD' AS COPMPANY, MB001, MB002, MB003, MB064 FROM YNRD..INVMB
) INV 
    ON RTRIM(INV.MB001) = RTRIM(B.材料品号)
   AND INV.COPMPANY = O.订单公司
INNER JOIN SDRD..INVMB SI 
    ON RTRIM(SI.MB001) = RTRIM(O.品号)
LEFT JOIN (
    SELECT
        T.COMPANY,
        RTRIM(T.物料编号) AS 物料编号,
        SUM(T.可制单剩余数量) AS 可制单剩余数量
    FROM (
        SELECT 
            'SDRD' AS COMPANY,
            TD004 AS 物料编号,
            TD008 - ISNULL(QTY.QTH007,0) AS 可制单剩余数量
        FROM SDRD..PURTD
        INNER JOIN SDRD..PURTC 
            ON TC001 = TD001 AND TC002 = TD002 
        INNER JOIN SDRD..PURMA 
            ON MA001 = TC004
        LEFT JOIN (
            SELECT 
                TH011 AS QTH011,
                TH012 AS QTH012,
                TH013 AS QTH013,
                SUM(TH007) AS QTH007,
                SUM(TH015) AS QTH015
            FROM SDRD..PURTH 
            WHERE TH030 = 'Y'
            GROUP BY TH011, TH012, TH013
        ) AS QTY 
            ON QTY.QTH011 = TD001 
           AND QTY.QTH012 = TD002 
           AND QTY.QTH013 = TD003
        WHERE TC014 = 'Y'
          AND TD018 = 'Y'
          AND TD016 = 'N'

        UNION ALL

        SELECT 
            'ZJRD' AS COMPANY,
            TD004 AS 物料编号,
            TD008 - ISNULL(QTY.QTH007,0) AS 可制单剩余数量
        FROM ZJRD..PURTD
        INNER JOIN ZJRD..PURTC 
            ON TC001 = TD001 AND TC002 = TD002 
        INNER JOIN ZJRD..PURMA 
            ON MA001 = TC004
        LEFT JOIN (
            SELECT 
                TH011 AS QTH011,
                TH012 AS QTH012,
                TH013 AS QTH013,
                SUM(TH007) AS QTH007,
                SUM(TH015) AS QTH015
            FROM ZJRD..PURTH 
            GROUP BY TH011, TH012, TH013
        ) AS QTY 
            ON QTY.QTH011 = TD001 
           AND QTY.QTH012 = TD002 
           AND QTY.QTH013 = TD003
        WHERE TC014 = 'Y'
          AND TD018 = 'Y'
          AND TD016 = 'N'

        UNION ALL

        SELECT 
            'AHRD' AS COMPANY,
            TD004 AS 物料编号,
            TD008 - ISNULL(QTY.QTH007,0) AS 可制单剩余数量
        FROM AHRD..PURTD
        INNER JOIN AHRD..PURTC 
            ON TC001 = TD001 AND TC002 = TD002 
        INNER JOIN AHRD..PURMA 
            ON MA001 = TC004
        LEFT JOIN (
            SELECT 
                TH011 AS QTH011,
                TH012 AS QTH012,
                TH013 AS QTH013,
                SUM(TH007) AS QTH007,
                SUM(TH015) AS QTH015
            FROM AHRD..PURTH 
            GROUP BY TH011, TH012, TH013
        ) AS QTY 
            ON QTY.QTH011 = TD001 
           AND QTY.QTH012 = TD002 
           AND QTY.QTH013 = TD003
        WHERE TC014 = 'Y'
          AND TD018 = 'Y'
          AND TD016 = 'N'

        UNION ALL

        SELECT 
            'YNRD' AS COMPANY,
            TD004 AS 物料编号,
            TD008 - ISNULL(QTY.QTH007,0) AS 可制单剩余数量
        FROM YNRD..PURTD
        INNER JOIN YNRD..PURTC 
            ON TC001 = TD001 AND TC002 = TD002 
        INNER JOIN YNRD..PURMA 
            ON MA001 = TC004
        LEFT JOIN (
            SELECT 
                TH011 AS QTH011,
                TH012 AS QTH012,
                TH013 AS QTH013,
                SUM(TH007) AS QTH007,
                SUM(TH015) AS QTH015
            FROM YNRD..PURTH 
            GROUP BY TH011, TH012, TH013
        ) AS QTY 
            ON QTY.QTH011 = TD001 
           AND QTY.QTH012 = TD002 
           AND QTY.QTH013 = TD003
        WHERE TC014 = 'Y'
          AND TD018 = 'Y'
          AND TD016 = 'N'
    ) T
    GROUP BY
        T.COMPANY,
        RTRIM(T.物料编号)
) PUR 
    ON PUR.COMPANY = O.订单公司
   AND PUR.物料编号 = RTRIM(B.材料品号)
LEFT OUTER JOIN (
SELECT *,ROW_NUMBER() OVER(PARTITION BY MB001 ORDER BY MB014 DESC) AS RN  
FROM (
    SELECT MB011,MB014,MB015,MB001 FROM SDRD..PURMB
    UNION
    SELECT MB011,MB014,MB015,MB001 FROM ZJRD..PURMB
    UNION
    SELECT MB011,MB014,MB015,MB001 FROM AHRD..PURMB
    --UNION
    --SELECT MB011,MB014,MB015,MB001 FROM YNRD..PURMB
    ) AS Q
) R ON R.MB001 = B.材料品号 AND RN = 1
WHERE LEFT(B.材料品号,1) IN ('3','5','6','7')
  AND B.物料用量 > 0
ORDER BY 
    TRIM(SI.MB001),
    TRIM(B.材料品号),
    O.订单公司;


    IF OBJECT_ID('tempdb..#Base') IS NOT NULL DROP TABLE #Base;
IF OBJECT_ID('tempdb..#NeedMatCompany') IS NOT NULL DROP TABLE #NeedMatCompany;
IF OBJECT_ID('tempdb..#NeedProduct') IS NOT NULL DROP TABLE #NeedProduct;
IF OBJECT_ID('tempdb..#ProdInfo') IS NOT NULL DROP TABLE #ProdInfo;
IF OBJECT_ID('tempdb..#InvInfo') IS NOT NULL DROP TABLE #InvInfo;
IF OBJECT_ID('tempdb..#PurInfo') IS NOT NULL DROP TABLE #PurInfo;

------------------------------------------------------------
-- 1) 先把最终真正需要的 产品+材料+公司 压成最小集合
------------------------------------------------------------
SELECT DISTINCT
    B.MB01       AS 产品品号,
    B.材料品号,
    B.材料品名,
    B.材料规格,
    O.订单公司   AS 公司别
INTO #Base
FROM #BCPXJ B
INNER JOIN ls O
    ON O.品号 = B.MB01
WHERE B.物料用量 > 0
  AND B.材料品号 LIKE '[3567]%';

CREATE CLUSTERED INDEX IX_Base
ON #Base(公司别, 材料品号, 产品品号);

------------------------------------------------------------
-- 2) 需要的 公司+材料 清单
------------------------------------------------------------
SELECT DISTINCT
    公司别,
    材料品号
INTO #NeedMatCompany
FROM #Base;

CREATE UNIQUE CLUSTERED INDEX IX_NeedMatCompany
ON #NeedMatCompany(公司别, 材料品号);

------------------------------------------------------------
-- 3) 需要的 产品清单
------------------------------------------------------------
SELECT DISTINCT
    产品品号
INTO #NeedProduct
FROM #Base;

CREATE UNIQUE CLUSTERED INDEX IX_NeedProduct
ON #NeedProduct(产品品号);

------------------------------------------------------------
-- 4) 产品主档，只回查需要的产品
------------------------------------------------------------
SELECT
    I.MB001 AS 产品品号,
    I.MB002 AS 产品品名,
    I.MB003 AS 产品规格
INTO #ProdInfo
FROM SDRD..INVMB I
INNER JOIN #NeedProduct N
    ON N.产品品号 = I.MB001;

CREATE UNIQUE CLUSTERED INDEX IX_ProdInfo
ON #ProdInfo(产品品号);

------------------------------------------------------------
-- 5) 库存信息，只回查需要的 公司+材料
------------------------------------------------------------
SELECT
    X.公司别,
    X.材料品号,
    X.库存数量
INTO #InvInfo
FROM
(
    SELECT
        'SDRD' AS 公司别,
        I.MB001 AS 材料品号,
        I.MB064 AS 库存数量
    FROM SDRD..INVMB I
    INNER JOIN #NeedMatCompany N
        ON N.公司别 = 'SDRD'
       AND N.材料品号 = I.MB001

    UNION ALL

    SELECT
        'ZJRD' AS 公司别,
        I.MB001 AS 材料品号,
        I.MB064 AS 库存数量
    FROM ZJRD..INVMB I
    INNER JOIN #NeedMatCompany N
        ON N.公司别 = 'ZJRD'
       AND N.材料品号 = I.MB001

    UNION ALL

    SELECT
        'AHRD' AS 公司别,
        I.MB001 AS 材料品号,
        I.MB064 AS 库存数量
    FROM AHRD..INVMB I
    INNER JOIN #NeedMatCompany N
        ON N.公司别 = 'AHRD'
       AND N.材料品号 = I.MB001

    UNION ALL

    SELECT
        'YNRD' AS 公司别,
        I.MB001 AS 材料品号,
        I.MB064 AS 库存数量
    FROM YNRD..INVMB I
    INNER JOIN #NeedMatCompany N
        ON N.公司别 = 'YNRD'
       AND N.材料品号 = I.MB001
) X;

CREATE UNIQUE CLUSTERED INDEX IX_InvInfo
ON #InvInfo(公司别, 材料品号);

------------------------------------------------------------
-- 6) 在途信息，只统计需要的 公司+材料
--    去掉了无用的 PURMA 连接
--    先按采购单身行算剩余，再按 物料编号+公司 汇总
------------------------------------------------------------
SELECT
    X.公司别,
    X.材料品号,
    SUM(X.剩余数量) AS 在途数量
INTO #PurInfo
FROM
(
    --------------------------------------------------------
    -- SDRD
    --------------------------------------------------------
    SELECT
        'SDRD' AS 公司别,
        T.物料编号 AS 材料品号,
        T.剩余数量
    FROM
    (
        SELECT
            D.TD004 AS 物料编号,
            D.TD001,
            D.TD002,
            D.TD003,
            D.TD008 - ISNULL(SUM(H.TH007), 0) AS 剩余数量
        FROM SDRD..PURTD D
        INNER JOIN SDRD..PURTC C
            ON C.TC001 = D.TD001
           AND C.TC002 = D.TD002
        INNER JOIN #NeedMatCompany N
            ON N.公司别 = 'SDRD'
           AND N.材料品号 = D.TD004
        LEFT JOIN SDRD..PURTH H
            ON H.TH011 = D.TD001
           AND H.TH012 = D.TD002
           AND H.TH013 = D.TD003
           AND H.TH030 = 'Y'
        WHERE C.TC014 = 'Y'
          AND D.TD018 = 'Y'
          AND D.TD016 = 'N'
        GROUP BY
            D.TD004,
            D.TD001,
            D.TD002,
            D.TD003,
            D.TD008
    ) T

    UNION ALL

    --------------------------------------------------------
    -- ZJRD
    --------------------------------------------------------
    SELECT
        'ZJRD' AS 公司别,
        T.物料编号 AS 材料品号,
        T.剩余数量
    FROM
    (
        SELECT
            D.TD004 AS 物料编号,
            D.TD001,
            D.TD002,
            D.TD003,
            D.TD008 - ISNULL(SUM(H.TH007), 0) AS 剩余数量
        FROM ZJRD..PURTD D
        INNER JOIN ZJRD..PURTC C
            ON C.TC001 = D.TD001
           AND C.TC002 = D.TD002
        INNER JOIN #NeedMatCompany N
            ON N.公司别 = 'ZJRD'
           AND N.材料品号 = D.TD004
        LEFT JOIN ZJRD..PURTH H
            ON H.TH011 = D.TD001
           AND H.TH012 = D.TD002
           AND H.TH013 = D.TD003
        WHERE C.TC014 = 'Y'
          AND D.TD018 = 'Y'
          AND D.TD016 = 'N'
        GROUP BY
            D.TD004,
            D.TD001,
            D.TD002,
            D.TD003,
            D.TD008
    ) T

    UNION ALL

    --------------------------------------------------------
    -- AHRD
    --------------------------------------------------------
    SELECT
        'AHRD' AS 公司别,
        T.物料编号 AS 材料品号,
        T.剩余数量
    FROM
    (
        SELECT
            D.TD004 AS 物料编号,
            D.TD001,
            D.TD002,
            D.TD003,
            D.TD008 - ISNULL(SUM(H.TH007), 0) AS 剩余数量
        FROM AHRD..PURTD D
        INNER JOIN AHRD..PURTC C
            ON C.TC001 = D.TD001
           AND C.TC002 = D.TD002
        INNER JOIN #NeedMatCompany N
            ON N.公司别 = 'AHRD'
           AND N.材料品号 = D.TD004
        LEFT JOIN AHRD..PURTH H
            ON H.TH011 = D.TD001
           AND H.TH012 = D.TD002
           AND H.TH013 = D.TD003
        WHERE C.TC014 = 'Y'
          AND D.TD018 = 'Y'
          AND D.TD016 = 'N'
        GROUP BY
            D.TD004,
            D.TD001,
            D.TD002,
            D.TD003,
            D.TD008
    ) T

    UNION ALL

    --------------------------------------------------------
    -- YNRD
    --------------------------------------------------------
    SELECT
        'YNRD' AS 公司别,
        T.物料编号 AS 材料品号,
        T.剩余数量
    FROM
    (
        SELECT
            D.TD004 AS 物料编号,
            D.TD001,
            D.TD002,
            D.TD003,
            D.TD008 - ISNULL(SUM(H.TH007), 0) AS 剩余数量
        FROM YNRD..PURTD D
        INNER JOIN YNRD..PURTC C
            ON C.TC001 = D.TD001
           AND C.TC002 = D.TD002
        INNER JOIN #NeedMatCompany N
            ON N.公司别 = 'YNRD'
           AND N.材料品号 = D.TD004
        LEFT JOIN YNRD..PURTH H
            ON H.TH011 = D.TD001
           AND H.TH012 = D.TD002
           AND H.TH013 = D.TD003
        WHERE C.TC014 = 'Y'
          AND D.TD018 = 'Y'
          AND D.TD016 = 'N'
        GROUP BY
            D.TD004,
            D.TD001,
            D.TD002,
            D.TD003,
            D.TD008
    ) T
) X
GROUP BY
    X.公司别,
    X.材料品号;

CREATE UNIQUE CLUSTERED INDEX IX_PurInfo
ON #PurInfo(公司别, 材料品号);

------------------------------------------------------------
-- 7) 最终结果
------------------------------------------------------------
SELECT
    TRIM(P.产品品号) AS 产品品号,
    P.产品品名,
    P.产品规格,
    TRIM(B.材料品号) AS 材料品号,
    B.材料品名,
    B.材料规格,
    ISNULL(U.在途数量, 0) AS 在途数量,
    I.库存数量 AS 库存数量,
    B.公司别
FROM #Base B
INNER JOIN #ProdInfo P
    ON P.产品品号 = B.产品品号
INNER JOIN #InvInfo I
    ON I.公司别 = B.公司别
   AND I.材料品号 = B.材料品号
LEFT JOIN #PurInfo U
    ON U.公司别 = B.公司别
   AND U.材料品号 = B.材料品号
ORDER BY
    TRIM(P.产品品号),
    TRIM(B.材料品号),
    B.公司别;