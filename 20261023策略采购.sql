USE SDRD;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#ISSUE') IS NOT NULL DROP TABLE #ISSUE;

--DELETE FROM LSSJ..ITEMTMP
--="INSERT INTO LSSJ..ITEMTMP(ITEMNO) VALUES('"&&"');"

------------------------------------------------------------
-- ITEMTMP 材料范围
------------------------------------------------------------
SELECT DISTINCT
    LTRIM(RTRIM(ITEMNO)) AS 材料品号
--LTRIM(RTRIM(MB001)) AS 材料品号
INTO #ITEM
FROM LSSJ..ITEMTMP
WHERE ISNULL(LTRIM(RTRIM(ITEMNO)), '') <> ''

--FROM SDRD..INVMB
--WHERE ISNULL(LTRIM(RTRIM(MB001)), '') <> '' AND MB002 LIKE '%贴片电容%';

------------------------------------------------------------
-- 四地领退料
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(E.TE004)) AS 材料品号,
    M.MB002 AS 材料品名,
    M.MB003 AS 材料规格,

    ISNULL(
        NULLIF(
            LTRIM(RTRIM(
                CASE
                    WHEN CHARINDEX('-', ISNULL(W.MD011, '')) > 0
                        THEN LEFT(W.MD011, CHARINDEX('-', W.MD011) - 1)
                    ELSE W.MD011
                END
            )),
            ''
        ),
        '广东瑞德'
    ) AS 事业部,

    CASE
        WHEN LEFT(E.TE001, 2) = '54'
            THEN CAST(E.TE005 AS DECIMAL(38, 8))
        WHEN LEFT(E.TE001, 2) = '56'
            THEN -CAST(E.TE005 AS DECIMAL(38, 8))
    END AS 领用量,

    LTRIM(RTRIM(D.TD004)) AS 产品品号,
    P.MB002 AS 产品品名,
    P.MB003 AS 产品规格,
    MA.MA002 AS 客户简称,
    P.MB109 AS 核准状况
    ,C.TC003 AS 领料日期
INTO #ISSUE
FROM SDRD..MOCTE AS E
INNER JOIN SDRD..MOCTC AS C
    ON C.TC001 = E.TE001
   AND C.TC002 = E.TE002
INNER JOIN #ITEM AS I
    ON I.材料品号 = E.TE004
INNER JOIN SDRD..INVMB AS M
    ON M.MB001 = E.TE004
INNER JOIN SDRD..MOCTA AS A
    ON A.TA001 = E.TE011
   AND A.TA002 = E.TE012
INNER JOIN SDRD..COPTD AS D
    ON D.TD001 = A.TA026
   AND D.TD002 = A.TA027
   AND D.TD003 = A.TA028
INNER JOIN SDRD..COPTC AS H
    ON H.TC001 = D.TD001
   AND H.TC002 = D.TD002
INNER JOIN SDRD..COPMA AS MA
    ON MA.MA001 = H.TC004
INNER JOIN SDRD..INVMB AS P
    ON P.MB001 = D.TD004
LEFT JOIN SDRD..CMSMD AS W
    ON W.MD001 = A.TA021
WHERE C.TC003 >= '20260101'
  AND C.TC003 <  '20261231'
  AND LEFT(E.TE001, 2) IN ('54', '56')
  AND E.TE019 = 'Y'

UNION ALL

SELECT
    LTRIM(RTRIM(E.TE004)),
    M.MB002,
    M.MB003,
    '浙江瑞德',

    CASE
        WHEN LEFT(E.TE001, 2) = '54'
            THEN CAST(E.TE005 AS DECIMAL(38, 8))
        WHEN LEFT(E.TE001, 2) = '56'
            THEN -CAST(E.TE005 AS DECIMAL(38, 8))
    END,

    LTRIM(RTRIM(D.TD004)),
    P.MB002,
    P.MB003,
    MA.MA002
    ,P.MB109
    ,C.TC003
FROM ZJRD..MOCTE AS E
INNER JOIN ZJRD..MOCTC AS C
    ON C.TC001 = E.TE001
   AND C.TC002 = E.TE002
INNER JOIN #ITEM AS I
    ON I.材料品号 = E.TE004
INNER JOIN ZJRD..INVMB AS M
    ON M.MB001 = E.TE004
INNER JOIN ZJRD..MOCTA AS A
    ON A.TA001 = E.TE011
   AND A.TA002 = E.TE012
INNER JOIN ZJRD..COPTD AS D
    ON D.TD001 = A.TA026
   AND D.TD002 = A.TA027
   AND D.TD003 = A.TA028
INNER JOIN ZJRD..COPTC AS H
    ON H.TC001 = D.TD001
   AND H.TC002 = D.TD002
INNER JOIN ZJRD..COPMA AS MA
    ON MA.MA001 = H.TC004
INNER JOIN ZJRD..INVMB AS P
    ON P.MB001 = D.TD004
