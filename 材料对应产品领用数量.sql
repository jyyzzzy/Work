IF OBJECT_ID('tempdb..#ITEM_RAW') IS NOT NULL DROP TABLE #ITEM_RAW;
IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#ISSUE_RAW') IS NOT NULL DROP TABLE #ISSUE_RAW;
IF OBJECT_ID('tempdb..#ISSUE_NET') IS NOT NULL DROP TABLE #ISSUE_NET;
IF OBJECT_ID('tempdb..#A') IS NOT NULL DROP TABLE #A;
IF OBJECT_ID('tempdb..#RESULT') IS NOT NULL DROP TABLE #RESULT;
IF OBJECT_ID('tempdb..#INVMB') IS NOT NULL DROP TABLE #INVMB;
--DELETE FROM LSSJ..ITEMTMP
--="INSERT INTO LSSJ..ITEMTMP(ITEMNO) VALUES('"&&"');"
------------------------------------------------------------
-- 1. ITEMTMP 原始材料清单
------------------------------------------------------------
SELECT DISTINCT
    LTRIM(RTRIM(ITEMNO)) COLLATE DATABASE_DEFAULT AS 材料品号
INTO #ITEM_RAW
FROM LSSJ..ITEMTMP
WHERE ISNULL(LTRIM(RTRIM(ITEMNO)), '') <> '';

CREATE UNIQUE CLUSTERED INDEX IX_ITEM_RAW_材料品号
ON #ITEM_RAW(材料品号);

------------------------------------------------------------
-- 2. 先排查 ITEMTMP 料号是否有领退料
--    只保留有领退料记录的料号，减少后续数据量
------------------------------------------------------------
SELECT
    X.账套,
    X.工单单别,
    X.工单单号,
    X.材料品号,
    X.实际领用数量
