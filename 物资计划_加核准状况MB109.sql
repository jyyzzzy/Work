USE SDRD;
SET NOCOUNT ON;

DECLARE @M0 DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @BeginDate CHAR(8) = CONVERT(CHAR(8), DATEADD(MONTH, -12, @M0), 112);
DECLARE @M0Char CHAR(8) = CONVERT(CHAR(8), @M0, 112);
DECLARE @OrderBeginDate CHAR(8) = CONVERT(CHAR(8), DATEADD(MONTH, -2, @M0), 112);
DECLARE @TodayChar CHAR(8) = CONVERT(CHAR(8), GETDATE(), 112);

IF OBJECT_ID('tempdb..#ITEM') IS NOT NULL DROP TABLE #ITEM;
IF OBJECT_ID('tempdb..#STOCK') IS NOT NULL DROP TABLE #STOCK;
IF OBJECT_ID('tempdb..#ONWAY') IS NOT NULL DROP TABLE #ONWAY;
IF OBJECT_ID('tempdb..#ALLOC') IS NOT NULL DROP TABLE #ALLOC;
IF OBJECT_ID('tempdb..#ISSUE_DETAIL') IS NOT NULL DROP TABLE #ISSUE_DETAIL;
IF OBJECT_ID('tempdb..#ISSUE') IS NOT NULL DROP TABLE #ISSUE;
IF OBJECT_ID('tempdb..#SALE_INFO') IS NOT NULL DROP TABLE #SALE_INFO;
IF OBJECT_ID('tempdb..#PRODUCT_INFO') IS NOT NULL DROP TABLE #PRODUCT_INFO;
IF OBJECT_ID('tempdb..#SAMPLE_SPEC') IS NOT NULL DROP TABLE #SAMPLE_SPEC;

------------------------------------------------------------
-- 1. 物料
------------------------------------------------------------
SELECT *
INTO #ITEM
FROM (
    SELECT N'顺德瑞德' 账套,RTRIM(MB001) 品号,RTRIM(MB002) 品名,RTRIM(MB003) 规格,RTRIM(MB004) 单位,CONVERT(NVARCHAR(100),UDF52) 采购参考周期,RTRIM(MB109) 核准状况
    FROM SDRD..INVMB WITH(NOLOCK)
    WHERE LEFT(MB001,1) IN ('3','5','6','7')
      AND EXISTS (
          SELECT 1
          FROM (VALUES
              (N'集成电路'),(N'光耦'),(N'可变流半导体'),(N'场效应管'),(N'集成模块'),
              (N'可控硅'),(N'WIFI模块'),(N'温湿度传感器'),(N'整流桥'),(N'整流二极管'),
              (N'阻容模块'),(N'快恢复二极管'),(N'三极管'),(N'红外接收头'),
              (N'人体感应接收头'),(N'霍尔器件'),(N'红外发射二极管')
          ) K(关键词)
          WHERE RTRIM(MB002) COLLATE Chinese_PRC_CI_AS LIKE N'%' + K.关键词 + N'%' COLLATE Chinese_PRC_CI_AS
      )
    UNION ALL
    SELECT N'浙江瑞德',RTRIM(MB001),RTRIM(MB002),RTRIM(MB003),RTRIM(MB004),CONVERT(NVARCHAR(100),UDF52),RTRIM(MB109)
    FROM ZJRD..INVMB WITH(NOLOCK)
    WHERE LEFT(MB001,1) IN ('3','5','6','7')
      AND EXISTS (
          SELECT 1
          FROM (VALUES
              (N'集成电路'),(N'光耦'),(N'可变流半导体'),(N'场效应管'),(N'集成模块'),
              (N'可控硅'),(N'WIFI模块'),(N'温湿度传感器'),(N'整流桥'),(N'整流二极管'),
              (N'阻容模块'),(N'快恢复二极管'),(N'三极管'),(N'红外接收头'),
              (N'人体感应接收头'),(N'霍尔器件'),(N'红外发射二极管')
          ) K(关键词)
          WHERE RTRIM(MB002) COLLATE Chinese_PRC_CI_AS LIKE N'%' + K.关键词 + N'%' COLLATE Chinese_PRC_CI_AS
      )
    UNION ALL
    SELECT N'安徽瑞德',RTRIM(MB001),RTRIM(MB002),RTRIM(MB003),RTRIM(MB004),CONVERT(NVARCHAR(100),UDF52),RTRIM(MB109)
    FROM AHRD..INVMB WITH(NOLOCK)
    WHERE LEFT(MB001,1) IN ('3','5','6','7')
      AND EXISTS (
          SELECT 1
          FROM (VALUES
              (N'集成电路'),(N'光耦'),(N'可变流半导体'),(N'场效应管'),(N'集成模块'),
              (N'可控硅'),(N'WIFI模块'),(N'温湿度传感器'),(N'整流桥'),(N'整流二极管'),
              (N'阻容模块'),(N'快恢复二极管'),(N'三极管'),(N'红外接收头'),
              (N'人体感应接收头'),(N'霍尔器件'),(N'红外发射二极管')
          ) K(关键词)
          WHERE RTRIM(MB002) COLLATE Chinese_PRC_CI_AS LIKE N'%' + K.关键词 + N'%' COLLATE Chinese_PRC_CI_AS
      )
    UNION ALL
    SELECT N'越南瑞德',RTRIM(MB001),RTRIM(MB002),RTRIM(MB003),RTRIM(MB004),CONVERT(NVARCHAR(100),UDF52),RTRIM(MB109)
    FROM YNRD..INVMB WITH(NOLOCK)
    WHERE LEFT(MB001,1) IN ('3','5','6','7')
      AND EXISTS (
          SELECT 1
          FROM (VALUES
              (N'集成电路'),(N'光耦'),(N'可变流半导体'),(N'场效应管'),(N'集成模块'),
              (N'可控硅'),(N'WIFI模块'),(N'温湿度传感器'),(N'整流桥'),(N'整流二极管'),
              (N'阻容模块'),(N'快恢复二极管'),(N'三极管'),(N'红外接收头'),
              (N'人体感应接收头'),(N'霍尔器件'),(N'红外发射二极管')
          ) K(关键词)
          WHERE RTRIM(MB002) COLLATE Chinese_PRC_CI_AS LIKE N'%' + K.关键词 + N'%' COLLATE Chinese_PRC_CI_AS
      )
) X;

