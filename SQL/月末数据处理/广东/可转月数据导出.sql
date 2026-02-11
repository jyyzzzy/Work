drop TABLE #ZYCLZLB

--select *from  web_lnk.RDSJK.dbo.ZYCLZLB

--delete from  web_lnk.RDSJK.dbo.ZYCLZLB

SELECT   '              '类别,
	CLZL025 关联单号 ,

	'                                                                                                                                                                                                               '备注,
	CLZL001 品号 ,
	CLZL002 品名,
	CLZL003 规格,
	CLZL004 供应商,
	CLZL005 供应商简称,
	CLZL012 标准单价,
	CLZL011 库存,
	CLZL013 金额 ,
	CLZL014 交易数量,
	CLZL015 交易金额,
	CLZL016 库存日期,
	CLZL017 日期,
	CLZL018 [账龄(天)],
	MB007 商品类别,
	MA003 类别名称,
	CLZL019 单价,
	(SELECT b.MC001+ b.MC002 FROM SDRD..CMSMC b WHERE b.MC001=CLZL020) AS 仓别,
	CLZL021 物料状态,
	ZLDZ04 所属事业部,
	ZLDZ06 客户名称,
	ZLDZ06 分析原因
INTO #ZYCLZLB
FROM web_lnk.RDSJK.dbo.ZYCLZLB 
	JOIN  SDRD..INVMB ON MB001=CLZL001 
	LEFT JOIN SDRD..INVMA ON MB007=MA002 
	LEFT JOIN  web_lnk.RDSJK.dbo.ZLDZYY ON ZLDZ01='SDRD' AND CLZL016=ZLDZ03 AND ZLDZ02=CLZL001 
WHERE (
		LEFT(CLZL001,1)='3' 
		OR LEFT(CLZL001,1)='5'
		OR LEFT(CLZL001,1)='6' 
		OR LEFT(CLZL001,1)='7'
	) AND (CLZL017 = '2025/11/30')  
	AND CLZL021='良品'
	AND CLZL016<='2025/11/30'  
ORDER BY MB007,
	CLZL001,
	CLZL021 DESC,
	CLZL004,
	CLZL014,
	CLZL017,
	CLZL018 DESC

 SELECT *FROM  web_lnk.RDSJK.dbo.ZYCLZLB  WHERE (CLZL017 = '2025/11/30') 

 DELETE FROM  web_lnk.RDSJK.dbo.ZYCLZLB  WHERE (CLZL017 = '2025/11/30') 

 SELECT *FROM   #ZYCLZLB
 /***产线退料标注***/
 UPDATE zy SET 类别='产线退料',关联单号= '工单:'+LA024 
 FROM #ZYCLZLB zy 
 JOIN  ( 
	SELECT LA001,LA024,SUM(LA011*LA006) SL,LEFT(LA004,6)+'01' YF 
	FROM SDRD..INVLA A 
	JOIN  SDRD.dbo.CMSMC ON LA009=CMSMC.MC001 
	JOIN SDRD.dbo.INVMB ON MB001=LA001 
	WHERE CMSMC.MC004='1' 
	AND CMSMC.MC018='Y' 
	AND CMSMC.UDF01 LIKE '%-良品' 
	AND CMSMC.MC002 NOT LIKE '%车间仓%' 
	AND CMSMC.MC002 NOT LIKE '%外协仓%'
	AND CMSMC.MC002 NOT LIKE '%非ROHS%'
	AND CMSMC.MC002 NOT LIKE '%辅料%' 
	AND LA006 LIKE '5%' 
	AND LEN(LA024)=16 
	AND LEFT(LA001,1 ) IN('3','5','6','7') 
	GROUP BY LA001,MB017,LEFT(LA004,6),LA024 
	HAVING(SUM(LA011*LA006))>0 
) AS MOC ON  品号=LA001 AND 库存日期=YF AND 供应商简称='产线退料'

  /***产线退料标注***/



 /***产线退料标注***/
 UPDATE zy SET 类别='连续转月',备注= '最初入库时间:'+LEFT(CREATE_DATE ,8)
 --SELECT TG001+'-'+TG002+ '最初入库时间:'+left(CREATE_DATE ,8),*
  FROM #ZYCLZLB zy JOIN (SELECT TG001,TG002, TH.CREATE_DATE,TG005,TH014 YF,TH004,TH047 je,TH016,TH018
FROM SDRD..PURTH TH INNER JOIN SDRD..PURTG ON TH001=TG001 AND TH002=TG002
WHERE TH030 = 'Y' AND TH016 > 0 AND DATEDIFF(MONTH,CAST(LEFT(TH.CREATE_DATE,6)+'01' AS DATETIME),CAST(LEFT(TH014,6)+'01' AS DATETIME))>1) AS PUR ON  品号=TH004 AND 库存日期=YF AND  供应商=TG005

  /***产线退料标注***/
  --select Datediff(MONTH,cast('20200331' as datetime),cast('20200615' as datetime))>2


 SELECT   RTRIM(类别) 类别,RTRIM(关联单号)关联单号,RTRIM(品号)品号 , 
 品名,规格,供应商,供应商简称,标准单价,库存,金额 ,交易数量, 交易金额,
 库存日期,日期,[账龄(天)],商品类别,类别名称,单价,仓别,物料状态,
 ISNULL(所属事业部,'')所属事业部,ISNULL(客户名称,'') 客户名称,ISNULL(分析原因,'')分析原因,RTRIM(备注) 备注 FROM  #ZYCLZLB


 SELECT   SUM(交易金额) FROM  #ZYCLZLB

