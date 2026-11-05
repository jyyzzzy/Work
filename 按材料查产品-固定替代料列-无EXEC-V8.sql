/*
按材料查询产品、单位用量、最近生产事业部和客户。
BOMMD、INVMB统一取SDRD；采购进货数量取四地Pur_Sup_Detail。
4开头替代群组中，MD013='Y'为正式料，其余为替代料；ITEMTMP中的替代料先映射回正式料。
*/

USE SDRD;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#RAW_ITEM') IS NOT NULL DROP TABLE #RAW_ITEM;
IF OBJECT_ID('tempdb..#ALT_REL') IS NOT NULL DROP TABLE #ALT_REL;
IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#ALT') IS NOT NULL DROP TABLE #ALT;
IF OBJECT_ID('tempdb..#BOM') IS NOT NULL DROP TABLE #BOM;
IF OBJECT_ID('tempdb..#PRODUCT') IS NOT NULL DROP TABLE #PRODUCT;
IF OBJECT_ID('tempdb..#PURCHASE') IS NOT NULL DROP TABLE #PURCHASE;
IF OBJECT_ID('tempdb..#RECEIPT') IS NOT NULL DROP TABLE #RECEIPT;
IF OBJECT_ID('tempdb..#LATEST') IS NOT NULL DROP TABLE #LATEST;
IF OBJECT_ID('tempdb..#ALT_WIDE') IS NOT NULL DROP TABLE #ALT_WIDE;

------------------------------------------------------------
-- 1. 原始查询材料
------------------------------------------------------------
SELECT DISTINCT
    LTRIM(RTRIM(ITEMNO)) COLLATE DATABASE_DEFAULT AS 原材料品号
INTO #RAW_ITEM
FROM LSSJ..ITEMTMP
WHERE ISNULL(LTRIM(RTRIM(ITEMNO)), '') <> '';

------------------------------------------------------------
-- 2. 正式料和替代料关系
--    同一4开头MD001中：MD013='Y'为正式料，其余为替代料
------------------------------------------------------------
;WITH FORMAL AS
(
    SELECT
        LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT AS 替代群组,
        LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT AS 正式材料品号,
        ROW_NUMBER() OVER
        (
            PARTITION BY LTRIM(RTRIM(MD001))
            ORDER BY LTRIM(RTRIM(MD002)), LTRIM(RTRIM(MD003))
        ) AS RN
    FROM SDRD..BOMMD
    WHERE MD001 LIKE '4%'
      AND ISNULL(MD013, '') = 'Y'
      AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
),
ALTERNATIVE AS
(
    SELECT
        LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT AS 替代群组,
        LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT AS 替代品号,
        LTRIM(RTRIM(MD002)) COLLATE DATABASE_DEFAULT AS 替代顺序
    FROM SDRD..BOMMD
    WHERE MD001 LIKE '4%'
      AND ISNULL(MD013, '') <> 'Y'
      AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
)
SELECT DISTINCT
    F.正式材料品号,
    A.替代品号,
    A.替代群组,
    A.替代顺序
INTO #ALT_REL
FROM FORMAL AS F
INNER JOIN ALTERNATIVE AS A
    ON A.替代群组 = F.替代群组
WHERE F.RN = 1
  AND A.替代品号 <> F.正式材料品号;

------------------------------------------------------------
-- 3. 查询材料统一转换为正式料
--    ITEMTMP中即使放的是替代料，也不会再被过滤掉
------------------------------------------------------------
SELECT DISTINCT
    ISNULL(A.正式材料品号, R.原材料品号) AS 材料品号
INTO #ITEM
FROM #RAW_ITEM AS R
LEFT JOIN #ALT_REL AS A
    ON A.替代品号 = R.原材料品号;

CREATE UNIQUE CLUSTERED INDEX IX_ITEM
    ON #ITEM (材料品号);

------------------------------------------------------------
-- 4. 正式料对应的替代料、品名和规格
------------------------------------------------------------
;WITH ALT_DISTINCT AS
(
    SELECT
        A.正式材料品号,
        A.替代品号,
        MIN(A.替代群组) AS 替代群组,
        MIN(A.替代顺序) AS 替代顺序
    FROM #ALT_REL AS A
    INNER JOIN #ITEM AS T
        ON T.材料品号 = A.正式材料品号
    GROUP BY
        A.正式材料品号,
        A.替代品号
),
ALT_NO AS
(
    SELECT
        正式材料品号,
        替代品号,
        ROW_NUMBER() OVER
        (
            PARTITION BY 正式材料品号
            ORDER BY 替代群组, 替代顺序, 替代品号
        ) AS 替代序号
    FROM ALT_DISTINCT
)
SELECT
    A.正式材料品号,
    A.替代序号,
    A.替代品号,
    LTRIM(RTRIM(I.MB002)) AS 替代品名,
    LTRIM(RTRIM(I.MB003)) AS 替代规格
