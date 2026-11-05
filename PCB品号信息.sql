USE SDRD;
SET NOCOUNT ON;

------------------------------------------------------------
-- 四账套领退料汇总
------------------------------------------------------------
IF OBJECT_ID('tempdb..#ISSUE') IS NOT NULL DROP TABLE #ISSUE;

SELECT
    MATL,
    SUM(QTY2025) AS QTY2025,
    SUM(QTY2026) AS QTY2026
INTO #ISSUE
FROM
(
    -- SDRD
    SELECT
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT AS MATL,
        CASE
            WHEN LEFT(C.TC003,4)='2025'
            THEN CASE WHEN LEFT(E.TE001,2)='54'
                      THEN CAST(E.TE005 AS DECIMAL(38,8))
                      ELSE -CAST(E.TE005 AS DECIMAL(38,8))
                 END
            ELSE 0
        END AS QTY2025,
        CASE
            WHEN LEFT(C.TC003,4)='2026'
            THEN CASE WHEN LEFT(E.TE001,2)='54'
                      THEN CAST(E.TE005 AS DECIMAL(38,8))
                      ELSE -CAST(E.TE005 AS DECIMAL(38,8))
                 END
            ELSE 0
        END AS QTY2026
    FROM SDRD..MOCTE E
    JOIN SDRD..MOCTC C
      ON C.TC001=E.TE001
     AND C.TC002=E.TE002
    WHERE LEFT(E.TE001,2) IN ('54','56')
      AND C.TC003>='20250101'
      AND C.TC003<'20270101'

    UNION ALL

    -- ZJRD
    SELECT
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT,
        CASE WHEN LEFT(C.TC003,4)='2025'
             THEN CASE WHEN LEFT(E.TE001,2)='54'
                       THEN CAST(E.TE005 AS DECIMAL(38,8))
                       ELSE -CAST(E.TE005 AS DECIMAL(38,8))
                  END
             ELSE 0 END,
        CASE WHEN LEFT(C.TC003,4)='2026'
             THEN CASE WHEN LEFT(E.TE001,2)='54'
                       THEN CAST(E.TE005 AS DECIMAL(38,8))
                       ELSE -CAST(E.TE005 AS DECIMAL(38,8))
                  END
             ELSE 0 END
    FROM ZJRD..MOCTE E
    JOIN ZJRD..MOCTC C
      ON C.TC001=E.TE001
     AND C.TC002=E.TE002
    WHERE LEFT(E.TE001,2) IN ('54','56')
      AND C.TC003>='20250101'
      AND C.TC003<'20270101'

    UNION ALL

    -- AHRD
    SELECT
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT,
        CASE WHEN LEFT(C.TC003,4)='2025'
             THEN CASE WHEN LEFT(E.TE001,2)='54'
                       THEN CAST(E.TE005 AS DECIMAL(38,8))
                       ELSE -CAST(E.TE005 AS DECIMAL(38,8))
                  END
             ELSE 0 END,
        CASE WHEN LEFT(C.TC003,4)='2026'
             THEN CASE WHEN LEFT(E.TE001,2)='54'
                       THEN CAST(E.TE005 AS DECIMAL(38,8))
                       ELSE -CAST(E.TE005 AS DECIMAL(38,8))
                  END
             ELSE 0 END
    FROM AHRD..MOCTE E
    JOIN AHRD..MOCTC C
      ON C.TC001=E.TE001
     AND C.TC002=E.TE002
    WHERE LEFT(E.TE001,2) IN ('54','56')
      AND C.TC003>='20250101'
      AND C.TC003<'20270101'

    UNION ALL

    -- YNRD
    SELECT
        LTRIM(RTRIM(E.TE004)) COLLATE DATABASE_DEFAULT,
        CASE WHEN LEFT(C.TC003,4)='2025'
             THEN CASE WHEN LEFT(E.TE001,2)='54'
                       THEN CAST(E.TE005 AS DECIMAL(38,8))
                       ELSE -CAST(E.TE005 AS DECIMAL(38,8))
                  END
             ELSE 0 END,
        CASE WHEN LEFT(C.TC003,4)='2026'
             THEN CASE WHEN LEFT(E.TE001,2)='54'
                       THEN CAST(E.TE005 AS DECIMAL(38,8))
                       ELSE -CAST(E.TE005 AS DECIMAL(38,8))
                  END
             ELSE 0 END
    FROM YNRD..MOCTE E
    JOIN YNRD..MOCTC C
      ON C.TC001=E.TE001
     AND C.TC002=E.TE002
    WHERE LEFT(E.TE001,2) IN ('54','56')
      AND C.TC003>='20250101'
      AND C.TC003<'20270101'
) A
GROUP BY MATL;

------------------------------------------------------------
-- 查询5开头物料
------------------------------------------------------------
SELECT
    CL.MB001 AS 品号,
    CL.MB002 AS 品名,
    CL.MB003 AS 规格,
    CL.MB004 AS 单位,
    CL.MB109 AS 核准状况,
    CL.UDF01 AS 尺寸,
    CL.UDF02 AS 指定供应商,
    CL.UDF03 AS 材质,
    CL.UDF04 AS 工艺,
    CL.UDF05 AS 选型备注,
    ISNULL(I.QTY2025,0) AS [2025年总领用量],
    ISNULL(I.QTY2026,0) AS [2026年总领用量]
FROM SDRD..INVMB CL
LEFT JOIN #ISSUE I
    ON I.MATL = LTRIM(RTRIM(CL.MB001))
WHERE CL.MB001 LIKE '5%'
ORDER BY CL.MB001;