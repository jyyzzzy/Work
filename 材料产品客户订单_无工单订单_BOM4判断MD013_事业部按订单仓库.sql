


IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#BOM') IS NOT NULL DROP TABLE #BOM;
IF OBJECT_ID('tempdb..#ANCESTOR') IS NOT NULL DROP TABLE #ANCESTOR;
IF OBJECT_ID('tempdb..#POTENTIAL_PROD') IS NOT NULL DROP TABLE #POTENTIAL_PROD;
IF OBJECT_ID('tempdb..#ORDER_BASE') IS NOT NULL DROP TABLE #ORDER_BASE;
IF OBJECT_ID('tempdb..#ORDER_AGG') IS NOT NULL DROP TABLE #ORDER_AGG;
IF OBJECT_ID('tempdb..#ORDER_CUST_AGG') IS NOT NULL DROP TABLE #ORDER_CUST_AGG;
IF OBJECT_ID('tempdb..#RELATION') IS NOT NULL DROP TABLE #RELATION;
IF OBJECT_ID('tempdb..#REL_PROD') IS NOT NULL DROP TABLE #REL_PROD;
IF OBJECT_ID('tempdb..#ORDER_DEPT') IS NOT NULL DROP TABLE #ORDER_DEPT;
IF OBJECT_ID('tempdb..#CUSTOMER_DEPT') IS NOT NULL DROP TABLE #CUSTOMER_DEPT;
IF OBJECT_ID('tempdb..#INVMB') IS NOT NULL DROP TABLE #INVMB;

------------------------------------------------------------
-- 1. 材料清单
------------------------------------------------------------
SELECT DISTINCT
    LTRIM(RTRIM(ITEMNO)) COLLATE DATABASE_DEFAULT AS ITEMNO
INTO #ITEM
FROM LSSJ..ITEMTMP
WHERE ISNULL(LTRIM(RTRIM(ITEMNO)), '') <> '';

-- 单个材料测试时使用：
-- SELECT '304090316100' ITEMNO INTO #ITEM;

CREATE UNIQUE CLUSTERED INDEX IX_ITEM_ITEMNO ON #ITEM(ITEMNO);

------------------------------------------------------------
-- 2. BOM 预清洗
--    规则：父件 MD001 为 4 开头时，只累计 MD013='Y' 的用量；其他父件正常累计
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT AS CHILD,
    LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT AS PARENT,
    SUM(
        CASE
            WHEN (MD001 LIKE '4%' AND MD013 = 'Y')
              OR MD001 NOT LIKE '4%'
            THEN
                CAST(ISNULL(MD006, 0) AS DECIMAL(38,12)) /
                CAST(ISNULL(NULLIF(MD007, 0), 1) AS DECIMAL(38,12))
            ELSE 0
        END
    ) AS CNT
INTO #BOM
FROM SDRD..BOMMD
WHERE ISNULL(LTRIM(RTRIM(MD003)), '') <> ''
  AND ISNULL(LTRIM(RTRIM(MD001)), '') <> ''
GROUP BY
    LTRIM(RTRIM(MD003)) COLLATE DATABASE_DEFAULT,
    LTRIM(RTRIM(MD001)) COLLATE DATABASE_DEFAULT;

CREATE INDEX IX_BOM_CHILD ON #BOM(CHILD) INCLUDE(PARENT, CNT);
CREATE INDEX IX_BOM_PARENT ON #BOM(PARENT);

------------------------------------------------------------
-- 3. 从材料向上递归，找所有可能产品
------------------------------------------------------------
;WITH U AS
(
    SELECT
        I.ITEMNO AS COMP,
        B.PARENT AS P,
        CAST(B.CNT AS DECIMAL(38,12)) AS CNT,
        CAST(1 AS INT) AS LVL,
        CAST('|' + I.ITEMNO + '|' + B.PARENT + '|' AS VARCHAR(4000)) AS PATH
    FROM #ITEM I
    INNER JOIN #BOM B
        ON B.CHILD = I.ITEMNO

    UNION ALL

    SELECT
        U.COMP,
        B.PARENT AS P,
        CAST(U.CNT * B.CNT AS DECIMAL(38,12)) AS CNT,
        U.LVL + 1 AS LVL,
        CAST(U.PATH + B.PARENT + '|' AS VARCHAR(4000)) AS PATH
    FROM U
    INNER JOIN #BOM B
        ON B.CHILD = U.P
    WHERE U.LVL < 50
      AND CHARINDEX('|' + B.PARENT + '|', U.PATH) = 0
)
SELECT
    COMP,
    P,
    CNT
INTO #ANCESTOR
FROM U
OPTION (MAXRECURSION 100);