SELECT  RTRIM(品号)品号 , 品名,规格,SUM(交易数量) 可转库存, SUM(交易金额 )可转金额,
SUM(CASE WHEN 备注 LIKE '%退料%' THEN 交易数量  ELSE 0 END) 退料数量,SUM(CASE WHEN 备注 LIKE '%退料%' THEN 交易数量  ELSE 0 END)*(SUM(交易金额 )/SUM(交易数量)) 退料金额,
SUM(CASE WHEN 备注 LIKE '%最初入库时间%' THEN 交易数量  ELSE 0 END) 连续转月数 ,SUM(CASE WHEN 备注 LIKE '%最初入库时间%' THEN 交易数量  ELSE 0 END) *(SUM(交易金额 )/SUM(交易数量)) 连续转月金额
 FROM  #ZYCLZLB GROUP BY 品号 , 品名,规格  HAVING(SUM(交易数量))>0



 SELECT TG001,TG002,TH003, TH.CREATE_DATE,TG005,MA002,TH014 YF,TH004,TH006,TH006,TH047 je,TH016,TH018
FROM SDRD..PURTH TH INNER JOIN SDRD..PURTG ON TH001=TG001 AND TH002=TG002 JOIN SDRD..PURMA ON MA001=TG005
WHERE TH030 = 'Y' AND TH016 > 0 AND TH014='20200701' AND LEFT(TH.CREATE_DATE,8)<='20200701'


SELECT *FROM   RDSJK..TYGYS 

 SELECT   RTRIM(类别) 类别,RTRIM(关联单号)关联单号,RTRIM(备注) 备注,RTRIM(品号)品号 , 品名,规格,供应商,供应商简称,标准单价,库存,金额 ,交易数量, 交易金额,库存日期,日期,[账龄(天)],
 商品类别,类别名称,单价,仓别,物料状态,ISNULL(所属事业部,'')所属事业部,ISNULL(客户名称,'') 客户名称,ISNULL(分析原因,'')分析原因 FROM  #ZYCLZLB WHERE  (SELECT COUNT(*) 
 FROM  RDSJK..TYGYS WHERE TY01=供应商 AND TY06='SDRD')=0

 SELECT *FROM INVLA 


 SELECT   LEFT(LA004,6)YF ,LEFT(LA006,2) DB,CASE WHEN LA024 LIKE '%瑞德智能%' THEN '瑞德智能' ELSE '本地采购' END,MB001,MB002,MB003,MB004,-SUM(LA011*LA006) YL  
 FROM  INVLA JOIN INVMB ON MB001=LA001 JOIN CMSMC C  ON LA009=MC001 
 WHERE (LA004 >= '20200801'  AND  LA004 <= '20201130' ) AND C.UDF01 LIKE '%-良品%' AND LEFT(LA001,1) NOT IN('A','1','2')  AND LA006 NOT LIKE ('1%')  
 AND LEFT(LA006,2) NOT IN('35','18' ,'19','34') AND LEFT(LA006,2) NOT IN('1102','1112' )

 GROUP BY LEFT(LA004,6),CASE WHEN LA024 LIKE '%瑞德智能%' THEN '瑞德智能' ELSE '本地采购' END,MB001,MB002,MB003,MB004,LEFT(LA006,2) HAVING(-SUM(LA011*LA006))>0 
 ORDER BY YF,MB001,MB002,CASE WHEN LA024 LIKE '%瑞德智能%' THEN '瑞德智能' ELSE '本地采购' END



 
 SELECT   MB001,MB002,MB003,-SUM(LA011*LA006) YL INTO #TEM1  FROM  INVLA JOIN INVMB ON MB001=LA001 JOIN CMSMC C  ON LA009=MC001 
 WHERE (LA004 >= '20200801'  AND  LA004 <= '20201130' ) AND C.UDF01 LIKE '%-良品%' AND LEFT(LA001,1) NOT IN('A','1','2') 
 AND LA006 NOT LIKE ('1%')  AND LEFT(LA006,2) NOT IN('35','18' ,'19','34') AND LEFT(LA006,2) NOT IN('1102','1112' )

 GROUP BY MB001,MB002,MB003 HAVING(-SUM(LA011*LA006))>0 ORDER BY MB001,MB002 



 
 select  case isnull( YL,0) when 0 then '无使用' else '未用完' end  , rtrim(类别) 类别,rtrim(关联单号)关联单号,rtrim(备注) 备注,
 rtrim(品号)品号 , 品名,规格,供应商,供应商全称,标准单价,库存, YL 实际用量,金额 ,交易数量, 交易金额,库存日期,日期,[账龄(天)],商品类别,
 类别名称,单价,仓别,物料状态,isnull(所属事业部,'')所属事业部,isnull(客户名称,'') 客户名称,isnull(分析原因,'')分析原因 
 from  #ZYCLZLB LEFT JOIN #TEM1 ON rtrim(品号)=MB001 
 WHERE (select count(*) from  RDSJK..TYGYS where TY01=供应商 and TY06='SDRD')=0