CREATE INDEX IX_ITEM ON #ITEM(账套,品号);

------------------------------------------------------------
-- 2. 库存
------------------------------------------------------------
SELECT *
INTO #STOCK
FROM (
    SELECT N'顺德瑞德' 账套,RTRIM(MC.MC001) 品号,SUM(ISNULL(MC.MC007,0)) 库存数量 FROM SDRD..INVMC MC WITH(NOLOCK) JOIN SDRD..CMSMC WH WITH(NOLOCK) ON WH.MC001=MC.MC002 JOIN #ITEM I ON I.账套=N'顺德瑞德' AND I.品号=RTRIM(MC.MC001) WHERE WH.MC005='Y' GROUP BY RTRIM(MC.MC001)
    UNION ALL
    SELECT N'浙江瑞德',RTRIM(MC.MC001),SUM(ISNULL(MC.MC007,0)) FROM ZJRD..INVMC MC WITH(NOLOCK) JOIN ZJRD..CMSMC WH WITH(NOLOCK) ON WH.MC001=MC.MC002 JOIN #ITEM I ON I.账套=N'浙江瑞德' AND I.品号=RTRIM(MC.MC001) WHERE WH.MC005='Y' GROUP BY RTRIM(MC.MC001)
    UNION ALL
    SELECT N'安徽瑞德',RTRIM(MC.MC001),SUM(ISNULL(MC.MC007,0)) FROM AHRD..INVMC MC WITH(NOLOCK) JOIN AHRD..CMSMC WH WITH(NOLOCK) ON WH.MC001=MC.MC002 JOIN #ITEM I ON I.账套=N'安徽瑞德' AND I.品号=RTRIM(MC.MC001) WHERE WH.MC005='Y' GROUP BY RTRIM(MC.MC001)
    UNION ALL
    SELECT N'越南瑞德',RTRIM(MC.MC001),SUM(ISNULL(MC.MC007,0)) FROM YNRD..INVMC MC WITH(NOLOCK) JOIN YNRD..CMSMC WH WITH(NOLOCK) ON WH.MC001=MC.MC002 JOIN #ITEM I ON I.账套=N'越南瑞德' AND I.品号=RTRIM(MC.MC001) WHERE WH.MC005='Y' GROUP BY RTRIM(MC.MC001)
) X;

CREATE INDEX IX_STOCK ON #STOCK(账套,品号);

------------------------------------------------------------
-- 3. 在途
------------------------------------------------------------
SELECT *
INTO #ONWAY
FROM (
    SELECT N'顺德瑞德' 账套,RTRIM(TD004) 品号,SUM(ISNULL(TD008,0)-ISNULL(TD015,0)) 在途数量 FROM SDRD..PURTD WITH(NOLOCK) JOIN #ITEM I ON I.账套=N'顺德瑞德' AND I.品号=RTRIM(TD004) WHERE TD016='N' AND TD018='Y' GROUP BY RTRIM(TD004)
    UNION ALL
    SELECT N'浙江瑞德',RTRIM(TD004),SUM(ISNULL(TD008,0)-ISNULL(TD015,0)) FROM ZJRD..PURTD WITH(NOLOCK) JOIN #ITEM I ON I.账套=N'浙江瑞德' AND I.品号=RTRIM(TD004) WHERE TD016='N' AND TD018='Y' GROUP BY RTRIM(TD004)
    UNION ALL
    SELECT N'安徽瑞德',RTRIM(TD004),SUM(ISNULL(TD008,0)-ISNULL(TD015,0)) FROM AHRD..PURTD WITH(NOLOCK) JOIN #ITEM I ON I.账套=N'安徽瑞德' AND I.品号=RTRIM(TD004) WHERE TD016='N' AND TD018='Y' GROUP BY RTRIM(TD004)
    UNION ALL
    SELECT N'越南瑞德',RTRIM(TD004),SUM(ISNULL(TD008,0)-ISNULL(TD015,0)) FROM YNRD..PURTD WITH(NOLOCK) JOIN #ITEM I ON I.账套=N'越南瑞德' AND I.品号=RTRIM(TD004) WHERE TD016='N' AND TD018='Y' GROUP BY RTRIM(TD004)
) X
WHERE 在途数量 > 0;

