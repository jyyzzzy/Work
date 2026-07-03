/*========================================================
  查询 INVMB 中所有产品：品号 1 或 A 开头
  下展 BOM，取所有 2 开头半成品
  关联 INVLA，取产品最近交易时间 LA004
  增加半成品对应自动化点数
  不使用 CTE
========================================================*/

IF OBJECT_ID('tempdb..#PRODUCT') IS NOT NULL DROP TABLE #PRODUCT;
IF OBJECT_ID('tempdb..#PROD_LA') IS NOT NULL DROP TABLE #PROD_LA;
IF OBJECT_ID('tempdb..#PROD_LA_LAST') IS NOT NULL DROP TABLE #PROD_LA_LAST;
IF OBJECT_ID('tempdb..#BOM_TREE') IS NOT NULL DROP TABLE #BOM_TREE;
IF OBJECT_ID('tempdb..#ProductPoint') IS NOT NULL DROP TABLE #ProductPoint;
IF OBJECT_ID('tempdb..#SemiPoint') IS NOT NULL DROP TABLE #SemiPoint;

------------------------------------------------------------
-- 1. 取产品：1 或 A 开头
------------------------------------------------------------
SELECT
    RTRIM(MB001) AS 产品品号,
    MB002 AS 产品品名,
    MB003 AS 产品规格
INTO #PRODUCT
FROM SDRD.dbo.INVMB WITH(NOLOCK)
WHERE LEFT(RTRIM(MB001), 1) IN ('1', 'A');

CREATE INDEX IX_PRODUCT_产品品号 ON #PRODUCT(产品品号);

------------------------------------------------------------
-- 2. 取四个账套产品最近交易时间和事业部
--    账套：SDRD / ZJRD / AHRD / YNRD
--    只取 INVLA.LA006 是 58 开头的交易
--
--    口径：
--    1）产品最近交易时间：四个账套 INVLA.LA004 最大值
--    2）事业部：只取四个账套里面最近交易日期那一笔的事业部
--    3）如果 CMSMD.MD011 取不到事业部，直接使用该笔 INVLA.UDF06
------------------------------------------------------------

IF OBJECT_ID('tempdb..#PROD_LA_RAW') IS NOT NULL DROP TABLE #PROD_LA_RAW;
IF OBJECT_ID('tempdb..#PROD_LA') IS NOT NULL DROP TABLE #PROD_LA;

------------------------------------------------------------
-- 2.1 汇总四个账套 INVLA 明细，并解析事业部
------------------------------------------------------------
SELECT
    A.账套,
    A.产品品号,
    A.产品最近交易时间,
    A.LA006,
    A.UDF06,
    A.工作中心编号,
    A.解析事业部
