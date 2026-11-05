SET NOCOUNT ON;

DECLARE @BeginDate CHAR(8) = '20260901';
DECLARE @EndDate   CHAR(8) = '20261231';

SELECT
    A.LA001 AS 品号,
    B.MB002 AS 品名,
    B.MB003 AS 规格,
    B.MB004 AS 单位,
    A.LA004 AS 日期,
    CASE A.LA005
        WHEN '1' THEN '入库'
        ELSE '出库'
    END AS [出/入库],
    A.LA006 AS 单别,
    Q.MQ002 AS 单据名称,
    A.LA007 AS 单号,
    A.LA008 AS 序号,
    A.LA009 AS 仓库编号,
    C.MC002 AS 仓库名称,
    CASE C.MC004
        WHEN '1' THEN '存货仓'
        ELSE '非存货仓'
    END AS 仓库性质,
    A.LA011 AS 交易数量,
    A.LA012 AS 单位成本,
    A.LA013 AS 金额,
    A.LA017 AS [金额-材料],
    A.LA018 AS [金额-人工],
    A.LA019 AS [金额-制费],
    A.LA020 AS [金额-加工],
    CASE A.LA014
        WHEN '1' THEN '入库'
        WHEN '2' THEN '销货'
        WHEN '3' THEN '领用'
        WHEN '4' THEN '调拨'
        WHEN '5' THEN '调整'
    END AS 交易别,
    CASE A.LA015
        WHEN 'Y' THEN '成本计算来源'
        WHEN 'N' THEN '赋值计算结果'
        WHEN 'y' THEN '成本调整'
        WHEN 'r' THEN '返工领'
        WHEN 'R' THEN '返工入'
    END AS 影响成本,
    A.LA010 AS 备注,
    A.LA024 AS 对象
    ,MOCTA.TA006 产品品号
    ,MOCTA.TA034 产品品名
    ,MOCTA.TA035 产品规格
FROM dbo.INVLA AS A
INNER JOIN dbo.INVMB AS B
    ON B.MB001 = A.LA001
INNER JOIN dbo.CMSMQ AS Q
    ON Q.MQ001 = A.LA006
INNER JOIN dbo.CMSMC AS C
    ON C.MC001 = A.LA009
LEFT OUTER JOIN MOCTA ON TA001 = LEFT(A.LA024,4) AND TA002 = SUBSTRING(A.LA024,6,17)
WHERE A.LA004 >= @BeginDate
  AND A.LA004 <= @EndDate
  AND( LEFT(A.LA006,2) = '54'
  OR LEFT(A.LA006,2) = '56')
  AND LEFT(A.LA001,1) IN ('3','5','6','7')
ORDER BY
    A.LA004,
    A.LA006,
    A.LA007,
    A.LA008;