CREATE INDEX IX_ONWAY ON #ONWAY(账套,品号);

------------------------------------------------------------
-- 4. 分配
------------------------------------------------------------
SELECT *
INTO #ALLOC
FROM (
    SELECT N'顺德瑞德' 账套,RTRIM(TB003) 品号,SUM(CASE WHEN ISNULL(TB004,0)-ISNULL(TB005,0)>0 THEN ISNULL(TB004,0)-ISNULL(TB005,0) ELSE 0 END) 分配数量 FROM SDRD..MOCTB TB WITH(NOLOCK) JOIN SDRD..MOCTA TA WITH(NOLOCK) ON TA001=TB001 AND TA002=TB002 JOIN #ITEM I ON I.账套=N'顺德瑞德' AND I.品号=RTRIM(TB003) WHERE TA013='Y' AND TA011 IN ('1','2','3') GROUP BY RTRIM(TB003)
    UNION ALL
    SELECT N'浙江瑞德',RTRIM(TB003),SUM(CASE WHEN ISNULL(TB004,0)-ISNULL(TB005,0)>0 THEN ISNULL(TB004,0)-ISNULL(TB005,0) ELSE 0 END) FROM ZJRD..MOCTB TB WITH(NOLOCK) JOIN ZJRD..MOCTA TA WITH(NOLOCK) ON TA001=TB001 AND TA002=TB002 JOIN #ITEM I ON I.账套=N'浙江瑞德' AND I.品号=RTRIM(TB003) WHERE TA013='Y' AND TA011 IN ('1','2','3') GROUP BY RTRIM(TB003)
    UNION ALL
    SELECT N'安徽瑞德',RTRIM(TB003),SUM(CASE WHEN ISNULL(TB004,0)-ISNULL(TB005,0)>0 THEN ISNULL(TB004,0)-ISNULL(TB005,0) ELSE 0 END) FROM AHRD..MOCTB TB WITH(NOLOCK) JOIN AHRD..MOCTA TA WITH(NOLOCK) ON TA001=TB001 AND TA002=TB002 JOIN #ITEM I ON I.账套=N'安徽瑞德' AND I.品号=RTRIM(TB003) WHERE TA013='Y' AND TA011 IN ('1','2','3') GROUP BY RTRIM(TB003)
    UNION ALL
    SELECT N'越南瑞德',RTRIM(TB003),SUM(CASE WHEN ISNULL(TB004,0)-ISNULL(TB005,0)>0 THEN ISNULL(TB004,0)-ISNULL(TB005,0) ELSE 0 END) FROM YNRD..MOCTB TB WITH(NOLOCK) JOIN YNRD..MOCTA TA WITH(NOLOCK) ON TA001=TB001 AND TA002=TB002 JOIN #ITEM I ON I.账套=N'越南瑞德' AND I.品号=RTRIM(TB003) WHERE TA013='Y' AND TA011 IN ('1','2','3') GROUP BY RTRIM(TB003)
) X;

CREATE INDEX IX_ALLOC ON #ALLOC(账套,品号);