INTO #ISSUE_RAW
FROM
(
    SELECT
        'SDRD' AS 账套,
        LTRIM(RTRIM(TE.TE011)) COLLATE DATABASE_DEFAULT AS 工单单别,
        LTRIM(RTRIM(TE.TE012)) COLLATE DATABASE_DEFAULT AS 工单单号,
        LTRIM(RTRIM(TE.TE004)) COLLATE DATABASE_DEFAULT AS 材料品号,
        CASE
            WHEN TC.TC001 LIKE '54%' THEN CAST(ISNULL(TE.TE005, 0) AS DECIMAL(38,8))
            WHEN TC.TC001 LIKE '56%' THEN CAST(0 - ISNULL(TE.TE005, 0) AS DECIMAL(38,8))
            ELSE CAST(0 AS DECIMAL(38,8))
        END AS 实际领用数量
    FROM SDRD..MOCTC TC
    INNER JOIN SDRD..MOCTE TE
        ON TE.TE001 = TC.TC001
       AND TE.TE002 = TC.TC002
    INNER JOIN #ITEM_RAW I
        ON LTRIM(RTRIM(TE.TE004)) COLLATE DATABASE_DEFAULT = I.材料品号
    WHERE TC.TC003 >= '20260101'
      AND TC.TC003 <=  '20261231'
      AND TE.TE019 = 'Y'
      AND (TC.TC001 LIKE '54%' OR TC.TC001 LIKE '56%')
      AND ISNULL(TE.TE005, 0) <> 0
      AND ISNULL(LTRIM(RTRIM(TE.TE011)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TE.TE012)), '') <> ''

    UNION ALL

    SELECT
        'ZJRD' AS 账套,
        LTRIM(RTRIM(TE.TE011)) COLLATE DATABASE_DEFAULT AS 工单单别,
        LTRIM(RTRIM(TE.TE012)) COLLATE DATABASE_DEFAULT AS 工单单号,
        LTRIM(RTRIM(TE.TE004)) COLLATE DATABASE_DEFAULT AS 材料品号,
        CASE
            WHEN TC.TC001 LIKE '54%' THEN CAST(ISNULL(TE.TE005, 0) AS DECIMAL(38,8))
            WHEN TC.TC001 LIKE '56%' THEN CAST(0 - ISNULL(TE.TE005, 0) AS DECIMAL(38,8))
            ELSE CAST(0 AS DECIMAL(38,8))
        END AS 实际领用数量
    FROM ZJRD..MOCTC TC
    INNER JOIN ZJRD..MOCTE TE
        ON TE.TE001 = TC.TC001
       AND TE.TE002 = TC.TC002
    INNER JOIN #ITEM_RAW I
        ON LTRIM(RTRIM(TE.TE004)) COLLATE DATABASE_DEFAULT = I.材料品号
    WHERE TC.TC003 >= '20260101'
      AND TC.TC003 <=  '20261231'
      AND TE.TE019 = 'Y'
      AND (TC.TC001 LIKE '54%' OR TC.TC001 LIKE '56%')
      AND ISNULL(TE.TE005, 0) <> 0
      AND ISNULL(LTRIM(RTRIM(TE.TE011)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TE.TE012)), '') <> ''

    UNION ALL

    SELECT
        'AHRD' AS 账套,
        LTRIM(RTRIM(TE.TE011)) COLLATE DATABASE_DEFAULT AS 工单单别,
        LTRIM(RTRIM(TE.TE012)) COLLATE DATABASE_DEFAULT AS 工单单号,
        LTRIM(RTRIM(TE.TE004)) COLLATE DATABASE_DEFAULT AS 材料品号,
        CASE
            WHEN TC.TC001 LIKE '54%' THEN CAST(ISNULL(TE.TE005, 0) AS DECIMAL(38,8))
            WHEN TC.TC001 LIKE '56%' THEN CAST(0 - ISNULL(TE.TE005, 0) AS DECIMAL(38,8))
            ELSE CAST(0 AS DECIMAL(38,8))
        END AS 实际领用数量
    FROM AHRD..MOCTC TC
    INNER JOIN AHRD..MOCTE TE
        ON TE.TE001 = TC.TC001
       AND TE.TE002 = TC.TC002
    INNER JOIN #ITEM_RAW I
        ON LTRIM(RTRIM(TE.TE004)) COLLATE DATABASE_DEFAULT = I.材料品号
    WHERE TC.TC003 >= '20260101'
      AND TC.TC003 <=  '20261231'
      AND TE.TE019 = 'Y'
      AND (TC.TC001 LIKE '54%' OR TC.TC001 LIKE '56%')
      AND ISNULL(TE.TE005, 0) <> 0
      AND ISNULL(LTRIM(RTRIM(TE.TE011)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TE.TE012)), '') <> ''

    UNION ALL

    SELECT
        'YNRD' AS 账套,
        LTRIM(RTRIM(TE.TE011)) COLLATE DATABASE_DEFAULT AS 工单单别,
        LTRIM(RTRIM(TE.TE012)) COLLATE DATABASE_DEFAULT AS 工单单号,
        LTRIM(RTRIM(TE.TE004)) COLLATE DATABASE_DEFAULT AS 材料品号,
        CASE
            WHEN TC.TC001 LIKE '54%' THEN CAST(ISNULL(TE.TE005, 0) AS DECIMAL(38,8))
            WHEN TC.TC001 LIKE '56%' THEN CAST(0 - ISNULL(TE.TE005, 0) AS DECIMAL(38,8))
            ELSE CAST(0 AS DECIMAL(38,8))
        END AS 实际领用数量
    FROM YNRD..MOCTC TC
    INNER JOIN YNRD..MOCTE TE
        ON TE.TE001 = TC.TC001
       AND TE.TE002 = TC.TC002
    INNER JOIN #ITEM_RAW I
        ON LTRIM(RTRIM(TE.TE004)) COLLATE DATABASE_DEFAULT = I.材料品号
    WHERE TC.TC003 >= '20260101'
      AND TC.TC003 <=  '20261231'
      AND TE.TE019 = 'Y'
      AND (TC.TC001 LIKE '54%' OR TC.TC001 LIKE '56%')
      AND ISNULL(TE.TE005, 0) <> 0
      AND ISNULL(LTRIM(RTRIM(TE.TE011)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TE.TE012)), '') <> ''
) X;

