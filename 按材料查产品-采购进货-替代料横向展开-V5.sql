/*
版本：V5（SDRD统一BOM主数据＋替代料横向展开＋采购进货数量＋最近生产入库信息）

输出字段：
材料品号、替代品号1、替代品号2……、材料品名、材料规格、材料单位、
产品品号、产品品名、产品规格、产品单位、单位用量、
2025年采购进货总数量、2026年采购进货总数量、事业部、客户、帐套

口径：
1. BOMMD、INVMB统一读取SDRD库。
2. 4开头的MD001为替代群组：MD013='Y'为正式料，MD013<>'Y'为替代料。
3. 替代料不单独参与BOM展开，统一横向显示在正式料所在行。
4. 采购进货数量取四地Pur_Sup_Detail.TH016C；采购退货在视图中为负数，自动冲减。
5. 产品、事业部、客户取四地范围内该产品最近一次生产入库单。
*/

USE SDRD;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#INVMB') IS NOT NULL DROP TABLE #INVMB;
IF OBJECT_ID('tempdb..#ALT_PAIR') IS NOT NULL DROP TABLE #ALT_PAIR;
IF OBJECT_ID('tempdb..#ALTERNATIVE') IS NOT NULL DROP TABLE #ALTERNATIVE;
IF OBJECT_ID('tempdb..#BOM_EDGE') IS NOT NULL DROP TABLE #BOM_EDGE;
IF OBJECT_ID('tempdb..#BOM') IS NOT NULL DROP TABLE #BOM;
IF OBJECT_ID('tempdb..#BOM_PRODUCT') IS NOT NULL DROP TABLE #BOM_PRODUCT;
IF OBJECT_ID('tempdb..#PURCHASE') IS NOT NULL DROP TABLE #PURCHASE;
IF OBJECT_ID('tempdb..#PROD_RECEIPT') IS NOT NULL DROP TABLE #PROD_RECEIPT;
IF OBJECT_ID('tempdb..#LATEST_RECEIPT') IS NOT NULL DROP TABLE #LATEST_RECEIPT;

------------------------------------------------------------
-- 1. 待查询材料
------------------------------------------------------------
SELECT DISTINCT
    LTRIM(RTRIM(ITEMNO)) COLLATE DATABASE_DEFAULT AS 材料品号
INTO #ITEM
FROM LSSJ..ITEMTMP
WHERE ISNULL(LTRIM(RTRIM(ITEMNO)), '') <> '';

CREATE UNIQUE CLUSTERED INDEX IX_ITEM
ON #ITEM(材料品号);

------------------------------------------------------------
-- 2. 品号资料
--    四地INVMB统一，直接取SDRD..INVMB
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(MB001)) COLLATE DATABASE_DEFAULT AS 品号,
    LTRIM(RTRIM(MB002)) COLLATE DATABASE_DEFAULT AS 品名,
    LTRIM(RTRIM(MB003)) COLLATE DATABASE_DEFAULT AS 规格,
    LTRIM(RTRIM(MB004)) COLLATE DATABASE_DEFAULT AS 单位
INTO #INVMB
FROM SDRD..INVMB
WHERE ISNULL(LTRIM(RTRIM(MB001)), '') <> '';

CREATE UNIQUE CLUSTERED INDEX IX_INVMB
ON #INVMB(品号);

------------------------------------------------------------
-- 3. 正式料与替代料关系
--    MD001以4开头：同一个MD001视为同一个替代群组
--    MD013 = 'Y'：正式料
--    MD013 <> 'Y'：替代料
------------------------------------------------------------
SELECT DISTINCT
    F.正式材料品号,
    A.替代品号,
    F.替代群组品号,
    A.替代顺序