CREATE INDEX IX_ANCESTOR_P ON #ANCESTOR(P);
CREATE INDEX IX_ANCESTOR_COMP ON #ANCESTOR(COMP);

------------------------------------------------------------
-- 4. 可能产品清单
------------------------------------------------------------
SELECT DISTINCT
    P AS PROD
INTO #POTENTIAL_PROD
FROM #ANCESTOR
WHERE ISNULL(P, '') <> '';

CREATE UNIQUE CLUSTERED INDEX IX_POTENTIAL_PROD ON #POTENTIAL_PROD(PROD);

------------------------------------------------------------
-- 5. 四账套订单基础数据
--    明细粒度：账套 + 订单单别 + 订单单号 + 订单序号 + 产品 + 客户 + 入库仓库
------------------------------------------------------------
SELECT
    X.账套,
    X.TD001,
    X.TD002,
    X.TD003,
    X.PROD,
    X.入库仓库,
    X.客户编号,
    X.客户简称,
    X.[2025年订单数量],
    X.[2026年订单数量]
INTO #ORDER_BASE
FROM
(
    SELECT
        'SDRD' AS 账套,
        LTRIM(RTRIM(TD.TD001)) COLLATE DATABASE_DEFAULT AS TD001,
        LTRIM(RTRIM(TD.TD002)) COLLATE DATABASE_DEFAULT AS TD002,
        LTRIM(RTRIM(TD.TD003)) COLLATE DATABASE_DEFAULT AS TD003,
        P.PROD,
        LTRIM(RTRIM(TD.TD007)) COLLATE DATABASE_DEFAULT AS 入库仓库,
        LTRIM(RTRIM(TC.TC004)) COLLATE DATABASE_DEFAULT AS 客户编号,
        NULLIF(LTRIM(RTRIM(MA.MA002)), '') COLLATE DATABASE_DEFAULT AS 客户简称,
        CASE WHEN TC.TC003 >= '20250101' AND TC.TC003 < '20260101'
             THEN CAST(ISNULL(TD.TD008, 0) AS DECIMAL(38,8)) ELSE 0 END AS [2025年订单数量],
        CASE WHEN TC.TC003 >= '20260101' AND TC.TC003 < '20270101'
             THEN CAST(ISNULL(TD.TD008, 0) AS DECIMAL(38,8)) ELSE 0 END AS [2026年订单数量]
    FROM SDRD..COPTC TC
    INNER JOIN SDRD..COPTD TD
        ON TD.TD001 = TC.TC001
       AND TD.TD002 = TC.TC002
    INNER JOIN #POTENTIAL_PROD P
        ON TD.TD004 COLLATE DATABASE_DEFAULT = P.PROD
    LEFT JOIN SDRD..COPMA MA
        ON MA.MA001 = TC.TC004
    WHERE TD.TD021 = 'Y'
      AND NOT EXISTS
      (
          SELECT 1
          FROM SDRD..MOCTA TA
          WHERE TA.TA026 = TD.TD001
            AND TA.TA027 = TD.TD002
            AND TA.TA028 = TD.TD003
      )
      AND TC.TC003 >= '20250101'
      AND TC.TC003 <  '20270101'

    UNION ALL

    SELECT
        'ZJRD' AS 账套,
        LTRIM(RTRIM(TD.TD001)) COLLATE DATABASE_DEFAULT AS TD001,
        LTRIM(RTRIM(TD.TD002)) COLLATE DATABASE_DEFAULT AS TD002,
        LTRIM(RTRIM(TD.TD003)) COLLATE DATABASE_DEFAULT AS TD003,
        P.PROD,
        LTRIM(RTRIM(TD.TD007)) COLLATE DATABASE_DEFAULT AS 入库仓库,
        LTRIM(RTRIM(TC.TC004)) COLLATE DATABASE_DEFAULT AS 客户编号,
        NULLIF(LTRIM(RTRIM(MA.MA002)), '') COLLATE DATABASE_DEFAULT AS 客户简称,
        CASE WHEN TC.TC003 >= '20250101' AND TC.TC003 < '20260101'
             THEN CAST(ISNULL(TD.TD008, 0) AS DECIMAL(38,8)) ELSE 0 END AS [2025年订单数量],
        CASE WHEN TC.TC003 >= '20260101' AND TC.TC003 < '20270101'
             THEN CAST(ISNULL(TD.TD008, 0) AS DECIMAL(38,8)) ELSE 0 END AS [2026年订单数量]
    FROM ZJRD..COPTC TC
    INNER JOIN ZJRD..COPTD TD
        ON TD.TD001 = TC.TC001
       AND TD.TD002 = TC.TC002
    INNER JOIN #POTENTIAL_PROD P
        ON TD.TD004 COLLATE DATABASE_DEFAULT = P.PROD
    LEFT JOIN ZJRD..COPMA MA
        ON MA.MA001 = TC.TC004
    WHERE TD.TD021 = 'Y'
      AND NOT EXISTS
      (
          SELECT 1
          FROM ZJRD..MOCTA TA
          WHERE TA.TA026 = TD.TD001
            AND TA.TA027 = TD.TD002
            AND TA.TA028 = TD.TD003
      )
      AND TC.TC003 >= '20250101'
      AND TC.TC003 <  '20270101'

    UNION ALL

    SELECT
        'AHRD' AS 账套,
        LTRIM(RTRIM(TD.TD001)) COLLATE DATABASE_DEFAULT AS TD001,
        LTRIM(RTRIM(TD.TD002)) COLLATE DATABASE_DEFAULT AS TD002,
        LTRIM(RTRIM(TD.TD003)) COLLATE DATABASE_DEFAULT AS TD003,
        P.PROD,
        LTRIM(RTRIM(TD.TD007)) COLLATE DATABASE_DEFAULT AS 入库仓库,
        LTRIM(RTRIM(TC.TC004)) COLLATE DATABASE_DEFAULT AS 客户编号,
        NULLIF(LTRIM(RTRIM(MA.MA002)), '') COLLATE DATABASE_DEFAULT AS 客户简称,
        CASE WHEN TC.TC003 >= '20250101' AND TC.TC003 < '20260101'
             THEN CAST(ISNULL(TD.TD008, 0) AS DECIMAL(38,8)) ELSE 0 END AS [2025年订单数量],
        CASE WHEN TC.TC003 >= '20260101' AND TC.TC003 < '20270101'
             THEN CAST(ISNULL(TD.TD008, 0) AS DECIMAL(38,8)) ELSE 0 END AS [2026年订单数量]
    FROM AHRD..COPTC TC
    INNER JOIN AHRD..COPTD TD
        ON TD.TD001 = TC.TC001
       AND TD.TD002 = TC.TC002
    INNER JOIN #POTENTIAL_PROD P
        ON TD.TD004 COLLATE DATABASE_DEFAULT = P.PROD
    LEFT JOIN AHRD..COPMA MA
        ON MA.MA001 = TC.TC004
    WHERE TD.TD021 = 'Y'
      AND NOT EXISTS
      (
          SELECT 1
          FROM AHRD..MOCTA TA
          WHERE TA.TA026 = TD.TD001
            AND TA.TA027 = TD.TD002
            AND TA.TA028 = TD.TD003
      )
      AND TC.TC003 >= '20250101'
      AND TC.TC003 <  '20270101'

    UNION ALL

    SELECT
        'YNRD' AS 账套,
        LTRIM(RTRIM(TD.TD001)) COLLATE DATABASE_DEFAULT AS TD001,
        LTRIM(RTRIM(TD.TD002)) COLLATE DATABASE_DEFAULT AS TD002,
        LTRIM(RTRIM(TD.TD003)) COLLATE DATABASE_DEFAULT AS TD003,
        P.PROD,
        LTRIM(RTRIM(TD.TD007)) COLLATE DATABASE_DEFAULT AS 入库仓库,
        LTRIM(RTRIM(TC.TC004)) COLLATE DATABASE_DEFAULT AS 客户编号,
        NULLIF(LTRIM(RTRIM(MA.MA002)), '') COLLATE DATABASE_DEFAULT AS 客户简称,
        CASE WHEN TC.TC003 >= '20250101' AND TC.TC003 < '20260101'
             THEN CAST(ISNULL(TD.TD008, 0) AS DECIMAL(38,8)) ELSE 0 END AS [2025年订单数量],
        CASE WHEN TC.TC003 >= '20260101' AND TC.TC003 < '20270101'
             THEN CAST(ISNULL(TD.TD008, 0) AS DECIMAL(38,8)) ELSE 0 END AS [2026年订单数量]
    FROM YNRD..COPTC TC
    INNER JOIN YNRD..COPTD TD
        ON TD.TD001 = TC.TC001
       AND TD.TD002 = TC.TC002
    INNER JOIN #POTENTIAL_PROD P
        ON TD.TD004 COLLATE DATABASE_DEFAULT = P.PROD
    LEFT JOIN YNRD..COPMA MA
        ON MA.MA001 = TC.TC004
    WHERE TD.TD021 = 'Y'
      AND NOT EXISTS
      (
          SELECT 1
          FROM YNRD..MOCTA TA
          WHERE TA.TA026 = TD.TD001
            AND TA.TA027 = TD.TD002
            AND TA.TA028 = TD.TD003
      )
      AND TC.TC003 >= '20250101'
      AND TC.TC003 <  '20270101'
) X
WHERE ISNULL(X.客户编号, '') <> '';