------------------------------------------------------------
-- 3. 汇总实际领用数量
------------------------------------------------------------
SELECT
    X.账套,
    X.工单单别,
    X.工单单号,
    X.材料品号,
    SUM(X.实际领用数量) AS 实际领用数量
INTO #ISSUE_NET
FROM #ISSUE_RAW X
GROUP BY
    X.账套,
    X.工单单别,
    X.工单单号,
    X.材料品号
HAVING SUM(X.实际领用数量) <> 0;

CREATE INDEX IX_ISSUE_NET_工单
ON #ISSUE_NET(账套, 工单单别, 工单单号);

CREATE INDEX IX_ISSUE_NET_材料
ON #ISSUE_NET(账套, 材料品号);

------------------------------------------------------------
-- 4. 过滤后的 ITEMTMP 材料清单
--    无领用的 ITEMTMP 料号已经被排除
------------------------------------------------------------
SELECT DISTINCT
    材料品号
INTO #ITEM
FROM #ISSUE_NET;

CREATE UNIQUE CLUSTERED INDEX IX_ITEM_材料品号
ON #ITEM(材料品号);

------------------------------------------------------------
-- 如果没有任何领用，直接返回空结果，避免继续跑订单/工单/物料资料
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM #ITEM)
BEGIN
    SELECT
        CAST(NULL AS VARCHAR(50)) AS 材料品号,
        CAST(NULL AS NVARCHAR(255)) AS 材料品名,
        CAST(NULL AS NVARCHAR(255)) AS 材料规格,
        CAST(NULL AS VARCHAR(50)) AS 产品品号,
        CAST(NULL AS NVARCHAR(255)) AS 产品品名,
        CAST(NULL AS NVARCHAR(255)) AS 产品规格,
        CAST(NULL AS DECIMAL(38,8)) AS 领用数量,
        CAST(NULL AS NVARCHAR(50)) AS 事业部,
        CAST(NULL AS VARCHAR(20)) AS 账套
    WHERE 1 = 0;

    RETURN;
END;

------------------------------------------------------------
-- 5. A表：订单 - 工单 - 产品 - 事业部 - 账套
--    只取已经存在领用的工单，减少订单/工单关联量
------------------------------------------------------------
SELECT DISTINCT
    X.账套,
    X.订单单别,
    X.订单单号,
    X.订单序号,
    X.工单单别,
    X.工单单号,
    X.产品品号,
    X.事业部