WHERE C.TC003 >= '20260101'
  AND C.TC003 <  '20261231'
  AND LEFT(E.TE001, 2) IN ('54', '56')
  AND E.TE019 = 'Y'

UNION ALL

SELECT
    LTRIM(RTRIM(E.TE004)),
    M.MB002,
    M.MB003,

    ISNULL(
        NULLIF(
            LTRIM(RTRIM(
                CASE
                    WHEN CHARINDEX('-', ISNULL(W.MD011, '')) > 0
                        THEN LEFT(W.MD011, CHARINDEX('-', W.MD011) - 1)
                    ELSE W.MD011
                END
            )),
            ''
        ),
        '安徽瑞德'
    ),

    CASE
        WHEN LEFT(E.TE001, 2) = '54'
            THEN CAST(E.TE005 AS DECIMAL(38, 8))
        WHEN LEFT(E.TE001, 2) = '56'
            THEN -CAST(E.TE005 AS DECIMAL(38, 8))
    END,

    LTRIM(RTRIM(D.TD004)),
    P.MB002,
    P.MB003,
    MA.MA002
    ,P.MB109
    ,C.TC003
FROM AHRD..MOCTE AS E
INNER JOIN AHRD..MOCTC AS C
    ON C.TC001 = E.TE001
   AND C.TC002 = E.TE002
INNER JOIN #ITEM AS I
    ON I.材料品号 = E.TE004
INNER JOIN AHRD..INVMB AS M
    ON M.MB001 = E.TE004
INNER JOIN AHRD..MOCTA AS A
    ON A.TA001 = E.TE011
   AND A.TA002 = E.TE012
INNER JOIN AHRD..COPTD AS D
    ON D.TD001 = A.TA026
   AND D.TD002 = A.TA027
   AND D.TD003 = A.TA028
INNER JOIN AHRD..COPTC AS H
    ON H.TC001 = D.TD001
   AND H.TC002 = D.TD002
INNER JOIN AHRD..COPMA AS MA
    ON MA.MA001 = H.TC004
INNER JOIN AHRD..INVMB AS P
    ON P.MB001 = D.TD004
LEFT JOIN AHRD..CMSMD AS W
    ON W.MD001 = A.TA021
WHERE C.TC003 >= '20260101'
  AND C.TC003 <  '20261231'
  AND LEFT(E.TE001, 2) IN ('54', '56')
  AND E.TE019 = 'Y'

UNION ALL

SELECT
    LTRIM(RTRIM(E.TE004)),
    M.MB002,
    M.MB003,
    '越南瑞德',

    CASE
        WHEN LEFT(E.TE001, 2) = '54'
            THEN CAST(E.TE005 AS DECIMAL(38, 8))
        WHEN LEFT(E.TE001, 2) = '56'
            THEN -CAST(E.TE005 AS DECIMAL(38, 8))
    END,

    LTRIM(RTRIM(D.TD004)),
    P.MB002,
    P.MB003,
    MA.MA002
    ,P.MB109
    ,C.TC003
FROM YNRD..MOCTE AS E
INNER JOIN YNRD..MOCTC AS C
    ON C.TC001 = E.TE001
   AND C.TC002 = E.TE002
INNER JOIN #ITEM AS I
    ON I.材料品号 = E.TE004
INNER JOIN YNRD..INVMB AS M
    ON M.MB001 = E.TE004
INNER JOIN YNRD..MOCTA AS A
    ON A.TA001 = E.TE011
   AND A.TA002 = E.TE012
INNER JOIN YNRD..COPTD AS D
    ON D.TD001 = A.TA026
   AND D.TD002 = A.TA027
   AND D.TD003 = A.TA028
INNER JOIN YNRD..COPTC AS H
    ON H.TC001 = D.TD001
   AND H.TC002 = D.TD002
INNER JOIN YNRD..COPMA AS MA
    ON MA.MA001 = H.TC004
INNER JOIN YNRD..INVMB AS P
    ON P.MB001 = D.TD004
WHERE C.TC003 >= '20260101'
  AND C.TC003 <  '20261231'
  AND LEFT(E.TE001, 2) IN ('54', '56')
  AND E.TE019 = 'Y';

------------------------------------------------------------
-- 汇总结果
------------------------------------------------------------
SELECT
    材料品号,
    材料品名,
    材料规格,
    事业部,
    SUM(领用量) AS [总领用量],
    产品品号,
    产品品名,
    产品规格,
    客户简称,
    核准状况
--    ,领料日期
FROM #ISSUE
GROUP BY
    材料品号,
    材料品名,
    材料规格,
    事业部,
    产品品号,
    产品品名,
    产品规格,
    客户简称
    ,核准状况
--    ,领料日期
HAVING SUM(领用量) <> 0
ORDER BY
    材料品号,
    事业部,
    产品品号,
    客户简称;