INTO #PROD_LA_RAW
FROM
(
    ----------------------------------------------------------
    ---- SDRD
    ----------------------------------------------------------
    --SELECT
    --    'SDRD' AS 账套,
    --    RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT AS 产品品号,
    --    LA.LA004 AS 产品最近交易时间,
    --    RTRIM(LA.LA006) COLLATE DATABASE_DEFAULT AS LA006,
    --    RTRIM(ISNULL(LA.UDF06, '')) COLLATE DATABASE_DEFAULT AS UDF06,

    --    WC.工作中心编号,

    --    RTRIM(
    --        LEFT(
    --            ISNULL(MD.MD011, '') COLLATE DATABASE_DEFAULT,
    --            CHARINDEX('-', ISNULL(MD.MD011, '') COLLATE DATABASE_DEFAULT + '-') - 1
    --        )
    --    ) AS 解析事业部
    --FROM SDRD.dbo.INVLA LA WITH(NOLOCK)
    --INNER JOIN #PRODUCT P
    --    ON RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT = P.产品品号 COLLATE DATABASE_DEFAULT
    --OUTER APPLY
    --(
    --    SELECT
    --        RTRIM(
    --            LEFT(
    --                ISNULL(LA.UDF06, '') COLLATE DATABASE_DEFAULT,
    --                CHARINDEX('|', ISNULL(LA.UDF06, '') COLLATE DATABASE_DEFAULT + '|') - 1
    --            )
    --        ) AS 工作中心编号
    --) WC
    --LEFT JOIN SDRD.dbo.CMSMD MD WITH(NOLOCK)
    --    ON RTRIM(MD.MD001) COLLATE DATABASE_DEFAULT = WC.工作中心编号 COLLATE DATABASE_DEFAULT
    --WHERE LEFT(RTRIM(LA.LA006), 2) = '58'

    --UNION ALL

    ----------------------------------------------------------
    ---- ZJRD
    ----------------------------------------------------------
    --SELECT
    --    'ZJRD' AS 账套,
    --    RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT AS 产品品号,
    --    LA.LA004 AS 产品最近交易时间,
    --    RTRIM(LA.LA006) COLLATE DATABASE_DEFAULT AS LA006,
    --    RTRIM(ISNULL(LA.UDF06, '')) COLLATE DATABASE_DEFAULT AS UDF06,

    --    WC.工作中心编号,

    --    RTRIM(
    --        LEFT(
    --            ISNULL(MD.MD011, '') COLLATE DATABASE_DEFAULT,
    --            CHARINDEX('-', ISNULL(MD.MD011, '') COLLATE DATABASE_DEFAULT + '-') - 1
    --        )
    --    ) AS 解析事业部
    --FROM ZJRD.dbo.INVLA LA WITH(NOLOCK)
    --INNER JOIN #PRODUCT P
    --    ON RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT = P.产品品号 COLLATE DATABASE_DEFAULT
    --OUTER APPLY
    --(
    --    SELECT
    --        RTRIM(
    --            LEFT(
    --                ISNULL(LA.UDF06, '') COLLATE DATABASE_DEFAULT,
    --                CHARINDEX('|', ISNULL(LA.UDF06, '') COLLATE DATABASE_DEFAULT + '|') - 1
    --            )
    --        ) AS 工作中心编号
    --) WC
    --LEFT JOIN ZJRD.dbo.CMSMD MD WITH(NOLOCK)
    --    ON RTRIM(MD.MD001) COLLATE DATABASE_DEFAULT = WC.工作中心编号 COLLATE DATABASE_DEFAULT
    --WHERE LEFT(RTRIM(LA.LA006), 2) = '58'

    --UNION ALL

    ----------------------------------------------------------
    ---- AHRD
    ----------------------------------------------------------
    --SELECT
    --    'AHRD' AS 账套,
    --    RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT AS 产品品号,
    --    LA.LA004 AS 产品最近交易时间,
    --    RTRIM(LA.LA006) COLLATE DATABASE_DEFAULT AS LA006,
    --    RTRIM(ISNULL(LA.UDF06, '')) COLLATE DATABASE_DEFAULT AS UDF06,

    --    WC.工作中心编号,

    --    RTRIM(
    --        LEFT(
    --            ISNULL(MD.MD011, '') COLLATE DATABASE_DEFAULT,
    --            CHARINDEX('-', ISNULL(MD.MD011, '') COLLATE DATABASE_DEFAULT + '-') - 1
    --        )
    --    ) AS 解析事业部
    --FROM AHRD.dbo.INVLA LA WITH(NOLOCK)
    --INNER JOIN #PRODUCT P
    --    ON RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT = P.产品品号 COLLATE DATABASE_DEFAULT
    --OUTER APPLY
    --(
    --    SELECT
    --        RTRIM(
    --            LEFT(
    --                ISNULL(LA.UDF06, '') COLLATE DATABASE_DEFAULT,
    --                CHARINDEX('|', ISNULL(LA.UDF06, '') COLLATE DATABASE_DEFAULT + '|') - 1
    --            )
    --        ) AS 工作中心编号
    --) WC
    --LEFT JOIN AHRD.dbo.CMSMD MD WITH(NOLOCK)
    --    ON RTRIM(MD.MD001) COLLATE DATABASE_DEFAULT = WC.工作中心编号 COLLATE DATABASE_DEFAULT
    --WHERE LEFT(RTRIM(LA.LA006), 2) = '58'

    --UNION ALL

    --------------------------------------------------------
    -- YNRD
    --------------------------------------------------------
    SELECT
        'YNRD' AS 账套,
        RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT AS 产品品号,
        LA.LA004 AS 产品最近交易时间,
        RTRIM(LA.LA006) COLLATE DATABASE_DEFAULT AS LA006,
        RTRIM(ISNULL(LA.UDF06, '')) COLLATE DATABASE_DEFAULT AS UDF06,

        WC.工作中心编号,

        RTRIM(
            LEFT(
                ISNULL(MD.MD011, '') COLLATE DATABASE_DEFAULT,
                CHARINDEX('-', ISNULL(MD.MD011, '') COLLATE DATABASE_DEFAULT + '-') - 1
            )
        ) AS 解析事业部
    FROM YNRD.dbo.INVLA LA WITH(NOLOCK)
    INNER JOIN #PRODUCT P
        ON RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT = P.产品品号 COLLATE DATABASE_DEFAULT
    OUTER APPLY
    (
        SELECT
            RTRIM(
                LEFT(
                    ISNULL(LA.UDF06, '') COLLATE DATABASE_DEFAULT,
                    CHARINDEX('|', ISNULL(LA.UDF06, '') COLLATE DATABASE_DEFAULT + '|') - 1
                )
            ) AS 工作中心编号
    ) WC
    LEFT JOIN YNRD.dbo.CMSMD MD WITH(NOLOCK)
        ON RTRIM(MD.MD001) COLLATE DATABASE_DEFAULT = WC.工作中心编号 COLLATE DATABASE_DEFAULT
    WHERE LEFT(RTRIM(LA.LA006), 2) = '58'
) A;