INTO #A
FROM
(
    SELECT
        'SDRD' AS 账套,
        LTRIM(RTRIM(TD.TD001)) COLLATE DATABASE_DEFAULT AS 订单单别,
        LTRIM(RTRIM(TD.TD002)) COLLATE DATABASE_DEFAULT AS 订单单号,
        LTRIM(RTRIM(TD.TD003)) COLLATE DATABASE_DEFAULT AS 订单序号,
        LTRIM(RTRIM(TA.TA001)) COLLATE DATABASE_DEFAULT AS 工单单别,
        LTRIM(RTRIM(TA.TA002)) COLLATE DATABASE_DEFAULT AS 工单单号,
        LTRIM(RTRIM(TD.TD004)) COLLATE DATABASE_DEFAULT AS 产品品号,
        ISNULL(NULLIF(LTRIM(RTRIM(SUBSTRING(ME.ME002, 1, 4))), ''), '未取到') COLLATE DATABASE_DEFAULT AS 事业部
    FROM SDRD..COPTC TC
    INNER JOIN SDRD..COPTD TD
        ON TD.TD001 = TC.TC001
       AND TD.TD002 = TC.TC002
    INNER JOIN SDRD..MOCTA TA
        ON TA.TA026 = TD.TD001
       AND TA.TA027 = TD.TD002
       AND TA.TA028 = TD.TD003
    LEFT JOIN SDRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    LEFT JOIN SDRD..CMSME ME
        ON ME.ME001 = MD.MD015
    WHERE TD.TD021 = 'Y'
      AND ISNULL(LTRIM(RTRIM(TD.TD004)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TA.TA001)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TA.TA002)), '') <> ''
      AND EXISTS
      (
          SELECT 1
          FROM #ISSUE_NET I
          WHERE I.账套 = 'SDRD'
            AND I.工单单别 = LTRIM(RTRIM(TA.TA001)) COLLATE DATABASE_DEFAULT
            AND I.工单单号 = LTRIM(RTRIM(TA.TA002)) COLLATE DATABASE_DEFAULT
      )

    UNION ALL

    SELECT
        'ZJRD' AS 账套,
        LTRIM(RTRIM(TD.TD001)) COLLATE DATABASE_DEFAULT AS 订单单别,
        LTRIM(RTRIM(TD.TD002)) COLLATE DATABASE_DEFAULT AS 订单单号,
        LTRIM(RTRIM(TD.TD003)) COLLATE DATABASE_DEFAULT AS 订单序号,
        LTRIM(RTRIM(TA.TA001)) COLLATE DATABASE_DEFAULT AS 工单单别,
        LTRIM(RTRIM(TA.TA002)) COLLATE DATABASE_DEFAULT AS 工单单号,
        LTRIM(RTRIM(TD.TD004)) COLLATE DATABASE_DEFAULT AS 产品品号,
        ISNULL(NULLIF(LTRIM(RTRIM(SUBSTRING(ME.ME002, 1, 4))), ''), '未取到') COLLATE DATABASE_DEFAULT AS 事业部
    FROM ZJRD..COPTC TC
    INNER JOIN ZJRD..COPTD TD
        ON TD.TD001 = TC.TC001
       AND TD.TD002 = TC.TC002
    INNER JOIN ZJRD..MOCTA TA
        ON TA.TA026 = TD.TD001
       AND TA.TA027 = TD.TD002
       AND TA.TA028 = TD.TD003
    LEFT JOIN ZJRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    LEFT JOIN ZJRD..CMSME ME
        ON ME.ME001 = MD.MD015
    WHERE TD.TD021 = 'Y'
      AND ISNULL(LTRIM(RTRIM(TD.TD004)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TA.TA001)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TA.TA002)), '') <> ''
      AND EXISTS
      (
          SELECT 1
          FROM #ISSUE_NET I
          WHERE I.账套 = 'ZJRD'
            AND I.工单单别 = LTRIM(RTRIM(TA.TA001)) COLLATE DATABASE_DEFAULT
            AND I.工单单号 = LTRIM(RTRIM(TA.TA002)) COLLATE DATABASE_DEFAULT
      )

    UNION ALL

    SELECT
        'AHRD' AS 账套,
        LTRIM(RTRIM(TD.TD001)) COLLATE DATABASE_DEFAULT AS 订单单别,
        LTRIM(RTRIM(TD.TD002)) COLLATE DATABASE_DEFAULT AS 订单单号,
        LTRIM(RTRIM(TD.TD003)) COLLATE DATABASE_DEFAULT AS 订单序号,
        LTRIM(RTRIM(TA.TA001)) COLLATE DATABASE_DEFAULT AS 工单单别,
        LTRIM(RTRIM(TA.TA002)) COLLATE DATABASE_DEFAULT AS 工单单号,
        LTRIM(RTRIM(TD.TD004)) COLLATE DATABASE_DEFAULT AS 产品品号,
        ISNULL(NULLIF(LTRIM(RTRIM(SUBSTRING(ME.ME002, 1, 4))), ''), '未取到') COLLATE DATABASE_DEFAULT AS 事业部
    FROM AHRD..COPTC TC
    INNER JOIN AHRD..COPTD TD
        ON TD.TD001 = TC.TC001
       AND TD.TD002 = TC.TC002
    INNER JOIN AHRD..MOCTA TA
        ON TA.TA026 = TD.TD001
       AND TA.TA027 = TD.TD002
       AND TA.TA028 = TD.TD003
    LEFT JOIN AHRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    LEFT JOIN AHRD..CMSME ME
        ON ME.ME001 = MD.MD015
    WHERE TD.TD021 = 'Y'
      AND ISNULL(LTRIM(RTRIM(TD.TD004)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TA.TA001)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TA.TA002)), '') <> ''
      AND EXISTS
      (
          SELECT 1
          FROM #ISSUE_NET I
          WHERE I.账套 = 'AHRD'
            AND I.工单单别 = LTRIM(RTRIM(TA.TA001)) COLLATE DATABASE_DEFAULT
            AND I.工单单号 = LTRIM(RTRIM(TA.TA002)) COLLATE DATABASE_DEFAULT
      )

    UNION ALL

    SELECT
        'YNRD' AS 账套,
        LTRIM(RTRIM(TD.TD001)) COLLATE DATABASE_DEFAULT AS 订单单别,
        LTRIM(RTRIM(TD.TD002)) COLLATE DATABASE_DEFAULT AS 订单单号,
        LTRIM(RTRIM(TD.TD003)) COLLATE DATABASE_DEFAULT AS 订单序号,
        LTRIM(RTRIM(TA.TA001)) COLLATE DATABASE_DEFAULT AS 工单单别,
        LTRIM(RTRIM(TA.TA002)) COLLATE DATABASE_DEFAULT AS 工单单号,
        LTRIM(RTRIM(TD.TD004)) COLLATE DATABASE_DEFAULT AS 产品品号,
        ISNULL(NULLIF(LTRIM(RTRIM(SUBSTRING(ME.ME002, 1, 4))), ''), '未取到') COLLATE DATABASE_DEFAULT AS 事业部
    FROM YNRD..COPTC TC
    INNER JOIN YNRD..COPTD TD
        ON TD.TD001 = TC.TC001
       AND TD.TD002 = TC.TC002
    INNER JOIN YNRD..MOCTA TA
        ON TA.TA026 = TD.TD001
       AND TA.TA027 = TD.TD002
       AND TA.TA028 = TD.TD003
    LEFT JOIN YNRD..CMSMD MD
        ON MD.MD001 = TA.TA021
    LEFT JOIN YNRD..CMSME ME
        ON ME.ME001 = MD.MD015
    WHERE TD.TD021 = 'Y'
      AND ISNULL(LTRIM(RTRIM(TD.TD004)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TA.TA001)), '') <> ''
      AND ISNULL(LTRIM(RTRIM(TA.TA002)), '') <> ''
      AND EXISTS
      (
          SELECT 1
          FROM #ISSUE_NET I
          WHERE I.账套 = 'YNRD'
            AND I.工单单别 = LTRIM(RTRIM(TA.TA001)) COLLATE DATABASE_DEFAULT
            AND I.工单单号 = LTRIM(RTRIM(TA.TA002)) COLLATE DATABASE_DEFAULT
      )
) X;

