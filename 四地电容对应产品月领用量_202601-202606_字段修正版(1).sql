USE SDRD;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#ISSUE') IS NOT NULL
    DROP TABLE #ISSUE;

CREATE TABLE #ISSUE
(
    所属公司   NVARCHAR(20),
    账套       VARCHAR(10),
    材料品号   NVARCHAR(50),
    材料品名   NVARCHAR(255),
    材料规格   NVARCHAR(500),
    产品品号   NVARCHAR(50),
    产品品名   NVARCHAR(255),
    产品规格   NVARCHAR(500),
    月份       CHAR(6),
    领用量     DECIMAL(38, 10)
);

------------------------------------------------------------
-- 广东瑞德
------------------------------------------------------------
INSERT INTO #ISSUE
(
    所属公司,
    账套,
    材料品号,
    材料品名,
    材料规格,
    产品品号,
    产品品名,
    产品规格,
    月份,
    领用量
)
SELECT
    N'广东瑞德',
    'SDRD',
    RTRIM(M.MB001),
    M.MB002,
    M.MB003,
    RTRIM(D.TD004),
    P.MB002,
    P.MB003,
    LEFT(C.TC003, 6),
    SUM
    (
        CASE C.TC008
            WHEN '54' THEN CAST(E.TE005 AS DECIMAL(38, 10))
            WHEN '56' THEN -CAST(E.TE005 AS DECIMAL(38, 10))
            ELSE 0
        END
    )
FROM SDRD..MOCTC AS C
INNER JOIN SDRD..MOCTE AS E
    ON E.TE001 = C.TC001
   AND E.TE002 = C.TC002
INNER JOIN SDRD..MOCTA AS A
    ON A.TA001 = E.TE011
   AND A.TA002 = E.TE012
INNER JOIN SDRD..COPTD AS D
    ON D.TD001 = A.TA026
   AND D.TD002 = A.TA027
   AND D.TD003 = A.TA028
INNER JOIN SDRD..INVMB AS M
    ON M.MB001 = E.TE004
LEFT JOIN SDRD..INVMB AS P
    ON P.MB001 = D.TD004
WHERE C.TC003 BETWEEN '20260101' AND '20260731'
  AND C.TC008 IN ('54', '56')
  AND M.MB002 LIKE N'%电容%'
GROUP BY
    M.MB001,
    M.MB002,
    M.MB003,
    D.TD004,
    P.MB002,
    P.MB003,
    LEFT(C.TC003, 6);

------------------------------------------------------------
-- 浙江瑞德
------------------------------------------------------------
INSERT INTO #ISSUE
(
    所属公司,
    账套,
    材料品号,
    材料品名,
    材料规格,
    产品品号,
    产品品名,
    产品规格,
    月份,
    领用量
)
SELECT
    N'浙江瑞德',
    'ZJRD',
    RTRIM(M.MB001),
    M.MB002,
    M.MB003,
    RTRIM(D.TD004),
    P.MB002,
    P.MB003,
    LEFT(C.TC003, 6),
    SUM
    (
        CASE C.TC008
            WHEN '54' THEN CAST(E.TE005 AS DECIMAL(38, 10))
            WHEN '56' THEN -CAST(E.TE005 AS DECIMAL(38, 10))
            ELSE 0
        END
    )
FROM ZJRD..MOCTC AS C
INNER JOIN ZJRD..MOCTE AS E
    ON E.TE001 = C.TC001
   AND E.TE002 = C.TC002
INNER JOIN ZJRD..MOCTA AS A
    ON A.TA001 = E.TE011
   AND A.TA002 = E.TE012
INNER JOIN ZJRD..COPTD AS D
    ON D.TD001 = A.TA026
   AND D.TD002 = A.TA027
   AND D.TD003 = A.TA028
INNER JOIN ZJRD..INVMB AS M
    ON M.MB001 = E.TE004
LEFT JOIN ZJRD..INVMB AS P
    ON P.MB001 = D.TD004
WHERE C.TC003 BETWEEN '20260101' AND '20260731'
  AND C.TC008 IN ('54', '56')
  AND M.MB002 LIKE N'%电容%'
GROUP BY
    M.MB001,
    M.MB002,
    M.MB003,
    D.TD004,
    P.MB002,
    P.MB003,
    LEFT(C.TC003, 6);

