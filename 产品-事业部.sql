USE SDRD;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#PROD') IS NOT NULL DROP TABLE #PROD;
IF OBJECT_ID('tempdb..#LATEST') IS NOT NULL DROP TABLE #LATEST;

------------------------------------------------------------
-- 1. 产品品号
------------------------------------------------------------
SELECT DISTINCT
    RTRIM(ITEMNO) AS 产品品号
INTO #ITEM
FROM LSSJ..ITEMTMP
WHERE ISNULL(RTRIM(ITEMNO), '') <> '';

------------------------------------------------------------
-- 2. 四地生产入库
-- 工作中心直接取生产入库单头 MOCTF.TF011
------------------------------------------------------------

-- 顺德：TF011 匹配工作中心，匹配不到写“顺德瑞德”
SELECT
    1 AS 账套顺序,
    '顺德瑞德' AS 账套,
    RTRIM(G.TG004) AS 产品品号,
    F.TF003 AS 入库日期,
    G.TG001 AS 入库单别,
    G.TG002 AS 入库单号,
    G.TG003 AS 入库序号,
    CASE
        WHEN CHARINDEX('-', ISNULL(D.MD011, '')) > 0
            THEN LTRIM(RTRIM(
                LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
            ))
        WHEN ISNULL(LTRIM(RTRIM(D.MD011)), '') <> ''
            THEN LTRIM(RTRIM(D.MD011))
        ELSE '顺德瑞德'
    END AS 事业部
INTO #PROD
FROM SDRD..MOCTG AS G
INNER JOIN SDRD..MOCTF AS F
    ON F.TF001 = G.TG001
   AND F.TF002 = G.TG002
INNER JOIN #ITEM AS I
    ON I.产品品号 = RTRIM(G.TG004)
LEFT JOIN SDRD..CMSMD AS D
    ON D.MD001 = F.TF011

UNION ALL

-- 浙江：全部写“浙江瑞德”
SELECT
    2,
    '浙江瑞德',
    RTRIM(G.TG004),
    F.TF003,
    G.TG001,
    G.TG002,
    G.TG003,
    '浙江瑞德'
FROM ZJRD..MOCTG AS G
INNER JOIN ZJRD..MOCTF AS F
    ON F.TF001 = G.TG001
   AND F.TF002 = G.TG002
INNER JOIN #ITEM AS I
    ON I.产品品号 = RTRIM(G.TG004)

UNION ALL

-- 安徽：TF011 匹配工作中心，匹配不到写“安徽瑞德”
SELECT
    3,
    '安徽瑞德',
    RTRIM(G.TG004),
    F.TF003,
    G.TG001,
    G.TG002,
    G.TG003,
    CASE
        WHEN CHARINDEX('-', ISNULL(D.MD011, '')) > 0
            THEN LTRIM(RTRIM(
                LEFT(D.MD011, CHARINDEX('-', D.MD011) - 1)
            ))
        WHEN ISNULL(LTRIM(RTRIM(D.MD011)), '') <> ''
            THEN LTRIM(RTRIM(D.MD011))
        ELSE '安徽瑞德'
    END
FROM AHRD..MOCTG AS G
INNER JOIN AHRD..MOCTF AS F
    ON F.TF001 = G.TG001
   AND F.TF002 = G.TG002
INNER JOIN #ITEM AS I
    ON I.产品品号 = RTRIM(G.TG004)
LEFT JOIN AHRD..CMSMD AS D
    ON D.MD001 = F.TF011

UNION ALL

-- 越南：全部写“越南瑞德”
SELECT
    4,
    '越南瑞德',
    RTRIM(G.TG004),
    F.TF003,
    G.TG001,
    G.TG002,
    G.TG003,
    '越南瑞德'
FROM YNRD..MOCTG AS G
INNER JOIN YNRD..MOCTF AS F
    ON F.TF001 = G.TG001
   AND F.TF002 = G.TG002
INNER JOIN #ITEM AS I
    ON I.产品品号 = RTRIM(G.TG004);

------------------------------------------------------------
-- 3. 每个产品、每个账套取最近一张生产入库单
------------------------------------------------------------
SELECT
    P.*,
    ROW_NUMBER() OVER
    (
        PARTITION BY P.产品品号, P.账套
        ORDER BY
            P.入库日期 DESC,
            P.入库单别 DESC,
            P.入库单号 DESC,
            P.入库序号 DESC
    ) AS RN
INTO #LATEST
FROM #PROD AS P;

------------------------------------------------------------
-- 4. 四地最近生产事业部放同一行，用 | 分隔
------------------------------------------------------------
SELECT
    I.产品品号,
    ISNULL(
        STUFF(
            (
                SELECT
                    '|' + L.事业部
                FROM #LATEST AS L
                WHERE L.产品品号 = I.产品品号
                  AND L.RN = 1
                ORDER BY L.账套顺序
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'),
            1,
            1,
            ''
        ),
        ''
    ) AS 最近生产事业部
FROM #ITEM AS I
ORDER BY I.产品品号;