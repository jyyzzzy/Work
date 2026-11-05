SELECT RTRIM(TB003) 材料品号
,MB002 材料品名
,MB003 材料规格
,SUM(TB004-TB005) 未领用量
FROM MOCTA
INNER JOIN MOCTB ON TB001 = TA001 AND TB002 = TA002 
INNER JOIN INVMB ON MB001 = TB003
WHERE (TA011 IN ('2','3') OR TA011 = '1' AND TA009 <= CONVERT(CHAR(8), DATEADD(DAY, 30, GETDATE()), 112))
AND TB004>TB005 AND TB011 <> '4' AND TA013 = 'Y' AND LEFT(TB003,1) IN ('3','5','6','7')
AND (
    MB002 LIKE '%贴片电容%'
    OR MB002 LIKE '%电阻%'
    OR MB002 LIKE '%集成电路%'
    OR MB002 LIKE '%可控硅%'
    OR MB002 LIKE '%场效应管%'
    OR MB002 LIKE '%功率半导体%'
)
GROUP BY TB003,MB002,MB003
ORDER BY TB003

SELECT '0000'+'-'+'00000000000'+'-'+'0000',TB003,MB002,MB003,'分配',SUM(CASE WHEN TB004 - TB005 <= 0 THEN 0 ELSE TB004 - TB005 END),  
0,MB004,'00000000','' 
FROM SDRD..MOCTB WITH(NOLOCK) INNER JOIN SDRD..MOCTA WITH(NOLOCK) ON TA001 = TB001 AND TA002 = TB002   
INNER JOIN SDRD..INVMB WITH(NOLOCK) ON TB003 = MB001 
WHERE TA013 = 'Y' AND (TA011 = '1' OR TA011 = '2' OR TA011 = '3')  
GROUP BY TB003,MB002,MB003,MB004  

SELECT TB001+'-'+TB002+'-'+'0000',TB003,TA006,TA035+'><'+TA034,'工单'+'-'+MOCTA.UDF02,TB004,CASE WHEN TB004-TB005 <=0 THEN 0 ELSE TB004-TB005 END,TA007,
CASE TA001 WHEN '5109' THEN  TD.TD012 ELSE CASE TA001  WHEN '5111' THEN ATD.TD012 ELSE TA009  END  END TA009
 ,''  
FROM SDRD..MOCTB TB WITH(NOLOCK)
INNER JOIN SDRD..MOCTA WITH(NOLOCK) ON TA001 = TB001 AND TA002 = TB002   
LEFT JOIN ZJRD..PURTD TD WITH(NOLOCK) ON TB.UDF01=TD.TD001+'-'+TD.TD002+'-'+TD.TD003 AND TA001='5109'
LEFT JOIN AHRD..PURTD ATD WITH(NOLOCK) ON TB.UDF01=ATD.TD001+'-'+ATD.TD002+'-'+ATD.TD003 AND TA001='5111'
WHERE (TA011 = '1' OR TA011 = '2' OR TA011 = '3') AND TA013 = 'Y' AND TB004>0  




SELECT
    A.所属基地,
    A.材料品号,
    A.材料品名,
    A.材料规格,
    A.未领用量,
    ISNULL(P.有效采购单价, 0) AS 有效采购单价
