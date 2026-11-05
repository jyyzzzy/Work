SELECT w1.workflowname
	, w.requestname
	, F.requestid
	, occurdate 费用日期
	, O.部门名称
	, o1.科目名称
	, amount 金额
	,case
	when w.currentnodetype = '3' then '归档'
	else '未归档' end as 状态,w.status
FROM fnaexpenseinfo_2026 F --年度需更新
	left join OA_COMPLETEDEP O ON F.organizationid = O.部门ID
	left join OA_COMPLETETYPE o1 on f.subject = o1.科目编号
	left join workflow_requestbase w on w.requestid = F.requestid
	left join workflow_base w1 on w.workflowid = w1.id
WHERE O.部门名称 LIKE '%研发中心%' 
ORDER BY occurdate
select * from OA_BX_VIEW WHERE 状态 <> '归档' ORDER BY 申请日期,requestId
select * from OA_BX_VIEW WHERE 归档日期 >= '2026-11-01'--AND 归档日期 <= '2026-10-21'
AND 科目名称 = '损益类/管理费用/差旅费' 
--AND 部门名称 LIKE '%研发中心%'
--AND (部门名称 LIKE '%研发%' OR 部门名称 LIKE '%工程%')
--申请单信息
SELECT * 
FROM Apply_Info 
WHERE 申请日期 >='2026-11-01' --AND 申请日期 <= '2026-10-21'
AND 科目名称 LIKE '%管理费用%' 
--AND 费用承担 LIKE '%研发中心%' 
--AND 状态 <> '已报销'
AND 申请金额 > 0 
AND EXISTS(SELECT 1 FROM HrmResource WHERE status = '1'AND 申请人 = lastname)
AND 费用承担 IS NOT NULL
AND 状态= '未关联'
ORDER BY 申请日期
select * from OA_BX_VIEW 
WHERE 

申请日期 >='2026-10-01'
AND 科目名称 = '损益类/管理费用/差旅费' 
AND 部门名称 LIKE '%研发中心%'

select * from OA_BX_VIEW WHERE 归档日期>='2026-10-01'--AND 归档日期 <= '2026-10-21'
AND 科目名称 = '损益类/管理费用/差旅费' 
AND 部门名称 LIKE '%研发中心%'

SELECT sqbzw,* FROM uf_Budget_Request WHERE djid = 2763884

UPDATE uf_Budget_Request SET sqbzw = '0' WHERE sqbzw = '3'