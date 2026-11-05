CREATE OR ALTER VIEW dbo.MATSD
AS
WITH ITEM AS
(
    SELECT
        N'顺德基地' AS BASE,
        LTRIM(RTRIM(MB001)) AS MATERIAL_NO,
        MAX(LTRIM(RTRIM(MB002))) AS MATERIAL_NAME,
        MAX(LTRIM(RTRIM(MB003))) AS MATERIAL_SPEC,
        MAX(LTRIM(RTRIM(MB004))) AS UNIT
    FROM SDRD..INVMB WITH(NOLOCK)
    GROUP BY LTRIM(RTRIM(MB001))

    UNION ALL

    SELECT
        N'浙江基地',
        LTRIM(RTRIM(MB001)),
        MAX(LTRIM(RTRIM(MB002))),
        MAX(LTRIM(RTRIM(MB003))),
        MAX(LTRIM(RTRIM(MB004)))
    FROM ZJRD..INVMB WITH(NOLOCK)
    GROUP BY LTRIM(RTRIM(MB001))

    UNION ALL

    SELECT
        N'安徽基地',
        LTRIM(RTRIM(MB001)),
        MAX(LTRIM(RTRIM(MB002))),
        MAX(LTRIM(RTRIM(MB003))),
        MAX(LTRIM(RTRIM(MB004)))
    FROM AHRD..INVMB WITH(NOLOCK)
    GROUP BY LTRIM(RTRIM(MB001))

    UNION ALL

    SELECT
        N'越南基地',
        LTRIM(RTRIM(MB001)),
        MAX(LTRIM(RTRIM(MB002))),
        MAX(LTRIM(RTRIM(MB003))),
        MAX(LTRIM(RTRIM(MB004)))
    FROM YNRD..INVMB WITH(NOLOCK)
    GROUP BY LTRIM(RTRIM(MB001))
),
QTY AS
(
    ------------------------------------------------------------
    -- 库存：纳入库存仓 CMSMC.MC005 = 'Y'
    ------------------------------------------------------------
    SELECT
        N'顺德基地' AS BASE,
        LTRIM(RTRIM(MC.MC001)) AS MATERIAL_NO,
        SUM(CAST(ISNULL(MC.MC007, 0) AS DECIMAL(38,6))) AS STOCK_QTY,
        CAST(0 AS DECIMAL(38,6)) AS IN_TRANSIT_QTY,
        CAST(0 AS DECIMAL(38,6)) AS ALLOCATED_QTY
    FROM SDRD..INVMC MC WITH(NOLOCK)
    INNER JOIN SDRD..CMSMC WH WITH(NOLOCK)
        ON MC.MC002 = WH.MC001
    WHERE WH.MC005 = 'Y'
    GROUP BY LTRIM(RTRIM(MC.MC001))

    UNION ALL

    SELECT
        N'浙江基地',
        LTRIM(RTRIM(MC.MC001)),
        SUM(CAST(ISNULL(MC.MC007, 0) AS DECIMAL(38,6))),
        CAST(0 AS DECIMAL(38,6)),
        CAST(0 AS DECIMAL(38,6))
    FROM ZJRD..INVMC MC WITH(NOLOCK)
    INNER JOIN ZJRD..CMSMC WH WITH(NOLOCK)
        ON MC.MC002 = WH.MC001
    WHERE WH.MC005 = 'Y'
    GROUP BY LTRIM(RTRIM(MC.MC001))

    UNION ALL

    SELECT
        N'安徽基地',
        LTRIM(RTRIM(MC.MC001)),
        SUM(CAST(ISNULL(MC.MC007, 0) AS DECIMAL(38,6))),
        CAST(0 AS DECIMAL(38,6)),
        CAST(0 AS DECIMAL(38,6))
    FROM AHRD..INVMC MC WITH(NOLOCK)
    INNER JOIN AHRD..CMSMC WH WITH(NOLOCK)
        ON MC.MC002 = WH.MC001
    WHERE WH.MC005 = 'Y'
    GROUP BY LTRIM(RTRIM(MC.MC001))

    UNION ALL

    SELECT
        N'越南基地',
        LTRIM(RTRIM(MC.MC001)),
        SUM(CAST(ISNULL(MC.MC007, 0) AS DECIMAL(38,6))),
        CAST(0 AS DECIMAL(38,6)),
        CAST(0 AS DECIMAL(38,6))
    FROM YNRD..INVMC MC WITH(NOLOCK)
    INNER JOIN YNRD..CMSMC WH WITH(NOLOCK)
        ON MC.MC002 = WH.MC001
    WHERE WH.MC005 = 'Y'
    GROUP BY LTRIM(RTRIM(MC.MC001))

    UNION ALL

    ------------------------------------------------------------
    -- 在途：PURTD，未结束 TD016 = 'N'，已审核/确认 TD018 = 'Y'
    ------------------------------------------------------------
    SELECT
        N'顺德基地',
        LTRIM(RTRIM(TD.TD004)),
        CAST(0 AS DECIMAL(38,6)),
        SUM(CAST(
            ISNULL(TD.TD008, 0) - ISNULL(TD.TD015, 0)
            AS DECIMAL(38,6)
        )),
        CAST(0 AS DECIMAL(38,6))
    FROM SDRD..PURTD TD WITH(NOLOCK)
    WHERE TD.TD016 = 'N'
      AND TD.TD018 = 'Y'
    GROUP BY LTRIM(RTRIM(TD.TD004))

    UNION ALL

    SELECT
        N'浙江基地',
        LTRIM(RTRIM(TD.TD004)),
        CAST(0 AS DECIMAL(38,6)),
        SUM(CAST(
            ISNULL(TD.TD008, 0) - ISNULL(TD.TD015, 0)
            AS DECIMAL(38,6)
        )),
        CAST(0 AS DECIMAL(38,6))
    FROM ZJRD..PURTD TD WITH(NOLOCK)
    WHERE TD.TD016 = 'N'
      AND TD.TD018 = 'Y'
    GROUP BY LTRIM(RTRIM(TD.TD004))

    UNION ALL

    SELECT
        N'安徽基地',
        LTRIM(RTRIM(TD.TD004)),
        CAST(0 AS DECIMAL(38,6)),
        SUM(CAST(
            ISNULL(TD.TD008, 0) - ISNULL(TD.TD015, 0)
            AS DECIMAL(38,6)
        )),
        CAST(0 AS DECIMAL(38,6))
    FROM AHRD..PURTD TD WITH(NOLOCK)
    WHERE TD.TD016 = 'N'
      AND TD.TD018 = 'Y'
    GROUP BY LTRIM(RTRIM(TD.TD004))

    UNION ALL

    SELECT
        N'越南基地',
        LTRIM(RTRIM(TD.TD004)),
        CAST(0 AS DECIMAL(38,6)),
        SUM(CAST(
            ISNULL(TD.TD008, 0) - ISNULL(TD.TD015, 0)
            AS DECIMAL(38,6)
        )),
        CAST(0 AS DECIMAL(38,6))
    FROM YNRD..PURTD TD WITH(NOLOCK)
    WHERE TD.TD016 = 'N'
      AND TD.TD018 = 'Y'
    GROUP BY LTRIM(RTRIM(TD.TD004))

    UNION ALL

    ------------------------------------------------------------
    -- 分配：已审核工单，状态 1/2/3
    ------------------------------------------------------------
    SELECT
        N'顺德基地',
        LTRIM(RTRIM(TB.TB003)),
        CAST(0 AS DECIMAL(38,6)),
        CAST(0 AS DECIMAL(38,6)),
        SUM(
            CAST(
                CASE
                    WHEN ISNULL(TB.TB004, 0) - ISNULL(TB.TB005, 0) <= 0
                        THEN 0
                    ELSE ISNULL(TB.TB004, 0) - ISNULL(TB.TB005, 0)
                END
                AS DECIMAL(38,6)
            )
        )
    FROM SDRD..MOCTB TB WITH(NOLOCK)
    INNER JOIN SDRD..MOCTA TA WITH(NOLOCK)
        ON TA.TA001 = TB.TB001
       AND TA.TA002 = TB.TB002
    WHERE TA.TA013 = 'Y'
      AND TA.TA011 IN ('1', '2', '3')
    GROUP BY LTRIM(RTRIM(TB.TB003))

    UNION ALL

    SELECT
        N'浙江基地',
        LTRIM(RTRIM(TB.TB003)),
        CAST(0 AS DECIMAL(38,6)),
        CAST(0 AS DECIMAL(38,6)),
        SUM(
            CAST(
                CASE
                    WHEN ISNULL(TB.TB004, 0) - ISNULL(TB.TB005, 0) <= 0
                        THEN 0
                    ELSE ISNULL(TB.TB004, 0) - ISNULL(TB.TB005, 0)
                END
                AS DECIMAL(38,6)
            )
        )
    FROM ZJRD..MOCTB TB WITH(NOLOCK)
    INNER JOIN ZJRD..MOCTA TA WITH(NOLOCK)
        ON TA.TA001 = TB.TB001
       AND TA.TA002 = TB.TB002
    WHERE TA.TA013 = 'Y'
      AND TA.TA011 IN ('1', '2', '3')
    GROUP BY LTRIM(RTRIM(TB.TB003))

    UNION ALL

    SELECT
        N'安徽基地',
        LTRIM(RTRIM(TB.TB003)),
        CAST(0 AS DECIMAL(38,6)),
        CAST(0 AS DECIMAL(38,6)),
        SUM(
            CAST(
                CASE
                    WHEN ISNULL(TB.TB004, 0) - ISNULL(TB.TB005, 0) <= 0
                        THEN 0
                    ELSE ISNULL(TB.TB004, 0) - ISNULL(TB.TB005, 0)
                END
                AS DECIMAL(38,6)
            )
        )
    FROM AHRD..MOCTB TB WITH(NOLOCK)
    INNER JOIN AHRD..MOCTA TA WITH(NOLOCK)
        ON TA.TA001 = TB.TB001
       AND TA.TA002 = TB.TB002
    WHERE TA.TA013 = 'Y'
      AND TA.TA011 IN ('1', '2', '3')
    GROUP BY LTRIM(RTRIM(TB.TB003))

    UNION ALL

    SELECT
        N'越南基地',
        LTRIM(RTRIM(TB.TB003)),
        CAST(0 AS DECIMAL(38,6)),
        CAST(0 AS DECIMAL(38,6)),
        SUM(
            CAST(
                CASE
                    WHEN ISNULL(TB.TB004, 0) - ISNULL(TB.TB005, 0) <= 0
                        THEN 0
                    ELSE ISNULL(TB.TB004, 0) - ISNULL(TB.TB005, 0)
                END
                AS DECIMAL(38,6)
            )
        )
    FROM YNRD..MOCTB TB WITH(NOLOCK)
    INNER JOIN YNRD..MOCTA TA WITH(NOLOCK)
        ON TA.TA001 = TB.TB001
       AND TA.TA002 = TB.TB002
    WHERE TA.TA013 = 'Y'
      AND TA.TA011 IN ('1', '2', '3')
    GROUP BY LTRIM(RTRIM(TB.TB003))
),
AGG AS
(
    SELECT
        BASE,
        MATERIAL_NO,
        SUM(STOCK_QTY) AS STOCK_QTY,
        SUM(IN_TRANSIT_QTY) AS IN_TRANSIT_QTY,
        SUM(ALLOCATED_QTY) AS ALLOCATED_QTY
    FROM QTY
    GROUP BY
        BASE,
        MATERIAL_NO
)
SELECT
    A.BASE,
    A.MATERIAL_NO,
    I.MATERIAL_NAME,
    I.MATERIAL_SPEC,
    I.UNIT,
    A.STOCK_QTY,
    A.IN_TRANSIT_QTY,
    A.ALLOCATED_QTY
FROM AGG A
LEFT JOIN ITEM I
    ON I.BASE = A.BASE
   AND I.MATERIAL_NO = A.MATERIAL_NO
WHERE
    (
        ISNULL(A.STOCK_QTY, 0) <> 0
        OR ISNULL(A.IN_TRANSIT_QTY, 0) <> 0
        OR ISNULL(A.ALLOCATED_QTY, 0) <> 0
    )
    AND LEFT(A.MATERIAL_NO, 1) IN ('3', '5', '6', '7');
GO