FROM
(
    SELECT
        所属基地,
        RTRIM(TB003) AS 材料品号,
        MB002 AS 材料品名,
        MB003 AS 材料规格,
        SUM(未领用量) AS 未领用量
    FROM
    (
        /* 广东瑞德 */
        SELECT
            '广东瑞德' AS 所属基地,
            MOCTB.TB003,
            INVMB.MB002,
            INVMB.MB003,
            MOCTB.TB004 - MOCTB.TB005 AS 未领用量
        FROM SDRD..MOCTA
        INNER JOIN SDRD..MOCTB
            ON MOCTB.TB001 = MOCTA.TA001
           AND MOCTB.TB002 = MOCTA.TA002
        INNER JOIN SDRD..INVMB
            ON INVMB.MB001 = MOCTB.TB003
        WHERE
            (
                MOCTA.TA011 IN ('2', '3')
                OR (
                    MOCTA.TA011 = '1'
                    AND MOCTA.TA009 <= CONVERT(CHAR(8), DATEADD(DAY, 30, GETDATE()), 112)
                )
            )
            AND MOCTB.TB004 > MOCTB.TB005
            AND MOCTB.TB011 <> '4'
            AND MOCTA.TA013 = 'Y'
            AND LEFT(MOCTB.TB003, 1) IN ('3', '5', '6', '7')
            --AND (
            --    INVMB.MB002 LIKE '%贴片电容%'
            --    OR INVMB.MB002 LIKE '%贴片电阻%'
            --    OR INVMB.MB002 LIKE '%集成电路%'
            --    OR INVMB.MB002 LIKE '%可控硅%'
            --    OR INVMB.MB002 LIKE '%场效应管%'
            --    OR INVMB.MB002 LIKE '%功率半导体%'
            --    OR INVMB.MB002 LIKE '%可变流半导体%'
            --)

        UNION ALL

        /* 浙江瑞德 */
        SELECT
            '浙江瑞德' AS 所属基地,
            MOCTB.TB003,
            INVMB.MB002,
            INVMB.MB003,
            MOCTB.TB004 - MOCTB.TB005 AS 未领用量
        FROM ZJRD..MOCTA
        INNER JOIN ZJRD..MOCTB
            ON MOCTB.TB001 = MOCTA.TA001
           AND MOCTB.TB002 = MOCTA.TA002
        INNER JOIN ZJRD..INVMB
            ON INVMB.MB001 = MOCTB.TB003
        WHERE
            (
                MOCTA.TA011 IN ('2', '3')
                OR (
                    MOCTA.TA011 = '1'
                    AND MOCTA.TA009 <= CONVERT(CHAR(8), DATEADD(DAY, 30, GETDATE()), 112)
                )
            )
            AND MOCTB.TB004 > MOCTB.TB005
            AND MOCTB.TB011 <> '4'
            AND MOCTA.TA013 = 'Y'
            AND LEFT(MOCTB.TB003, 1) IN ('3', '5', '6', '7')
            --AND (
            --    INVMB.MB002 LIKE '%贴片电容%'
            --    OR INVMB.MB002 LIKE '%贴片电阻%'
            --    OR INVMB.MB002 LIKE '%集成电路%'
            --    OR INVMB.MB002 LIKE '%可控硅%'
            --    OR INVMB.MB002 LIKE '%场效应管%'
            --    OR INVMB.MB002 LIKE '%功率半导体%'
            --    OR INVMB.MB002 LIKE '%可变流半导体%'
            --)

        UNION ALL

        /* 安徽瑞德 */
        SELECT
            '安徽瑞德' AS 所属基地,
            MOCTB.TB003,
            INVMB.MB002,
            INVMB.MB003,
            MOCTB.TB004 - MOCTB.TB005 AS 未领用量
        FROM AHRD..MOCTA
        INNER JOIN AHRD..MOCTB
            ON MOCTB.TB001 = MOCTA.TA001
           AND MOCTB.TB002 = MOCTA.TA002
        INNER JOIN AHRD..INVMB
            ON INVMB.MB001 = MOCTB.TB003
        WHERE
            (
                MOCTA.TA011 IN ('2', '3')
                OR (
                    MOCTA.TA011 = '1'
                    AND MOCTA.TA009 <= CONVERT(CHAR(8), DATEADD(DAY, 30, GETDATE()), 112)
                )
            )
            AND MOCTB.TB004 > MOCTB.TB005
            AND MOCTB.TB011 <> '4'
            AND MOCTA.TA013 = 'Y'
            AND LEFT(MOCTB.TB003, 1) IN ('3', '5', '6', '7')
            --AND (
            --    INVMB.MB002 LIKE '%贴片电容%'
            --    OR INVMB.MB002 LIKE '%贴片电阻%'
            --    OR INVMB.MB002 LIKE '%集成电路%'
            --    OR INVMB.MB002 LIKE '%可控硅%'
            --    OR INVMB.MB002 LIKE '%场效应管%'
            --    OR INVMB.MB002 LIKE '%功率半导体%'
            --    OR INVMB.MB002 LIKE '%可变流半导体%'
            --)

        UNION ALL

        /* 越南瑞德 */
        SELECT
            '越南瑞德' AS 所属基地,
            MOCTB.TB003,
            INVMB.MB002,
            INVMB.MB003,
            MOCTB.TB004 - MOCTB.TB005 AS 未领用量
        FROM YNRD..MOCTA
        INNER JOIN YNRD..MOCTB
            ON MOCTB.TB001 = MOCTA.TA001
           AND MOCTB.TB002 = MOCTA.TA002
        INNER JOIN YNRD..INVMB
            ON INVMB.MB001 = MOCTB.TB003
        WHERE
            (
                MOCTA.TA011 IN ('2', '3')
                OR (
                    MOCTA.TA011 = '1'
                    AND MOCTA.TA009 <= CONVERT(CHAR(8), DATEADD(DAY, 30, GETDATE()), 112)
                )
            )
            AND MOCTB.TB004 > MOCTB.TB005
            AND MOCTB.TB011 <> '4'
            AND MOCTA.TA013 = 'Y'
            AND LEFT(MOCTB.TB003, 1) IN ('3', '5', '6', '7')
            --AND (
            --    INVMB.MB002 LIKE '%贴片电容%'
            --    OR INVMB.MB002 LIKE '%贴片电阻%'
            --    OR INVMB.MB002 LIKE '%集成电路%'
            --    OR INVMB.MB002 LIKE '%可控硅%'
            --    OR INVMB.MB002 LIKE '%场效应管%'
            --    OR INVMB.MB002 LIKE '%功率半导体%'
            --    OR INVMB.MB002 LIKE '%可变流半导体%'
            --)
    ) B
    GROUP BY
        所属基地,
        TB003,
        MB002,
        MB003
) A

OUTER APPLY
(
    SELECT TOP 1
        PURMB.MB011 AS 有效采购单价
    FROM SDRD..PURMB
    WHERE RTRIM(PURMB.MB001) = A.材料品号
      AND PURMB.MB003 = 'RMB'
      AND PURMB.MB014 <= CONVERT(CHAR(8), GETDATE(), 112)
      AND PURMB.MB015 > CONVERT(CHAR(8), GETDATE(), 112)
    ORDER BY
        PURMB.MB014 DESC,
        PURMB.MB008 DESC
) P

ORDER BY
    A.所属基地,
    A.材料品号;