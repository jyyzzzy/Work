SET NOCOUNT ON;

SELECT
    M.MB001 AS 品号,
    CAST(ISNULL(B.LB003,0) AS DECIMAL(18,6)) AS [202512月初总数量],
    CAST(ISNULL(C.LB003,0) AS DECIMAL(18,6)) AS [202601月初总数量],
    CAST(ISNULL(A.用量,0) AS DECIMAL(18,6)) AS [202512库存交易总数量],
    CAST(ISNULL(B.LB003,0) + ISNULL(A.用量,0) AS DECIMAL(18,6)) AS [202512月初总数量+库存交易总数量],
    CAST(
        ISNULL(C.LB003,0)
        - (
            ISNULL(B.LB003,0)
            + ISNULL(A.用量,0)
          )
        AS DECIMAL(18,6)
    ) AS [202601月初差值]
FROM INVMB M
LEFT JOIN
(
    SELECT
        LB001,
        SUM(LB003) AS LB003
    FROM INVLB
    WHERE LB002 = '202512'
    GROUP BY LB001
) B
    ON M.MB001 = B.LB001
LEFT JOIN
(
    SELECT
        LB001,
        SUM(LB003) AS LB003
    FROM INVLB
    WHERE LB002 = '202601'
    GROUP BY LB001
) C
    ON M.MB001 = C.LB001
LEFT JOIN
(
    SELECT
        LA001,
        SUM(LA011 * LA005) AS 用量
    FROM INVLA
    WHERE LA004 >= '20251201'
      AND LA004 <= '20251231'
    GROUP BY LA001
) A
    ON M.MB001 = A.LA001
WHERE
    LEFT(M.MB001,1) IN ('3','5','6','7')
    AND ABS(
            ISNULL(C.LB003,0)
            - (
                ISNULL(B.LB003,0)
                + ISNULL(A.用量,0)
              )
        ) > 0.000001
ORDER BY
    M.MB001;