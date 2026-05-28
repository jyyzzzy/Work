SELECT MOCTG.TG001 as MOCTGTG001,
    MOCTG.TG002 as MOCTGTG002,
    MOCTG.TG003 as MOCTGTG003,
    MOCTF.TF003 as MOCTFTF003,
    MOCTG.TG004 as MOCTGTG004,
    MOCTG.TG005 as MOCTGTG005,
    MOCTG.TG006 as MOCTGTG006,
    MOCTG.TG007 as MOCTGTG007,
    MOCTG.TG013 as MOCTGTG013,
    ISNULL(COPMB.DJ, 0) as COPTDTD011,
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
    MOCTA.TA028 as MOCTATA028,
    INVMB.MB008 INVMBMB008,
    INVMA.MA003 INVMAMA003
FROM MOCTG as MOCTG with(nolock)
    Left JOIN MOCTA as MOCTA with(nolock) On MOCTG.TG014 = MOCTA.TA001
    and MOCTG.TG015 = MOCTA.TA002
    Left JOIN MOCTF as MOCTF with(nolock) On MOCTG.TG001 = MOCTF.TF001
    and MOCTG.TG002 = MOCTF.TF002
    Left JOIN INVMB as INVMB with(nolock) On MOCTG.TG004 = INVMB.MB001
    Left JOIN INVMA as INVMA with(nolock) On INVMB.MB008 = INVMA.MA002
    Left JOIN COPTC as COPTC with(nolock) On MOCTA.TA026 = COPTC.TC001
    AND MOCTA.TA027 = COPTC.TC002
    Left JOIN CMSMD as CMSMD with(nolock) On MOCTF.TF011 = CMSMD.MD001
    Left JOIN  [v_COPDJ] AS COPMB with(nolock) ON COPMB.MB01 = MOCTG.TG004
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
                FROM BOMMD AS A with(nolock)
                    LEFT JOIN BOMMD AS B with(nolock) ON A.MD003 = B.MD001
                    LEFT JOIN BOMMD AS C with(nolock) ON B.MD003 = C.MD001
                    LEFT JOIN BOMMD AS D with(nolock) ON C.MD003 = D.MD001
                    LEFT JOIN BOMMD AS E with(nolock) ON D.MD003 = E.MD001
                    LEFT JOIN BOMMD AS F with(nolock) ON E.MD003 = F.MD001
            ) AS BOM
            INNER JOIN INVMB AS MB02 with(nolock) ON BOM.MD002 = MB02.MB001
    ) AS BOMMD On BOMMD.BOM001 = MOCTG.TG004
WHERE NULL IS NULL
    AND MOCTG.TG004 = '122749440000'
    AND ((MOCTF.TF006 = 'Y'))
GROUP BY MOCTG.TG001,
    MOCTG.TG002,
    MOCTG.TG003,
    MOCTF.TF003,
    MOCTG.TG004,
    MOCTG.TG005,
    MOCTG.TG006,
    MOCTG.TG007,
    MOCTG.TG013,
    COPMB.DJ,
    INVMB.MB057,
    MOCTF.TF011,
    CMSMD.MD002,
    MOCTG.TG010,
    MOCTG.TG014,
    MOCTG.TG015,
    MOCTA.TA026,
    MOCTA.TA027,
    MOCTA.TA028,
    INVMB.MB008,
    INVMA.MA003;
/*
SELECT MOCTG.TG001 as MOCTGTG001,
    MOCTG.TG002 as MOCTGTG002,
    MOCTG.TG003 as MOCTGTG003,
    MOCTF.TF003 as MOCTFTF003,
    MOCTG.TG004 as MOCTGTG004,
    MOCTG.TG005 as MOCTGTG005,
    MOCTG.TG006 as MOCTGTG006,
    MOCTG.TG007 as MOCTGTG007,
    MOCTG.TG013 as MOCTGTG013,
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
    MOCTA.TA028 as MOCTATA028,
    INVMB.MB008 INVMBMB008,
    INVMA.MA003 INVMAMA003
FROM MOCTG as MOCTG
    Left JOIN MOCTA as MOCTA On MOCTG.TG014 = MOCTA.TA001
    and MOCTG.TG015 = MOCTA.TA002
    Left JOIN MOCTF as MOCTF On MOCTG.TG001 = MOCTF.TF001
    and MOCTG.TG002 = MOCTF.TF002
    Left JOIN INVMB as INVMB On MOCTG.TG004 = INVMB.MB001
    Left JOIN INVMA as INVMA On INVMB.MB008 = INVMA.MA002
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
                WHERE COPMB.MB017 <= CONVERT(VARCHAR(12), GETDATE(), 112)
                    AND (
                        COPMB.MB018 >= CONVERT(VARCHAR(12), GETDATE(), 112)
                        OR COPMB.MB018 = ''
                    )
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
                FROM SDRD..BOMMD AS A
                    LEFT JOIN SDRD..BOMMD AS B ON A.MD003 = B.MD001
                    LEFT JOIN SDRD..BOMMD AS C ON B.MD003 = C.MD001
                    LEFT JOIN SDRD..BOMMD AS D ON C.MD003 = D.MD001
                    LEFT JOIN SDRD..BOMMD AS E ON D.MD003 = E.MD001
                    LEFT JOIN SDRD..BOMMD AS F ON E.MD003 = F.MD001
            ) AS BOM
            INNER JOIN SDRD..INVMB AS MB02 ON BOM.MD002 = MB02.MB001
    ) AS BOMMD On BOMMD.BOM001 = MOCTG.TG004
WHERE && OpenOption
    AND ((MOCTF.TF006 = 'Y'))
GROUP BY MOCTG.TG001,
    MOCTG.TG002,
    MOCTG.TG003,
    MOCTF.TF003,
    MOCTG.TG004,
    MOCTG.TG005,
    MOCTG.TG006,
    MOCTG.TG007,
    MOCTG.TG013,
    COPMB.MB008,
    INVMB.MB057,
    MOCTF.TF011,
    CMSMD.MD002,
    MOCTG.TG010,
    MOCTG.TG014,
    MOCTG.TG015,
    MOCTA.TA026,
    MOCTA.TA027,
    MOCTA.TA028,
    INVMB.MB008,
    INVMA.MA003;*/