INTO #ALT
FROM ALT_NO AS A
LEFT JOIN SDRD..INVMB AS I
    ON I.MB001 = A.替代品号;

CREATE UNIQUE CLUSTERED INDEX IX_ALT
    ON #ALT (正式材料品号, 替代序号);

------------------------------------------------------------
-- 5. 从正式材料向上递归BOM
--    4开头替代群组只按MD013='Y'的正式料展开
------------------------------------------------------------
;WITH BOM_TREE AS
(
    SELECT
        T.材料品号,
        LTRIM(RTRIM(M.MD001)) COLLATE DATABASE_DEFAULT AS 产品品号,
        CAST(
            CAST(ISNULL(M.MD006, 0) AS DECIMAL(38,12)) /
            NULLIF(CAST(ISNULL(M.MD007, 0) AS DECIMAL(38,12)), 0)
            AS DECIMAL(38,12)
        ) AS 单位用量,
        CAST(
            '|' + T.材料品号 + '|' + LTRIM(RTRIM(M.MD001)) + '|'
            AS NVARCHAR(MAX)
        ) AS 品号路径
    FROM #ITEM AS T
    INNER JOIN SDRD..BOMMD AS M
        ON LTRIM(RTRIM(M.MD003)) COLLATE DATABASE_DEFAULT = T.材料品号
    WHERE ISNULL(M.MD007, 0) <> 0
      AND (M.MD001 NOT LIKE '4%' OR ISNULL(M.MD013, '') = 'Y')

    UNION ALL

    SELECT
        B.材料品号,
        LTRIM(RTRIM(M.MD001)) COLLATE DATABASE_DEFAULT,
        CAST(
            B.单位用量 *
            CAST(ISNULL(M.MD006, 0) AS DECIMAL(38,12)) /
            NULLIF(CAST(ISNULL(M.MD007, 0) AS DECIMAL(38,12)), 0)
            AS DECIMAL(38,12)
        ),
        CAST(
            B.品号路径 + LTRIM(RTRIM(M.MD001)) + '|'
            AS NVARCHAR(MAX)
        )
    FROM BOM_TREE AS B
    INNER JOIN SDRD..BOMMD AS M
        ON LTRIM(RTRIM(M.MD003)) COLLATE DATABASE_DEFAULT = B.产品品号
    WHERE ISNULL(M.MD007, 0) <> 0
      AND (M.MD001 NOT LIKE '4%' OR ISNULL(M.MD013, '') = 'Y')
      AND CHARINDEX(
            '|' + LTRIM(RTRIM(M.MD001)) + '|',
            B.品号路径
          ) = 0
)
SELECT
    材料品号,
    产品品号,
    CAST(SUM(单位用量) AS DECIMAL(38,12)) AS 单位用量
INTO #BOM
FROM BOM_TREE
GROUP BY 材料品号, 产品品号
OPTION (MAXRECURSION 100);

SELECT DISTINCT 产品品号
INTO #PRODUCT
FROM #BOM;

CREATE UNIQUE CLUSTERED INDEX IX_BOM
    ON #BOM (材料品号, 产品品号);

CREATE UNIQUE CLUSTERED INDEX IX_PRODUCT
    ON #PRODUCT (产品品号);

------------------------------------------------------------
-- 6. 四地采购进货数量
--    Pur_Sup_Detail中的退货数量为负数，会自动冲减
------------------------------------------------------------
SELECT
    X.帐套,
    X.材料品号,
    CAST(SUM(CASE WHEN X.日期 >= '20250101' AND X.日期 < '20260101'
                  THEN X.数量 ELSE 0 END) AS DECIMAL(38,8)) AS [2025年采购进货总数量],
    CAST(SUM(CASE WHEN X.日期 >= '20260101' AND X.日期 < '20270101'
                  THEN X.数量 ELSE 0 END) AS DECIMAL(38,8)) AS [2026年采购进货总数量]
