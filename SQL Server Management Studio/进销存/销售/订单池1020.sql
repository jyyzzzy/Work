SELECT 
	COPTC.TC001 + '-' + COPTC.TC002 AS [单别+单号],
	MOCTA.TA001 + '-' + MOCTA.TA002 AS 工单号,
	CMSMEA.ME002 AS 事业部,
	COPTD.TD013 AS 客户需求交期,
	MOCTA.TA010 AS 事业部排产日期,
	COPTD.TD016 AS [订单状态（是否已完成生产）],
	INVMA.MA003 AS 产品大类,
	CMSMQ.MQ002 AS 订单类别,
	CMSMEB.ME002 AS 事业部,
	COPTC.TC001 AS 订单单别,
	COPTC.TC039 AS 单据日期,
	COPTC.TC002 AS 核准日期,
	COPTC.TC002 AS 订单单号,
	COPTD.UDF05 AS 交货日期,
	COPMA.MA001 AS 客户简称,
	COPTD.TD004 AS 品号,
	COPTD.TD005 AS 品名,
	COPTD.TD006 AS 产品型号,
	COPTD.TD008 AS 订单数量,
	COPTD.TD011 AS 单价,
	COPTD.TD012 AS 金额,
	COPTC.TC005 AS 部门,
	COPTC.TC006 AS 业务员,
	COPTD.UDF01 AS PC交期,
	COPTD.UDF02 AS MC交期,
	COPTD.UDF03 AS 采购交期,
	COPTD.TD013 AS 预交货日,
	COPTD.UDF04 AS 客户原始交期,
	SUBSTRING(COPTD.TD013,1,6)可生产订单月份,
	ISNULL(LEFT(TE004A,6),'') AS 第一调整后月份,
	ISNULL(LEFT(TE004B,6),'') AS 第二调整后月份,
	ISNULL(LEFT(TE004C,6),'') AS 第三次调整后月份,
	ISNULL(ORDERCHANGE.TE006A,'') AS 调整原因,
	'' AS 有无单据,
	'' AS 调整类型,
	'' AS 变更通知日,
	'' AS 通知人,
	COPTD.UDF05 AS 本月最终交期,
	'' AS 调整情况,
	'' AS 取消金额,
	'' AS 总监,
	'' AS 事业部是否调整,
	'' AS 营销是否调整,
	'' AS 补录部门,
	'' AS 客户单号,
	'' AS 备料原因分类,
	'' AS 备料原因,
	'' AS [PMC意见-变更单],
	'' AS 辅助列,
	COPTD.TD008 AS 订单初始数量,
	COPTD.TD008*COPTD.TD011 AS 订单初始金额,
	COPTD.TD013 AS 当月日期,
	DATEDIFF(
		DAY,
		CASE WHEN LEN(LTRIM(RTRIM(COPTD.TD013)))=8 AND COPTD.TD013 NOT LIKE '%[^0-9]%'
			THEN CONVERT(date, LTRIM(RTRIM(COPTD.TD013)), 112) END,
		CASE WHEN LEN(LTRIM(RTRIM(COPTD.UDF05)))=8 AND COPTD.UDF05 NOT LIKE '%[^0-9]%'
			THEN CONVERT(date, LTRIM(RTRIM(COPTD.UDF05)), 112) END
	) AS [超期天数],
	CASE
		WHEN LEN(LTRIM(RTRIM(COPTD.TD013)))=8
		AND LEN(LTRIM(RTRIM(COPTD.UDF05)))=8
		AND CONVERT(date, LTRIM(RTRIM(COPTD.UDF05)),112) > CONVERT(date, LTRIM(RTRIM(COPTD.TD013)),112)
		THEN 'TRUE' ELSE 'FALSE'
	END AS [是否超期],
	'' AS 超期订单跟进,
	COPMA.MA001 AS 关联方,
	TD011 AS 系统单价
FROM COPTC --订单单头
INNER JOIN COPTD ON COPTD.TD001 = COPTC.TC001 AND COPTD.TD002 = COPTC.TC002 --订单单身
INNER JOIN MOCTA ON MOCTA.TA026 = COPTC.TC001 AND MOCTA.TA027 = COPTC.TC002 -- 工单单头
INNER JOIN INVMB ON INVMB.MB001 = COPTD.TD004--品号信息
INNER JOIN INVMA ON INVMA.MA002 = INVMB.MB007--品号类别
LEFT OUTER JOIN CMSMD ON CMSMD.MD001 = MOCTA.TA021--工作中心信息
LEFT OUTER JOIN CMSME AS CMSMEA ON CMSMEA.ME001 = COPTC.TC005--营销部门信息
LEFT OUTER JOIN CMSME AS CMSMEB ON CMSMEB.ME001 = CMSMD.MD015  --制造部门信息
INNER JOIN CMSMQ ON CMSMQ.MQ001 = COPTC.TC001 --系统单据性质
LEFT OUTER JOIN COPMA ON COPMA.MA001 = COPTC.TC004 --客户基本信息
LEFT OUTER JOIN (--订单变更信息
    SELECT TE001, TE002,
           MAX(CASE WHEN TE003='0001' THEN TE004 END) AS TE004A,--第一次变更
           MAX(CASE WHEN TE003='0002' THEN TE004 END) AS TE004B,--第二次变更
           MAX(CASE WHEN TE003='0003' THEN TE004 END) AS TE004C,--第三次变更
		   MAX(TE006) AS TE006A --变更原因
    FROM COPTE
    GROUP BY TE001, TE002
) AS ORDERCHANGE
  ON ORDERCHANGE.TE001 = COPTC.TC001
 AND ORDERCHANGE.TE002 = COPTC.TC002


select
    ddbh 订单编号,
    dddb 订单单别,
    dddh 订单单号,
    cpbm 产品编码,
        wjsl 未交数量,
        modedatacreatedate 创建日期,
        erpdyztm ERP账套,
        khbm 客户编码,
        khjc 客户简称,
        ddsl 订单数量,
        yjsl 已交数量,
        yjhr 预交货日,
        cpmc 产品名称,
        cpxh 产品型号,
    lcbh 流程编号,
    wscsl 未生产数量,
    备注,
    bgbb 变更版本,
    zj 总监,
    zxyjhr 最小预交货日,
    lastname 变更人,
    bghsl 变更后数量,
    bghyjhr 变更后预交货日,
    变更备注
from [192.168.8.24].[ecology].[dbo].Order_Pool left join [192.168.8.24].[ecology].[dbo].HrmResource h on h.id=bgr
ORDER BY modedatacreatedate
;
SELECT * FROM master.dbo.Order_Pool;
SELECT * FROM master.dbo.HrmResource;



