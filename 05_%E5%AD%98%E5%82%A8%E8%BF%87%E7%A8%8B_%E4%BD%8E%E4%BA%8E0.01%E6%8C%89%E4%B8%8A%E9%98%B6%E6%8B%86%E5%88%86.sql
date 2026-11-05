USE [LSSJ]
GO

/****** 对象:  StoredProcedure [dbo].[usp_RebuildBOMMonthPrice]    脚本日期: 2026/10/17 11:41:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[usp_RebuildBOMMonthPrice]
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
           先选择最新生效记录；若最新单价低于 0.01，则视为无售价。
           无有效售价的子件将在下一层按照父件单位售价分摊。
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
            WHERE P.MB008 IS NOT NULL
              AND NULLIF(RTRIM(P.MB001), '') IS NOT NULL
              AND NULLIF(RTRIM(P.MB002), '') IS NOT NULL
              AND P.MB017 IS NOT NULL AND P.MB017 <> ''
              AND P.MB017 <= @Date
              AND (P.MB018 IS NULL OR P.MB018 = '' OR P.MB018 >= @Date)
        ) P
        WHERE RN = 1 AND UnitPrice >= 0.01;
        CREATE UNIQUE CLUSTERED INDEX IX_SystemPrice
            ON #SystemPrice(CustomerNo, CurrencyNo, ItemNo);

        /* 4.存在 BOM 子件的、系统售价不低于 0.01 的父件作为根节点。
           一个客户、币种、根品号产生一棵独立的价格树。 */
        SELECT P.CustomerNo, P.CurrencyNo,
               P.ItemNo AS RootItemNo, P.UnitPrice
        INTO #Roots
        FROM #SystemPrice P
        WHERE EXISTS (SELECT 1 FROM #Edges E WHERE E.ParentItem = P.ItemNo);

        IF NOT EXISTS (SELECT 1 FROM #Roots)
            THROW 51004, N'没有找到当月有效且有 BOM 的系统定价，旧月度数据未更改。', 1;

        /* 5.使用逐层插入取代复杂的递归 CTE。
           #SystemPrice 已剔除无效低价，COALESCE(P.UnitPrice, 分摊价)
           会对系统价低于 0.01 的子件按上阶售价继续分摊。
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


