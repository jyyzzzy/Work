SELECT MOCTG.TG001 as MOCTGTG001,
    MOCTG.TG002 as MOCTGTG002,
    MOCTG.TG003 as MOCTGTG003,
    MOCTF.TF003 as MOCTFTF003,
    MOCTG.TG004 as MOCTGTG004,
    MOCTG.TG005 as MOCTGTG005,
    MOCTG.TG006 as MOCTGTG006,
    MOCTG.TG007 as MOCTGTG007,
    MOCTG.TG011 as MOCTGTG011,
    ISNULL(COPMB.MB008, 0) as COPTDTD011,
    INVMB.MB057 as INVMBMB057,
    ISNULL(
        SUM(
            ISNULL(BOMMD.BOM008, 0) * ISNULL(BOMMD.BOM012, 0) /CASE
                ISNULL(BOMMD.BOM009, 1)
                WHEN 0 THEN 1
                ELSE ISNULL(BOMMD.BOM009, 1)
            END
        ),
        0
    ) as MOCTGUDF51,
    MOCTF.TF011 as MOCTFTF011,
    CMSMD.MD002 as CMSMDMD002,
    MOCTG.TG010 as MOCTGTG010,
    MOCTG.TG014 as MOCTGTG014,
    MOCTG.TG015 as MOCTGTG015,
    MOCTA.TA026 as MOCTATA026,
    MOCTA.TA027 as MOCTATA027,
    MOCTA.TA028 as MOCTATA028