CREATE INDEX IX_ORDER_BASE_PROD ON #ORDER_BASE(PROD);
CREATE INDEX IX_ORDER_BASE_CUST ON #ORDER_BASE(PROD, 客户编号);
CREATE INDEX IX_ORDER_BASE_BILL ON #ORDER_BASE(账套, TD001, TD002, TD003);
CREATE INDEX IX_ORDER_BASE_WH ON #ORDER_BASE(账套, 入库仓库) INCLUDE(PROD, 客户编号);

------------------------------------------------------------
-- 6. 产品订单汇总
--    用于过滤 2025、2026 没有订单的产品
------------------------------------------------------------
SELECT
    PROD,
    SUM([2025年订单数量]) AS [2025年订单数量],
    SUM([2026年订单数量]) AS [2026年订单数量]
INTO #ORDER_AGG
FROM #ORDER_BASE
GROUP BY PROD
HAVING SUM(ISNULL([2025年订单数量], 0)) + SUM(ISNULL([2026年订单数量], 0)) > 0;

CREATE UNIQUE CLUSTERED INDEX IX_ORDER_AGG_PROD ON #ORDER_AGG(PROD);

------------------------------------------------------------
-- 7. 客户维度订单汇总
--    最终输出用这个表取客户编号、客户简称、2025/2026订单数量
------------------------------------------------------------
SELECT
    PROD,
    客户编号,
    MAX(客户简称) AS 客户简称,
    SUM([2025年订单数量]) AS [2025年订单数量],
    SUM([2026年订单数量]) AS [2026年订单数量]