INTO #ALT_PAIR
FROM
(
    SELECT
        LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT AS 替代群组品号,
        LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT AS 正式材料品号
    FROM SDRD..BOMMD
    WHERE MD001 LIKE '4%'
      AND ISNULL(MD013, '') = 'Y'
      AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
) AS F
INNER JOIN
(
    SELECT
        LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT AS 替代群组品号,
        LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT AS 替代品号,
        LTRIM(RTRIM(MD002)) COLLATE DATABASE_DEFAULT AS 替代顺序
    FROM SDRD..BOMMD
    WHERE MD001 LIKE '4%'
      AND ISNULL(MD013, '') <> 'Y'
      AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
) AS A
    ON A.替代群组品号 = F.替代群组品号
INNER JOIN #ITEM AS I
    ON I.材料品号 = F.正式材料品号
WHERE A.替代品号 <> F.正式材料品号;

CREATE INDEX IX_ALT_PAIR
ON #ALT_PAIR(正式材料品号, 替代品号);

;WITH ALT_DISTINCT AS
(
    SELECT
        正式材料品号,
        替代品号,
        MIN(替代群组品号) AS 替代群组品号,
        MIN(替代顺序) AS 替代顺序
    FROM #ALT_PAIR
    GROUP BY
        正式材料品号,
        替代品号
)
SELECT
    正式材料品号,
    替代品号,
    ROW_NUMBER() OVER
    (
        PARTITION BY 正式材料品号
        ORDER BY 替代群组品号, 替代顺序, 替代品号
    ) AS 替代序号
INTO #ALTERNATIVE
FROM ALT_DISTINCT;

CREATE UNIQUE CLUSTERED INDEX IX_ALTERNATIVE
ON #ALTERNATIVE(正式材料品号, 替代序号);

------------------------------------------------------------
-- 4. BOM边关系
--    四地BOMMD统一，直接取SDRD..BOMMD
--    单位用量 = MD006 / MD007
--    4开头替代群组只使用MD013='Y'的正式料参与BOM展开
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT AS 父件品号,
    LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT AS 子件品号,
    CAST(
        CAST(ISNULL(MD006, 0) AS DECIMAL(38,12)) /
        NULLIF(CAST(ISNULL(MD007, 0) AS DECIMAL(38,12)), 0)
        AS DECIMAL(38,12)
    ) AS 单位用量
INTO #BOM_EDGE
FROM SDRD..BOMMD
WHERE ISNULL(LTRIM(RTRIM(MD001)), '') <> ''
  AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
  AND (MD001 NOT LIKE '4%' OR MD013 = 'Y')
  AND ISNULL(MD007, 0) <> 0;

CREATE INDEX IX_BOM_EDGE_CHILD
ON #BOM_EDGE(子件品号)
INCLUDE(父件品号, 单位用量);

------------------------------------------------------------
-- 5. 从材料向上递归展开全部父件，计算累计单位用量
------------------------------------------------------------
;WITH BOM_TREE AS
(
    SELECT
        I.材料品号,
        E.父件品号 AS 产品品号,
        CAST(E.单位用量 AS DECIMAL(38,12)) AS 单位用量,
        CAST(
            '|' + I.材料品号 + '|' + E.父件品号 + '|'
            AS NVARCHAR(MAX)
        ) AS 品号路径
    FROM #ITEM AS I
    INNER JOIN #BOM_EDGE AS E
        ON E.子件品号 = I.材料品号

    UNION ALL

    SELECT
        T.材料品号,
        E.父件品号,
        CAST(
            T.单位用量 * E.单位用量
            AS DECIMAL(38,12)
        ),
        CAST(
            T.品号路径 + E.父件品号 + '|'
            AS NVARCHAR(MAX)
        )
    FROM BOM_TREE AS T
    INNER JOIN #BOM_EDGE AS E
        ON E.子件品号 = T.产品品号
    WHERE CHARINDEX('|' + E.父件品号 + '|', T.品号路径) = 0
)
SELECT
    材料品号,
    产品品号,
    CAST(SUM(单位用量) AS DECIMAL(38,12)) AS 单位用量
INTO #BOM
FROM BOM_TREE
GROUP BY
    材料品号,
    产品品号
OPTION (MAXRECURSION 100);