INTO #PURCHASE
FROM
(
    SELECT 'SDRD' AS 帐套,
           LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT AS 材料品号,
           D.TH014C AS 日期,
           CAST(ISNULL(D.TH016C, 0) AS DECIMAL(38,8)) AS 数量
    FROM SDRD..Pur_Sup_Detail AS D
    INNER JOIN #ITEM AS T
        ON T.材料品号 = LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT
    WHERE D.TH014C >= '20250101' AND D.TH014C < '20270101'

    UNION ALL

    SELECT 'ZJRD', LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT,
           D.TH014C, CAST(ISNULL(D.TH016C, 0) AS DECIMAL(38,8))
    FROM ZJRD..Pur_Sup_Detail AS D
    INNER JOIN #ITEM AS T
        ON T.材料品号 = LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT
    WHERE D.TH014C >= '20250101' AND D.TH014C < '20270101'

    UNION ALL

    SELECT 'AHRD', LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT,
           D.TH014C, CAST(ISNULL(D.TH016C, 0) AS DECIMAL(38,8))
    FROM AHRD..Pur_Sup_Detail AS D
    INNER JOIN #ITEM AS T
        ON T.材料品号 = LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT
    WHERE D.TH014C >= '20250101' AND D.TH014C < '20270101'

    UNION ALL

    SELECT 'YNRD', LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT,
           D.TH014C, CAST(ISNULL(D.TH016C, 0) AS DECIMAL(38,8))
    FROM YNRD..Pur_Sup_Detail AS D
    INNER JOIN #ITEM AS T
        ON T.材料品号 = LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT
    WHERE D.TH014C >= '20250101' AND D.TH014C < '20270101'
) AS X
GROUP BY X.帐套, X.材料品号;

CREATE UNIQUE CLUSTERED INDEX IX_PURCHASE
    ON #PURCHASE (帐套, 材料品号);

------------------------------------------------------------
-- 7. 四地生产入库单
------------------------------------------------------------
SELECT *
INTO #RECEIPT
FROM
(
    SELECT
        1 AS 帐套顺序,
        'SDRD' AS 帐套,
        LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT AS 产品品号,
        F.TF003 AS 入库日期,
        G.TG001 AS 入库单别,
        G.TG002 AS 入库单号,
        G.TG003 AS 入库序号,
        CASE
            WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                THEN LTRIM(RTRIM(LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)))
            WHEN ISNULL(LTRIM(RTRIM(MD.MD011)), '') <> ''
                THEN LTRIM(RTRIM(MD.MD011))
            ELSE '顺德瑞德'
        END COLLATE DATABASE_DEFAULT AS 事业部,
        ISNULL(COALESCE(NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                        NULLIF(LTRIM(RTRIM(MA.MA003)), '')), '')
            COLLATE DATABASE_DEFAULT AS 客户
    FROM SDRD..MOCTG AS G
    INNER JOIN SDRD..MOCTF AS F
        ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
    INNER JOIN #PRODUCT AS P
        ON P.产品品号 = LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT
    LEFT JOIN SDRD..CMSMD AS MD
        ON MD.MD001 = F.TF011
    LEFT JOIN SDRD..MOCTA AS TA
        ON TA.TA001 = G.TG014 AND TA.TA002 = G.TG015
    LEFT JOIN SDRD..COPTD AS TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN SDRD..COPTC AS TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN SDRD..COPMA AS MA
        ON MA.MA001 = TC.TC004

    UNION ALL

    SELECT
        2, 'ZJRD',
        LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT,
        F.TF003, G.TG001, G.TG002, G.TG003,
        '浙江瑞德' COLLATE DATABASE_DEFAULT,
        ISNULL(COALESCE(NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                        NULLIF(LTRIM(RTRIM(MA.MA003)), '')), '')
            COLLATE DATABASE_DEFAULT
    FROM ZJRD..MOCTG AS G
    INNER JOIN ZJRD..MOCTF AS F
        ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
    INNER JOIN #PRODUCT AS P
        ON P.产品品号 = LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT
    LEFT JOIN ZJRD..MOCTA AS TA
        ON TA.TA001 = G.TG014 AND TA.TA002 = G.TG015
    LEFT JOIN ZJRD..COPTD AS TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN ZJRD..COPTC AS TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN ZJRD..COPMA AS MA
        ON MA.MA001 = TC.TC004

    UNION ALL

    SELECT
        3, 'AHRD',
        LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT,
        F.TF003, G.TG001, G.TG002, G.TG003,
        CASE
            WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                THEN LTRIM(RTRIM(LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)))
            WHEN ISNULL(LTRIM(RTRIM(MD.MD011)), '') <> ''
                THEN LTRIM(RTRIM(MD.MD011))
            ELSE '安徽瑞德'
        END COLLATE DATABASE_DEFAULT,
        ISNULL(COALESCE(NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                        NULLIF(LTRIM(RTRIM(MA.MA003)), '')), '')
            COLLATE DATABASE_DEFAULT
    FROM AHRD..MOCTG AS G
    INNER JOIN AHRD..MOCTF AS F
        ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
    INNER JOIN #PRODUCT AS P
        ON P.产品品号 = LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT
    LEFT JOIN AHRD..CMSMD AS MD
        ON MD.MD001 = F.TF011
    LEFT JOIN AHRD..MOCTA AS TA
        ON TA.TA001 = G.TG014 AND TA.TA002 = G.TG015
    LEFT JOIN AHRD..COPTD AS TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN AHRD..COPTC AS TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN AHRD..COPMA AS MA
        ON MA.MA001 = TC.TC004

    UNION ALL

    SELECT
        4, 'YNRD',
        LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT,
        F.TF003, G.TG001, G.TG002, G.TG003,
        '越南瑞德' COLLATE DATABASE_DEFAULT,
        ISNULL(COALESCE(NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                        NULLIF(LTRIM(RTRIM(MA.MA003)), '')), '')
            COLLATE DATABASE_DEFAULT
    FROM YNRD..MOCTG AS G
    INNER JOIN YNRD..MOCTF AS F
        ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
    INNER JOIN #PRODUCT AS P
        ON P.产品品号 = LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT
    LEFT JOIN YNRD..MOCTA AS TA
        ON TA.TA001 = G.TG014 AND TA.TA002 = G.TG015
    LEFT JOIN YNRD..COPTD AS TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN YNRD..COPTC AS TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN YNRD..COPMA AS MA
        ON MA.MA001 = TC.TC004
) AS R;

