USE [LSSJ];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* 首次创建正式表。再次运行不会清空原有历史数据。 */
IF OBJECT_ID(N'dbo.BOM_MONTH_PRICE', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BOM_MONTH_PRICE
    (
        Id               BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CompanyNo        VARCHAR(10) NOT NULL,
        PriceMonth       CHAR(6) NOT NULL,
        CustomerNo       VARCHAR(30) NOT NULL,
        CurrencyNo       VARCHAR(10) NOT NULL,
        RootItemNo       VARCHAR(50) NOT NULL,
        ParentItemNo     VARCHAR(50) NULL,
        ItemNo           VARCHAR(50) NOT NULL,
        LevelNo          INT NOT NULL,
        BomLineNo        VARCHAR(20) NULL,
        TreePath         VARCHAR(2000) NOT NULL,
        BomQty           DECIMAL(24,10) NULL,
        MonthUnitCost    DECIMAL(24,8) NULL,
        ParentTotalCost  DECIMAL(28,8) NULL,
        RootUnitPrice    DECIMAL(24,8) NOT NULL,
        UnitPrice        DECIMAL(24,8) NOT NULL,
        PriceSource      NVARCHAR(20) NOT NULL,
        CalcTime         DATETIME2(0) NOT NULL CONSTRAINT DF_BOM_MONTH_PRICE_CalcTime DEFAULT SYSDATETIME()
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.BOM_MONTH_PRICE')
      AND name = N'IX_BOM_MONTH_PRICE_Lookup'
)
BEGIN
    CREATE INDEX IX_BOM_MONTH_PRICE_Lookup
    ON dbo.BOM_MONTH_PRICE (CompanyNo, PriceMonth, CustomerNo, CurrencyNo, ItemNo)
    INCLUDE (RootItemNo, LevelNo, UnitPrice);
END;
GO

/* 参数 YYYYMM；省略参数时处理当前月。此过程只处理 SDRD 一家公司。 */
IF OBJECT_ID(N'dbo.usp_RebuildBOMMonthPrice', N'P') IS NULL
    EXEC(N'CREATE PROCEDURE dbo.usp_RebuildBOMMonthPrice AS BEGIN SET NOCOUNT ON; END');
GO

ALTER PROCEDURE dbo.usp_RebuildBOMMonthPrice
    @PriceMonth CHAR(6) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Month CHAR(6) = ISNULL(@PriceMonth, CONVERT(CHAR(6), GETDATE(), 112));
    DECLARE @Date CHAR(8);
    DECLARE @ThisMonth CHAR(6) = CONVERT(CHAR(6), GETDATE(), 112);
    DECLARE @Level INT = 0;
    DECLARE @Affected INT = 0;
    DECLARE @AppLockResult INT;
    DECLARE @LockResource NVARCHAR(255);

    IF @Month IS NULL OR LEN(RTRIM(@Month)) <> 6
       OR @Month LIKE '%[^0-9]%'
       OR ISDATE(@Month + '01') <> 1
        THROW 51001, N'@PriceMonth 必须是有效 YYYYMM，例如 202610。', 1;

    IF @Month > @ThisMonth
        THROW 51002, N'不允许计算未来月份。', 1;

    SET @LockResource = N'BOM_MONTH_PRICE_SDRD_' + @Month;

    SET @Date = CASE WHEN @Month = @ThisMonth
                     THEN CONVERT(CHAR(8), GETDATE(), 112)
                     ELSE CONVERT(CHAR(8), EOMONTH(CONVERT(DATE, @Month + '01', 112)), 112)
                END;

    /* 按月份互斥，避免人工运行与定时任务同时覆盖同一月份。 */
    EXEC @AppLockResult = sys.sp_getapplock
        @Resource = @LockResource,
        @LockMode = 'Exclusive',
        @LockOwner = 'Session',
        @LockTimeout = 0;
    IF @AppLockResult < 0
        THROW 51003, N'该月份 BOM 价格正在计算，请勿并发执行。', 1;

    BEGIN TRY
        /* 1.当月单位成本。相同品号/月份出现多行时先归并，避免重复 BOM 分支。
             正式上线前应核对 INVLB 是否还需要 COMPANY='0001' 过滤。 */
        SELECT RTRIM(LB001) AS ItemNo,
               MAX(CAST(LB010 AS DECIMAL(24,8))) AS UnitCost
        INTO #Cost
        FROM SDRD.dbo.INVLB
        WHERE LB002 = @Month
        GROUP BY RTRIM(LB001);
        CREATE UNIQUE CLUSTERED INDEX IX_Cost ON #Cost(ItemNo);

        /* 2.有效 BOM 明细，沿用旧视图对 MD013 的过滤规则。
             MD006/MD007 是一单位父件所需的子件数量。
             MD002 作为 BOM 行号，区分一棵树中的相同品号分支。 */
        SELECT RTRIM(K.MD001) AS ParentItem,
               RTRIM(K.MD002) AS [LineNo],
               RTRIM(K.MD003) AS ChildItem,
               CAST(
                   CAST(K.MD006 AS DECIMAL(24,10)) /
                   NULLIF(CAST(K.MD007 AS DECIMAL(24,10)), 0)
                   AS DECIMAL(24,10)
               ) AS BomQty,
               C.UnitCost
        INTO #Edges
        FROM SDRD.dbo.BOMMD K
        LEFT JOIN #Cost C ON C.ItemNo = K.MD003
        WHERE K.MD001 IS NOT NULL AND K.MD003 IS NOT NULL
          AND LTRIM(RTRIM(K.MD001)) <> ''
          AND LTRIM(RTRIM(K.MD003)) <> ''
          AND ISNULL(K.MD007, 0) > 0
          AND ISNULL(K.MD006, 0) > 0
          AND (K.MD001 NOT LIKE '4%' OR K.MD013 = 'Y');
        CREATE INDEX IX_Edges_Parent ON #Edges(ParentItem);

        /* 同一个父件下的 BOM 成本总额 = SUM(子件成本 × 用量)。
           子件有缺失的当月成本时，不对该父件按剩余子件强行分摊。 */
        SELECT ParentItem,
               CAST(SUM(CAST(UnitCost * BomQty AS DECIMAL(28,8))) AS DECIMAL(28,8)) AS TotalCost,
               SUM(CASE WHEN UnitCost IS NULL THEN 1 ELSE 0 END) AS MissingCount
        INTO #ParentCost
        FROM #Edges
        GROUP BY ParentItem;
        CREATE UNIQUE CLUSTERED INDEX IX_ParentCost ON #ParentCost(ParentItem);

        /* 3.在本月份基准日有效的 COPMB 系统售价。
           历史月份取月末有效价格；本月份取今日有效价格。
           MB001=客户；MB002=品号；MB004=币种；MB008=价格。 */
        SELECT CustomerNo, ItemNo, CurrencyNo, UnitPrice
        INTO #SystemPrice
        FROM
        (
            SELECT RTRIM(P.MB001) AS CustomerNo,
                   RTRIM(P.MB002) AS ItemNo,
                   ISNULL(NULLIF(RTRIM(P.MB004), ''), 'RMB') AS CurrencyNo,
                   CAST(P.MB008 AS DECIMAL(24,8)) AS UnitPrice,
                   ROW_NUMBER() OVER
                   (
                       PARTITION BY P.MB001, P.MB002,
                                    ISNULL(NULLIF(RTRIM(P.MB004), ''), 'RMB')
                       ORDER BY P.MB017 DESC, P.MB018 DESC, P.MB008 DESC
                   ) AS RN
            FROM SDRD.dbo.COPMB P
            WHERE P.MB008 > 0
              AND NULLIF(RTRIM(P.MB001), '') IS NOT NULL
              AND NULLIF(RTRIM(P.MB002), '') IS NOT NULL
              AND P.MB017 IS NOT NULL AND P.MB017 <> ''
              AND P.MB017 <= @Date
              AND (P.MB018 IS NULL OR P.MB018 = '' OR P.MB018 >= @Date)
        ) P
        WHERE RN = 1;
        CREATE UNIQUE CLUSTERED INDEX IX_SystemPrice
            ON #SystemPrice(CustomerNo, CurrencyNo, ItemNo);

        /* 4.存在 BOM 子件的、有系统售价的父件作为根节点。
           一个客户、币种、根品号产生一棵独立的价格树。 */
        SELECT P.CustomerNo, P.CurrencyNo,
               P.ItemNo AS RootItemNo, P.UnitPrice
        INTO #Roots
        FROM #SystemPrice P
        WHERE EXISTS (SELECT 1 FROM #Edges E WHERE E.ParentItem = P.ItemNo);

        IF NOT EXISTS (SELECT 1 FROM #Roots)
            THROW 51004, N'没有找到当月有效且有 BOM 的系统定价，旧月度数据未更改。', 1;

        /* 5.使用逐层插入取代复杂的递归 CTE。
           ItemChain 检测循环 BOM；TreePath 保存行号路径。 */
        CREATE TABLE #Tree
        (
            CustomerNo      VARCHAR(30) NOT NULL,
            CurrencyNo      VARCHAR(10) NOT NULL,
            RootItemNo      VARCHAR(50) NOT NULL,
            ParentItemNo    VARCHAR(50) NULL,
            ItemNo          VARCHAR(50) NOT NULL,
            LevelNo         INT NOT NULL,
            BomLineNo       VARCHAR(20) NULL,
            TreePath        VARCHAR(2000) NOT NULL,
            ItemChain       VARCHAR(2000) NOT NULL,
            BomQty          DECIMAL(24,10) NULL,
            MonthUnitCost   DECIMAL(24,8) NULL,
            ParentTotalCost DECIMAL(28,8) NULL,
            RootUnitPrice   DECIMAL(24,8) NOT NULL,
            UnitPrice       DECIMAL(24,8) NOT NULL,
            PriceSource     NVARCHAR(20) NOT NULL
        );
        CREATE INDEX IX_Tree_LevelItem ON #Tree(LevelNo, ItemNo);

        INSERT INTO #Tree
        (
            CustomerNo, CurrencyNo, RootItemNo, ParentItemNo, ItemNo,
            LevelNo, BomLineNo, TreePath, ItemChain, BomQty,
            MonthUnitCost, ParentTotalCost, RootUnitPrice, UnitPrice, PriceSource
        )
        SELECT R.CustomerNo, R.CurrencyNo, R.RootItemNo,
               NULL, R.RootItemNo, 0, NULL,
               R.RootItemNo,
               CAST('|' + R.RootItemNo + '|' AS VARCHAR(2000)),
               NULL, C.UnitCost, NULL,
               R.UnitPrice, R.UnitPrice, N'系统定价'
        FROM #Roots R
        LEFT JOIN #Cost C ON C.ItemNo = R.RootItemNo;

        WHILE @Level < 30
        BEGIN
            INSERT INTO #Tree
            (
                CustomerNo, CurrencyNo, RootItemNo, ParentItemNo, ItemNo,
                LevelNo, BomLineNo, TreePath, ItemChain, BomQty,
                MonthUnitCost, ParentTotalCost, RootUnitPrice, UnitPrice, PriceSource
            )
            SELECT T.CustomerNo, T.CurrencyNo, T.RootItemNo,
                   T.ItemNo, E.ChildItem, T.LevelNo + 1,
                   E.[LineNo],
                   CAST(T.TreePath + '/' + E.[LineNo] AS VARCHAR(2000)),
                   CAST(T.ItemChain + E.ChildItem + '|' AS VARCHAR(2000)),
                   E.BomQty, E.UnitCost, PC.TotalCost,
                   T.RootUnitPrice,
                   CAST(COALESCE(
                       P.UnitPrice,
                       CAST(T.UnitPrice AS DECIMAL(20,8)) *
                       CAST(
                           CAST(E.UnitCost AS DECIMAL(20,8)) /
                           NULLIF(CAST(PC.TotalCost AS DECIMAL(20,8)), 0)
                           AS DECIMAL(18,12)
                       )
                   ) AS DECIMAL(24,8)),
                   CASE WHEN P.UnitPrice IS NOT NULL
                        THEN N'系统定价' ELSE N'BOM成本分摊' END
            FROM #Tree T
            JOIN #Edges E ON E.ParentItem = T.ItemNo
            JOIN #ParentCost PC ON PC.ParentItem = E.ParentItem
            LEFT JOIN #SystemPrice P
                   ON P.CustomerNo = T.CustomerNo
                  AND P.CurrencyNo = T.CurrencyNo
                  AND P.ItemNo = E.ChildItem
            WHERE T.LevelNo = @Level
              AND PC.MissingCount = 0 AND PC.TotalCost > 0
              AND T.UnitPrice > 0
              AND CHARINDEX('|' + E.ChildItem + '|', T.ItemChain) = 0
              AND LEN(T.ItemChain) + LEN(E.ChildItem) + 1 <= 2000
              AND LEN(T.TreePath) + LEN(E.[LineNo]) + 1 <= 2000;

            SET @Affected = @@ROWCOUNT;
            IF @Affected = 0 BREAK;
            SET @Level += 1;
        END;

        IF @Level >= 30
        BEGIN
            IF EXISTS
            (
                SELECT 1 FROM #Tree T
                JOIN #Edges E ON E.ParentItem = T.ItemNo
                JOIN #ParentCost PC ON PC.ParentItem = T.ItemNo
                WHERE T.LevelNo = 30 AND PC.MissingCount = 0
                  AND PC.TotalCost > 0
                  AND CHARINDEX('|' + E.ChildItem + '|', T.ItemChain) = 0
            )
                THROW 51005, N'BOM 超过 30 层，停止更新，避免生成不完整价格树。', 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM #Tree WHERE LevelNo > 0)
            THROW 51006, N'本月未能生成任何 BOM 子件价格，请检查 INVLB.LB010；原有数据未更改。', 1;

        /* 6.按月份原子替换：读视图的用户不会看到删除后、写入前的空窗。 */
        BEGIN TRANSACTION;

        DELETE FROM dbo.BOM_MONTH_PRICE
        WHERE CompanyNo = 'SDRD' AND PriceMonth = @Month;

        INSERT INTO dbo.BOM_MONTH_PRICE
        (
            CompanyNo, PriceMonth, CustomerNo, CurrencyNo,
            RootItemNo, ParentItemNo, ItemNo, LevelNo, BomLineNo,
            TreePath, BomQty, MonthUnitCost, ParentTotalCost,
            RootUnitPrice, UnitPrice, PriceSource, CalcTime
        )
        SELECT 'SDRD', @Month, CustomerNo, CurrencyNo,
               RootItemNo, ParentItemNo, ItemNo, LevelNo, BomLineNo,
               TreePath, BomQty, MonthUnitCost, ParentTotalCost,
               RootUnitPrice, UnitPrice, PriceSource, SYSDATETIME()
        FROM #Tree;

        COMMIT TRANSACTION;

        SELECT @Month AS PriceMonth,
               COUNT_BIG(*) AS TotalNodes,
               SUM(CASE WHEN LevelNo = 0 THEN 1 ELSE 0 END) AS RootCount,
               SUM(CASE WHEN LevelNo > 0 THEN 1 ELSE 0 END) AS ChildCount
        FROM dbo.BOM_MONTH_PRICE
        WHERE CompanyNo = 'SDRD' AND PriceMonth = @Month;

        EXEC sys.sp_releaseapplock
            @Resource = @LockResource,
            @LockOwner = 'Session';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC sys.sp_releaseapplock
            @Resource = @LockResource,
            @LockOwner = 'Session';
        THROW;
    END CATCH;
END;
GO


/* 首次上线选定需要回填的月份范围。示例 2025-01 至当前月。
   只需要运行一次；执行前应核对历史 BOM 结构和历史成本数据是否完整。
   注意：过去月份仍采用当前 BOM 结构，不能自动还原历史版本 BOM。 */
USE [LSSJ];
GO
DECLARE @Month DATE = '20250101';
DECLARE @EndMonth DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

DECLARE @Errors TABLE(PriceMonth CHAR(6), ErrorMessage NVARCHAR(4000));

WHILE @Month <= @EndMonth
BEGIN
    DECLARE @YYYYMM CHAR(6) = CONVERT(CHAR(6), @Month, 112);
    PRINT N'开始计算：' + @YYYYMM;
    BEGIN TRY
        EXEC dbo.usp_RebuildBOMMonthPrice @PriceMonth = @YYYYMM;
    END TRY
    BEGIN CATCH
        INSERT INTO @Errors(PriceMonth, ErrorMessage)
        VALUES (@YYYYMM, ERROR_MESSAGE());
        PRINT N'月份处理失败：' + @YYYYMM + N'，' + ERROR_MESSAGE();
    END CATCH;
    SET @Month = DATEADD(MONTH, 1, @Month);
END;
SELECT * FROM @Errors ORDER BY PriceMonth;
GO

/* 查看任意根品号的各层售价；按树路径排序。 */
SELECT TOP (200) PriceMonth, CustomerNo, CurrencyNo, RootItemNo,
       LevelNo, ParentItemNo, ItemNo, TreePath, BomQty,
       MonthUnitCost, ParentTotalCost, UnitPrice, PriceSource
FROM LSSJ.dbo.BOM_MONTH_PRICE
WHERE CompanyNo = 'SDRD' AND PriceMonth = CONVERT(CHAR(6), GETDATE(), 112)
--AND ISNULL(UnitPrice,0) = 0
--AND LEFT(RootItemNo,1) = 'A'
--AND PriceSource = 'BOM成本分摊'
ORDER BY CustomerNo, CurrencyNo, RootItemNo, TreePath;
GO


USE [SDRD]
GO

/****** 对象:  View [dbo].[vw_ProdOutputReport]    脚本日期: 2026/10/16 14:48:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[vw_ProdOutputReport]
AS
WITH CTE_Base AS (
    --1.生产入库明细
    SELECT 
        G.TG001, G.TG002, G.TG003, G.TG004, G.TG005,
        G.TG006, G.TG007, G.TG010, G.TG013, G.TG014, G.TG015,
        F.TF003, F.TF011, 
        LEFT(F.TF003, 6) AS MonthNo,
        RTRIM(G.TG001) + '-' + RTRIM(G.TG002) + '-' + RTRIM(G.TG003) AS DocKey
    FROM SDRD.dbo.MOCTF F WITH(NOLOCK)
    JOIN SDRD.dbo.MOCTG G WITH(NOLOCK) 
        ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
    WHERE 
        --日期条件移到视图外部，这里不写日期
        F.TF006 = 'Y'
        AND G.TG022 = 'Y'
        AND G.TG001 LIKE '58%'
        AND G.TG014 LIKE '5101%'
        AND (G.TG004 LIKE '1%' OR G.TG004 LIKE 'A%')
),
CTE_PriceKeys AS (
    --2.客户商品价格匹配条件
    SELECT DISTINCT 
        O.TC004 AS CustomerNo, 
        B.TG004 AS ItemNo,
        B.TF003 AS ProdDate,
        ISNULL(NULLIF(RTRIM(O.TC008), ''), 'RMB') AS CurrencyNo
    FROM CTE_Base B
    JOIN SDRD.dbo.MOCTA A WITH(NOLOCK) 
        ON B.TG014 = A.TA001 AND B.TG015 = A.TA002
    JOIN SDRD.dbo.COPTC O WITH(NOLOCK) 
        ON A.TA026 = O.TC001 AND A.TA027 = O.TC002
    WHERE O.TC004 IS NOT NULL AND O.TC004 <> ''
),
CTE_Price AS (
    --3.系统定价：生产当日有效客户商品价格
    SELECT CustomerNo, ItemNo, ProdDate, CurrencyNo, Price
    FROM (
        SELECT 
            K.*, 
            Q.MB008 AS Price,
            ROW_NUMBER() OVER (
                PARTITION BY K.CustomerNo, K.ItemNo, K.ProdDate, K.CurrencyNo
                ORDER BY Q.MB017 DESC, Q.MB018 DESC, Q.MB008 DESC
            ) AS RN
        FROM CTE_PriceKeys K
        JOIN SDRD.dbo.COPMB Q WITH(NOLOCK)
            ON Q.MB001 = K.CustomerNo 
            AND Q.MB002 = K.ItemNo
            AND Q.MB004 = K.CurrencyNo
            AND Q.MB017 IS NOT NULL AND Q.MB017 <> ''
            AND Q.MB017 <= K.ProdDate
            AND (Q.MB018 IS NULL OR Q.MB018 = '' OR Q.MB018 >= K.ProdDate)
    ) X WHERE RN = 1
),
CTE_Cost AS (
    --4.实际材料成本：最近交易记录
    SELECT LA001, LA006, LA007, LA008, LA017
    FROM (
        SELECT 
            L.LA001, L.LA006, L.LA007, L.LA008, L.LA017,
            ROW_NUMBER() OVER (
                PARTITION BY L.LA006, L.LA007, L.LA008, L.LA001
                ORDER BY L.LA004 DESC
            ) AS RN
        FROM SDRD.dbo.INVLA L WITH(NOLOCK)
        JOIN CTE_Base B 
            ON L.LA001 = B.TG004 
            AND L.LA006 = B.TG001
            AND L.LA007 = B.TG002 
            AND L.LA008 = B.TG003
        WHERE L.LA006 LIKE '58%'
    ) X WHERE RN =1
),
CTE_Rate AS (
    --5.月份汇率
    SELECT MG001, MonthNo, MG003
    FROM (
        SELECT 
            R.MG001, 
            LEFT(R.MG002, 6) AS MonthNo, 
            R.MG003,
            ROW_NUMBER() OVER (
                PARTITION BY R.MG001, LEFT(R.MG002, 6)
                ORDER BY R.MG002
            ) AS RN
        FROM SDRD.dbo.CMSMG R WITH(NOLOCK)
    ) X WHERE RN =1
)
--6.最终产值报表
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
    CASE WHEN CM.MA002 IS NULL THEN NULL ELSE RTRIM(CM.MA002) + '+' + ISNULL(RTRIM(C3.MA003), '') END AS [客户+类别],
    B.TG007 AS [单位],
    CU.CurrencyNo AS [币种],
    CAST(O.TC009 AS FLOAT) AS [汇率],
    CAST(B.TG013 AS FLOAT) AS [验收数量],
    PR.Price   AS [单价],
    CAST(V.产值/CTE_Rate2.MG003 AS FLOAT) AS [产值],
    CAST(T.不含税产值/CTE_Rate2.MG003 AS FLOAT) AS [不含税产值],
    CAST(ISNULL(MB.MB057, 0)/CTE_Rate2.MG003 AS FLOAT) AS [单位标准材料成本],
    B.TF011 AS [工作中心],
    D.MD002 AS [工作中心名称],
    CASE WHEN D.MD011 IS NULL THEN '顺德瑞德'  ELSE LEFT(D.MD011, CHARINDEX('-', D.MD011 + '-') - 1)  END AS [事业部],
    B.TG010 AS [仓库],
    B.TG014 AS [工单单别],
    B.TG015 AS [工单单号],
    A.TA026 AS [订单单别],
    A.TA027 AS [订单单号],
    CASE WHEN ISNULL(A.TA026, '') = '' OR ISNULL(A.TA027, '') = ''
         THEN NULL
         ELSE RTRIM(A.TA026) + '-' + RTRIM(A.TA027)
    END AS [客户订单],
    A.TA028 AS [订单序号],
    MB.MB008 AS [品号分类四],
    C4.MA003 AS [品号类别名称],
    C3.MA003 AS [商品类别],
    PR.PriceSource AS [备注],
    ISNULL(MB.MB096, 0) AS [工时底数],
    CAST(ISNULL(MB.MB096, 0) * 100.0 / 3600 * B.TG013 AS DECIMAL(24, 10)) AS [定额工时],
     CAST(U.UnitMaterial/CTE_Rate2.MG003 AS FLOAT)AS [单位材料],
     CAST(ISNULL(L.LA017, 0)/CTE_Rate2.MG003 AS FLOAT)AS [材料成本],
     CASE WHEN ISNULL(T.不含税产值, 0) = 0 THEN '0.00%' ELSE CONCAT(CAST(ISNULL(L.LA017, 0) * 100.0 / NULLIF(T.不含税产值, 0) AS DECIMAL(15, 2)), '%') END AS [材料占比],
    0 AS [材料剔除],
    CASE WHEN O.TC008 = 'USD' OR CM.MA001 = '10000059'  THEN 'Y' ELSE 'N' END AS [外销]      
FROM CTE_Base B
LEFT JOIN SDRD.dbo.MOCTA A WITH(NOLOCK) 
    ON B.TG014 = A.TA001 AND B.TG015 = A.TA002
LEFT JOIN SDRD.dbo.COPTC O WITH(NOLOCK) 
    ON A.TA026 = O.TC001 AND A.TA027 = O.TC002
LEFT JOIN SDRD.dbo.COPTD OD WITH(NOLOCK) 
    ON OD.TD001 = A.TA026 AND OD.TD002 = A.TA027
    AND OD.TD003 = A.TA028 AND OD.TD004 = B.TG004
LEFT JOIN SDRD.dbo.COPMA CM WITH(NOLOCK) 
    ON O.TC004 = CM.MA001
LEFT JOIN SDRD.dbo.INVMB MB WITH(NOLOCK) 
    ON B.TG004 = MB.MB001
LEFT JOIN SDRD.dbo.INVMA C4 WITH(NOLOCK) 
    ON MB.MB008 = C4.MA002
LEFT JOIN SDRD.dbo.INVMA C3 WITH(NOLOCK) 
    ON MB.MB007 = C3.MA002
LEFT JOIN SDRD.dbo.CMSMD D WITH(NOLOCK) 
    ON B.TF011 = D.MD001

CROSS APPLY (
    SELECT ISNULL(NULLIF(RTRIM(O.TC008), ''), 'RMB') AS CurrencyNo
) CU

LEFT JOIN CTE_Price P 
    ON P.CustomerNo = O.TC004 AND P.ItemNo = B.TG004
    AND P.ProdDate = B.TF003 AND P.CurrencyNo = CU.CurrencyNo

LEFT JOIN CTE_Cost L 
    ON B.TG004 = L.LA001 AND B.TG001 = L.LA006
    AND B.TG002 = L.LA007 AND B.TG003 = L.LA008

LEFT JOIN CTE_Rate R 
    ON R.MG001 = CU.CurrencyNo AND R.MonthNo = B.MonthNo

--第四优先级：使用 LSSJ 按月预计算的多层 BOM 单价（不再逐条扫描 BOMMD）
OUTER APPLY (
    SELECT TOP (1) BP.UnitPrice AS KitPrice
    FROM LSSJ.dbo.BOM_MONTH_PRICE BP
    WHERE BP.CompanyNo = 'SDRD'
      AND BP.PriceMonth = B.MonthNo
      AND BP.CustomerNo = RTRIM(O.TC004)
      AND BP.CurrencyNo = CU.CurrencyNo
      AND BP.ItemNo = RTRIM(B.TG004)
      AND BP.LevelNo > 0
      AND BP.UnitPrice > 0
      -- 前两个优先级命中时，不执行套件备选取价
      AND (OD.TD011 IS NULL OR OD.TD011 <= 0.1)
      AND ISNULL(P.Price, 0) <= 0
    ORDER BY
        CASE WHEN EXISTS (
             SELECT 1 FROM SDRD.dbo.COPTD OD2 WITH(NOLOCK)
             WHERE OD2.TD001 = A.TA026
               AND OD2.TD002 = A.TA027
               AND OD2.TD004 = BP.RootItemNo
        ) THEN 0 ELSE 1 END,
        BP.LevelNo ASC, BP.RootItemNo, BP.TreePath
) KIT

--税率系数
CROSS APPLY (
    SELECT CAST(
        CASE WHEN O.TC008 = 'USD' OR CM.MA001 = '10000059' OR O.TC016 IN ('3', '4', '9')
             THEN 1.0 ELSE 1.0 + ISNULL(CAST(O.TC041 AS DECIMAL(18, 6)), 0.13)
        END AS DECIMAL(18, 6)
    ) AS TaxFactor
) TX

--四级取价
CROSS APPLY (
    SELECT
        CAST(
            CASE 
                 WHEN OD.TD011 IS NOT NULL and OD.TD011>0.1 THEN OD.TD011
                 WHEN P.Price > 0 THEN P.Price
                 WHEN KIT.KitPrice IS NOT NULL THEN KIT.KitPrice
                 WHEN L.LA017 > 0 AND B.TG013 > 0 THEN CAST(L.LA017 AS DECIMAL(24, 6))/ NULLIF(CAST(B.TG013 AS DECIMAL(24, 6)), 0) / 0.6 * TX.TaxFactor
                 ELSE 0
            END AS DECIMAL(24, 8)
        ) AS Price,
         CAST(
            CASE 
                 WHEN OD.TD011 IS NOT NULL and OD.TD011>0.1 THEN OD.TD011*O.TC009
                 WHEN P.Price > 0 THEN P.Price*O.TC009
                 WHEN KIT.KitPrice IS NOT NULL THEN KIT.KitPrice*O.TC009
                 WHEN L.LA017 > 0 AND B.TG013 > 0 THEN CAST(L.LA017 AS DECIMAL(24, 6))/ NULLIF(CAST(B.TG013 AS DECIMAL(24, 6)), 0) / 0.6 * TX.TaxFactor
                 ELSE 0
            END AS DECIMAL(24, 8)
        ) AS RMBPrice,
        CASE 
             WHEN OD.TD011 IS NOT NULL and OD.TD011>0.1 THEN '订单价格'
             WHEN P.Price > 0 THEN '系统定价'
             WHEN KIT.KitPrice IS NOT NULL THEN '系统套件拆分'
             WHEN L.LA017 > 0 AND B.TG013 > 0 THEN '按60%材料折算'
             ELSE ''
        END AS PriceSource
) PR

CROSS APPLY (
    SELECT CAST(B.TG013 * PR.RMBPrice AS DECIMAL(24, 4)) AS 产值
) V

CROSS APPLY (
    SELECT CAST(V.产值 / NULLIF(TX.TaxFactor, 0)
                AS DECIMAL(24, 4)) AS 不含税产值
) T

CROSS APPLY (
    SELECT ISNULL(CAST(ISNULL(L.LA017, 0) / NULLIF(B.TG013, 0)
                       AS DECIMAL(24, 9)), 0) AS UnitMaterial
) U
CROSS APPLY (
  SELECT MG001, MonthNo, MG003
    FROM (
        SELECT 
            R.MG001, 
            LEFT(R.MG002, 6) AS MonthNo, 
            R.MG003,
            ROW_NUMBER() OVER (
                PARTITION BY R.MG001 
                ORDER BY R.MG002
            ) AS RN
        FROM SDRD.dbo.CMSMG R WITH(NOLOCK) where MG001='RMB'
    ) X WHERE RN =1
)CTE_Rate2
GO




/* 执行账号需有 msdb SQL Server Agent 作业管理权限。
   SQL Server Agent 必须已启动；06:00 使用数据库服务器本地时间。 */
USE [msdb];
GO
DECLARE @JobName SYSNAME = N'SDRD_BOM月度价格_每日0600';
DECLARE @JobId UNIQUEIDENTIFIER;

/* 只替换我们自己的同名任务，不影响其他 SQL Agent 作业。 */
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = @JobName)
    EXEC dbo.sp_delete_job @job_name = @JobName, @delete_unused_schedule = 1;

EXEC dbo.sp_add_job
    @job_name = @JobName,
    @enabled = 1,
    @description = N'每天06:00刷新 LSSJ.dbo.BOM_MONTH_PRICE 当前月 SDRD 的 BOM 分摊价格',
    @job_id = @JobId OUTPUT;

EXEC dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_name = N'刷新当前月份价格',
    @subsystem = N'TSQL',
    @database_name = N'LSSJ',
    @command = N'EXEC dbo.usp_RebuildBOMMonthPrice;',
    @retry_attempts = 2,
    @retry_interval = 10,
    @on_success_action = 1,
    @on_fail_action = 2;

EXEC dbo.sp_add_schedule
    @schedule_name = N'SDRD_BOM月度价格_每天0600',
    @enabled = 1,
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 60000;

EXEC dbo.sp_attach_schedule
    @job_id = @JobId,
    @schedule_name = N'SDRD_BOM月度价格_每天0600';

EXEC dbo.sp_add_jobserver @job_id = @JobId;
GO
