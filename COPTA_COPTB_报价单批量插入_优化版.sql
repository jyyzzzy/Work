SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#COPTA') IS NOT NULL
    DROP TABLE #COPTA;

DECLARE @Today VARCHAR(8);
DECLARE @TA002 BIGINT;

SET @Today = SDRD.dbo.fn_cpc_date_to_char(GETDATE());

------------------------------------------------------------
-- 1. 取得今天当前最大的报价单号
------------------------------------------------------------
SELECT
    @TA002 = ISNULL(
        MAX(CAST(TA002 AS BIGINT)),
        CAST(@Today + '000' AS BIGINT)
    )
FROM dbo.COPTA
WHERE TA002 LIKE @Today + '%';


------------------------------------------------------------
-- 2. 每个客户取最新且存在 COPTB 单身的历史报价单
--    不再要求 TB003 = '0001'
------------------------------------------------------------
SELECT
    H.TA001 AS TA01,
    H.TA002 AS YTA02,
    C.客户简称 AS TA04,
    @TA002 + ROW_NUMBER() OVER (
        ORDER BY C.客户简称
    ) AS XTA02
INTO #COPTA
FROM
(
    SELECT DISTINCT
        RTRIM(客户简称) AS 客户简称
    FROM LSSJ..TJD
    WHERE ISNULL(RTRIM(客户简称), '') <> ''
) C
CROSS APPLY
(
    SELECT TOP 1
        A.TA001,
        A.TA002
    FROM dbo.COPTA A
    WHERE RTRIM(A.TA004) = C.客户简称
      AND A.TA001 =
        CASE RTRIM(A.COMPANY)
            WHEN '0006' THEN '2171'
            WHEN '0011' THEN '21A1'
            WHEN '0001' THEN '2101'
            WHEN 'YNRD' THEN '21V1'
            WHEN '0005' THEN '2101'
            ELSE ''
        END
      AND EXISTS
      (
          SELECT 1
          FROM dbo.COPTB B
          WHERE B.TB001 = A.TA001
            AND B.TB002 = A.TA002
      )
    ORDER BY A.TA002 DESC
) H;


------------------------------------------------------------
-- 3. 临时表索引
------------------------------------------------------------
CREATE UNIQUE CLUSTERED INDEX IX_COPTA
ON #COPTA(TA01, YTA02, TA04);


------------------------------------------------------------
-- 4. 插入报价单单头 COPTA
------------------------------------------------------------
INSERT INTO dbo.COPTA
(
    COMPANY,
    CREATOR,
    USR_GROUP,
    CREATE_DATE,
    MODIFIER,
    MODI_DATE,
    FLAG,

    TA001,
    TA002,
    TA003,
    TA004,
    TA005,
    TA006,
    TA007,
    TA008,
    TA009,
    TA010,
    TA011,
    TA012,
    TA013,
    TA014,
    TA015,
    TA016,
    TA017,
    TA018,
    TA019,
    TA020,
    TA021,
    TA022,
    TA023,
    TA025,
    TA024,
    TA026,
    TA027,
    TA028,
    TA029,
    TA030,
    TA031,
    TA032,
    TA033,
    TA034,
    TA035,
    TA036,
    TA037,
    TA038,
    TA039,
    TA040,
    TA041,
    TA042
)
SELECT
    H.COMPANY,
    '10105978',
    '90001',
    @Today,
    H.MODIFIER,
    NULL,
    1,

    H.TA001,
    A.XTA02,
    @Today,
    H.TA004,
    H.TA005,
    H.TA006,
    H.TA007,
    H.TA008,
    H.TA009,
    H.TA010,
    H.TA011,
    H.TA012,
    @Today,
    H.TA014,
    '',
    H.TA016,
    H.TA017,
    H.TA018,
    'N',
    '',
    '',
    H.TA022,
    H.TA023,
    H.TA025,
    H.TA024,
    H.TA026,
    H.TA027,
    H.TA028,
    H.TA029,
    H.TA030,
    H.TA031,
    H.TA032,
    H.TA033,
    H.TA034,
    H.TA035,
    H.TA036,
    H.TA037,
    H.TA038,
    H.TA039,
    H.TA040,
    H.TA041,
    H.TA042
