USE [SDRD];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*
用途：替代 dbo.vw_ProdOutputReport，以日期区间获取生产入库产值。
调用：EXEC SDRD.dbo.usp_ProdOutputReport @StartDate='2026-09-01', @EndDate='2026-09-30';
日期：起止日期均包含；底层 TF003 为 YYYYMMDD 字符日期，不对列使用函数。
取价：订单价 >=0.01 -> 当天有效系统价 >=0.01 -> LSSJ.BOM_MONTH_PRICE -> 60%材料折算 -> 0。
注意：最新有效的系统定价若低于0.01，不向前回溯旧定价。
本过程仅查询，不修改价格表和报表数据；不删除原视图。
*/
IF OBJECT_ID(N'dbo.usp_ProdOutputReport', N'P') IS NULL
    EXEC(N'CREATE PROCEDURE dbo.usp_ProdOutputReport AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE dbo.usp_ProdOutputReport
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL OR @EndDate IS NULL OR @StartDate > @EndDate
        THROW 51021, N'开始日期、结束日期不能为空，且开始日期不能晚于结束日期。', 1;

    DECLARE @From CHAR(8) = CONVERT(CHAR(8), @StartDate, 112);
    DECLARE @To   CHAR(8) = CONVERT(CHAR(8), @EndDate, 112);

    /* 1. 先按入库日期筛选，避免整库执行各项关联计算。 */
    SELECT
        G.TG001, G.TG002, G.TG003, G.TG004, G.TG005,
        G.TG006, G.TG007, G.TG010, G.TG013, G.TG014, G.TG015,
        F.TF003, F.TF011,
        LEFT(F.TF003, 6) AS MonthNo,
        RTRIM(G.TG001) + '-' + RTRIM(G.TG002) + '-' + RTRIM(G.TG003) AS DocKey
    INTO #Base
    FROM dbo.MOCTF AS F WITH (NOLOCK)
    INNER JOIN dbo.MOCTG AS G WITH (NOLOCK)
        ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
    WHERE F.TF003 >= @From AND F.TF003 <= @To
      AND F.TF006 = 'Y'
      AND G.TG022 = 'Y'
      AND G.TG001 LIKE '58%'
      AND G.TG014 LIKE '5101%'
      AND (G.TG004 LIKE '1%' OR G.TG004 LIKE 'A%');

    CREATE INDEX IX_Base_WorkOrder ON #Base (TG014, TG015);
    CREATE INDEX IX_Base_Doc ON #Base (TG001, TG002, TG003, TG004);

    /* 2. 将必要的客户、品号、入库日、币种组合去重。 */
    SELECT DISTINCT
        O.TC004 AS CustomerNo,
        B.TG004 AS ItemNo,
        B.TF003 AS ProdDate,
        ISNULL(NULLIF(RTRIM(O.TC008), ''), 'RMB') AS CurrencyNo
    INTO #PriceKeys
    FROM #Base AS B
    INNER JOIN dbo.MOCTA AS A WITH (NOLOCK)
        ON B.TG014 = A.TA001 AND B.TG015 = A.TA002
    INNER JOIN dbo.COPTC AS O WITH (NOLOCK)
        ON A.TA026 = O.TC001 AND A.TA027 = O.TC002
    WHERE O.TC004 IS NOT NULL AND O.TC004 <> '';

    /* 3. 每个组合找最新有效系统价；先取最新，再判定 0.01。 */
    SELECT
        K.CustomerNo, K.ItemNo, K.ProdDate, K.CurrencyNo,
        CASE WHEN Q.MB008 >= 0.01
             THEN CAST(Q.MB008 AS DECIMAL(24,8))
             ELSE CAST(NULL AS DECIMAL(24,8)) END AS Price
    INTO #Price
    FROM #PriceKeys AS K
    OUTER APPLY
    (
        SELECT TOP (1) P.MB008
        FROM dbo.COPMB AS P WITH (NOLOCK)
        WHERE P.MB001 = K.CustomerNo
          AND P.MB002 = K.ItemNo
          AND P.MB004 = K.CurrencyNo
          AND P.MB017 IS NOT NULL AND P.MB017 <> ''
          AND P.MB017 <= K.ProdDate
          AND (P.MB018 IS NULL OR P.MB018 = '' OR P.MB018 >= K.ProdDate)
        ORDER BY P.MB017 DESC, P.MB018 DESC, P.MB008 DESC
    ) AS Q;

    CREATE INDEX IX_Price_Lookup
        ON #Price (CustomerNo, ItemNo, ProdDate, CurrencyNo);

    /* 4. 对入库明细去重，取 INVLA 相同单据/品号最近一笔材料成本。 */
    SELECT DISTINCT
        B.TG004 AS LA001,
        B.TG001 AS LA006,
        B.TG002 AS LA007,
        B.TG003 AS LA008
    INTO #CostKeys
    FROM #Base AS B;

    SELECT X.LA001, X.LA006, X.LA007, X.LA008, X.LA017
    INTO #Cost
    FROM
    (
        SELECT
            LA.LA001, LA.LA006, LA.LA007, LA.LA008, LA.LA017,
            ROW_NUMBER() OVER
            (
                PARTITION BY LA.LA001, LA.LA006, LA.LA007, LA.LA008
                ORDER BY LA.LA004 DESC
            ) AS RN
        FROM dbo.INVLA AS LA WITH (NOLOCK)
        INNER JOIN #CostKeys AS K
            ON LA.LA001 = K.LA001 AND LA.LA006 = K.LA006
           AND LA.LA007 = K.LA007 AND LA.LA008 = K.LA008
        WHERE LA.LA006 LIKE '58%'
    ) AS X
    WHERE X.RN = 1;

    CREATE INDEX IX_Cost_Lookup
        ON #Cost (LA001, LA006, LA007, LA008);

    /* 5. 保留原视图的人民币基础汇率选择逻辑：RMB 最早一条 CMSMG。 */
    SELECT TOP (1) MG003
    INTO #RmbRate
    FROM dbo.CMSMG WITH (NOLOCK)
    WHERE MG001 = 'RMB'
    ORDER BY MG002;

    /* 6. 最终结果：输出字段名、顺序和原视图保持一致。 */
    SELECT
        'SDRD' AS [基地/公司别],
        RTRIM(B.TG001) AS [入库单别],
        RTRIM(B.TG002) AS [入库单号],
        RTRIM(B.TG003) AS [入库序号],
        B.TF003 AS [入库日期],
        B.DocKey AS [入库单别-单号-序号],
        B.TG004 AS [产品品号],
        B.TG005 AS [品名],
        B.TG006 AS [规格],
        O.TC004 AS [客户编码],
        CM.MA002 AS [客户],
        CASE WHEN CM.MA002 IS NULL THEN NULL
             ELSE RTRIM(CM.MA002) + '+' + ISNULL(RTRIM(C3.MA003), '') END AS [客户+类别],
        B.TG007 AS [单位],
        CU.CurrencyNo AS [币种],
        CAST(O.TC009 AS FLOAT) AS [汇率],
        CAST(B.TG013 AS FLOAT) AS [验收数量],
        PR.Price AS [单价],
        CAST(V.产值 / NULLIF(Rate.MG003, 0) AS FLOAT) AS [产值],
        CAST(T.不含税产值 / NULLIF(Rate.MG003, 0) AS FLOAT) AS [不含税产值],
        CAST(ISNULL(MB.MB057, 0) / NULLIF(Rate.MG003, 0) AS FLOAT) AS [单位标准材料成本],
        B.TF011 AS [工作中心],
        D.MD002 AS [工作中心名称],
        CASE WHEN D.MD011 IS NULL THEN '顺德瑞德'
             ELSE LEFT(D.MD011, CHARINDEX('-', D.MD011 + '-') - 1) END AS [事业部],
        B.TG010 AS [仓库],
        B.TG014 AS [工单单别],
        B.TG015 AS [工单单号],
        A.TA026 AS [订单单别],
        A.TA027 AS [订单单号],
        CASE WHEN ISNULL(A.TA026, '') = '' OR ISNULL(A.TA027, '') = '' THEN NULL
             ELSE RTRIM(A.TA026) + '-' + RTRIM(A.TA027) END AS [客户订单],
        A.TA028 AS [订单序号],
        MB.MB008 AS [品号分类四],
        C4.MA003 AS [品号类别名称],
        C3.MA003 AS [商品类别],
        PR.PriceSource AS [备注],
        ISNULL(MB.MB096, 0) AS [工时底数],
        CAST(ISNULL(MB.MB096, 0) * 100.0 / 3600 * B.TG013 AS DECIMAL(24,10)) AS [定额工时],
        CAST(U.UnitMaterial / NULLIF(Rate.MG003, 0) AS FLOAT) AS [单位材料],
        CAST(ISNULL(L.LA017, 0) / NULLIF(Rate.MG003, 0) AS FLOAT) AS [材料成本],
        CASE WHEN ISNULL(T.不含税产值, 0) = 0 THEN '0.00%'
             ELSE CONCAT(CAST(ISNULL(L.LA017, 0) * 100.0
                              / NULLIF(T.不含税产值, 0) AS DECIMAL(15,2)), '%') END AS [材料占比],
        0 AS [材料剔除],
        CASE WHEN O.TC008 = 'USD' OR CM.MA001 = '10000059' THEN 'Y' ELSE 'N' END AS [外销]
    FROM #Base AS B
    LEFT JOIN dbo.MOCTA AS A WITH (NOLOCK)
        ON B.TG014 = A.TA001 AND B.TG015 = A.TA002
    LEFT JOIN dbo.COPTC AS O WITH (NOLOCK)
        ON A.TA026 = O.TC001 AND A.TA027 = O.TC002
    LEFT JOIN dbo.COPTD AS OD WITH (NOLOCK)
        ON OD.TD001 = A.TA026 AND OD.TD002 = A.TA027
       AND OD.TD003 = A.TA028 AND OD.TD004 = B.TG004
    LEFT JOIN dbo.COPMA AS CM WITH (NOLOCK)
        ON O.TC004 = CM.MA001
    LEFT JOIN dbo.INVMB AS MB WITH (NOLOCK)
        ON B.TG004 = MB.MB001
    LEFT JOIN dbo.INVMA AS C4 WITH (NOLOCK)
        ON MB.MB008 = C4.MA002
    LEFT JOIN dbo.INVMA AS C3 WITH (NOLOCK)
        ON MB.MB007 = C3.MA002
    LEFT JOIN dbo.CMSMD AS D WITH (NOLOCK)
        ON B.TF011 = D.MD001
    CROSS APPLY
    (
        SELECT ISNULL(NULLIF(RTRIM(O.TC008), ''), 'RMB') AS CurrencyNo
    ) AS CU
    LEFT JOIN #Price AS P
        ON P.CustomerNo = O.TC004 AND P.ItemNo = B.TG004
       AND P.ProdDate = B.TF003 AND P.CurrencyNo = CU.CurrencyNo
    LEFT JOIN #Cost AS L
        ON L.LA001 = B.TG004 AND L.LA006 = B.TG001
       AND L.LA007 = B.TG002 AND L.LA008 = B.TG003
    CROSS JOIN #RmbRate AS Rate

    /* 通过已计算的月度 BOM 价格表取多层级子件售价。 */
    OUTER APPLY
    (
        SELECT TOP (1) BP.UnitPrice AS KitPrice
        FROM LSSJ.dbo.BOM_MONTH_PRICE AS BP
        WHERE BP.CompanyNo = 'SDRD'
          AND BP.PriceMonth = B.MonthNo
          AND BP.CustomerNo = RTRIM(O.TC004)
          AND BP.CurrencyNo = CU.CurrencyNo
          AND BP.ItemNo = RTRIM(B.TG004)
          AND BP.LevelNo > 0
          AND BP.UnitPrice > 0
          AND (OD.TD011 IS NULL OR OD.TD011 < 0.01)
          AND (P.Price IS NULL OR P.Price < 0.01)
        ORDER BY
            CASE WHEN EXISTS
            (
                SELECT 1 FROM dbo.COPTD AS OD2 WITH (NOLOCK)
                WHERE OD2.TD001 = A.TA026
                  AND OD2.TD002 = A.TA027
                  AND OD2.TD004 = BP.RootItemNo
            ) THEN 0 ELSE 1 END,
            BP.LevelNo ASC, BP.RootItemNo, BP.TreePath
    ) AS KIT
    CROSS APPLY
    (
        SELECT CAST(
            CASE WHEN O.TC008 = 'USD' OR CM.MA001 = '10000059'
                      OR O.TC016 IN ('3','4','9')
                 THEN 1.0
                 ELSE 1.0 + ISNULL(CAST(O.TC041 AS DECIMAL(18,6)), 0.13)
            END AS DECIMAL(18,6)) AS TaxFactor
    ) AS TX
    CROSS APPLY
    (
        SELECT
            CAST(CASE
                WHEN OD.TD011 >= 0.01 THEN OD.TD011
                WHEN P.Price >= 0.01 THEN P.Price
                WHEN KIT.KitPrice IS NOT NULL THEN KIT.KitPrice
                WHEN L.LA017 > 0 AND B.TG013 > 0
                     THEN CAST(L.LA017 AS DECIMAL(24,6))
                          / NULLIF(CAST(B.TG013 AS DECIMAL(24,6)), 0)
                          / 0.6 * TX.TaxFactor
                ELSE 0
            END AS DECIMAL(24,8)) AS Price,
            CAST(CASE
                WHEN OD.TD011 >= 0.01 THEN OD.TD011 * O.TC009
                WHEN P.Price >= 0.01 THEN P.Price * O.TC009
                WHEN KIT.KitPrice IS NOT NULL THEN KIT.KitPrice * O.TC009
                WHEN L.LA017 > 0 AND B.TG013 > 0
                     THEN CAST(L.LA017 AS DECIMAL(24,6))
                          / NULLIF(CAST(B.TG013 AS DECIMAL(24,6)), 0)
                          / 0.6 * TX.TaxFactor
                ELSE 0
            END AS DECIMAL(24,8)) AS RMBPrice,
            CASE
                WHEN OD.TD011 >= 0.01 THEN N'订单价格'
                WHEN P.Price >= 0.01 THEN N'系统定价'
                WHEN KIT.KitPrice IS NOT NULL THEN N'系统套件拆分'
                WHEN L.LA017 > 0 AND B.TG013 > 0 THEN N'按60%材料折算'
                ELSE N''
            END AS PriceSource
    ) AS PR
    CROSS APPLY
    (
        SELECT CAST(B.TG013 * PR.RMBPrice AS DECIMAL(24,4)) AS 产值
    ) AS V
    CROSS APPLY
    (
        SELECT CAST(V.产值 / NULLIF(TX.TaxFactor, 0) AS DECIMAL(24,4)) AS 不含税产值
    ) AS T
    CROSS APPLY
    (
        SELECT ISNULL(
            CAST(ISNULL(L.LA017, 0) / NULLIF(B.TG013, 0) AS DECIMAL(24,9)), 0
        ) AS UnitMaterial
    ) AS U
    OPTION (RECOMPILE);
END;
GO

-- 测试调用（只查询，不更新）：
-- EXEC SDRD.dbo.usp_ProdOutputReport @StartDate='2026-09-01', @EndDate='2026-09-30';