CREATE INDEX IX_PROD_LA_RAW_产品品号_交易时间
ON #PROD_LA_RAW(产品品号, 产品最近交易时间);

------------------------------------------------------------
-- 2.2 每个产品只取四个账套里面最近交易日期的那一笔
--     事业部优先取 CMSMD.MD011 的 - 前内容
--     取不到则直接用 INVLA.UDF06
------------------------------------------------------------
SELECT
    X.产品品号,
    X.产品最近交易时间,

    CASE
        WHEN ISNULL(X.解析事业部, '') <> ''
            THEN X.解析事业部
        ELSE X.UDF06
    END AS 事业部
INTO #PROD_LA
FROM
(
    SELECT
        R.账套,
        R.产品品号,
        R.产品最近交易时间,
        R.LA006,
        R.UDF06,
        R.解析事业部,

        ROW_NUMBER() OVER(
            PARTITION BY R.产品品号
            ORDER BY
                R.产品最近交易时间 DESC,
                R.LA006 DESC,
                CASE R.账套
                    WHEN 'SDRD' THEN 1
                    WHEN 'ZJRD' THEN 2
                    WHEN 'AHRD' THEN 3
                    WHEN 'YNRD' THEN 4
                    ELSE 9
                END
        ) AS RN
    FROM #PROD_LA_RAW R
) X
WHERE X.RN = 1;

CREATE INDEX IX_PROD_LA_产品品号
ON #PROD_LA(产品品号);

------------------------------------------------------------
-- 3. 建立 BOM 下展临时表
------------------------------------------------------------
CREATE TABLE #BOM_TREE
(
    产品品号        NVARCHAR(40)  NOT NULL,
    上阶品号        NVARCHAR(40)  NOT NULL,
    下阶品号        NVARCHAR(40)  NOT NULL,
    单位用量        DECIMAL(38,10) NULL,
    阶层            INT NOT NULL,
    路径            VARCHAR(MAX) NULL
);

------------------------------------------------------------
-- 4. 插入第一层 BOM
------------------------------------------------------------
INSERT INTO #BOM_TREE
(
    产品品号,
    上阶品号,
    下阶品号,
    单位用量,
    阶层,
    路径
)
SELECT
    P.产品品号,
    RTRIM(MD.MD001) AS 上阶品号,
    RTRIM(MD.MD003) AS 下阶品号,
    CAST(
        CAST(MD.MD006 AS DECIMAL(38,10))
        / NULLIF(CAST(MD.MD007 AS DECIMAL(38,10)), 0)
        AS DECIMAL(38,10)
    ) AS 单位用量,
    1 AS 阶层,
    CAST('|' + P.产品品号 + '|' + RTRIM(MD.MD003) + '|' AS VARCHAR(MAX)) AS 路径
FROM #PRODUCT P
INNER JOIN SDRD.dbo.BOMMD MD WITH(NOLOCK)
    ON RTRIM(MD.MD001) = P.产品品号
WHERE ISNULL(RTRIM(MD.MD003), '') <> '';

CREATE INDEX IX_BOM_TREE_阶层_下阶品号 ON #BOM_TREE(阶层, 下阶品号);
CREATE INDEX IX_BOM_TREE_产品_下阶 ON #BOM_TREE(产品品号, 下阶品号);

------------------------------------------------------------
-- 5. WHILE 循环下展 BOM
------------------------------------------------------------
DECLARE @LEVEL INT = 1;
DECLARE @ROWS INT = 1;

WHILE @ROWS > 0
BEGIN
    INSERT INTO #BOM_TREE
    (
        产品品号,
        上阶品号,
        下阶品号,
        单位用量,
        阶层,
        路径
    )
    SELECT
        T.产品品号,
        RTRIM(MD.MD001) AS 上阶品号,
        RTRIM(MD.MD003) AS 下阶品号,
        CAST(
            T.单位用量
            * CAST(MD.MD006 AS DECIMAL(38,10))
            / NULLIF(CAST(MD.MD007 AS DECIMAL(38,10)), 0)
            AS DECIMAL(38,10)
        ) AS 单位用量,
        T.阶层 + 1 AS 阶层,
        CAST(T.路径 + RTRIM(MD.MD003) + '|' AS VARCHAR(MAX)) AS 路径
    FROM #BOM_TREE T
    INNER JOIN SDRD.dbo.BOMMD MD WITH(NOLOCK)
        ON RTRIM(MD.MD001) = T.下阶品号
    WHERE T.阶层 = @LEVEL
      AND ISNULL(RTRIM(MD.MD003), '') <> ''
      AND T.路径 NOT LIKE '%|' + RTRIM(MD.MD003) + '|%';

    SET @ROWS = @@ROWCOUNT;
    SET @LEVEL = @LEVEL + 1;