------------------------------------------------------------
-- 安徽瑞德
------------------------------------------------------------
INSERT INTO #ISSUE
(
    所属公司,
    账套,
    材料品号,
    材料品名,
    材料规格,
    产品品号,
    产品品名,
    产品规格,
    月份,
    领用量
)
SELECT
    N'安徽瑞德',
    'AHRD',
    RTRIM(M.MB001),
    M.MB002,
    M.MB003,
    RTRIM(D.TD004),
    P.MB002,
    P.MB003,
    LEFT(C.TC003, 6),
    SUM
    (
        CASE C.TC008
            WHEN '54' THEN CAST(E.TE005 AS DECIMAL(38, 10))
            WHEN '56' THEN -CAST(E.TE005 AS DECIMAL(38, 10))
            ELSE 0
        END
    )
FROM AHRD..MOCTC AS C
INNER JOIN AHRD..MOCTE AS E
    ON E.TE001 = C.TC001
   AND E.TE002 = C.TC002
INNER JOIN AHRD..MOCTA AS A
    ON A.TA001 = E.TE011
   AND A.TA002 = E.TE012
INNER JOIN AHRD..COPTD AS D
    ON D.TD001 = A.TA026
   AND D.TD002 = A.TA027
   AND D.TD003 = A.TA028
INNER JOIN AHRD..INVMB AS M
    ON M.MB001 = E.TE004
LEFT JOIN AHRD..INVMB AS P
    ON P.MB001 = D.TD004
WHERE C.TC003 BETWEEN '20260101' AND '20260731'
  AND C.TC008 IN ('54', '56')
  AND M.MB002 LIKE N'%电容%'
GROUP BY
    M.MB001,
    M.MB002,
    M.MB003,
    D.TD004,
    P.MB002,
    P.MB003,
    LEFT(C.TC003, 6);

------------------------------------------------------------
-- 越南瑞德
------------------------------------------------------------
INSERT INTO #ISSUE
(
    所属公司,
    账套,
    材料品号,
    材料品名,
    材料规格,
    产品品号,
    产品品名,
    产品规格,
    月份,
    领用量
)
SELECT
    N'越南瑞德',
    'YNRD',
    RTRIM(M.MB001),
    M.MB002,
    M.MB003,
    RTRIM(D.TD004),
    P.MB002,
    P.MB003,
    LEFT(C.TC003, 6),
    SUM
    (
        CASE C.TC008
            WHEN '54' THEN CAST(E.TE005 AS DECIMAL(38, 10))
            WHEN '56' THEN -CAST(E.TE005 AS DECIMAL(38, 10))
            ELSE 0
        END
    )
FROM YNRD..MOCTC AS C
INNER JOIN YNRD..MOCTE AS E
    ON E.TE001 = C.TC001
   AND E.TE002 = C.TC002
INNER JOIN YNRD..MOCTA AS A
    ON A.TA001 = E.TE011
   AND A.TA002 = E.TE012
INNER JOIN YNRD..COPTD AS D
    ON D.TD001 = A.TA026
   AND D.TD002 = A.TA027
   AND D.TD003 = A.TA028
INNER JOIN YNRD..INVMB AS M
    ON M.MB001 = E.TE004
LEFT JOIN YNRD..INVMB AS P
    ON P.MB001 = D.TD004
WHERE C.TC003 BETWEEN '20260101' AND '20260731'
  AND C.TC008 IN ('54', '56')
  AND M.MB002 LIKE N'%电容%'
GROUP BY
    M.MB001,
    M.MB002,
    M.MB003,
    D.TD004,
    P.MB002,
    P.MB003,
    LEFT(C.TC003, 6);

------------------------------------------------------------
-- 按材料、订单产品、账套汇总，每个月一列
------------------------------------------------------------
SELECT
    所属公司,
    账套,
    材料品号,
    材料品名,
    材料规格,
    产品品号,
    产品品名,
    产品规格,
    SUM(CASE WHEN 月份 = '202601' THEN 领用量 ELSE 0 END) AS [202601领用量],
    SUM(CASE WHEN 月份 = '202602' THEN 领用量 ELSE 0 END) AS [202602领用量],
    SUM(CASE WHEN 月份 = '202603' THEN 领用量 ELSE 0 END) AS [202603领用量],
    SUM(CASE WHEN 月份 = '202604' THEN 领用量 ELSE 0 END) AS [202604领用量],
    SUM(CASE WHEN 月份 = '202605' THEN 领用量 ELSE 0 END) AS [202605领用量],
    SUM(CASE WHEN 月份 = '202606' THEN 领用量 ELSE 0 END) AS [202606领用量],
    SUM(CASE WHEN 月份 = '202607' THEN 领用量 ELSE 0 END) AS [202607领用量],
    SUM(领用量) AS [202601-202607总领用量]
FROM #ISSUE
GROUP BY
    所属公司,
    账套,
    材料品号,
    材料品名,
    材料规格,
    产品品号,
    产品品名,
    产品规格
ORDER BY
    材料品号,
    产品品号,
    账套;

DROP TABLE #ISSUE;