------------------------------------------------------------
-- 5. 领用明细：过去12个月所有订单
--    使用部门 = 工单工作中心 TA021 -> CMSMD.MD001 -> CMSMD.MD011 截取 '-' 前
--    销售部门 = 销售订单 TC005 -> CMSME.ME001 -> CMSME.ME002
--    业务员 = 客户信息 COPMA.MA016 -> CMSMV.MV001 -> CMSMV.MV002
------------------------------------------------------------
SELECT *
INTO #ISSUE_DETAIL
FROM (
    SELECT N'顺德瑞德' 账套,
           RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT 品号,
           ISNULL(RTRIM(TC.TC004),'') COLLATE DATABASE_DEFAULT 客户编号,
           ISNULL(RTRIM(CUS.MA002),ISNULL(RTRIM(TC.TC004),'')) COLLATE DATABASE_DEFAULT 客户简称,
           ISNULL(RTRIM(CUS.MA003),'') COLLATE DATABASE_DEFAULT 客户全称,
           CASE 
                WHEN CHARINDEX('-', ISNULL(RTRIM(WC.MD011), '')) > 0 
                    THEN LEFT(RTRIM(WC.MD011), CHARINDEX('-', RTRIM(WC.MD011)) - 1)
                ELSE ISNULL(RTRIM(WC.MD011), '')
           END COLLATE DATABASE_DEFAULT 使用部门,
           ISNULL(RTRIM(DEPT.ME002),ISNULL(RTRIM(TC.TC005),'')) COLLATE DATABASE_DEFAULT 销售部门,
           ISNULL(RTRIM(EMP.MV002),ISNULL(RTRIM(CUS.MA016),'')) COLLATE DATABASE_DEFAULT 业务员,
           RTRIM(ISNULL(NULLIF(RTRIM(TD.TD004),''),ISNULL(RTRIM(TA.TA006),''))) COLLATE DATABASE_DEFAULT 成品品号,
           ISNULL(RTRIM(PROD.MB002),'') COLLATE DATABASE_DEFAULT 成品品名,
           ISNULL(RTRIM(PROD.MB003),'') COLLATE DATABASE_DEFAULT 成品规格,
           TC.TC003 订单日期,
           ISNULL(RTRIM(MQ.MQ002),'') COLLATE DATABASE_DEFAULT 订单单别名称,
           LA.LA004 领用日期,
           CONVERT(DECIMAL(38,10),-1*ISNULL(LA.LA011,0)*ISNULL(LA.LA005,0)) 使用量
    FROM SDRD..INVLA LA WITH(NOLOCK)
    JOIN #ITEM I ON I.账套=N'顺德瑞德' AND I.品号=RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT
    LEFT JOIN SDRD..MOCTE TE WITH(NOLOCK) ON TE.TE001=LA.LA006 AND TE.TE002=LA.LA007 AND TE.TE003=LA.LA008
    LEFT JOIN SDRD..MOCTA TA WITH(NOLOCK) ON TA.TA001=TE.TE011 AND TA.TA002=TE.TE012
    LEFT JOIN SDRD..COPTD TD WITH(NOLOCK) ON TD.TD001=TA.TA026 AND TD.TD002=TA.TA027 AND TD.TD003=TA.TA028
    LEFT JOIN SDRD..COPTC TC WITH(NOLOCK) ON TC.TC001=TD.TD001 AND TC.TC002=TD.TD002
    LEFT JOIN SDRD..CMSMQ MQ WITH(NOLOCK) ON MQ.MQ001=TC.TC001
    LEFT JOIN SDRD..COPMA CUS WITH(NOLOCK) ON CUS.MA001=TC.TC004
    LEFT JOIN SDRD..CMSMD WC WITH(NOLOCK) ON WC.MD001=TA.TA021
    LEFT JOIN SDRD..CMSME DEPT WITH(NOLOCK) ON DEPT.ME001=TC.TC005
    LEFT JOIN SDRD..CMSMV EMP WITH(NOLOCK) ON EMP.MV001=CUS.MA016
    LEFT JOIN SDRD..INVMB PROD WITH(NOLOCK) ON RTRIM(PROD.MB001)=RTRIM(ISNULL(NULLIF(RTRIM(TD.TD004),''),ISNULL(RTRIM(TA.TA006),'')))
    WHERE LA.LA004>=@BeginDate 
      AND LA.LA004<@M0Char 
      AND LEFT(LA.LA006,2) IN ('54','56') 
      AND TC.TC003>=@BeginDate
      AND TC.TC003<=@TodayChar

    UNION ALL
    SELECT N'浙江瑞德' 账套,
           RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT 品号,
           ISNULL(RTRIM(TC.TC004),'') COLLATE DATABASE_DEFAULT 客户编号,
           ISNULL(RTRIM(CUS.MA002),ISNULL(RTRIM(TC.TC004),'')) COLLATE DATABASE_DEFAULT 客户简称,
           ISNULL(RTRIM(CUS.MA003),'') COLLATE DATABASE_DEFAULT 客户全称,
           CASE 
                WHEN CHARINDEX('-', ISNULL(RTRIM(WC.MD011), '')) > 0 
                    THEN LEFT(RTRIM(WC.MD011), CHARINDEX('-', RTRIM(WC.MD011)) - 1)
                ELSE ISNULL(RTRIM(WC.MD011), '')
           END COLLATE DATABASE_DEFAULT 使用部门,
           ISNULL(RTRIM(DEPT.ME002),ISNULL(RTRIM(TC.TC005),'')) COLLATE DATABASE_DEFAULT 销售部门,
           ISNULL(RTRIM(EMP.MV002),ISNULL(RTRIM(CUS.MA016),'')) COLLATE DATABASE_DEFAULT 业务员,
           RTRIM(ISNULL(NULLIF(RTRIM(TD.TD004),''),ISNULL(RTRIM(TA.TA006),''))) COLLATE DATABASE_DEFAULT 成品品号,
           ISNULL(RTRIM(PROD.MB002),'') COLLATE DATABASE_DEFAULT 成品品名,
           ISNULL(RTRIM(PROD.MB003),'') COLLATE DATABASE_DEFAULT 成品规格,
           TC.TC003 订单日期,
           ISNULL(RTRIM(MQ.MQ002),'') COLLATE DATABASE_DEFAULT 订单单别名称,
           LA.LA004 领用日期,
           CONVERT(DECIMAL(38,10),-1*ISNULL(LA.LA011,0)*ISNULL(LA.LA005,0)) 使用量
    FROM ZJRD..INVLA LA WITH(NOLOCK)
    JOIN #ITEM I ON I.账套=N'浙江瑞德' AND I.品号=RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT
    LEFT JOIN ZJRD..MOCTE TE WITH(NOLOCK) ON TE.TE001=LA.LA006 AND TE.TE002=LA.LA007 AND TE.TE003=LA.LA008
    LEFT JOIN ZJRD..MOCTA TA WITH(NOLOCK) ON TA.TA001=TE.TE011 AND TA.TA002=TE.TE012
    LEFT JOIN ZJRD..COPTD TD WITH(NOLOCK) ON TD.TD001=TA.TA026 AND TD.TD002=TA.TA027 AND TD.TD003=TA.TA028
    LEFT JOIN ZJRD..COPTC TC WITH(NOLOCK) ON TC.TC001=TD.TD001 AND TC.TC002=TD.TD002
    LEFT JOIN ZJRD..CMSMQ MQ WITH(NOLOCK) ON MQ.MQ001=TC.TC001
    LEFT JOIN ZJRD..COPMA CUS WITH(NOLOCK) ON CUS.MA001=TC.TC004
    LEFT JOIN ZJRD..CMSMD WC WITH(NOLOCK) ON WC.MD001=TA.TA021
    LEFT JOIN ZJRD..CMSME DEPT WITH(NOLOCK) ON DEPT.ME001=TC.TC005
    LEFT JOIN ZJRD..CMSMV EMP WITH(NOLOCK) ON EMP.MV001=CUS.MA016
    LEFT JOIN ZJRD..INVMB PROD WITH(NOLOCK) ON RTRIM(PROD.MB001)=RTRIM(ISNULL(NULLIF(RTRIM(TD.TD004),''),ISNULL(RTRIM(TA.TA006),'')))
    WHERE LA.LA004>=@BeginDate 
      AND LA.LA004<@M0Char 
      AND LEFT(LA.LA006,2) IN ('54','56') 
      AND TC.TC003>=@BeginDate
      AND TC.TC003<=@TodayChar

    UNION ALL
    SELECT N'安徽瑞德' 账套,
           RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT 品号,
           ISNULL(RTRIM(TC.TC004),'') COLLATE DATABASE_DEFAULT 客户编号,
           ISNULL(RTRIM(CUS.MA002),ISNULL(RTRIM(TC.TC004),'')) COLLATE DATABASE_DEFAULT 客户简称,
           ISNULL(RTRIM(CUS.MA003),'') COLLATE DATABASE_DEFAULT 客户全称,
           CASE 
                WHEN CHARINDEX('-', ISNULL(RTRIM(WC.MD011), '')) > 0 
                    THEN LEFT(RTRIM(WC.MD011), CHARINDEX('-', RTRIM(WC.MD011)) - 1)
                ELSE ISNULL(RTRIM(WC.MD011), '')
           END COLLATE DATABASE_DEFAULT 使用部门,
           ISNULL(RTRIM(DEPT.ME002),ISNULL(RTRIM(TC.TC005),'')) COLLATE DATABASE_DEFAULT 销售部门,
           ISNULL(RTRIM(EMP.MV002),ISNULL(RTRIM(CUS.MA016),'')) COLLATE DATABASE_DEFAULT 业务员,
           RTRIM(ISNULL(NULLIF(RTRIM(TD.TD004),''),ISNULL(RTRIM(TA.TA006),''))) COLLATE DATABASE_DEFAULT 成品品号,
           ISNULL(RTRIM(PROD.MB002),'') COLLATE DATABASE_DEFAULT 成品品名,
           ISNULL(RTRIM(PROD.MB003),'') COLLATE DATABASE_DEFAULT 成品规格,
           TC.TC003 订单日期,
           ISNULL(RTRIM(MQ.MQ002),'') COLLATE DATABASE_DEFAULT 订单单别名称,
           LA.LA004 领用日期,
           CONVERT(DECIMAL(38,10),-1*ISNULL(LA.LA011,0)*ISNULL(LA.LA005,0)) 使用量
    FROM AHRD..INVLA LA WITH(NOLOCK)
    JOIN #ITEM I ON I.账套=N'安徽瑞德' AND I.品号=RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT
    LEFT JOIN AHRD..MOCTE TE WITH(NOLOCK) ON TE.TE001=LA.LA006 AND TE.TE002=LA.LA007 AND TE.TE003=LA.LA008
    LEFT JOIN AHRD..MOCTA TA WITH(NOLOCK) ON TA.TA001=TE.TE011 AND TA.TA002=TE.TE012
    LEFT JOIN AHRD..COPTD TD WITH(NOLOCK) ON TD.TD001=TA.TA026 AND TD.TD002=TA.TA027 AND TD.TD003=TA.TA028
    LEFT JOIN AHRD..COPTC TC WITH(NOLOCK) ON TC.TC001=TD.TD001 AND TC.TC002=TD.TD002
    LEFT JOIN AHRD..CMSMQ MQ WITH(NOLOCK) ON MQ.MQ001=TC.TC001
    LEFT JOIN AHRD..COPMA CUS WITH(NOLOCK) ON CUS.MA001=TC.TC004
    LEFT JOIN AHRD..CMSMD WC WITH(NOLOCK) ON WC.MD001=TA.TA021
    LEFT JOIN AHRD..CMSME DEPT WITH(NOLOCK) ON DEPT.ME001=TC.TC005
    LEFT JOIN AHRD..CMSMV EMP WITH(NOLOCK) ON EMP.MV001=CUS.MA016
    LEFT JOIN AHRD..INVMB PROD WITH(NOLOCK) ON RTRIM(PROD.MB001)=RTRIM(ISNULL(NULLIF(RTRIM(TD.TD004),''),ISNULL(RTRIM(TA.TA006),'')))
    WHERE LA.LA004>=@BeginDate 
      AND LA.LA004<@M0Char 
      AND LEFT(LA.LA006,2) IN ('54','56') 
      AND TC.TC003>=@BeginDate
      AND TC.TC003<=@TodayChar

    UNION ALL
    SELECT N'越南瑞德' 账套,
           RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT 品号,
           ISNULL(RTRIM(TC.TC004),'') COLLATE DATABASE_DEFAULT 客户编号,
           ISNULL(RTRIM(CUS.MA002),ISNULL(RTRIM(TC.TC004),'')) COLLATE DATABASE_DEFAULT 客户简称,
           ISNULL(RTRIM(CUS.MA003),'') COLLATE DATABASE_DEFAULT 客户全称,
           CASE 
                WHEN CHARINDEX('-', ISNULL(RTRIM(WC.MD011), '')) > 0 
                    THEN LEFT(RTRIM(WC.MD011), CHARINDEX('-', RTRIM(WC.MD011)) - 1)
                ELSE ISNULL(RTRIM(WC.MD011), '')
           END COLLATE DATABASE_DEFAULT 使用部门,
           ISNULL(RTRIM(DEPT.ME002),ISNULL(RTRIM(TC.TC005),'')) COLLATE DATABASE_DEFAULT 销售部门,
           ISNULL(RTRIM(EMP.MV002),ISNULL(RTRIM(CUS.MA016),'')) COLLATE DATABASE_DEFAULT 业务员,
           RTRIM(ISNULL(NULLIF(RTRIM(TD.TD004),''),ISNULL(RTRIM(TA.TA006),''))) COLLATE DATABASE_DEFAULT 成品品号,
           ISNULL(RTRIM(PROD.MB002),'') COLLATE DATABASE_DEFAULT 成品品名,
           ISNULL(RTRIM(PROD.MB003),'') COLLATE DATABASE_DEFAULT 成品规格,
           TC.TC003 订单日期,
           ISNULL(RTRIM(MQ.MQ002),'') COLLATE DATABASE_DEFAULT 订单单别名称,
           LA.LA004 领用日期,
           CONVERT(DECIMAL(38,10),-1*ISNULL(LA.LA011,0)*ISNULL(LA.LA005,0)) 使用量
    FROM YNRD..INVLA LA WITH(NOLOCK)
    JOIN #ITEM I ON I.账套=N'越南瑞德' AND I.品号=RTRIM(LA.LA001) COLLATE DATABASE_DEFAULT
    LEFT JOIN YNRD..MOCTE TE WITH(NOLOCK) ON TE.TE001=LA.LA006 AND TE.TE002=LA.LA007 AND TE.TE003=LA.LA008
    LEFT JOIN YNRD..MOCTA TA WITH(NOLOCK) ON TA.TA001=TE.TE011 AND TA.TA002=TE.TE012
    LEFT JOIN YNRD..COPTD TD WITH(NOLOCK) ON TD.TD001=TA.TA026 AND TD.TD002=TA.TA027 AND TD.TD003=TA.TA028
    LEFT JOIN YNRD..COPTC TC WITH(NOLOCK) ON TC.TC001=TD.TD001 AND TC.TC002=TD.TD002
    LEFT JOIN YNRD..CMSMQ MQ WITH(NOLOCK) ON MQ.MQ001=TC.TC001
    LEFT JOIN YNRD..COPMA CUS WITH(NOLOCK) ON CUS.MA001=TC.TC004
    LEFT JOIN YNRD..CMSMD WC WITH(NOLOCK) ON WC.MD001=TA.TA021
    LEFT JOIN YNRD..CMSME DEPT WITH(NOLOCK) ON DEPT.ME001=TC.TC005
    LEFT JOIN YNRD..CMSMV EMP WITH(NOLOCK) ON EMP.MV001=CUS.MA016
    LEFT JOIN YNRD..INVMB PROD WITH(NOLOCK) ON RTRIM(PROD.MB001)=RTRIM(ISNULL(NULLIF(RTRIM(TD.TD004),''),ISNULL(RTRIM(TA.TA006),'')))
    WHERE LA.LA004>=@BeginDate 
      AND LA.LA004<@M0Char 
      AND LEFT(LA.LA006,2) IN ('54','56') 
      AND TC.TC003>=@BeginDate
      AND TC.TC003<=@TodayChar
) X;