FROM MOCTG as MOCTG
    Left JOIN MOCTA as MOCTA On MOCTG.TG014 = MOCTA.TA001
    and MOCTG.TG015 = MOCTA.TA002
    Left JOIN MOCTF as MOCTF On MOCTG.TG001 = MOCTF.TF001
    and MOCTG.TG002 = MOCTF.TF002
    Left JOIN INVMB as INVMB On MOCTG.TG004 = INVMB.MB001
    Left JOIN COPTC as COPTC On MOCTA.TA026 = COPTC.TC001
    AND MOCTA.TA027 = COPTC.TC002
    Left JOIN CMSMD as CMSMD On MOCTF.TF011 = CMSMD.MD001
    Left JOIN (
        SELECT MB001,
            MB002,
            MB008,
            MB017,
            MB018
        FROM COPMB as COPMB
        WHERE COPMB.MB001 + COPMB.MB002 + COPMB.MB017 IN (
                SELECT COPMB.MB001 + COPMB.MB002 + MAX(COPMB.MB017)
                FROM COPMB as COPMB
                WHERE COPMB.MB017 <= '20261231'
                GROUP BY COPMB.MB001,
                    COPMB.MB002
            )
    ) AS COPMB ON COPMB.MB001 = COPTC.TC004
    AND COPMB.MB002 = MOCTG.TG004
    Left JOIN (
        SELECT BOM.MD001 AS BOM001,
            BOM.MD002 AS BOM004,
            MB02.MB002 AS BOM005,
            MB02.MB003 AS BOM006,
            MB02.MB025 AS BOM007,
            BOM.MD003 AS BOM008,
            BOM.MD004 AS BOM009,
            BOM.MD005 AS BOM010,
            MB02.MB064 AS BOM011,
            MB02.MB049 AS BOM012
        FROM (
                SELECT A.MD001 AS MD001,
                    ISNULL(
                        F.MD003,
                        ISNULL(
                            E.MD003,
                            ISNULL(D.MD003, ISNULL(C.MD003, ISNULL(B.MD003, A.MD003)))
                        )
                    ) AS MD002,
                    ISNULL(
                        F.MD006 * ISNULL(
                            E.MD006 * ISNULL(
                                D.MD006 * ISNULL(
                                    C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                                    ISNULL(B.MD006 * A.MD006, A.MD006)
                                ),
                                ISNULL(
                                    C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                                    ISNULL(B.MD006 * A.MD006, A.MD006)
                                )
                            ),
                            ISNULL(
                                D.MD006 * ISNULL(
                                    C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                                    ISNULL(B.MD006 * A.MD006, A.MD006)
                                ),
                                ISNULL(
                                    C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                                    ISNULL(B.MD006 * A.MD006, A.MD006)
                                )
                            )
                        ),
                        ISNULL(
                            E.MD006 * ISNULL(
                                D.MD006 * ISNULL(
                                    C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                                    ISNULL(B.MD006 * A.MD006, A.MD006)
                                ),
                                ISNULL(
                                    C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                                    ISNULL(B.MD006 * A.MD006, A.MD006)
                                )
                            ),
                            ISNULL(
                                D.MD006 * ISNULL(
                                    C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                                    ISNULL(B.MD006 * A.MD006, A.MD006)
                                ),
                                ISNULL(
                                    C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                                    ISNULL(B.MD006 * A.MD006, A.MD006)
                                )
                            )
                        )
                    ) AS MD003,
                    ISNULL(
                        F.MD007 * ISNULL(
                            E.MD007 * ISNULL(
                                D.MD007 * ISNULL(
                                    C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                                    ISNULL(B.MD007 * A.MD007, A.MD007)
                                ),
                                ISNULL(
                                    C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                                    ISNULL(B.MD007 * A.MD007, A.MD007)
                                )
                            ),
                            ISNULL(
                                D.MD007 * ISNULL(
                                    C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                                    ISNULL(B.MD007 * A.MD007, A.MD007)
                                ),
                                ISNULL(
                                    C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                                    ISNULL(B.MD007 * A.MD007, A.MD007)
                                )
                            )
                        ),
                        ISNULL(
                            E.MD007 * ISNULL(
                                D.MD007 * ISNULL(
                                    C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                                    ISNULL(B.MD007 * A.MD007, A.MD007)
                                ),
                                ISNULL(
                                    C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                                    ISNULL(B.MD007 * A.MD007, A.MD007)
                                )
                            ),
                            ISNULL(
                                D.MD007 * ISNULL(
                                    C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                                    ISNULL(B.MD007 * A.MD007, A.MD007)
                                ),
                                ISNULL(
                                    C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                                    ISNULL(B.MD007 * A.MD007, A.MD007)
                                )
                            )
                        )
                    ) AS MD004,
                    ISNULL(
                        F.MD017,
                        ISNULL(
                            E.MD017,
                            ISNULL(D.MD017, ISNULL(C.MD017, ISNULL(B.MD017, A.MD017)))
                        )
                    ) AS MD005
                FROM SDRD..BOMMD AS A WITH(nolock)
                    LEFT JOIN SDRD..BOMMD AS B WITH(nolock) ON A.MD003 = B.MD001
                    LEFT JOIN SDRD..BOMMD AS C WITH(nolock) ON B.MD003 = C.MD001
                    LEFT JOIN SDRD..BOMMD AS D WITH(nolock) ON C.MD003 = D.MD001
                    LEFT JOIN SDRD..BOMMD AS E WITH(nolock) ON D.MD003 = E.MD001
                    LEFT JOIN SDRD..BOMMD AS F WITH(nolock) ON E.MD003 = F.MD001
            ) AS BOM
            INNER JOIN SDRD..INVMB AS MB02 WITH(nolock) ON BOM.MD002 = MB02.MB001
    ) AS BOMMD On BOMMD.BOM001 = MOCTG.TG004
WHERE MOCTF.TF003 BETWEEN '20251001' AND '20251031'
    AND ((MOCTF.TF006 = 'Y'))
GROUP BY MOCTG.TG001,
    MOCTG.TG002,
    MOCTG.TG003,
    MOCTF.TF003,
    MOCTG.TG004,
    MOCTG.TG005,
    MOCTG.TG006,
    MOCTG.TG007,
    MOCTG.TG011,
    COPMB.MB008,
    INVMB.MB057,
    MOCTF.TF011,
    CMSMD.MD002,
    MOCTG.TG010,
    MOCTG.TG014,
    MOCTG.TG015,
    MOCTA.TA026,
    MOCTA.TA027,
    MOCTA.TA028

DECLARE @EndDate VARCHAR(20);
SET @EndDate = '20261231';

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#BASE') IS NOT NULL DROP TABLE #BASE;
IF OBJECT_ID('tempdb..#PROD') IS NOT NULL DROP TABLE #PROD;
IF OBJECT_ID('tempdb..#PAIR') IS NOT NULL DROP TABLE #PAIR;
IF OBJECT_ID('tempdb..#COPMB_LAST') IS NOT NULL DROP TABLE #COPMB_LAST;
IF OBJECT_ID('tempdb..#BOMCOST') IS NOT NULL DROP TABLE #BOMCOST;

