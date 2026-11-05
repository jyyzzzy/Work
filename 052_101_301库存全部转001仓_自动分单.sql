SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @DOC_TYPE    VARCHAR(4)  = '1201';
DECLARE @DOC_DATE    VARCHAR(8)  = CONVERT(VARCHAR(8), GETDATE(), 112);
DECLARE @YM          VARCHAR(6)  = CONVERT(VARCHAR(6), GETDATE(), 112);
DECLARE @CREATE_DATE VARCHAR(17);

DECLARE @MAX_TA_SEQ  INT;
DECLARE @MAX_TB_SEQ  INT;
DECLARE @START_SEQ   INT;
DECLARE @DOC_COUNT   INT;

SET @CREATE_DATE =
      CONVERT(VARCHAR(8), GETDATE(), 112)
    + REPLACE(CONVERT(VARCHAR(12), GETDATE(), 114), ':', '');

IF OBJECT_ID('tempdb..#TRANSFER') IS NOT NULL DROP TABLE #TRANSFER;
IF OBJECT_ID('tempdb..#DOC') IS NOT NULL DROP TABLE #DOC;

------------------------------------------------------------
-- 1. 取得052、101、301仓全部非零库存
--    正库存、负库存都生成调拨单
--
--    TB007 = MC007 库存数量
--    TB010 = MC008 / MC007 单位成本
--    TB011 = MC008 库存金额
--
--    每3333笔分一张单
------------------------------------------------------------
SELECT
    X.RN,
    ((X.RN - 1) / 3333) + 1 AS BATCH_NO,
    ((X.RN - 1) % 3333) + 1 AS LINE_NO,

    X.MC001,
    X.MC002,
    X.MC003,
    X.MC007,
    X.MC008,

    X.MB002,
    X.MB003,
    X.MB004,
    X.MB072,
    X.MB090,

    CAST
    (
        CAST(X.MC008 AS DECIMAL(38,8))
        /
        NULLIF(CAST(X.MC007 AS DECIMAL(38,8)), 0)
        AS DECIMAL(17,8)
    ) AS UNIT_COST
INTO #TRANSFER
FROM
(
    SELECT
        ROW_NUMBER() OVER
        (
            ORDER BY C.MC002, C.MC001
        ) AS RN,

        C.MC001,
        C.MC002,
        C.MC003,
        C.MC007,
        C.MC008,

        M.MB002,
        M.MB003,
        M.MB004,
        M.MB072,
        M.MB090
    FROM dbo.INVMC C
    INNER JOIN dbo.INVMB M
        ON M.MB001 = C.MC001
    WHERE C.MC002 IN ('052', '101', '301')
      AND C.MC007 <> 0
) X;

------------------------------------------------------------
-- 2. 没有库存则停止
------------------------------------------------------------
IF NOT EXISTS
(
    SELECT 1
    FROM #TRANSFER
)
BEGIN
    THROW 50001, '052、101、301仓没有非零库存。', 1;
END;

------------------------------------------------------------
-- 3. 计算需要生成多少张调拨单
------------------------------------------------------------
SELECT
    @DOC_COUNT = MAX(BATCH_NO)
FROM #TRANSFER;