CREATE INDEX IX_A_工单
ON #A(账套, 工单单别, 工单单号);

CREATE INDEX IX_A_产品
ON #A(账套, 产品品号);

------------------------------------------------------------
-- 6. A表直接匹配工单领退料表
------------------------------------------------------------
SELECT
    A.账套,
    I.材料品号,
    A.产品品号,
    A.事业部,
    SUM(I.实际领用数量) AS 领用数量
INTO #RESULT
FROM #A A
INNER JOIN #ISSUE_NET I
    ON I.账套 = A.账套
   AND I.工单单别 = A.工单单别
   AND I.工单单号 = A.工单单号
GROUP BY
    A.账套,
    I.材料品号,
    A.产品品号,
    A.事业部
HAVING SUM(I.实际领用数量) <> 0;

CREATE UNIQUE CLUSTERED INDEX IX_RESULT_KEY
ON #RESULT(材料品号, 产品品号, 事业部, 账套);

------------------------------------------------------------
-- 7. 先提取本次结果实际需要取物料资料的品号
--    避免扫描四地 INVMB 全表
------------------------------------------------------------
IF OBJECT_ID('tempdb..#NEED_ITEM') IS NOT NULL DROP TABLE #NEED_ITEM;

SELECT DISTINCT
    R.账套,
    R.材料品号 AS ITEMNO
