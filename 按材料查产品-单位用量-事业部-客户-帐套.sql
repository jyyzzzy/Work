USE SDRD;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#BOM_EDGE') IS NOT NULL DROP TABLE #BOM_EDGE;
IF OBJECT_ID('tempdb..#BOM') IS NOT NULL DROP TABLE #BOM;
IF OBJECT_ID('tempdb..#RELATION') IS NOT NULL DROP TABLE #RELATION;

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
-- 2. 四账套 BOM 边关系
--    单位用量 = MD006 / MD007
--    4 开头父件仅取 MD013 = 'Y'
------------------------------------------------------------
SELECT
    X.帐套,
    X.父件品号,
    X.子件品号,
    X.单位用量
INTO #BOM_EDGE
FROM
(
    SELECT
        'SDRD' AS 帐套,
        LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT AS 父件品号,
        LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT AS 子件品号,
        CAST(
            CAST(ISNULL(MD006, 0) AS DECIMAL(38,12)) /
            NULLIF(CAST(ISNULL(MD007, 0) AS DECIMAL(38,12)), 0)
            AS DECIMAL(38,12)
        ) AS 单位用量
    FROM SDRD..BOMMD
    WHERE ISNULL(LTRIM(RTRIM(MD001)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
      AND (MD001 NOT LIKE '4%' OR MD013 = 'Y')
      AND ISNULL(MD007, 0) <> 0

    UNION ALL

    SELECT
        'ZJRD',
        LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT,
        CAST(
            CAST(ISNULL(MD006, 0) AS DECIMAL(38,12)) /
            NULLIF(CAST(ISNULL(MD007, 0) AS DECIMAL(38,12)), 0)
            AS DECIMAL(38,12)
        )
    FROM ZJRD..BOMMD
    WHERE ISNULL(LTRIM(RTRIM(MD001)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
      AND (MD001 NOT LIKE '4%' OR MD013 = 'Y')
      AND ISNULL(MD007, 0) <> 0

    UNION ALL

    SELECT
        'AHRD',
        LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT,
        CAST(
            CAST(ISNULL(MD006, 0) AS DECIMAL(38,12)) /
            NULLIF(CAST(ISNULL(MD007, 0) AS DECIMAL(38,12)), 0)
            AS DECIMAL(38,12)
        )
    FROM AHRD..BOMMD
    WHERE ISNULL(LTRIM(RTRIM(MD001)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
      AND (MD001 NOT LIKE '4%' OR MD013 = 'Y')
      AND ISNULL(MD007, 0) <> 0

    UNION ALL

    SELECT
        'YNRD',
        LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT,
        CAST(
            CAST(ISNULL(MD006, 0) AS DECIMAL(38,12)) /
            NULLIF(CAST(ISNULL(MD007, 0) AS DECIMAL(38,12)), 0)
            AS DECIMAL(38,12)
        )
    FROM YNRD..BOMMD
    WHERE ISNULL(LTRIM(RTRIM(MD001)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
      AND (MD001 NOT LIKE '4%' OR MD013 = 'Y')
      AND ISNULL(MD007, 0) <> 0
) AS X;

CREATE INDEX IX_BOM_EDGE_CHILD
ON #BOM_EDGE(帐套, 子件品号)
INCLUDE(父件品号, 单位用量);

------------------------------------------------------------
-- 3. 从材料向上递归展开全部父件，计算累计单位用量
------------------------------------------------------------
;WITH BOM_TREE AS
(
    SELECT
        E.帐套,
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
        T.帐套,
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
        ON E.帐套 = T.帐套
       AND E.子件品号 = T.产品品号
    WHERE CHARINDEX('|' + E.父件品号 + '|', T.品号路径) = 0
)
SELECT
    帐套,
    材料品号,
    产品品号,
    CAST(SUM(单位用量) AS DECIMAL(38,12)) AS 单位用量
INTO #BOM
FROM BOM_TREE
GROUP BY
    帐套,
    材料品号,
    产品品号
OPTION (MAXRECURSION 100);

CREATE UNIQUE CLUSTERED INDEX IX_BOM
ON #BOM(帐套, 材料品号, 产品品号);

------------------------------------------------------------
-- 4. 通过 2025-2026 年领退料记录取得产品、事业部、客户
------------------------------------------------------------
SELECT DISTINCT
    X.帐套,
    X.材料品号,
    X.产品品号,
    X.事业部,
    X.客户
INTO #RELATION
FROM
(
    ------------------------------------------------------------
    -- SDRD：工作中心匹配不到时写“顺德瑞德”
    ------------------------------------------------------------
    SELECT
        'SDRD' AS 帐套,
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT AS 材料品号,
        LTRIM(RTRIM(TA.TA006)) COLLATE DATABASE_DEFAULT AS 产品品号,
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
    FROM SDRD..MOCTE AS E
    INNER JOIN #ITEM AS I
        ON I.材料品号 = LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT
    INNER JOIN SDRD..MOCTC AS C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN SDRD..MOCTA AS TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    LEFT JOIN SDRD..CMSMD AS MD
        ON MD.MD001 = TA.TA021
    LEFT JOIN SDRD..COPTD AS TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN SDRD..COPTC AS TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN SDRD..COPMA AS MA
        ON MA.MA001 = TC.TC004
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20250101'
      AND C.TC003 <  '20270101'
      AND ISNULL(LTRIM(RTRIM(TA.TA006)), '') <> ''

    UNION ALL

    ------------------------------------------------------------
    -- ZJRD：事业部固定写“浙江瑞德”
    ------------------------------------------------------------
    SELECT
        'ZJRD',
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(TA.TA006)) COLLATE DATABASE_DEFAULT,
        '浙江瑞德' COLLATE DATABASE_DEFAULT,
        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(MA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT
    FROM ZJRD..MOCTE AS E
    INNER JOIN #ITEM AS I
        ON I.材料品号 = LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT
    INNER JOIN ZJRD..MOCTC AS C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN ZJRD..MOCTA AS TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    LEFT JOIN ZJRD..COPTD AS TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN ZJRD..COPTC AS TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN ZJRD..COPMA AS MA
        ON MA.MA001 = TC.TC004
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20250101'
      AND C.TC003 <  '20270101'
      AND ISNULL(LTRIM(RTRIM(TA.TA006)), '') <> ''

    UNION ALL

    ------------------------------------------------------------
    -- AHRD：工作中心匹配不到时写“安徽瑞德”
    ------------------------------------------------------------
    SELECT
        'AHRD',
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(TA.TA006)) COLLATE DATABASE_DEFAULT,
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
    FROM AHRD..MOCTE AS E
    INNER JOIN #ITEM AS I
        ON I.材料品号 = LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT
    INNER JOIN AHRD..MOCTC AS C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN AHRD..MOCTA AS TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    LEFT JOIN AHRD..CMSMD AS MD
        ON MD.MD001 = TA.TA021
    LEFT JOIN AHRD..COPTD AS TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN AHRD..COPTC AS TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN AHRD..COPMA AS MA
        ON MA.MA001 = TC.TC004
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20250101'
      AND C.TC003 <  '20270101'
      AND ISNULL(LTRIM(RTRIM(TA.TA006)), '') <> ''

    UNION ALL

    ------------------------------------------------------------
    -- YNRD：事业部固定写“越南瑞德”
    ------------------------------------------------------------
    SELECT
        'YNRD',
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(TA.TA006)) COLLATE DATABASE_DEFAULT,
        '越南瑞德' COLLATE DATABASE_DEFAULT,
        ISNULL(
            COALESCE(
                NULLIF(LTRIM(RTRIM(MA.MA002)), ''),
                NULLIF(LTRIM(RTRIM(MA.MA003)), '')
            ),
            ''
        ) COLLATE DATABASE_DEFAULT
    FROM YNRD..MOCTE AS E
    INNER JOIN #ITEM AS I
        ON I.材料品号 = LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT
    INNER JOIN YNRD..MOCTC AS C
        ON C.TC001 = E.TE001
       AND C.TC002 = E.TE002
    INNER JOIN YNRD..MOCTA AS TA
        ON TA.TA001 = E.TE011
       AND TA.TA002 = E.TE012
    LEFT JOIN YNRD..COPTD AS TD
        ON TD.TD001 = TA.TA026
       AND TD.TD002 = TA.TA027
       AND TD.TD003 = ISNULL(NULLIF(LTRIM(RTRIM(TA.TA028)), ''), '0001')
    LEFT JOIN YNRD..COPTC AS TC
        ON TC.TC001 = ISNULL(TD.TD001, TA.TA026)
       AND TC.TC002 = ISNULL(TD.TD002, TA.TA027)
    LEFT JOIN YNRD..COPMA AS MA
        ON MA.MA001 = TC.TC004
    WHERE LEFT(E.TE001, 2) IN ('54', '56')
      AND C.TC003 >= '20250101'
      AND C.TC003 <  '20270101'
      AND ISNULL(LTRIM(RTRIM(TA.TA006)), '') <> ''
) AS X;

CREATE UNIQUE CLUSTERED INDEX IX_RELATION
ON #RELATION(帐套, 材料品号, 产品品号, 事业部, 客户);

------------------------------------------------------------
-- 5. 最终结果：仅保留要求的字段
------------------------------------------------------------
SELECT
    R.材料品号,
    R.产品品号,
    B.单位用量,
    R.事业部,
    R.客户,
    R.帐套
FROM #RELATION AS R
INNER JOIN #BOM AS B
    ON B.帐套 = R.帐套
   AND B.材料品号 = R.材料品号
   AND B.产品品号 = R.产品品号
ORDER BY
    R.材料品号,
    R.产品品号,
    R.事业部,
    R.客户,
    R.帐套;