------------------------------------------------------------
-- 5.1 使用部门标准化
--     其他 / 装配车间 / 自动化车间 统一归入浙江瑞德，然后参与后续汇总合并
------------------------------------------------------------
UPDATE #ISSUE_DETAIL
SET 使用部门 = N'浙江瑞德'
WHERE RTRIM(ISNULL(使用部门, N'')) IN (N'其他', N'装配车间', N'自动化车间');

CREATE INDEX IX_ISSUE_DETAIL ON #ISSUE_DETAIL(账套,品号,客户编号,使用部门,成品品号);

------------------------------------------------------------
-- 6. 使用量汇总：一个客户 + 一个使用部门一行
------------------------------------------------------------
SELECT
    账套,
    品号,
    客户编号,
    使用部门,
    MAX(客户简称) 客户简称,
    MAX(客户全称) 客户全称,

    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-1,@M0),112)  AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,0,@M0),112)   THEN 使用量 ELSE 0 END) 过去第1月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-2,@M0),112)  AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-1,@M0),112)  THEN 使用量 ELSE 0 END) 过去第2月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-3,@M0),112)  AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-2,@M0),112)  THEN 使用量 ELSE 0 END) 过去第3月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-4,@M0),112)  AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-3,@M0),112)  THEN 使用量 ELSE 0 END) 过去第4月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-5,@M0),112)  AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-4,@M0),112)  THEN 使用量 ELSE 0 END) 过去第5月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-6,@M0),112)  AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-5,@M0),112)  THEN 使用量 ELSE 0 END) 过去第6月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-7,@M0),112)  AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-6,@M0),112)  THEN 使用量 ELSE 0 END) 过去第7月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-8,@M0),112)  AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-7,@M0),112)  THEN 使用量 ELSE 0 END) 过去第8月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-9,@M0),112)  AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-8,@M0),112)  THEN 使用量 ELSE 0 END) 过去第9月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-10,@M0),112) AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-9,@M0),112)  THEN 使用量 ELSE 0 END) 过去第10月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-11,@M0),112) AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-10,@M0),112) THEN 使用量 ELSE 0 END) 过去第11月使用量,
    SUM(CASE WHEN 领用日期>=CONVERT(CHAR(8),DATEADD(MONTH,-12,@M0),112) AND 领用日期<CONVERT(CHAR(8),DATEADD(MONTH,-11,@M0),112) THEN 使用量 ELSE 0 END) 过去第12月使用量

