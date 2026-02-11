SELECT DISTINCT 
	workcode 工号,
	lastname 姓名,
	--HrmJobTitles.id,
	HrmJobTitles.jobtitlename 职位,
	DEPT.departmentcode 部门编号,
	DEPT.departmentname 部门名称,
	DEPT.subcompanyname 公司名称,
	--M.COMPANY 权限所在系统,
	MA002 系统名称,
	M.MG002 程序编号,
	MB002 程序名称,
	--MG004 可否运行,
	SUBSTRING(MG006,7,1) AS 单价,
	SUBSTRING(MG006,8,1) AS 金额,
	SUBSTRING(MG006,1,1) AS 查询,
	SUBSTRING(MG006,2,1) AS 更改,
	SUBSTRING(MG006,3,1) AS 删除,
	SUBSTRING(MG006,4,1) AS 审核,
	SUBSTRING(MG006,5,1) AS 撤销审核,
	SUBSTRING(MG006,6,1) AS 输出,
	SUBSTRING(MG006,9,1) AS 新增,
	SUBSTRING(MG006,10,1) AS 送签,
	SUBSTRING(MG006,12,1) AS 作废
FROM 
	(
		SELECT * FROM SDRD..ADMMG
		UNION ALL
		SELECT * FROM ZJRD..ADMMG
		UNION ALL
		SELECT * FROM AHRD..ADMMG
		UNION ALL
		SELECT * FROM YNRD..ADMMG
		UNION ALL
		SELECT * FROM RWDZ..ADMMG
		UNION ALL
		SELECT * FROM RDWL..ADMMG
	) AS M 
	INNER JOIN [DSCSYS].[dbo].[ADMMB] ON MB001 = MG002 
	INNER JOIN [DSCSYS].[dbo].[ADMMA] ON MA001 = MB004
	LEFT OUTER JOIN [192.168.8.24].[ecology].dbo.OA_Hrm AS HRM ON workcode COLLATE Chinese_PRC_BIN = MG001
	LEFT OUTER JOIN [192.168.8.24].[ecology].dbo.OA_COMPLETEDEP_Vcode AS DEPT ON DEPT.departmentID = HRM.departmentid 
	LEFT OUTER JOIN [192.168.8.24].[ecology].[dbo].HrmJobTitles on HRM.jobtitle=HrmJobTitles.id
WHERE
	EXISTS (
		SELECT 1 
		FROM [192.168.8.24].[ecology].dbo.OA_Hrm AS W 
		WHERE W.workcode COLLATE CHINESE_PRC_CI_AS = M.MG001 COLLATE CHINESE_PRC_CI_AS 
		--AND seclevel = '30'
	) 
	--AND  LEFT(M.MG002,3) IN ('MOC')
	AND DEPT.departmentname COLLATE Chinese_PRC_BIN LIKE '%营销中心%'
--AND LEFT(M.MG002,3) IN ('INV','PUR')
--AND SUBSTRING(M.MG002,1,5) <> 'PURAB'
--	AND SUBSTRING(M.MG002,1,4) <> 'PURB' 
--	AND SUBSTRING(M.MG002,1,4) <> 'PURQ' 
--	AND M.MG002 NOT IN(
--		'PURI01',
--		'PURI04',
--		'PURI05',
--		'PURI10',
--		'PURI12',
--		'PURI13',
--		'PURR01',
--		'PURR02',
--		'PURR03',
--		'PURR10',
--		'PURR11',
--		'PURR12',
--		'PURR19',
--		'PURR20',
--		'PURR36',
--		'PURR39'
--	)
--	AND LEFT(M.MG002,4) <> 'INVB' 
--	AND  M.MG002 NOT IN(
--		'INVI01',
--		'INVI03',
--		'INVI06',
--		'INVI14',
--		'INVQ02',
--		'INVR01',
--		'INVR02',
--		'INVR11',
--		'INVR12',
--		'INVR13',
--		'INVR14',
--		'INVR15',
--		'INVR16',
--		'INVR21',
--		'INVR27',
--		'INVR33',
--		'INVR34',
--		'INVR38',
--		'INVR45'
--	)
----AND MG002 IN ('PURI02','PURR04')
--	--AND SUBSTRING(MG006,2,1) = 'Y'
--AND MG004 = 'Y'  AND (SUBSTRING(MG006,7,1)='Y' OR SUBSTRING(MG006,8,1)='Y')
----AND (departmentname LIKE '%研发%' 
----OR lastname IN ('陈泽龙','罗佳','金旭','陈江平','雷霆','徐健灿','胡子扬','赵科','童怀俊','赖斯巧','孟奎')
----)
ORDER BY MG002,departmentcode,workcode