CREATE NONCLUSTERED INDEX IX_RECEIPT
    ON #RECEIPT (产品品号, 入库日期 DESC);

SELECT *
INTO #LATEST
FROM
(
    SELECT
        R.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY R.产品品号
            ORDER BY R.入库日期 DESC,
                     R.入库单别 DESC,
                     R.入库单号 DESC,
                     R.入库序号 DESC,
                     R.帐套顺序
        ) AS RN
    FROM #RECEIPT AS R
) AS X
WHERE X.RN = 1;

CREATE UNIQUE CLUSTERED INDEX IX_LATEST
    ON #LATEST (产品品号);

------------------------------------------------------------
-- 8. 替代料固定横向展开
--    不使用动态SQL；最多显示10个替代料
------------------------------------------------------------
SELECT
    A.正式材料品号,
    MAX(CASE WHEN A.替代序号 = 1 THEN A.替代品号 END) AS [替代品号1],
    MAX(CASE WHEN A.替代序号 = 1 THEN A.替代品名 END) AS [替代品名1],
    MAX(CASE WHEN A.替代序号 = 1 THEN A.替代规格 END) AS [替代规格1],
    MAX(CASE WHEN A.替代序号 = 2 THEN A.替代品号 END) AS [替代品号2],
    MAX(CASE WHEN A.替代序号 = 2 THEN A.替代品名 END) AS [替代品名2],
    MAX(CASE WHEN A.替代序号 = 2 THEN A.替代规格 END) AS [替代规格2],
    MAX(CASE WHEN A.替代序号 = 3 THEN A.替代品号 END) AS [替代品号3],
    MAX(CASE WHEN A.替代序号 = 3 THEN A.替代品名 END) AS [替代品名3],
    MAX(CASE WHEN A.替代序号 = 3 THEN A.替代规格 END) AS [替代规格3],
    MAX(CASE WHEN A.替代序号 = 4 THEN A.替代品号 END) AS [替代品号4],
    MAX(CASE WHEN A.替代序号 = 4 THEN A.替代品名 END) AS [替代品名4],
    MAX(CASE WHEN A.替代序号 = 4 THEN A.替代规格 END) AS [替代规格4],
    MAX(CASE WHEN A.替代序号 = 5 THEN A.替代品号 END) AS [替代品号5],
    MAX(CASE WHEN A.替代序号 = 5 THEN A.替代品名 END) AS [替代品名5],
    MAX(CASE WHEN A.替代序号 = 5 THEN A.替代规格 END) AS [替代规格5],
    MAX(CASE WHEN A.替代序号 = 6 THEN A.替代品号 END) AS [替代品号6],
    MAX(CASE WHEN A.替代序号 = 6 THEN A.替代品名 END) AS [替代品名6],
    MAX(CASE WHEN A.替代序号 = 6 THEN A.替代规格 END) AS [替代规格6],
    MAX(CASE WHEN A.替代序号 = 7 THEN A.替代品号 END) AS [替代品号7],
    MAX(CASE WHEN A.替代序号 = 7 THEN A.替代品名 END) AS [替代品名7],
    MAX(CASE WHEN A.替代序号 = 7 THEN A.替代规格 END) AS [替代规格7],
    MAX(CASE WHEN A.替代序号 = 8 THEN A.替代品号 END) AS [替代品号8],
    MAX(CASE WHEN A.替代序号 = 8 THEN A.替代品名 END) AS [替代品名8],
    MAX(CASE WHEN A.替代序号 = 8 THEN A.替代规格 END) AS [替代规格8],
    MAX(CASE WHEN A.替代序号 = 9 THEN A.替代品号 END) AS [替代品号9],
    MAX(CASE WHEN A.替代序号 = 9 THEN A.替代品名 END) AS [替代品名9],
    MAX(CASE WHEN A.替代序号 = 9 THEN A.替代规格 END) AS [替代规格9],
    MAX(CASE WHEN A.替代序号 = 10 THEN A.替代品号 END) AS [替代品号10],
    MAX(CASE WHEN A.替代序号 = 10 THEN A.替代品名 END) AS [替代品名10],
    MAX(CASE WHEN A.替代序号 = 10 THEN A.替代规格 END) AS [替代规格10]