CREATE UNIQUE CLUSTERED INDEX IX_BOM
ON #BOM(材料品号, 产品品号);

------------------------------------------------------------
-- 6. BOM产品清单
--    用于限制四地生产入库单查询范围
------------------------------------------------------------
SELECT DISTINCT
    产品品号
INTO #BOM_PRODUCT
FROM #BOM;

CREATE UNIQUE CLUSTERED INDEX IX_BOM_PRODUCT
ON #BOM_PRODUCT(产品品号);

------------------------------------------------------------
-- 7. 按材料品号汇总采购进货数量
--    日期：Pur_Sup_Detail.TH014C
--    材料：Pur_Sup_Detail.TH004C
--    数量：Pur_Sup_Detail.TH016C
--    进货为正数，退货在视图中为负数，结果为净采购进货数量
------------------------------------------------------------
SELECT
    X.帐套,
    X.材料品号,
    CAST(SUM(
        CASE
            WHEN X.进货日期 >= '20250101' AND X.进货日期 < '20260101'
                THEN X.进货数量
            ELSE 0
        END
    ) AS DECIMAL(38,8)) AS [2025年采购进货总数量],
    CAST(SUM(
        CASE
            WHEN X.进货日期 >= '20260101' AND X.进货日期 < '20270101'
                THEN X.进货数量
            ELSE 0
        END
    ) AS DECIMAL(38,8)) AS [2026年采购进货总数量]
INTO #PURCHASE
FROM
(
    SELECT
        'SDRD' AS 帐套,
        LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT AS 材料品号,
        D.TH014C AS 进货日期,
        CAST(ISNULL(D.TH016C, 0) AS DECIMAL(38,8)) AS 进货数量
    FROM SDRD..Pur_Sup_Detail AS D
    INNER JOIN #ITEM AS I
        ON I.材料品号 = LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT
    WHERE D.TH014C >= '20250101'
      AND D.TH014C <  '20270101'
      AND LEFT(LTRIM(RTRIM(D.TH004C)), 1) NOT IN ('1', 'A', '2')

    UNION ALL

    SELECT
        'ZJRD',
        LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT,
        D.TH014C,
        CAST(ISNULL(D.TH016C, 0) AS DECIMAL(38,8))
    FROM ZJRD..Pur_Sup_Detail AS D
    INNER JOIN #ITEM AS I
        ON I.材料品号 = LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT
    WHERE D.TH014C >= '20250101'
      AND D.TH014C <  '20270101'
      AND LEFT(LTRIM(RTRIM(D.TH004C)), 1) NOT IN ('1', 'A', '2')

    UNION ALL

    SELECT
        'AHRD',
        LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT,
        D.TH014C,
        CAST(ISNULL(D.TH016C, 0) AS DECIMAL(38,8))
    FROM AHRD..Pur_Sup_Detail AS D
    INNER JOIN #ITEM AS I
        ON I.材料品号 = LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT
    WHERE D.TH014C >= '20250101'
      AND D.TH014C <  '20270101'
      AND LEFT(LTRIM(RTRIM(D.TH004C)), 1) NOT IN ('1', 'A', '2')

    UNION ALL

    SELECT
        'YNRD',
        LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT,
        D.TH014C,
        CAST(ISNULL(D.TH016C, 0) AS DECIMAL(38,8))
    FROM YNRD..Pur_Sup_Detail AS D
    INNER JOIN #ITEM AS I
        ON I.材料品号 = LTRIM(RTRIM(D.TH004C)) COLLATE DATABASE_DEFAULT
    WHERE D.TH014C >= '20250101'
      AND D.TH014C <  '20270101'
      AND LEFT(LTRIM(RTRIM(D.TH004C)), 1) NOT IN ('1', 'A', '2')
) AS X
GROUP BY
    X.帐套,
    X.材料品号;

CREATE UNIQUE CLUSTERED INDEX IX_PURCHASE
ON #PURCHASE(帐套, 材料品号);

