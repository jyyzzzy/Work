SELECT * FROM w_SWM_JNGZ2

INSERT INTO w_SWM_JNGZ2(ID_
			,F_YF
			,F_GH
			,F_GH_NAME
			,F_XM
			,F_ZJMC
			,F_ZYLB
			,F_FZJG
			,F_FZRQ
			,F_YXQX
			,F_BTJE
			,F_BZ
			,TENANT_ID_
			,CREATE_TIME_
			,CREATE_BY_
			,GROUP_ID_
			) 
	SELECT NEWID() AS ID_
		,'{?payrollmonth}' AS F_YF
		, ID_  AS F_GH
		, F_GH AS F_GH_NAME
		, F_XM AS F_XM
		,'{?d.zjmc}'
		,'{?d.zylb}'
		,'{?d.fzjg}'
		,'{?d.fzrq}'
		,'{?d.yxqx}'
		,{?d.btje}
		,'{?d.bz}'
		,'1'
		,GETDATE() AS CREATE_TIME_
		,(SELECT ID_ FROM w_EMP_INFO WHERE F_GH ='{?sqrgh}') AS CREATE_BY
		,'1090425177784967349' AS GROUP_ID_
		FROM w_EMP_INFO WHERE F_GH ='{?d.gh}' AND ISNULL('{?d.gh}','')<>''

		exec sp_help w_SWM_JNGZ2

		SELECT * FROM w_SWM_JNGZ2
		
INSERT INTO w_SWM_JNGZ2(ID_
			,F_YF
			,F_GH
			,F_GH_NAME
			,F_XM
			,F_ZJMC
			,F_ZYLB
			,F_FZJG
			,F_FZRQ
			,F_YXQX
			,F_BTJE
			,F_BZ
			,TENANT_ID_
			,CREATE_TIME_
			,CREATE_BY_
			,GROUP_ID_
			) 
	SELECT NEWID() AS ID_
		,'2026-05' AS F_YF
		, ID_  AS F_GH
		, F_GH AS F_GH_NAME
		, F_XM AS F_XM
		,'特种作业操作证'
		,'电工作业'
		,'佛山市顺德区市场安全监管局'
		,'2021-12-03'
		,'2027-12-02'
		,50.00
		,'瑞德集团\瑞德智能\管理中心\行政部\'
		,'1'
		,'1090425177784967349'
		,GETDATE()  AS CREATE_TIME_
		,(SELECT ID_ FROM w_EMP_INFO WHERE F_GH ='10109538') AS CREATE_BY
		FROM w_EMP_INFO WHERE F_GH ='10105978' AND ISNULL('10105978','')<>''

sp_help w_SWM_JNGZ2