INTO #ALT_WIDE
FROM #ALT AS A
GROUP BY A.正式材料品号;

CREATE UNIQUE CLUSTERED INDEX IX_ALT_WIDE
    ON #ALT_WIDE (正式材料品号);

------------------------------------------------------------
-- 9. 最终结果
------------------------------------------------------------
SELECT
    B.材料品号,
    MI.MB002 AS 材料品名,
    MI.MB003 AS 材料规格,
    MI.MB004 AS 材料单位,
    A.[替代品号1],
    A.[替代品名1],
    A.[替代规格1],
    A.[替代品号2],
    A.[替代品名2],
    A.[替代规格2],
    A.[替代品号3],
    A.[替代品名3],
    A.[替代规格3],
    A.[替代品号4],
    A.[替代品名4],
    A.[替代规格4],
    A.[替代品号5],
    A.[替代品名5],
    A.[替代规格5],
    A.[替代品号6],
    A.[替代品名6],
    A.[替代规格6],
    A.[替代品号7],
    A.[替代品名7],
    A.[替代规格7],
    A.[替代品号8],
    A.[替代品名8],
    A.[替代规格8],
    A.[替代品号9],
    A.[替代品名9],
    A.[替代规格9],
    A.[替代品号10],
    A.[替代品名10],
    A.[替代规格10],
    B.产品品号,
    PI.MB002 AS 产品品名,
    PI.MB003 AS 产品规格,
    PI.MB004 AS 产品单位,
    B.单位用量,
    ISNULL(P.[2025年采购进货总数量], 0) AS [2025年采购进货总数量],
    ISNULL(P.[2026年采购进货总数量], 0) AS [2026年采购进货总数量],
    L.事业部,
    L.客户,
    L.帐套
FROM #BOM AS B
INNER JOIN #LATEST AS L
    ON L.产品品号 = B.产品品号
LEFT JOIN #PURCHASE AS P
    ON P.帐套 = L.帐套
   AND P.材料品号 = B.材料品号
LEFT JOIN SDRD..INVMB AS MI
    ON MI.MB001 = B.材料品号
LEFT JOIN SDRD..INVMB AS PI
    ON PI.MB001 = B.产品品号
LEFT JOIN #ALT_WIDE AS A
    ON A.正式材料品号 = B.材料品号
ORDER BY B.材料品号, B.产品品号;