------------------------------------------------------------
-- 1. 主数据先过滤
------------------------------------------------------------
SELECT
    G.TG001,
    G.TG002,
    G.TG003,
    F.TF003,
    G.TG004,
    G.TG005,
    G.TG006,
    G.TG007,
    G.TG011,
    I.MB057,
    F.TF011,
    M.MD002 AS CMSMDMD002,
    G.TG010,
    G.TG014,
    G.TG015,
    A.TA026,
    A.TA027,
    A.TA028,
    C.TC004
INTO #BASE
FROM MOCTG AS G
INNER JOIN MOCTF AS F
    ON G.TG001 = F.TF001
   AND G.TG002 = F.TF002
   AND F.TF006 = 'Y'
   AND F.TF003 BETWEEN '20251001' AND '20251031'
LEFT JOIN MOCTA AS A
    ON G.TG014 = A.TA001
   AND G.TG015 = A.TA002
LEFT JOIN INVMB AS I
    ON G.TG004 = I.MB001
LEFT JOIN COPTC AS C
    ON A.TA026 = C.TC001
   AND A.TA027 = C.TC002
LEFT JOIN CMSMD AS M
    ON F.TF011 = M.MD001;

------------------------------------------------------------
-- 2. 提取本次真正需要计算的品号、报价组合
------------------------------------------------------------
SELECT DISTINCT
    TG004
INTO #PROD
FROM #BASE;

SELECT DISTINCT
    TC004 AS MB001,
    TG004 AS MB002
INTO #PAIR
FROM #BASE
WHERE ISNULL(TC004, '') <> '';

------------------------------------------------------------
-- 3. 最新报价
------------------------------------------------------------
SELECT
    X.MB001,
    X.MB002,
    MAX(C.MB008) AS MB008
INTO #COPMB_LAST
FROM
(
    SELECT
        C1.MB001,
        C1.MB002,
        MAX(C1.MB017) AS MB017
    FROM COPMB AS C1
    INNER JOIN #PAIR AS P
        ON P.MB001 = C1.MB001
       AND P.MB002 = C1.MB002
    WHERE C1.MB017 <= @EndDate
    GROUP BY
        C1.MB001,
        C1.MB002
) AS X
INNER JOIN COPMB AS C
    ON C.MB001 = X.MB001
   AND C.MB002 = X.MB002
   AND C.MB017 = X.MB017
GROUP BY
    X.MB001,
    X.MB002;

------------------------------------------------------------
-- 4. BOM 成本汇总
------------------------------------------------------------
SELECT
    BOM.MD001 AS TG004,
    SUM(
        ISNULL(BOM.MD003, 0) * ISNULL(MB02.MB049, 0)
        / CASE
              WHEN ISNULL(BOM.MD004, 1) = 0 THEN 1
              ELSE ISNULL(BOM.MD004, 1)
          END
    ) AS MOCTGUDF51