------------------------------------------------------------
-- 8. 四账套生产入库单
--    产品品号：MOCTG.TG004
--    入库日期：MOCTF.TF003
--    工作中心：MOCTF.TF011
--    工单关系：MOCTG.TG014/TG015 -> MOCTA.TA001/TA002
--    客户关系：工单订单号 -> COPTC -> COPMA
------------------------------------------------------------
SELECT
    X.帐套顺序,
    X.帐套,
    X.产品品号,
    X.入库日期,
    X.入库单别,
    X.入库单号,
    X.入库序号,
    X.事业部,
    X.客户
INTO #PROD_RECEIPT
FROM
(
    ------------------------------------------------------------
    -- SDRD：TF011 匹配工作中心，匹配不到写“顺德瑞德”
    ------------------------------------------------------------
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
        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(MA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT AS 客户
    FROM SDRD..MOCTG AS G
    INNER JOIN SDRD..MOCTF AS F
        ON F.TF001 = G.TG001
       AND F.TF002 = G.TG002
    INNER JOIN #BOM_PRODUCT AS BP
        ON BP.产品品号 = LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT
    LEFT JOIN SDRD..CMSMD AS MD
        ON MD.MD001 = F.TF011
    LEFT JOIN SDRD..MOCTA AS TA
        ON TA.TA001 = G.TG014
       AND TA.TA002 = G.TG015
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

    ------------------------------------------------------------
    -- ZJRD：事业部固定写“浙江瑞德”
    ------------------------------------------------------------
    SELECT
        2,
        'ZJRD',
        LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT,
        F.TF003,
        G.TG001,
        G.TG002,
        G.TG003,
        '浙江瑞德' COLLATE DATABASE_DEFAULT,
        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(MA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT
    FROM ZJRD..MOCTG AS G
    INNER JOIN ZJRD..MOCTF AS F
        ON F.TF001 = G.TG001
       AND F.TF002 = G.TG002
    INNER JOIN #BOM_PRODUCT AS BP
        ON BP.产品品号 = LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT
    LEFT JOIN ZJRD..MOCTA AS TA
        ON TA.TA001 = G.TG014
       AND TA.TA002 = G.TG015
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

    ------------------------------------------------------------
    -- AHRD：TF011 匹配工作中心，匹配不到写“安徽瑞德”
    ------------------------------------------------------------
    SELECT
        3,
        'AHRD',
        LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT,
        F.TF003,
        G.TG001,
        G.TG002,
        G.TG003,
        CASE
            WHEN CHARINDEX('-', ISNULL(MD.MD011, '')) > 0
                THEN LTRIM(RTRIM(LEFT(MD.MD011, CHARINDEX('-', MD.MD011) - 1)))
            WHEN ISNULL(LTRIM(RTRIM(MD.MD011)), '') <> ''
                THEN LTRIM(RTRIM(MD.MD011))
            ELSE '安徽瑞德'
        END COLLATE DATABASE_DEFAULT,
        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(MA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT
    FROM AHRD..MOCTG AS G
    INNER JOIN AHRD..MOCTF AS F
        ON F.TF001 = G.TG001
       AND F.TF002 = G.TG002
    INNER JOIN #BOM_PRODUCT AS BP
        ON BP.产品品号 = LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT
    LEFT JOIN AHRD..CMSMD AS MD
        ON MD.MD001 = F.TF011
    LEFT JOIN AHRD..MOCTA AS TA
        ON TA.TA001 = G.TG014
       AND TA.TA002 = G.TG015
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

    ------------------------------------------------------------
    -- YNRD：事业部固定写“越南瑞德”
    ------------------------------------------------------------
    SELECT
        4,
        'YNRD',
        LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT,
        F.TF003,
        G.TG001,
        G.TG002,
        G.TG003,
        '越南瑞德' COLLATE DATABASE_DEFAULT,
        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(MA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT
    FROM YNRD..MOCTG AS G
    INNER JOIN YNRD..MOCTF AS F
        ON F.TF001 = G.TG001
       AND F.TF002 = G.TG002
    INNER JOIN #BOM_PRODUCT AS BP
        ON BP.产品品号 = LTRIM(RTRIM(G.TG004)) COLLATE DATABASE_DEFAULT
    LEFT JOIN YNRD..MOCTA AS TA
        ON TA.TA001 = G.TG014
       AND TA.TA002 = G.TG015
    LEFT JOIN YNRD..COPTD AS TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN YNRD..COPTC AS TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN YNRD..COPMA AS MA
        ON MA.MA001 = TC.TC004
) AS X;

------------------------------------------------------------
-- 9. 每个产品在四个帐套中只取最近一张生产入库单
------------------------------------------------------------
SELECT
    P.帐套顺序,
    P.帐套,
    P.产品品号,
    P.入库日期,
    P.入库单别,
    P.入库单号,
    P.入库序号,
    P.事业部,
    P.客户,
    ROW_NUMBER() OVER
    (
        PARTITION BY P.产品品号
        ORDER BY
            P.入库日期 DESC,
            P.入库单别 DESC,
            P.入库单号 DESC,
            P.入库序号 DESC,
            P.帐套顺序
    ) AS RN
INTO #LATEST_RECEIPT
FROM #PROD_RECEIPT AS P;

CREATE UNIQUE CLUSTERED INDEX IX_LATEST_RECEIPT
ON #LATEST_RECEIPT(产品品号, RN);

------------------------------------------------------------
-- 10. 动态生成替代品号列并输出最终结果
------------------------------------------------------------
DECLARE @ALT_COLUMNS NVARCHAR(MAX);
DECLARE @SQL NVARCHAR(MAX);

SELECT @ALT_COLUMNS =
(
    SELECT
        ', MAX(CASE WHEN A.替代序号 = ' +
        CONVERT(VARCHAR(10), N.替代序号) +
        ' THEN A.替代品号 END) AS ' +
        QUOTENAME('替代品号' + CONVERT(VARCHAR(10), N.替代序号))
    FROM
    (
        SELECT DISTINCT 替代序号
        FROM #ALTERNATIVE
    ) AS N
    ORDER BY N.替代序号
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)');

SET @ALT_COLUMNS = ISNULL(@ALT_COLUMNS, '');

SET @SQL = N'
SELECT
    B.材料品号' + @ALT_COLUMNS + N',
    MI.品名 AS 材料品名,
    MI.规格 AS 材料规格,
    MI.单位 AS 材料单位,
    B.产品品号,
    PI.品名 AS 产品品名,
    PI.规格 AS 产品规格,
    PI.单位 AS 产品单位,
    B.单位用量,
    ISNULL(P.[2025年采购进货总数量], 0) AS [2025年采购进货总数量],
    ISNULL(P.[2026年采购进货总数量], 0) AS [2026年采购进货总数量],
    L.事业部,
    L.客户,
    L.帐套
FROM #BOM AS B
INNER JOIN #LATEST_RECEIPT AS L
    ON L.产品品号 = B.产品品号
   AND L.RN = 1
LEFT JOIN #PURCHASE AS P
    ON P.帐套 = L.帐套
   AND P.材料品号 = B.材料品号
LEFT JOIN #INVMB AS MI
    ON MI.品号 = B.材料品号
LEFT JOIN #INVMB AS PI
    ON PI.品号 = B.产品品号
LEFT JOIN #ALTERNATIVE AS A
    ON A.正式材料品号 = B.材料品号
GROUP BY
    B.材料品号,
    MI.品名,
    MI.规格,
    MI.单位,
    B.产品品号,
    PI.品名,
    PI.规格,
    PI.单位,
    B.单位用量,
    P.[2025年采购进货总数量],
    P.[2026年采购进货总数量],
    L.事业部,
    L.客户,
    L.帐套
ORDER BY
    B.材料品号,
    B.产品品号,
    L.事业部,
    L.客户,
    L.帐套;';

EXEC sys.sp_executesql @SQL;
