USE SDRD;
SET NOCOUNT ON;

DECLARE @StartDate CHAR(8);
DECLARE @EndDate   CHAR(8);

SET @StartDate = CONVERT(CHAR(8), DATEADD(YEAR, -3, GETDATE()), 112);
SET @EndDate   = CONVERT(CHAR(8), DATEADD(DAY, 1, GETDATE()), 112);

IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#RESULT') IS NOT NULL DROP TABLE #RESULT;

------------------------------------------------------------
-- SDRD物料资料：只取品号首位为5的材料
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(MB001)) COLLATE DATABASE_DEFAULT AS 材料品号,
    LTRIM(RTRIM(MB002)) COLLATE DATABASE_DEFAULT AS 材料品名,
    LTRIM(RTRIM(MB003)) COLLATE DATABASE_DEFAULT AS 材料规格,
    LTRIM(RTRIM(MB004)) COLLATE DATABASE_DEFAULT AS 材料单位
INTO #ITEM
FROM SDRD..INVMB
WHERE LEFT(LTRIM(RTRIM(MB001)), 1) = '5';

CREATE UNIQUE CLUSTERED INDEX IX_ITEM
ON #ITEM(材料品号);

------------------------------------------------------------
-- 四地近三年领料对应产品、事业部、客户
------------------------------------------------------------
SELECT
    X.材料品号,
    X.材料品名,
    X.材料规格,
    X.材料单位,
    X.产品品号,
    X.产品品名,
    X.产品规格,
    X.事业部,
    X.客户简称,
    X.账套