END;

------------------------------------------------------------
-- 6. 计算自动化点数
--    这里完全参考你给的 ProductPoint 逻辑
------------------------------------------------------------
SELECT
    RTRIM(MD.MD001) AS MD001,
    RTRIM(MD.MD009) AS MD009,
    SUM(
        CONVERT(float, RTRIM(
            CASE ISNULL(MB3.MB180, '')
                WHEN '' THEN '-99999'
                ELSE MB3.MB180
            END
        ), 0) * MD.MD006 / MD.MD007
    ) AS Point
INTO #ProductPoint
FROM SDRD.dbo.BOMMD AS MD WITH(NOLOCK)
INNER JOIN SDRD.dbo.INVMB AS MB3 WITH(NOLOCK)
    ON MD.MD003 = MB3.MB001
WHERE MD.MD006 > 0
  AND MD.MD007 >= 1
  AND MB3.MB006 <> '220'
  AND LEFT(MD.MD003, 1) NOT IN ('A', '1', '2', '5', 'P')
GROUP BY
    RTRIM(MD.MD001),
    RTRIM(MD.MD009);

CREATE INDEX IX_ProductPoint_MD001_MD009 ON #ProductPoint(MD001, MD009);

------------------------------------------------------------
-- 7. 取半成品对应工艺和点数
--    口径：
--    BOMMF.MF001 = 半成品品号
--    BOMMF.MF004 = 工艺编号
--    ProductPoint.MD001 = 半成品品号
--    ProductPoint.MD009 = 工艺编号
------------------------------------------------------------
SELECT DISTINCT
    RTRIM(BOMMF.MF001) AS 半成品品号,

    IIF(
        ISNULL(INVMB.MB110, '') = '',
        RTRIM(INVMB.MB001),
        IIF(
            LEFT(INVMB.MB110, 1) = 'K',
            SUBSTRING(INVMB.MB110, 2, 13),
            SUBSTRING(INVMB.MB110, 1, 12)
        )
    ) AS 半成品PLM品号,

    BOMMF.MF004 AS 半成品工艺编号,
    CMSMW.MW002 AS 半成品工艺名称,

    CASE
        WHEN PP.Point IS NULL THEN -1
        WHEN PP.Point >= 0 THEN PP.Point
        ELSE 0
    END AS 半成品自动化点数
INTO #SemiPoint
FROM SDRD.dbo.BOMMF WITH(NOLOCK)
INNER JOIN SDRD.dbo.CMSMW WITH(NOLOCK)
    ON CMSMW.MW001 = BOMMF.MF004
INNER JOIN SDRD.dbo.INVMB WITH(NOLOCK)
    ON INVMB.MB001 = BOMMF.MF001
LEFT JOIN #ProductPoint AS PP
    ON PP.MD001 = RTRIM(BOMMF.MF001)
   AND PP.MD009 = RTRIM(BOMMF.MF004)
WHERE LEFT(RTRIM(BOMMF.MF001), 1) = '2'
  --AND BOMMF.MF004 IN ('P005');

CREATE INDEX IX_SemiPoint_半成品品号 ON #SemiPoint(半成品品号);

------------------------------------------------------------
-- 8. 最终输出
------------------------------------------------------------
SELECT
    T.产品品号,
    P.产品品名,
    P.产品规格,
    LA.产品最近交易时间,
    LA.事业部,

    T.下阶品号 AS 半成品品号,
    S.MB002 AS 半成品品名,
    S.MB003 AS 半成品规格,

    SP.半成品PLM品号,
    SP.半成品工艺编号,
    SP.半成品工艺名称,
    SP.半成品自动化点数,

    SUM(T.单位用量) AS 半成品累计单位用量
FROM #BOM_TREE T
INNER JOIN #PRODUCT P
    ON P.产品品号 = T.产品品号
INNER JOIN #PROD_LA LA
    ON LA.产品品号 = T.产品品号
LEFT JOIN SDRD.dbo.INVMB S WITH(NOLOCK)
    ON RTRIM(S.MB001) = T.下阶品号
LEFT JOIN #SemiPoint SP
    ON SP.半成品品号 = T.下阶品号
WHERE LEFT(T.下阶品号, 1) = '2'
GROUP BY
    T.产品品号,
    P.产品品名,
    P.产品规格,
    LA.产品最近交易时间,
    LA.事业部,

    T.下阶品号,
    S.MB002,
    S.MB003,

    SP.半成品PLM品号,
    SP.半成品工艺编号,
    SP.半成品工艺名称,
    SP.半成品自动化点数
ORDER BY
    T.产品品号,
    T.下阶品号,
    SP.半成品工艺编号;