INTO #ISSUE
FROM #ISSUE_DETAIL
GROUP BY
    账套,
    品号,
    客户编号,
    使用部门;

CREATE INDEX IX_ISSUE ON #ISSUE(账套,品号,客户编号,使用部门);

------------------------------------------------------------
-- 7. 销售部门、业务员合并：一个客户 + 一个使用部门一行
------------------------------------------------------------
SELECT
    C.账套,
    C.品号,
    C.客户编号,
    C.使用部门,

    STUFF((
        SELECT N'、' + X.销售部门
        FROM (
            SELECT DISTINCT D.销售部门
            FROM #ISSUE_DETAIL D
            WHERE D.账套 = C.账套
              AND D.品号 = C.品号
              AND D.客户编号 = C.客户编号
              AND D.使用部门 = C.使用部门
              AND ISNULL(D.销售部门,'') <> ''
        ) X
        ORDER BY X.销售部门
        FOR XML PATH(''), TYPE
    ).value('.','NVARCHAR(MAX)'),1,1,'') 销售部门,

    STUFF((
        SELECT N'、' + X.业务员
        FROM (
            SELECT DISTINCT D.业务员
            FROM #ISSUE_DETAIL D
            WHERE D.账套 = C.账套
              AND D.品号 = C.品号
              AND D.客户编号 = C.客户编号
              AND D.使用部门 = C.使用部门
              AND ISNULL(D.业务员,'') <> ''
        ) X
        ORDER BY X.业务员
        FOR XML PATH(''), TYPE
    ).value('.','NVARCHAR(MAX)'),1,1,'') 业务员