INTO #ORDER_CUST_AGG
FROM #ORDER_BASE
GROUP BY
    PROD,
    客户编号
HAVING SUM(ISNULL([2025年订单数量], 0)) + SUM(ISNULL([2026年订单数量], 0)) > 0;

CREATE UNIQUE CLUSTERED INDEX IX_ORDER_CUST_AGG ON #ORDER_CUST_AGG(PROD, 客户编号);

------------------------------------------------------------
-- 8. 只保留有订单产品的 材料-产品 BOM 关系
------------------------------------------------------------
SELECT
    A.P AS PROD,
    A.COMP AS MATL,
    SUM(A.CNT) AS CNT
INTO #RELATION
FROM #ANCESTOR A
INNER JOIN #ORDER_AGG OA
    ON OA.PROD = A.P
GROUP BY
    A.P,
    A.COMP;

CREATE INDEX IX_RELATION_PROD ON #RELATION(PROD);
CREATE INDEX IX_RELATION_MATL ON #RELATION(MATL);

------------------------------------------------------------
-- 9. 最终产品清单
------------------------------------------------------------
SELECT DISTINCT
    PROD
INTO #REL_PROD
FROM #RELATION;

CREATE UNIQUE CLUSTERED INDEX IX_REL_PROD ON #REL_PROD(PROD);

------------------------------------------------------------
-- 10. 事业部
--     口径：订单行入库仓库 COPTD.TD007 -> 仓库资料 CMSMC.MC001 -> CMSMC.UDF01
--     事业部取 UDF01 中 '-' 前面的部分
--     粒度：产品 + 客户
------------------------------------------------------------
SELECT DISTINCT
    D.PROD,
    D.客户编号,
    D.事业部