INTO #RESULT
FROM
(
    --------------------------------------------------------
    -- 顺德
    --------------------------------------------------------
    SELECT
        I.材料品号,
        I.材料品名,
        I.材料规格,
        I.材料单位,

        LTRIM(RTRIM(TD.TD004)) COLLATE DATABASE_DEFAULT AS 产品品号,
        LTRIM(RTRIM(P.MB002)) COLLATE DATABASE_DEFAULT AS 产品品名,
        LTRIM(RTRIM(P.MB003)) COLLATE DATABASE_DEFAULT AS 产品规格,

        CASE
            WHEN CHARINDEX('-', D.MD011) > 0
                THEN LTRIM(RTRIM(
                    LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
                ))
            ELSE LTRIM(RTRIM(D.MD011))
        END COLLATE DATABASE_DEFAULT AS 事业部,

        LTRIM(RTRIM(MA.MA002)) COLLATE DATABASE_DEFAULT AS 客户简称,
        '顺德瑞德' COLLATE DATABASE_DEFAULT AS 账套
    FROM SDRD..MOCTC C
    INNER JOIN SDRD..MOCTE E
        ON E.TE001 = C.TC001
       AND E.TE002 = C.TC002
    INNER JOIN #ITEM I
        ON LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT = I.材料品号
    INNER JOIN SDRD..MOCTA A
        ON A.TA001 = E.TE011
       AND A.TA002 = E.TE012
    INNER JOIN SDRD..CMSMD D
        ON D.MD001 = A.TA021
    INNER JOIN SDRD..COPTD TD
        ON TD.TD001 = A.TA026
       AND TD.TD002 = A.TA027
       AND TD.TD003 = A.TA028
    INNER JOIN SDRD..COPTC TC
        ON TC.TC001 = TD.TD001
       AND TC.TC002 = TD.TD002
    INNER JOIN SDRD..COPMA MA
        ON MA.MA001 = TC.TC004
    INNER JOIN SDRD..INVMB P
        ON P.MB001 = TD.TD004
    WHERE C.TC003 >= @StartDate
      AND C.TC003 <  @EndDate
      AND LEFT(E.TE001, 2) = '54'
      AND E.TE019 = 'Y'
      AND ISNULL(LTRIM(RTRIM(D.MD011)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(MA.MA002)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TD.TD004)), '') <> ''

    UNION ALL

    --------------------------------------------------------
    -- 浙江
    --------------------------------------------------------
    SELECT
        I.材料品号,
        I.材料品名,
        I.材料规格,
        I.材料单位,

        LTRIM(RTRIM(TD.TD004)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(P.MB002)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(P.MB003)) COLLATE DATABASE_DEFAULT,

        CASE
            WHEN CHARINDEX('-', D.MD011) > 0
                THEN LTRIM(RTRIM(
                    LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
                ))
            ELSE LTRIM(RTRIM(D.MD011))
        END COLLATE DATABASE_DEFAULT,

        LTRIM(RTRIM(MA.MA002)) COLLATE DATABASE_DEFAULT,
        '浙江瑞德' COLLATE DATABASE_DEFAULT
    FROM ZJRD..MOCTC C
    INNER JOIN ZJRD..MOCTE E
        ON E.TE001 = C.TC001
       AND E.TE002 = C.TC002
    INNER JOIN #ITEM I
        ON LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT = I.材料品号
    INNER JOIN ZJRD..MOCTA A
        ON A.TA001 = E.TE011
       AND A.TA002 = E.TE012
    INNER JOIN ZJRD..CMSMD D
        ON D.MD001 = A.TA021
    INNER JOIN ZJRD..COPTD TD
        ON TD.TD001 = A.TA026
       AND TD.TD002 = A.TA027
       AND TD.TD003 = A.TA028
    INNER JOIN ZJRD..COPTC TC
        ON TC.TC001 = TD.TD001
       AND TC.TC002 = TD.TD002
    INNER JOIN ZJRD..COPMA MA
        ON MA.MA001 = TC.TC004
    INNER JOIN SDRD..INVMB P
        ON P.MB001 COLLATE DATABASE_DEFAULT =
           TD.TD004 COLLATE DATABASE_DEFAULT
    WHERE C.TC003 >= @StartDate
      AND C.TC003 <  @EndDate
      AND LEFT(E.TE001, 2) = '54'
      AND E.TE019 = 'Y'
      AND ISNULL(LTRIM(RTRIM(D.MD011)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(MA.MA002)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TD.TD004)), '') <> ''

    UNION ALL

    --------------------------------------------------------
    -- 安徽
    --------------------------------------------------------
    SELECT
        I.材料品号,
        I.材料品名,
        I.材料规格,
        I.材料单位,

        LTRIM(RTRIM(TD.TD004)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(P.MB002)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(P.MB003)) COLLATE DATABASE_DEFAULT,

        CASE
            WHEN CHARINDEX('-', D.MD011) > 0
                THEN LTRIM(RTRIM(
                    LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
                ))
            ELSE LTRIM(RTRIM(D.MD011))
        END COLLATE DATABASE_DEFAULT,

        LTRIM(RTRIM(MA.MA002)) COLLATE DATABASE_DEFAULT,
        '安徽瑞德' COLLATE DATABASE_DEFAULT
    FROM AHRD..MOCTC C
    INNER JOIN AHRD..MOCTE E
        ON E.TE001 = C.TC001
       AND E.TE002 = C.TC002
    INNER JOIN #ITEM I
        ON LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT = I.材料品号
    INNER JOIN AHRD..MOCTA A
        ON A.TA001 = E.TE011
       AND A.TA002 = E.TE012
    INNER JOIN AHRD..CMSMD D
        ON D.MD001 = A.TA021
    INNER JOIN AHRD..COPTD TD
        ON TD.TD001 = A.TA026
       AND TD.TD002 = A.TA027
       AND TD.TD003 = A.TA028
    INNER JOIN AHRD..COPTC TC
        ON TC.TC001 = TD.TD001
       AND TC.TC002 = TD.TD002
    INNER JOIN AHRD..COPMA MA
        ON MA.MA001 = TC.TC004
    INNER JOIN SDRD..INVMB P
        ON P.MB001 COLLATE DATABASE_DEFAULT =
           TD.TD004 COLLATE DATABASE_DEFAULT
    WHERE C.TC003 >= @StartDate
      AND C.TC003 <  @EndDate
      AND LEFT(E.TE001, 2) = '54'
      AND E.TE019 = 'Y'
      AND ISNULL(LTRIM(RTRIM(D.MD011)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(MA.MA002)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TD.TD004)), '') <> ''

    UNION ALL

    --------------------------------------------------------
    -- 越南
    --------------------------------------------------------
    SELECT
        I.材料品号,
        I.材料品名,
        I.材料规格,
        I.材料单位,

        LTRIM(RTRIM(TD.TD004)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(P.MB002)) COLLATE DATABASE_DEFAULT,
        LTRIM(RTRIM(P.MB003)) COLLATE DATABASE_DEFAULT,

        CASE
            WHEN CHARINDEX('-', D.MD011) > 0
                THEN LTRIM(RTRIM(
                    LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
                ))
            ELSE LTRIM(RTRIM(D.MD011))
        END COLLATE DATABASE_DEFAULT,

        LTRIM(RTRIM(MA.MA002)) COLLATE DATABASE_DEFAULT,
        '越南瑞德' COLLATE DATABASE_DEFAULT
    FROM YNRD..MOCTC C
    INNER JOIN YNRD..MOCTE E
        ON E.TE001 = C.TC001
       AND E.TE002 = C.TC002
    INNER JOIN #ITEM I
        ON LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT = I.材料品号
    INNER JOIN YNRD..MOCTA A
        ON A.TA001 = E.TE011
       AND A.TA002 = E.TE012
    INNER JOIN YNRD..CMSMD D
        ON D.MD001 = A.TA021
    INNER JOIN YNRD..COPTD TD
        ON TD.TD001 = A.TA026
       AND TD.TD002 = A.TA027
       AND TD.TD003 = A.TA028
    INNER JOIN YNRD..COPTC TC
        ON TC.TC001 = TD.TD001
       AND TC.TC002 = TD.TD002
    INNER JOIN YNRD..COPMA MA
        ON MA.MA001 = TC.TC004
    INNER JOIN SDRD..INVMB P
        ON P.MB001 COLLATE DATABASE_DEFAULT =
           TD.TD004 COLLATE DATABASE_DEFAULT
    WHERE C.TC003 >= @StartDate
      AND C.TC003 <  @EndDate
      AND LEFT(E.TE001, 2) = '54'
      AND E.TE019 = 'Y'
      AND ISNULL(LTRIM(RTRIM(D.MD011)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(MA.MA002)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TD.TD004)), '') <> ''
) X;

------------------------------------------------------------
-- 相同材料、产品、事业部、客户、账套只显示一次
------------------------------------------------------------
SELECT
    材料品号,
    MAX(材料品名) AS 材料品名,
    MAX(材料规格) AS 材料规格,
    MAX(材料单位) AS 材料单位,
    产品品号,
    MAX(产品品名) AS 产品品名,
    MAX(产品规格) AS 产品规格,
    事业部,
    客户简称,
    账套
FROM #RESULT
GROUP BY
    材料品号,
    产品品号,
    事业部,
    客户简称,
    账套
ORDER BY
    材料品号,
    产品品号,
    账套,
    事业部,
    客户简称;