INTO #SALE_INFO
FROM (
    SELECT DISTINCT
        账套,
        品号,
        客户编号,
        使用部门
    FROM #ISSUE_DETAIL
) C;

CREATE INDEX IX_SALE_INFO ON #SALE_INFO(账套,品号,客户编号,使用部门);

------------------------------------------------------------
-- 8. 成品品名、规格合并：一个客户 + 一个使用部门一行
--    品名、规格来自过去一年所有订单；重复值合并
------------------------------------------------------------
SELECT
    C.账套,
    C.品号,
    C.客户编号,
    C.使用部门,

    STUFF((
        SELECT N'、' + X.成品品名
        FROM (
            SELECT DISTINCT D.成品品名
            FROM #ISSUE_DETAIL D
            WHERE D.账套 = C.账套
              AND D.品号 = C.品号
              AND D.客户编号 = C.客户编号
              AND D.使用部门 = C.使用部门
              AND ISNULL(RTRIM(D.成品品名), '') <> ''
        ) X
        ORDER BY X.成品品名
        FOR XML PATH(''), TYPE
    ).value('.','NVARCHAR(MAX)'), 1, 1, '') AS 成品品名,

    STUFF((
        SELECT N'、' + X.成品规格
        FROM (
            SELECT DISTINCT D.成品规格
            FROM #ISSUE_DETAIL D
            WHERE D.账套 = C.账套
              AND D.品号 = C.品号
              AND D.客户编号 = C.客户编号
              AND D.使用部门 = C.使用部门
              AND ISNULL(RTRIM(D.成品规格), '') <> ''
        ) X
        ORDER BY X.成品规格
        FOR XML PATH(''), TYPE
    ).value('.','NVARCHAR(MAX)'), 1, 1, '') AS 成品规格