INTO #BOMCOST
FROM
(
    SELECT
        A.MD001,
        ISNULL(
            F.MD003,
            ISNULL(
                E.MD003,
                ISNULL(D.MD003, ISNULL(C.MD003, ISNULL(B.MD003, A.MD003)))
            )
        ) AS MD002,
        ISNULL(
            F.MD006 * ISNULL(
                E.MD006 * ISNULL(
                    D.MD006 * ISNULL(
                        C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                        ISNULL(B.MD006 * A.MD006, A.MD006)
                    ),
                    ISNULL(
                        C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                        ISNULL(B.MD006 * A.MD006, A.MD006)
                    )
                ),
                ISNULL(
                    D.MD006 * ISNULL(
                        C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                        ISNULL(B.MD006 * A.MD006, A.MD006)
                    ),
                    ISNULL(
                        C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                        ISNULL(B.MD006 * A.MD006, A.MD006)
                    )
                )
            ),
            ISNULL(
                E.MD006 * ISNULL(
                    D.MD006 * ISNULL(
                        C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                        ISNULL(B.MD006 * A.MD006, A.MD006)
                    ),
                    ISNULL(
                        C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                        ISNULL(B.MD006 * A.MD006, A.MD006)
                    )
                ),
                ISNULL(
                    D.MD006 * ISNULL(
                        C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                        ISNULL(B.MD006 * A.MD006, A.MD006)
                    ),
                    ISNULL(
                        C.MD006 * ISNULL(B.MD006 * A.MD006, A.MD006),
                        ISNULL(B.MD006 * A.MD006, A.MD006)
                    )
                )
            )
        ) AS MD003,
        ISNULL(
            F.MD007 * ISNULL(
                E.MD007 * ISNULL(
                    D.MD007 * ISNULL(
                        C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                        ISNULL(B.MD007 * A.MD007, A.MD007)
                    ),
                    ISNULL(
                        C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                        ISNULL(B.MD007 * A.MD007, A.MD007)
                    )
                ),
                ISNULL(
                    D.MD007 * ISNULL(
                        C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                        ISNULL(B.MD007 * A.MD007, A.MD007)
                    ),
                    ISNULL(
                        C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                        ISNULL(B.MD007 * A.MD007, A.MD007)
                    )
                )
            ),
            ISNULL(
                E.MD007 * ISNULL(
                    D.MD007 * ISNULL(
                        C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                        ISNULL(B.MD007 * A.MD007, A.MD007)
                    ),
                    ISNULL(
                        C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                        ISNULL(B.MD007 * A.MD007, A.MD007)
                    )
                ),
                ISNULL(
                    D.MD007 * ISNULL(
                        C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                        ISNULL(B.MD007 * A.MD007, A.MD007)
                    ),
                    ISNULL(
                        C.MD007 * ISNULL(B.MD007 * A.MD007, A.MD007),
                        ISNULL(B.MD007 * A.MD007, A.MD007)
                    )
                )
            )
        ) AS MD004
    FROM SDRD..BOMMD AS A WITH (NOLOCK)
    INNER JOIN #PROD AS P
        ON P.TG004 = A.MD001
    LEFT JOIN SDRD..BOMMD AS B WITH (NOLOCK)
        ON A.MD003 = B.MD001
    LEFT JOIN SDRD..BOMMD AS C WITH (NOLOCK)
        ON B.MD003 = C.MD001
    LEFT JOIN SDRD..BOMMD AS D WITH (NOLOCK)
        ON C.MD003 = D.MD001
    LEFT JOIN SDRD..BOMMD AS E WITH (NOLOCK)
        ON D.MD003 = E.MD001
    LEFT JOIN SDRD..BOMMD AS F WITH (NOLOCK)
        ON E.MD003 = F.MD001
) AS BOM
INNER JOIN SDRD..INVMB AS MB02 WITH (NOLOCK)
    ON BOM.MD002 = MB02.MB001
GROUP BY
    BOM.MD001;

------------------------------------------------------------
-- 5. 最终结果
------------------------------------------------------------
SELECT
    B.TG001 AS MOCTGTG001,
    B.TG002 AS MOCTGTG002,
    B.TG003 AS MOCTGTG003,
    B.TF003 AS MOCTFTF003,
    B.TG004 AS MOCTGTG004,
    B.TG005 AS MOCTGTG005,
    B.TG006 AS MOCTGTG006,
    B.TG007 AS MOCTGTG007,
    B.TG011 AS MOCTGTG011,
    ISNULL(CL.MB008, 0) AS COPTDTD011,
    B.MB057 AS INVMBMB057,
    ISNULL(BC.MOCTGUDF51, 0) AS MOCTGUDF51,
    B.TF011 AS MOCTFTF011,
    B.CMSMDMD002 AS CMSMDMD002,
    B.TG010 AS MOCTGTG010,
    B.TG014 AS MOCTGTG014,
    B.TG015 AS MOCTGTG015,
    B.TA026 AS MOCTATA026,
    B.TA027 AS MOCTATA027,
    B.TA028 AS MOCTATA028
FROM #BASE AS B
LEFT JOIN #COPMB_LAST AS CL
    ON CL.MB001 = B.TC004
   AND CL.MB002 = B.TG004
LEFT JOIN #BOMCOST AS BC
    ON BC.TG004 = B.TG004;