FROM #COPTA A
INNER JOIN dbo.COPTA H
    ON H.TA001 = A.TA01
   AND H.TA002 = A.YTA02;


------------------------------------------------------------
-- 5. 插入报价单单身 COPTB
--    每张旧报价单取 TB003 最小的一笔作为模板
------------------------------------------------------------
INSERT INTO dbo.COPTB
(
    COMPANY,
    CREATOR,
    USR_GROUP,
    CREATE_DATE,
    MODIFIER,
    MODI_DATE,
    FLAG,

    TB001,
    TB002,
    TB003,
    TB004,
    TB005,
    TB006,
    TB007,
    TB008,
    TB009,
    TB010,
    TB011,
    TB012,
    TB013,
    TB014,
    TB015,
    TB016,
    TB017,
    TB018,
    TB019,
    TB020,
    TB021,
    TB022,
    TB023,
    TB024,
    TB025,
    TB026,
    TB027,
    TB028,
    TB029,
    TB030,
    TB031,
    TB032,
    TB033,
    TB034,
    TB035,
    TB036,
    TB037,
    TB038,
    TB039
)
SELECT
    B.COMPANY,
    '10105978',
    '90001',
    @Today,
    '',
    '',
    1,

    B.TB001,
    A.XTA02,

    RIGHT(
        '0000' +
        CONVERT(
            VARCHAR(10),
            ROW_NUMBER() OVER
            (
                PARTITION BY A.XTA02
                ORDER BY RTRIM(C.内部料号1)
            )
        ),
        4
    ),

    D.MB001,
    D.MB002,
    D.MB003,
    B.TB007,
    D.MB004,
    C.含税价格,
    B.TB010,

    'N',
    C.BZ,
    B.TB013,
    B.TB014,
    B.TB015,
    C.生效时间,
    C.失效时间,
    B.TB018,
    B.TB019,
    B.TB020,
    B.TB021,
    B.TB022,
    B.TB023,
    B.TB024,
    B.TB025,
    B.TB026,
    B.TB027,
    B.TB028,
    B.TB029,
    B.TB030,
    B.TB031,
    B.TB032,
    B.TB033,
    B.TB034,
    B.TB035,
    B.TB036,
    B.TB037,
    B.TB038,
    B.TB039
FROM #COPTA A
INNER JOIN LSSJ..TJD C
    ON RTRIM(C.客户简称) = RTRIM(A.TA04)
INNER JOIN dbo.INVMB D
    ON D.MB001 = RTRIM(C.内部料号1)
CROSS APPLY
(
    SELECT TOP 1
        X.*
    FROM dbo.COPTB X
    WHERE X.TB001 = A.TA01
      AND X.TB002 = A.YTA02
    ORDER BY X.TB003
) B;


------------------------------------------------------------
-- 6. 执行结果检查
------------------------------------------------------------

-- 本次生成的新报价单
SELECT *
FROM #COPTA
ORDER BY XTA02;

-- TJD 总行数
SELECT COUNT(*) AS TJD总行数
FROM LSSJ..TJD;

-- TJD 中能匹配 INVMB 的行数
SELECT COUNT(*) AS INVMB可匹配行数
FROM LSSJ..TJD C
WHERE EXISTS
(
    SELECT 1
    FROM dbo.INVMB D
    WHERE D.MB001 = RTRIM(C.内部料号1)
);

-- TJD 中无法匹配 INVMB 的数据
SELECT C.*
FROM LSSJ..TJD C
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.INVMB D
    WHERE D.MB001 = RTRIM(C.内部料号1)
)
ORDER BY C.客户简称, C.内部料号1;

-- TJD 中没有可用历史报价单模板的客户
SELECT
    C.客户简称,
    COUNT(*) AS 行数
FROM LSSJ..TJD C
WHERE NOT EXISTS
(
    SELECT 1
    FROM #COPTA A
    WHERE RTRIM(A.TA04) = RTRIM(C.客户简称)
)
GROUP BY C.客户简称
ORDER BY 行数 DESC;


SELECT * FROM COPTB WHERE TB001 = '21A1' AND TB002 >= '20260811001' AND TB002 <= '20260811092'