INTO #PRODUCT_INFO
FROM (SELECT DISTINCT 账套,品号,客户编号,使用部门 FROM #ISSUE_DETAIL) C;

CREATE INDEX IX_PRODUCT_INFO ON #PRODUCT_INFO(账套,品号,客户编号,使用部门);

------------------------------------------------------------
-- 8.1 过去2个月样板规格合并
--     样板型号列改为样板规格；同规格合并
------------------------------------------------------------
SELECT
    C.账套,
    C.品号,
    C.客户编号,
    C.使用部门,

    STUFF((
        SELECT N'、' + X.成品规格
        FROM (
            SELECT DISTINCT D.成品规格
            FROM #ISSUE_DETAIL D
            WHERE D.账套 = C.账套
              AND D.品号 = C.品号
              AND D.客户编号 = C.客户编号
              AND D.使用部门 = C.使用部门
              AND D.订单日期 >= @OrderBeginDate
              AND D.订单日期 <= @TodayChar
              AND D.订单单别名称 = N'样板订单'
              AND ISNULL(RTRIM(D.成品规格), '') <> ''
        ) X
        ORDER BY X.成品规格
        FOR XML PATH(''), TYPE
    ).value('.','NVARCHAR(MAX)'), 1, 1, '') AS 样板规格

INTO #SAMPLE_SPEC
FROM (SELECT DISTINCT 账套,品号,客户编号,使用部门 FROM #ISSUE_DETAIL) C;

CREATE INDEX IX_SAMPLE_SPEC ON #SAMPLE_SPEC(账套,品号,客户编号,使用部门);

------------------------------------------------------------
-- 9. 最终输出：按模板；一个客户 + 一个使用部门一行
------------------------------------------------------------
SELECT
    --ROW_NUMBER() OVER (ORDER BY ISNULL(U.使用部门,''),I.品号,ISNULL(U.客户简称,'')) AS 序号,
    --'' AS 供应商,
        I.账套 AS 所属基地,
    I.品号 AS 料号,
    I.品名,
    I.规格,
    I.采购参考周期 AS 周期,

    '' AS 未来第1月计划,
    '' AS 未来第2月计划,
    '' AS 未来第3月计划,
    '' AS 未来第4月计划,
    '' AS 未来第5月计划,
    '' AS 未来第6月计划,

    '' AS 过去1个计划量,
    '' AS 过去2个计划量,
    '' AS 过去3个计划量,
    '' AS 过去4个计划量,

    CASE WHEN ISNULL(U.过去第1月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第1月使用量,0) END AS 过去第1月使用量,
    CASE WHEN ISNULL(U.过去第2月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第2月使用量,0) END AS 过去第2月使用量,
    CASE WHEN ISNULL(U.过去第3月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第3月使用量,0) END AS 过去第3月使用量,
    CASE WHEN ISNULL(U.过去第4月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第4月使用量,0) END AS 过去第4月使用量,
    CASE WHEN ISNULL(U.过去第5月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第5月使用量,0) END AS 过去第5月使用量,
    CASE WHEN ISNULL(U.过去第6月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第6月使用量,0) END AS 过去第6月使用量,
    CASE WHEN ISNULL(U.过去第7月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第7月使用量,0) END AS 过去第7月使用量,
    CASE WHEN ISNULL(U.过去第8月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第8月使用量,0) END AS 过去第8月使用量,
    CASE WHEN ISNULL(U.过去第9月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第9月使用量,0) END AS 过去第9月使用量,
    CASE WHEN ISNULL(U.过去第10月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第10月使用量,0) END AS 过去第10月使用量,
    CASE WHEN ISNULL(U.过去第11月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第11月使用量,0) END AS 过去第11月使用量,
    CASE WHEN ISNULL(U.过去第12月使用量,0) < 0 THEN 0 ELSE ISNULL(U.过去第12月使用量,0) END AS 过去第12月使用量,

    ISNULL(S.库存数量,0) AS 现库存,
    ISNULL(O.在途数量,0) AS 在途,
    ISNULL(A.分配数量,0) AS 分配,

    ISNULL(SS.样板规格,'') AS 过去2个月样板型号,
    ISNULL(U.使用部门,'') AS 使用部门,
    ISNULL(U.客户简称,'') AS [客户],
    ISNULL(PI.成品品名,'') AS 品名,
    ISNULL(PI.成品规格,'') AS [所使用产品],
    ISNULL(SI.销售部门,'') AS 销售部门,
    ISNULL(SI.业务员,'') AS 业务员,
    '' AS 备注,
    ISNULL(I.核准状况,'') AS 可否交易
FROM #ITEM I
LEFT JOIN #ISSUE U ON U.账套=I.账套 AND U.品号=I.品号
LEFT JOIN #SALE_INFO SI 
    ON SI.账套 = U.账套 
   AND SI.品号 = U.品号 
   AND SI.客户编号 = U.客户编号
   AND SI.使用部门 = U.使用部门

LEFT JOIN #PRODUCT_INFO PI 
    ON PI.账套 = U.账套 
   AND PI.品号 = U.品号 
   AND PI.客户编号 = U.客户编号
   AND PI.使用部门 = U.使用部门
LEFT JOIN #SAMPLE_SPEC SS
    ON SS.账套 = U.账套
   AND SS.品号 = U.品号
   AND SS.客户编号 = U.客户编号
   AND SS.使用部门 = U.使用部门
LEFT JOIN #STOCK S ON S.账套=I.账套 AND S.品号=I.品号
LEFT JOIN #ONWAY O ON O.账套=I.账套 AND O.品号=I.品号
LEFT JOIN #ALLOC A ON A.账套=I.账套 AND A.品号=I.品号
ORDER BY


    I.品号,
        ISNULL(U.使用部门,''),
    ISNULL(U.客户简称,'');