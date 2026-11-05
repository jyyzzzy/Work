-- SDRD / 鼎捷易飞ERP / CMSMQ：新增小批量订单与试产订单
-- 模板：2205=小批量订单；2200=试产订单
-- 末位 5=小批量、0=试产；其他参数复制同类型模板。
-- UDF06 保持该业务单位现有单别的归属口径。
-- MQ034 最大长度20（源系统C 20.0）；22I5采用“小批量单(AR智能眼镜)”以避免超长。
-- 排除：LED照明、磁炉整机、原事业三部、安徽瑞德；浙江瑞德编码冲突不新增。
-- 本次仅新增：事业二三部、新能源部、锂电储能、AR智能眼镜（共8个单别）。
-- 可重复执行：跳过已存在的单别，不覆盖已有定义。

USE [SDRD];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Map TABLE (
    TemplateType VARCHAR(4) NOT NULL,
    TargetType VARCHAR(4) NOT NULL PRIMARY KEY,
    FullDescription NVARCHAR(20) NOT NULL,
    ReferenceType VARCHAR(4) NOT NULL
);

INSERT INTO @Map (TemplateType, TargetType, FullDescription, ReferenceType)
VALUES
    ('2205', '2215', N'小批量订单(二三部)', '2211'),
    ('2200', '2210', N'试产订单(二三部)', '2211'),
    ('2205', '2265', N'小批量订单(新能源部)', '2261'),
    ('2200', '2260', N'试产订单(新能源部)', '2261'),
    ('2205', '22L5', N'小批量订单(锂电)', '22L1'),
    ('2200', '22L0', N'试产订单(锂电)', '22L1'),
    ('2205', '22I5', N'小批量单(AR智能眼镜)', '22I1'),
    ('2200', '22I0', N'试产订单(AR智能眼镜)', '22I1');

-- 校验模板及业务单位参考单别，避免少插或写错归属
IF EXISTS (
    SELECT 1 FROM @Map AS M
    WHERE NOT EXISTS (SELECT 1 FROM dbo.CMSMQ AS T WHERE T.MQ001 = M.TemplateType)
       OR NOT EXISTS (SELECT 1 FROM dbo.CMSMQ AS R WHERE R.MQ001 = M.ReferenceType)
)
BEGIN
    RAISERROR(N'模板单别或业务单位参考单别不存在，已取消插入。', 16, 1);
    RETURN;
END;