INTO #ORDER_DEPT
FROM
(
    SELECT
        B.PROD,
        B.客户编号,
        NULLIF(
            LTRIM(RTRIM(LEFT(ISNULL(MC.UDF01, ''), CHARINDEX('-', ISNULL(MC.UDF01, '') + '-') - 1))),
            ''
        ) COLLATE DATABASE_DEFAULT AS 事业部
    FROM #ORDER_BASE B
    LEFT JOIN SDRD..CMSMC MC
        ON LTRIM(RTRIM(MC.MC001)) COLLATE DATABASE_DEFAULT = B.入库仓库
    WHERE B.账套 = 'SDRD'

    UNION ALL

    SELECT
        B.PROD,
        B.客户编号,
        NULLIF(
            LTRIM(RTRIM(LEFT(ISNULL(MC.UDF01, ''), CHARINDEX('-', ISNULL(MC.UDF01, '') + '-') - 1))),
            ''
        ) COLLATE DATABASE_DEFAULT AS 事业部
    FROM #ORDER_BASE B
    LEFT JOIN ZJRD..CMSMC MC
        ON LTRIM(RTRIM(MC.MC001)) COLLATE DATABASE_DEFAULT = B.入库仓库
    WHERE B.账套 = 'ZJRD'

    UNION ALL

    SELECT
        B.PROD,
        B.客户编号,
        NULLIF(
            LTRIM(RTRIM(LEFT(ISNULL(MC.UDF01, ''), CHARINDEX('-', ISNULL(MC.UDF01, '') + '-') - 1))),
            ''
        ) COLLATE DATABASE_DEFAULT AS 事业部
    FROM #ORDER_BASE B
    LEFT JOIN AHRD..CMSMC MC
        ON LTRIM(RTRIM(MC.MC001)) COLLATE DATABASE_DEFAULT = B.入库仓库
    WHERE B.账套 = 'AHRD'

    UNION ALL

    SELECT
        B.PROD,
        B.客户编号,
        NULLIF(
            LTRIM(RTRIM(LEFT(ISNULL(MC.UDF01, ''), CHARINDEX('-', ISNULL(MC.UDF01, '') + '-') - 1))),
            ''
        ) COLLATE DATABASE_DEFAULT AS 事业部
    FROM #ORDER_BASE B
    LEFT JOIN YNRD..CMSMC MC
        ON LTRIM(RTRIM(MC.MC001)) COLLATE DATABASE_DEFAULT = B.入库仓库
    WHERE B.账套 = 'YNRD'
) D
WHERE ISNULL(D.事业部, '') <> '';

CREATE INDEX IX_ORDER_DEPT ON #ORDER_DEPT(PROD, 客户编号);

------------------------------------------------------------
-- 11. 事业部按 产品 + 客户 拼接
------------------------------------------------------------
SELECT
    D1.PROD,
    D1.客户编号,
    STUFF(
        (
            SELECT ';' + D2.事业部
            FROM
            (
                SELECT DISTINCT
                    PROD,
                    客户编号,
                    事业部
                FROM #ORDER_DEPT
                WHERE ISNULL(事业部, '') <> ''
            ) D2
            WHERE D2.PROD = D1.PROD
              AND D2.客户编号 = D1.客户编号
            ORDER BY D2.事业部
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'),
        1,
        1,
        ''
    ) AS 事业部
INTO #CUSTOMER_DEPT
FROM
(
    SELECT DISTINCT
        PROD,
        客户编号
    FROM #ORDER_DEPT
    WHERE ISNULL(事业部, '') <> ''
) D1;

CREATE UNIQUE CLUSTERED INDEX IX_CUSTOMER_DEPT ON #CUSTOMER_DEPT(PROD, 客户编号);

------------------------------------------------------------
-- 12. 物料资料预清洗
------------------------------------------------------------
SELECT
    LTRIM(RTRIM(MB001)) COLLATE DATABASE_DEFAULT AS ITEMNO,
    MB002,
    MB003
INTO #INVMB
FROM SDRD..INVMB
WHERE EXISTS
(
    SELECT 1
    FROM #RELATION R
    WHERE R.PROD = LTRIM(RTRIM(MB001)) COLLATE DATABASE_DEFAULT
       OR R.MATL = LTRIM(RTRIM(MB001)) COLLATE DATABASE_DEFAULT
);

CREATE UNIQUE CLUSTERED INDEX IX_INVMB_ITEMNO ON #INVMB(ITEMNO);

------------------------------------------------------------
-- 13. 最终输出
------------------------------------------------------------
SELECT 
    R.MATL AS 材料品号,
    MATL.MB002 AS 材料品名,
    MATL.MB003 AS 材料规格,
    R.CNT AS 用量,

    R.PROD AS 产品品号,
    PROD.MB002 AS 产品品名,
    PROD.MB003 AS 产品规格,

    CA.客户编号,
    CA.客户简称,

    ISNULL(CA.[2025年订单数量], 0) AS [2025年订单数量],
    ISNULL(CA.[2026年订单数量], 0) AS [2026年订单数量],

    ISNULL(CD.事业部, '未取到') AS 事业部
FROM #RELATION R
INNER JOIN #ORDER_CUST_AGG CA
    ON CA.PROD = R.PROD
LEFT JOIN #INVMB MATL
    ON MATL.ITEMNO = R.MATL
LEFT JOIN #INVMB PROD
    ON PROD.ITEMNO = R.PROD
LEFT JOIN #CUSTOMER_DEPT CD
    ON CD.PROD = CA.PROD
   AND CD.客户编号 = CA.客户编号
ORDER BY
    R.MATL,
    R.PROD,
    CA.客户编号;