SET NOCOUNT ON;

DECLARE @StartDate CHAR(8) = '20260801';
DECLARE @EndDate   CHAR(8) = '20260831';

SELECT
    X.材料品号,
    MATL.MB002 AS 材料品名,
    MATL.MB003 AS 材料规格,
    X.事业部,
    --X.月份,
    SUM(X.领退料数量) AS 领退料数量,
    CAST(SUM(X.金额) AS DECIMAL(38, 2)) AS 金额,
    CAST(
        CASE
            WHEN SUM(X.领退料数量) = 0 THEN 0
            ELSE
                SUM(X.金额)
                / NULLIF(
                    CAST(SUM(X.领退料数量) AS DECIMAL(38, 8)),
                    0
                )
        END
        AS DECIMAL(28, 8)
    ) AS 单位成本,
    X.账套
FROM
(
    --------------------------------------------------------
    -- 顺德
    --------------------------------------------------------
    SELECT
        'SDRD' AS 账套,
        E.TE004 AS 材料品号,
        --LEFT(C.TC003, 6) AS 月份,
        CASE
            WHEN CHARINDEX('-', ISNULL(D.MD011, '')) > 0
                THEN LTRIM(RTRIM(
                    LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
                ))
            WHEN ISNULL(LTRIM(RTRIM(D.MD011)), '') <> ''
                THEN LTRIM(RTRIM(D.MD011))
            ELSE '广东瑞德'
        END AS 事业部,
        CAST(
            CASE
                WHEN LEFT(E.TE001, 2) = '54' THEN E.TE005
                WHEN LEFT(E.TE001, 2) = '56' THEN -E.TE005
                ELSE 0
            END
            AS DECIMAL(38, 8)
        ) AS 领退料数量,
        ISNULL(L.金额, 0) AS 金额
    FROM SDRD..MOCTC AS C WITH (NOLOCK)
    INNER JOIN SDRD..MOCTE AS E WITH (NOLOCK)
        ON E.TE001 = C.TC001
       AND E.TE002 = C.TC002
    LEFT JOIN SDRD..CMSMD AS D WITH (NOLOCK)
        ON D.MD001 = C.TC005
    LEFT JOIN
    (
        SELECT
            LA001,
            LA006,
            LA007,
            LA008,
            SUM(
                CAST(-1 * LA005 * LA013 AS DECIMAL(38, 8))
            ) AS 金额
        FROM SDRD..INVLA WITH (NOLOCK)
        WHERE LA004 BETWEEN @StartDate AND @EndDate
          AND LEFT(LA006, 2) IN ('54', '56')
        GROUP BY
            LA001,
            LA006,
            LA007,
            LA008
    ) AS L
        ON L.LA001 = E.TE004
       AND L.LA006 = E.TE001
       AND L.LA007 = E.TE002
       AND L.LA008 = E.TE003
    WHERE C.TC003 BETWEEN @StartDate AND @EndDate
      AND E.TE019 = 'Y'
      AND LEFT(E.TE001, 2) IN ('54', '56')

    UNION ALL

    --------------------------------------------------------
    -- 安徽
    --------------------------------------------------------
    SELECT
        'AHRD',
        E.TE004,
        --LEFT(C.TC003, 6),
        CASE
            WHEN CHARINDEX('-', ISNULL(D.MD011, '')) > 0
                THEN LTRIM(RTRIM(
                    LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
                ))
            WHEN ISNULL(LTRIM(RTRIM(D.MD011)), '') <> ''
                THEN LTRIM(RTRIM(D.MD011))
            ELSE '安徽瑞德'
        END,
        CAST(
            CASE
                WHEN LEFT(E.TE001, 2) = '54' THEN E.TE005
                WHEN LEFT(E.TE001, 2) = '56' THEN -E.TE005
                ELSE 0
            END
            AS DECIMAL(38, 8)
        ),
        ISNULL(L.金额, 0)
    FROM AHRD..MOCTC AS C WITH (NOLOCK)
    INNER JOIN AHRD..MOCTE AS E WITH (NOLOCK)
        ON E.TE001 = C.TC001
       AND E.TE002 = C.TC002
    LEFT JOIN AHRD..CMSMD AS D WITH (NOLOCK)
        ON D.MD001 = C.TC005
    LEFT JOIN
    (
        SELECT
            LA001,
            LA006,
            LA007,
            LA008,
            SUM(
                CAST(-1 * LA005 * LA013 AS DECIMAL(38, 8))
            ) AS 金额
        FROM AHRD..INVLA WITH (NOLOCK)
        WHERE LA004 BETWEEN @StartDate AND @EndDate
          AND LEFT(LA006, 2) IN ('54', '56')
        GROUP BY
            LA001,
            LA006,
            LA007,
            LA008
    ) AS L
        ON L.LA001 = E.TE004
       AND L.LA006 = E.TE001
       AND L.LA007 = E.TE002
       AND L.LA008 = E.TE003
    WHERE C.TC003 BETWEEN @StartDate AND @EndDate
      AND E.TE019 = 'Y'
      AND LEFT(E.TE001, 2) IN ('54', '56')

    UNION ALL

    --------------------------------------------------------
    -- 浙江
    --------------------------------------------------------
    SELECT
        'ZJRD',
        E.TE004,
        --LEFT(C.TC003, 6),
        CASE
            WHEN CHARINDEX('-', ISNULL(D.MD011, '')) > 0
                THEN LTRIM(RTRIM(
                    LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
                ))
            WHEN ISNULL(LTRIM(RTRIM(D.MD011)), '') <> ''
                THEN LTRIM(RTRIM(D.MD011))
            ELSE '浙江瑞德'
        END,
        CAST(
            CASE
                WHEN LEFT(E.TE001, 2) = '54' THEN E.TE005
                WHEN LEFT(E.TE001, 2) = '56' THEN -E.TE005
                ELSE 0
            END
            AS DECIMAL(38, 8)
        ),
        ISNULL(L.金额, 0)
    FROM ZJRD..MOCTC AS C WITH (NOLOCK)
    INNER JOIN ZJRD..MOCTE AS E WITH (NOLOCK)
        ON E.TE001 = C.TC001
       AND E.TE002 = C.TC002
    LEFT JOIN ZJRD..CMSMD AS D WITH (NOLOCK)
        ON D.MD001 = C.TC005
    LEFT JOIN
    (
        SELECT
            LA001,
            LA006,
            LA007,
            LA008,
            SUM(
                CAST(-1 * LA005 * LA013 AS DECIMAL(38, 8))
            ) AS 金额
        FROM ZJRD..INVLA WITH (NOLOCK)
        WHERE LA004 BETWEEN @StartDate AND @EndDate
          AND LEFT(LA006, 2) IN ('54', '56')
        GROUP BY
            LA001,
            LA006,
            LA007,
            LA008
    ) AS L
        ON L.LA001 = E.TE004
       AND L.LA006 = E.TE001
       AND L.LA007 = E.TE002
       AND L.LA008 = E.TE003
    WHERE C.TC003 BETWEEN @StartDate AND @EndDate
      AND E.TE019 = 'Y'
      AND LEFT(E.TE001, 2) IN ('54', '56')

    UNION ALL

    --------------------------------------------------------
    -- 越南
    --------------------------------------------------------
    SELECT
        'YNRD',
        E.TE004,
        --LEFT(C.TC003, 6),
        CASE
            WHEN CHARINDEX('-', ISNULL(D.MD011, '')) > 0
                THEN LTRIM(RTRIM(
                    LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
                ))
            WHEN ISNULL(LTRIM(RTRIM(D.MD011)), '') <> ''
                THEN LTRIM(RTRIM(D.MD011))
            ELSE '越南瑞德'
        END,
        CAST(
            CASE
                WHEN LEFT(E.TE001, 2) = '54' THEN E.TE005
                WHEN LEFT(E.TE001, 2) = '56' THEN -E.TE005
                ELSE 0
            END
            AS DECIMAL(38, 8)
        ),
        ISNULL(L.金额, 0)
    FROM YNRD..MOCTC AS C WITH (NOLOCK)
    INNER JOIN YNRD..MOCTE AS E WITH (NOLOCK)
        ON E.TE001 = C.TC001
       AND E.TE002 = C.TC002
    LEFT JOIN YNRD..CMSMD AS D WITH (NOLOCK)
        ON D.MD001 = C.TC005
    LEFT JOIN
    (
        SELECT
            LA001,
            LA006,
            LA007,
            LA008,
            SUM(
                CAST(-1 * LA005 * LA013 AS DECIMAL(38, 8))
            ) AS 金额
        FROM YNRD..INVLA WITH (NOLOCK)
        WHERE LA004 BETWEEN @StartDate AND @EndDate
          AND LEFT(LA006, 2) IN ('54', '56')
        GROUP BY
            LA001,
            LA006,
            LA007,
            LA008
    ) AS L
        ON L.LA001 = E.TE004
       AND L.LA006 = E.TE001
       AND L.LA007 = E.TE002
       AND L.LA008 = E.TE003
    WHERE C.TC003 BETWEEN @StartDate AND @EndDate
      AND E.TE019 = 'Y'
      AND LEFT(E.TE001, 2) IN ('54', '56')
) AS X
INNER JOIN SDRD..INVMB AS MATL WITH (NOLOCK)
    ON MATL.MB001 = X.材料品号
WHERE LEFT(X.材料品号, 1) IN ('3', '5', '6', '7')
--  AND MATL.MB002 LIKE '%继电器%'
GROUP BY
    X.材料品号,
    MATL.MB002,
    MATL.MB003,
    X.事业部,
    --X.月份,
    X.账套
ORDER BY
    --X.月份,
    X.事业部,
    X.材料品号,
    X.账套;