BEGIN TRY

    BEGIN TRANSACTION;

    ------------------------------------------------------------
    -- 4. 取得当前月份最后一个1201单号
    --    同时检查INVTA / INVTB，避免单号冲突
    ------------------------------------------------------------
    SELECT
        @MAX_TA_SEQ =
            ISNULL
            (
                MAX
                (
                    TRY_CONVERT
                    (
                        INT,
                        RIGHT(TA002, 5)
                    )
                ),
                0
            )
    FROM dbo.INVTA WITH (UPDLOCK, HOLDLOCK)
    WHERE TA001 = @DOC_TYPE
      AND LEFT(TA002, 6) = @YM;

    SELECT
        @MAX_TB_SEQ =
            ISNULL
            (
                MAX
                (
                    TRY_CONVERT
                    (
                        INT,
                        RIGHT(TB002, 5)
                    )
                ),
                0
            )
    FROM dbo.INVTB WITH (UPDLOCK, HOLDLOCK)
    WHERE TB001 = @DOC_TYPE
      AND LEFT(TB002, 6) = @YM;

    SET @START_SEQ =
        CASE
            WHEN @MAX_TA_SEQ > @MAX_TB_SEQ
                THEN @MAX_TA_SEQ
            ELSE @MAX_TB_SEQ
        END + 1;

    ------------------------------------------------------------
    -- 5. 检查单号是否超过99999
    ------------------------------------------------------------
    IF @START_SEQ + @DOC_COUNT - 1 > 99999
    BEGIN
        THROW 50002, '本月1201调拨单号已经超过99999。', 1;
    END;

    ------------------------------------------------------------
    -- 6. 建立批次与调拨单号对应关系
    ------------------------------------------------------------
    SELECT
        D.BATCH_NO,
        @YM +
        RIGHT
        (
            '00000' +
            CAST
            (
                @START_SEQ + D.BATCH_NO - 1
                AS VARCHAR(5)
            ),
            5
        ) AS DOC_NO
    INTO #DOC
    FROM
    (
        SELECT DISTINCT
            BATCH_NO
        FROM #TRANSFER
    ) D;

    ------------------------------------------------------------
    -- 7. 插入调拨单身 INVTB
    ------------------------------------------------------------
    INSERT INTO dbo.INVTB
    (
         COMPANY
        ,CREATOR
        ,USR_GROUP
        ,CREATE_DATE
        ,MODIFIER
        ,MODI_DATE
        ,FLAG

        ,TB001
        ,TB002
        ,TB003
        ,TB004
        ,TB005
        ,TB006
        ,TB007
        ,TB008
        ,TB009
        ,TB010
        ,TB011
        ,TB012
        ,TB013
        ,TB014
        ,TB015
        ,TB016
        ,TB017
        ,TB018
        ,TB019
        ,TB020
        ,TB021
        ,TB022
        ,TB023
        ,TB024
        ,TB025
        ,TB026
        ,TB027
        ,TB028
        ,TB029
        ,TB030
        ,TB031
        ,TB032
        ,TB033
        ,TB034
        ,TB035
        ,TB036
        ,TB037

        ,UDF01
        ,UDF02
        ,UDF03
        ,UDF04
        ,UDF05
        ,UDF06
        ,UDF51
        ,UDF52
        ,UDF53
        ,UDF54
        ,UDF55
        ,UDF56
    )
    SELECT
         '0001'
        ,'10105978'
        ,'90001'
        ,@CREATE_DATE
        ,''
        ,''
        ,1

        ,@DOC_TYPE
        ,D.DOC_NO

        --------------------------------------------------------
        -- 每张单从0001重新编号，最大3333
        --------------------------------------------------------
        ,RIGHT
        (
            '0000' + CAST(T.LINE_NO AS VARCHAR(4)),
            4
        )

        ,T.MC001
        ,T.MB002
        ,T.MB003

        --------------------------------------------------------
        -- 调拨数量：直接取INVMC现有库存
        -- 正负号完整保留
        --------------------------------------------------------
        ,T.MC007

        ,T.MB004

        --------------------------------------------------------
        -- 库存数量
        --------------------------------------------------------
        ,T.MC007

        --------------------------------------------------------
        -- 单位成本 = 库存金额 / 库存数量
        -- 不使用ABS，负号按实际计算结果保留
        --------------------------------------------------------
        ,T.UNIT_COST

        --------------------------------------------------------
        -- 金额：直接取INVMC.MC008
        -- 不使用数量×单位成本重新反算
        --------------------------------------------------------
        ,T.MC008

        --------------------------------------------------------
        -- 转出仓 / 转入仓
        --------------------------------------------------------
        ,T.MC002
        ,'001'

        ,'********************'
        ,''
        ,''
        ,'052/101/301库存全部转001仓'
        ,'N'
        ,@DOC_DATE
        ,T.MB072
        ,''
        ,0
        ,T.MB090

        --------------------------------------------------------
        -- 存储位置
        --------------------------------------------------------
        ,T.MC003

        ,0
        ,0
        ,0
        ,''
        ,'##########'
        ,'##########'
        ,''
        ,''
        ,''
        ,''
        ,0
        ,0
        ,0

        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
    FROM #TRANSFER T
    INNER JOIN #DOC D
        ON D.BATCH_NO = T.BATCH_NO;

    ------------------------------------------------------------
    -- 8. 插入调拨单头 INVTA
    --    每3333条生成一个单头
    ------------------------------------------------------------
    INSERT INTO dbo.INVTA
    (
         COMPANY
        ,CREATOR
        ,USR_GROUP
        ,CREATE_DATE
        ,MODIFIER
        ,MODI_DATE
        ,FLAG

        ,TA001
        ,TA002
        ,TA003
        ,TA004
        ,TA005
        ,TA006
        ,TA007
        ,TA008
        ,TA009
        ,TA010
        ,TA011
        ,TA012
        ,TA013
        ,TA014
        ,TA015
        ,TA016
        ,TA017
        ,TA018
        ,TA019
        ,TA020
        ,TA021
        ,TA022
        ,TA023
        ,TA024
        ,TA025
        ,TA026
        ,TA027
        ,TA028
        ,TA029
        ,TA030
        ,TA031

        ,UDF01
        ,UDF02
        ,UDF03
        ,UDF04
        ,UDF05
        ,UDF06
        ,UDF51
        ,UDF52
        ,UDF53
        ,UDF54
        ,UDF55
        ,UDF56
    )
    SELECT
         '0001'
        ,'10105978'
        ,'90001'
        ,@CREATE_DATE
        ,''
        ,''
        ,1

        ,@DOC_TYPE
        ,D.DOC_NO
        ,@DOC_DATE
        ,'120800'
        ,'052/101/301库存全部转001仓'
        ,'N'
        ,0
        ,'000101'
        ,'12'
        ,0

        --------------------------------------------------------
        -- 总数量：正负库存按实际符号汇总
        --------------------------------------------------------
        ,SUM(T.MC007)

        --------------------------------------------------------
        -- 总金额：正负金额按实际符号汇总
        --------------------------------------------------------
        ,SUM(T.MC008)

        ,'N'
        ,@DOC_DATE
        ,''
        ,0
        ,'N'
        ,''
        ,''
        ,''
        ,0
        ,''
        ,''
        ,''
        ,'1'
        ,''
        ,''
        ,''
        ,0
        ,0
        ,0

        ,''
        ,''
        ,''
        ,''
        ,''
        ,''
        ,0
        ,0
        ,0
        ,0
        ,0
        ,0
    FROM #TRANSFER T
    INNER JOIN #DOC D
        ON D.BATCH_NO = T.BATCH_NO
    GROUP BY
        T.BATCH_NO,
        D.DOC_NO;

    COMMIT TRANSACTION;

    ------------------------------------------------------------
    -- 9. 显示生成的调拨单汇总
    ------------------------------------------------------------
    SELECT
        D.BATCH_NO AS 批次,
        @DOC_TYPE AS 单别,
        D.DOC_NO AS 单号,
        COUNT(*) AS 明细笔数,
        SUM(T.MC007) AS 调拨数量,
        SUM(T.MC008) AS 调拨金额
    FROM #TRANSFER T
    INNER JOIN #DOC D
        ON D.BATCH_NO = T.BATCH_NO
    GROUP BY
        D.BATCH_NO,
        D.DOC_NO
    ORDER BY
        D.BATCH_NO;

    ------------------------------------------------------------
    -- 10. 显示调拨明细
    ------------------------------------------------------------
    SELECT
        D.DOC_NO AS 单号,
        RIGHT
        (
            '0000' + CAST(T.LINE_NO AS VARCHAR(4)),
            4
        ) AS 序号,

        T.MC001 AS 品号,
        T.MB002 AS 品名,
        T.MB003 AS 规格,
        T.MC002 AS 转出仓,
        '001' AS 转入仓,

        T.MC007 AS 库存数量,
        T.MC008 AS 库存金额,
        T.UNIT_COST AS 单位成本
    FROM #TRANSFER T
    INNER JOIN #DOC D
        ON D.BATCH_NO = T.BATCH_NO
    ORDER BY
        T.BATCH_NO,
        T.LINE_NO;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
