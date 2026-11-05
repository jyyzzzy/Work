USE SDRD;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- 0 = 仅预览；1 = 正式生成未审核调拨单（不会直接修改 INVMC）
DECLARE @Execute BIT = 0;
DECLARE @DocType CHAR(4) = '1201';
DECLARE @Now DATETIME = GETDATE();
DECLARE @BizDate CHAR(8) = CONVERT(CHAR(8), @Now, 112);
DECLARE @Prefix CHAR(6) = CONVERT(CHAR(6), @Now, 112);
DECLARE @CreateTime CHAR(17) = CONVERT(CHAR(8), @Now, 112)
    + REPLACE(CONVERT(CHAR(12), @Now, 114), ':', '');
DECLARE @MaxSerial INT = 0;
DECLARE @RowCount BIGINT = 0;
DECLARE @SheetCount INT = 0;

DROP TABLE IF EXISTS #Requests;
DROP TABLE IF EXISTS #Transfer;
DROP TABLE IF EXISTS #Lines;

BEGIN TRY
    BEGIN TRAN;

    -- 去重后读取配置，避免重复插入同一物料、同一仓库的调拨明细。
    SELECT DISTINCT
        LTRIM(RTRIM(ItemCode)) AS ItemCode,
        LTRIM(RTRIM(FromWarehouse)) AS FromWarehouse,
        LTRIM(RTRIM(ToWarehouse)) AS ToWarehouse
    INTO #Requests
    FROM LSSJ..TmpItemTransfer WITH(NOLOCK);

    IF NOT EXISTS (SELECT 1 FROM #Requests)
        THROW 50001, N'TmpItemTransfer 没有待处理数据。', 1;

    IF EXISTS
    (
        SELECT 1 FROM #Requests
        WHERE NULLIF(ItemCode, '') IS NULL
           OR NULLIF(FromWarehouse, '') IS NULL
           OR NULLIF(ToWarehouse, '') IS NULL
           OR FromWarehouse = ToWarehouse
    )
        THROW 50002, N'存在空品号、空仓库或来源仓与目标仓相同的配置。', 1;

    IF EXISTS
    (
        SELECT 1 FROM #Requests
        GROUP BY ItemCode, FromWarehouse
        HAVING COUNT(DISTINCT ToWarehouse) > 1
    )
        THROW 50003, N'同一品号、同一来源仓配置了多个目标仓，无法执行全量调拨。', 1;

    -- 验证品号及来源/目标仓存在；不允许因 INNER JOIN 默默丢掉配置行。
    IF EXISTS
    (
        SELECT 1
        FROM #Requests R
        LEFT JOIN dbo.INVMB B WITH(NOLOCK) ON B.MB001 = R.ItemCode
        LEFT JOIN dbo.CMSMC W1 WITH(NOLOCK) ON W1.MC001 = R.FromWarehouse
        LEFT JOIN dbo.CMSMC W2 WITH(NOLOCK) ON W2.MC001 = R.ToWarehouse
        WHERE B.MB001 IS NULL OR W1.MC001 IS NULL OR W2.MC001 IS NULL
    )
        THROW 50004, N'配置中有不存在的品号或仓库，请先检查 INVMB/CMSMC。', 1;

    -- MC007 = 来源仓现有库存数量。只调拨正库存，负库存、零库存不生成明细。
    -- 为了避免脏读，库存数量不加 NOLOCK；其他只读基础资料沿用 NOLOCK。
    SELECT
        ROW_NUMBER() OVER (ORDER BY R.ItemCode, R.FromWarehouse, R.ToWarehouse) AS RowNo,
        R.ItemCode,
        R.FromWarehouse,
        R.ToWarehouse,
        C.MC007 AS TransferQty,
        B.MB002,
        B.MB003,
        B.MB004,
        ISNULL(B.MB057, 0) AS MB057,
        B.MB072,
        B.MB090,
        ISNULL(C.MC003, '') AS MC003
    INTO #Transfer
    FROM #Requests R
    INNER JOIN dbo.INVMC C
        ON C.MC001 = R.ItemCode AND C.MC002 = R.FromWarehouse
    INNER JOIN dbo.INVMB B WITH(NOLOCK)
        ON B.MB001 = R.ItemCode
    WHERE C.MC007 > 0;

    SELECT @RowCount = COUNT_BIG(*) FROM #Transfer;
    IF @RowCount = 0
        THROW 50005, N'来源仓没有符合条件的正库存，未生成调拨单。', 1;

    SET @SheetCount = CONVERT(INT, (@RowCount + 3332) / 3333);

    -- 以 INVTA 和 INVTB 同时占用的当月最大序号为基准。
    -- 锁定相关单号范围，尽量避免与并发开单的单号冲突。
    SELECT @MaxSerial = ISNULL(MAX(SerialNo), 0)
    FROM
    (
        SELECT TRY_CONVERT(INT, RIGHT(RTRIM(TA002), 5)) AS SerialNo
        FROM dbo.INVTA WITH(UPDLOCK, HOLDLOCK)
        WHERE TA001 = @DocType AND TA002 LIKE @Prefix + '%'

        UNION ALL

        SELECT TRY_CONVERT(INT, RIGHT(RTRIM(TB002), 5))
        FROM dbo.INVTB WITH(UPDLOCK, HOLDLOCK)
        WHERE TB001 = @DocType AND TB002 LIKE @Prefix + '%'
    ) N;

    IF @MaxSerial + @SheetCount > 99999
        THROW 50006, N'本月调拨单号超出五位流水号范围。', 1;

    -- 一张单据最多 3333 行；从当月最大单号的下一个连续编号开始。
    SELECT
        T.*,
        CAST(@Prefix + RIGHT('00000' + CAST(
            @MaxSerial + 1 + CONVERT(INT, (T.RowNo - 1) / 3333)
            AS VARCHAR(5)), 5) AS CHAR(11)) AS DocNo,
        CAST(RIGHT('0000' + CAST(
            (T.RowNo - 1) % 3333 + 1
            AS VARCHAR(4)), 4) AS CHAR(4)) AS DetailNo
    INTO #Lines
    FROM #Transfer T;

    IF @Execute = 1
    BEGIN
        INSERT INTO dbo.INVTB
        (
            COMPANY, CREATOR, USR_GROUP, CREATE_DATE, MODIFIER, MODI_DATE, FLAG,
            TB001, TB002, TB003, TB004, TB005, TB006, TB007, TB008, TB009, TB010,
            TB011, TB012, TB013, TB014, TB015, TB016, TB017, TB018, TB019, TB020,
            TB021, TB022, TB023, TB024, TB025, TB026, TB027, TB028, TB029, TB030,
            TB031, TB032, TB033, TB034, TB035, TB036, TB037,
            UDF01, UDF02, UDF03, UDF04, UDF05, UDF06,
            UDF51, UDF52, UDF53, UDF54, UDF55, UDF56
        )
        SELECT
            '0001', '10105978', '90001', @CreateTime, '', '', 1,
            @DocType, L.DocNo, L.DetailNo, L.ItemCode, L.MB002, L.MB003,
            L.TransferQty, L.MB004, L.TransferQty, L.MB057,
            CAST(L.TransferQty * L.MB057 AS NUMERIC(15,2)),
            L.FromWarehouse, L.ToWarehouse, '********************',
            '', '', N'来源仓全部库存调拨', 'N', @BizDate, L.MB072,
            '', 0, L.MB090, L.MC003, 0, 0, 0, '', '##########', '##########',
            '', '', '', '', 0, 0, 0,
            '', '', '', '', '', '',
            0, 0, 0, 0, 0, 0
        FROM #Lines L;

        INSERT INTO dbo.INVTA
        (
            COMPANY, CREATOR, USR_GROUP, CREATE_DATE, MODIFIER, MODI_DATE, FLAG,
            TA001, TA002, TA003, TA004, TA005, TA006, TA007, TA008, TA009, TA010,
            TA011, TA012, TA013, TA014, TA015, TA016, TA017, TA018, TA019, TA020,
            TA021, TA022, TA023, TA024, TA025, TA026, TA027, TA028, TA029, TA030,
            TA031, UDF01, UDF02, UDF03, UDF04, UDF05, UDF06,
            UDF51, UDF52, UDF53, UDF54, UDF55, UDF56
        )
        SELECT
            '0001', '10105978', '90001', @CreateTime, '', '', 1,
            @DocType, L.DocNo, @BizDate, '120800', '', 'N', 0, '000101', '12', 0,
            SUM(L.TransferQty),
            SUM(CAST(L.TransferQty * L.MB057 AS NUMERIC(15,2))),
            'N', @BizDate, '', 0, 'N', '', '', '', 0, '', '', '', '1', '', '', '',
            0, 0, 0,
            '', '', '', '', '', '',
            0, 0, 0, 0, 0, 0
        FROM #Lines L
        GROUP BY L.DocNo;

        IF (SELECT COUNT(*) FROM dbo.INVTA WHERE TA001 = @DocType
            AND TA002 IN (SELECT DISTINCT DocNo FROM #Lines)) <> @SheetCount
            THROW 50007, N'表头数量与拆单数量不一致，已取消本次操作。', 1;

        COMMIT TRAN;
    END;

    -- 预览时先输出结果再回滚：临时表是在事务中创建的，回滚会删除临时表。
    SELECT
        CASE WHEN @Execute = 1 THEN N'已生成待审核调拨单' ELSE N'仅预览，未写入数据库' END AS 执行状态,
        L.DocNo AS 调拨单号,
        COUNT(*) AS 明细行数,
        SUM(L.TransferQty) AS 调拨总数量,
        SUM(CAST(L.TransferQty * L.MB057 AS NUMERIC(15,2))) AS 调拨总金额
    FROM #Lines L
    GROUP BY L.DocNo
    ORDER BY L.DocNo;

    SELECT
        L.DocNo AS 调拨单号,
        L.DetailNo AS 序号,
        L.ItemCode AS 品号,
        L.MB002 AS 品名,
        L.FromWarehouse AS 来源仓,
        L.ToWarehouse AS 目标仓,
        L.TransferQty AS 调拨数量,
        L.MB057 AS 单位成本,
        CAST(L.TransferQty * L.MB057 AS NUMERIC(15,2)) AS 金额
    FROM #Lines L
    ORDER BY L.DocNo, L.DetailNo;

    IF @Execute = 0 ROLLBACK TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH;
GO