INTO #NEED_ITEM
FROM #RESULT R
WHERE ISNULL(R.材料品号, '') <> ''

UNION

SELECT DISTINCT
    R.账套,
    R.产品品号 AS ITEMNO
FROM #RESULT R
WHERE ISNULL(R.产品品号, '') <> '';

CREATE UNIQUE CLUSTERED INDEX IX_NEED_ITEM_KEY
ON #NEED_ITEM(账套, ITEMNO);


------------------------------------------------------------
-- 8. 物料资料
--    用 #NEED_ITEM 主动关联 INVMB
--    不要对 INVMB.MB001 使用 LTRIM/RTRIM，保证能走 MB001 索引
------------------------------------------------------------
SELECT
    X.账套,
    X.ITEMNO,
    MAX(X.MB002) AS MB002,
    MAX(X.MB003) AS MB003
INTO #INVMB
FROM
(
    SELECT
        'SDRD' AS 账套,
        N.ITEMNO,
        M.MB002,
        M.MB003
    FROM #NEED_ITEM N
    INNER JOIN SDRD..INVMB M WITH(NOLOCK)
        ON M.MB001 = N.ITEMNO COLLATE DATABASE_DEFAULT
    WHERE N.账套 = 'SDRD'

    UNION ALL

    SELECT
        'ZJRD' AS 账套,
        N.ITEMNO,
        M.MB002,
        M.MB003
    FROM #NEED_ITEM N
    INNER JOIN ZJRD..INVMB M WITH(NOLOCK)
        ON M.MB001 = N.ITEMNO COLLATE DATABASE_DEFAULT
    WHERE N.账套 = 'ZJRD'

    UNION ALL

    SELECT
        'AHRD' AS 账套,
        N.ITEMNO,
        M.MB002,
        M.MB003
    FROM #NEED_ITEM N
    INNER JOIN AHRD..INVMB M WITH(NOLOCK)
        ON M.MB001 = N.ITEMNO COLLATE DATABASE_DEFAULT
    WHERE N.账套 = 'AHRD'

    UNION ALL

    SELECT
        'YNRD' AS 账套,
        N.ITEMNO,
        M.MB002,
        M.MB003
    FROM #NEED_ITEM N
    INNER JOIN YNRD..INVMB M WITH(NOLOCK)
        ON M.MB001 = N.ITEMNO COLLATE DATABASE_DEFAULT
    WHERE N.账套 = 'YNRD'
) X
GROUP BY
    X.账套,
    X.ITEMNO;

CREATE UNIQUE CLUSTERED INDEX IX_INVMB_KEY
ON #INVMB(账套, ITEMNO);

------------------------------------------------------------
-- 8. 最终输出
------------------------------------------------------------
SELECT
    R.材料品号,
    MATL.MB002 AS 材料品名,
    MATL.MB003 AS 材料规格,

    R.产品品号,
    PROD.MB002 AS 产品品名,
    PROD.MB003 AS 产品规格,

    R.领用数量,
    R.事业部,
    R.账套 AS COMPANY
FROM #RESULT R
LEFT JOIN #INVMB MATL
    ON MATL.账套 = R.账套
   AND MATL.ITEMNO = R.材料品号
LEFT JOIN #INVMB PROD
    ON PROD.账套 = R.账套
   AND PROD.ITEMNO = R.产品品号
ORDER BY
    R.材料品号,
    R.产品品号,
    R.事业部,
    R.账套;