BEGIN TRY
    BEGIN TRAN;

    INSERT INTO dbo.CMSMQ (
        [COMPANY],
        [CREATOR],
        [USR_GROUP],
        [CREATE_DATE],
        [MODIFIER],
        [MODI_DATE],
        [FLAG],
        [MQ001],
        [MQ002],
        [MQ003],
        [MQ004],
        [MQ005],
        [MQ006],
        [MQ007],
        [MQ008],
        [MQ009],
        [MQ010],
        [MQ011],
        [MQ012],
        [MQ013],
        [MQ014],
        [MQ015],
        [MQ016],
        [MQ017],
        [MQ018],
        [MQ019],
        [MQ020],
        [MQ021],
        [MQ022],
        [MQ023],
        [MQ024],
        [MQ025],
        [MQ026],
        [MQ027],
        [MQ028],
        [MQ029],
        [MQ030],
        [MQ031],
        [MQ032],
        [MQ033],
        [MQ034],
        [MQ035],
        [MQ036],
        [MQ037],
        [MQ038],
        [MQ039],
        [MQ040],
        [MQ041],
        [MQ042],
        [MQ043],
        [MQ044],
        [MQ045],
        [MQ046],
        [MQ047],
        [MQ048],
        [MQ049],
        [MQ050],
        [MQ051],
        [MQ052],
        [MQ053],
        [MQ054],
        [MQ055],
        [MQ056],
        [MQ057],
        [MQ058],
        [MQ059],
        [MQ060],
        [MQ061],
        [MQ062],
        [MQ063],
        [UDF01],
        [UDF02],
        [UDF03],
        [UDF04],
        [UDF05],
        [UDF06],
        [UDF51],
        [UDF52],
        [UDF53],
        [UDF54],
        [UDF55],
        [UDF56]
    )
    SELECT
        S.[COMPANY] AS [COMPANY],
        S.[CREATOR] AS [CREATOR],
        S.[USR_GROUP] AS [USR_GROUP],
        S.[CREATE_DATE] AS [CREATE_DATE],
        S.[MODIFIER] AS [MODIFIER],
        S.[MODI_DATE] AS [MODI_DATE],
        S.[FLAG] AS [FLAG],
        M.TargetType AS [MQ001],
        S.[MQ002] AS [MQ002],
        S.[MQ003] AS [MQ003],
        S.[MQ004] AS [MQ004],
        S.[MQ005] AS [MQ005],
        S.[MQ006] AS [MQ006],
        S.[MQ007] AS [MQ007],
        S.[MQ008] AS [MQ008],
        S.[MQ009] AS [MQ009],
        S.[MQ010] AS [MQ010],
        S.[MQ011] AS [MQ011],
        S.[MQ012] AS [MQ012],
        S.[MQ013] AS [MQ013],
        S.[MQ014] AS [MQ014],
        S.[MQ015] AS [MQ015],
        S.[MQ016] AS [MQ016],
        S.[MQ017] AS [MQ017],
        S.[MQ018] AS [MQ018],
        S.[MQ019] AS [MQ019],
        S.[MQ020] AS [MQ020],
        S.[MQ021] AS [MQ021],
        S.[MQ022] AS [MQ022],
        S.[MQ023] AS [MQ023],
        S.[MQ024] AS [MQ024],
        S.[MQ025] AS [MQ025],
        S.[MQ026] AS [MQ026],
        S.[MQ027] AS [MQ027],
        S.[MQ028] AS [MQ028],
        S.[MQ029] AS [MQ029],
        S.[MQ030] AS [MQ030],
        S.[MQ031] AS [MQ031],
        S.[MQ032] AS [MQ032],
        S.[MQ033] AS [MQ033],
        M.FullDescription AS [MQ034],
        S.[MQ035] AS [MQ035],
        S.[MQ036] AS [MQ036],
        S.[MQ037] AS [MQ037],
        S.[MQ038] AS [MQ038],
        S.[MQ039] AS [MQ039],
        S.[MQ040] AS [MQ040],
        S.[MQ041] AS [MQ041],
        S.[MQ042] AS [MQ042],
        S.[MQ043] AS [MQ043],
        S.[MQ044] AS [MQ044],
        S.[MQ045] AS [MQ045],
        S.[MQ046] AS [MQ046],
        S.[MQ047] AS [MQ047],
        S.[MQ048] AS [MQ048],
        S.[MQ049] AS [MQ049],
        S.[MQ050] AS [MQ050],
        S.[MQ051] AS [MQ051],
        S.[MQ052] AS [MQ052],
        S.[MQ053] AS [MQ053],
        S.[MQ054] AS [MQ054],
        S.[MQ055] AS [MQ055],
        S.[MQ056] AS [MQ056],
        S.[MQ057] AS [MQ057],
        S.[MQ058] AS [MQ058],
        S.[MQ059] AS [MQ059],
        S.[MQ060] AS [MQ060],
        S.[MQ061] AS [MQ061],
        S.[MQ062] AS [MQ062],
        S.[MQ063] AS [MQ063],
        S.[UDF01] AS [UDF01],
        S.[UDF02] AS [UDF02],
        S.[UDF03] AS [UDF03],
        S.[UDF04] AS [UDF04],
        S.[UDF05] AS [UDF05],
        R.UDF06 AS [UDF06],
        S.[UDF51] AS [UDF51],
        S.[UDF52] AS [UDF52],
        S.[UDF53] AS [UDF53],
        S.[UDF54] AS [UDF54],
        S.[UDF55] AS [UDF55],
        S.[UDF56] AS [UDF56]
    FROM dbo.CMSMQ AS S WITH (NOLOCK)
    INNER JOIN @Map AS M ON S.MQ001 = M.TemplateType
    INNER JOIN dbo.CMSMQ AS R WITH (NOLOCK)
        ON R.MQ001 = M.ReferenceType AND R.COMPANY = S.COMPANY
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.CMSMQ AS E WITH (UPDLOCK, HOLDLOCK)
        WHERE E.MQ001 = M.TargetType AND E.COMPANY = S.COMPANY
    );

    DECLARE @Inserted INT;
    SET @Inserted = @@ROWCOUNT;

    COMMIT TRAN;

    SELECT @Inserted AS 本次新增数量;
    SELECT C.MQ001 AS 单别, C.MQ002 AS 单据名称,
           C.MQ034 AS 单据全称, C.UDF06 AS 归属,
           C.MQ032 AS 单据格式
    FROM dbo.CMSMQ AS C
    INNER JOIN @Map AS M ON C.MQ001 = M.TargetType
    ORDER BY C.MQ001;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    DECLARE @ErrorMessage NVARCHAR(4000);
    SET @ErrorMessage = ERROR_MESSAGE();
    RAISERROR(N'%s', 16, 1, @ErrorMessage);
END CATCH;
