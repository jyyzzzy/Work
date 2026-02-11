--select convert(varchar ,getdate(),112)


USE ZJRD
USE SDRD
USE AHRD


declare @month2 varchar(8)
set @month2='20250731'

DECLARE @month VARCHAR(6)
SET @month=LEFT(CONVERT(VARCHAR ,DATEADD(MONTH,-3 ,@month2),112),6)
SELECT @month,@month2


EXEC ('ALTER view dbo.V_KCMX  
AS  
SELECT TOP 10000000 INVMA.MA002 AS MA002,INVMA.MA003 AS MA003,INVMA.MA004 AS MA004,  
        MB001,MB002,MB003,MB004,MB072,MB090,MB057,MB058,MB059,MB060,  
        MD003,MD004,A.MA003 AS MA003C,MF004,MF005,  
        CASE WHEN INVMA.MA001=''1'' THEN INVMB.MB005   
             WHEN INVMA.MA001=''2'' THEN INVMB.MB006   
             WHEN INVMA.MA001=''3'' THEN INVMB.MB007   
             WHEN INVMA.MA001=''4'' THEN INVMB.MB008 END CATEGORY,  
        FLOOR(ABS(ISNULL(LC004,0)))*SIGN(ISNULL(LC004,0))+SUM(ISNULL(INVLA.LA005*FLOOR(ABS(INVLA.LA011))*SIGN(INVLA.LA011),0)) INVNUMA,  
        ISNULL(LC004,0) - FLOOR(ABS(ISNULL(LC004,0)))*SIGN(ISNULL(LC004,0))+SUM(ISNULL(INVLA.LA005*(INVLA.LA011-FLOOR(ABS(INVLA.LA011))*SIGN(INVLA.LA011)),0)) INVNUMB,  
        (ISNULL(LC030,0) + SUM(ISNULL(INVLA.LA021,0)*ISNULL(INVLA.LA005,0))) QUANTYPACK,  
        (ISNULL(LC005,0) + SUM(ISNULL(INVLA.LA013,0)*ISNULL(INVLA.LA005,0))) INVMONEY         ,I.MC002 AS MC002,C.MC002 AS MC002C ,  
		
        SUM(ISNULL(INVLA.LA005*FLOOR(ABS(INVLA.LA011))*SIGN(INVLA.LA011),0)) INVNUMAH, 
        (SUM(ISNULL(INVLA.LA013,0)*ISNULL(INVLA.LA005,0))) INVMONEYH,
		 FLOOR(ABS(ISNULL(LC004,0)))*SIGN(ISNULL(LC004,0)) INVNUMAQ,  
        (ISNULL(LC005,0) ) INVMONEYQ   
FROM INVMC I   
LEFT JOIN INVMB AS INVMB ON MB001=I.MC001   
 LEFT JOIN INVLC AS INVLC ON LC001=I.MC001 AND LC002='''+@month+''' AND LC003=I.MC002   --取前三个月数据
 LEFT JOIN INVLA AS INVLA ON LA001=I.MC001 AND LA009=I.MC002 AND (LA004 BETWEEN '''+@month+'01'' AND '''+@month2+''')  
 LEFT JOIN CMSMC C ON C.MC001=I.MC002 LEFT JOIN INVMA AS INVMA ON MA001=''1'' AND MA002=MB005  LEFT JOIN ACTMA A ON A.MA001 =INVMA.MA004   
 LEFT JOIN CMSMF AS CMSMF ON MF001=''RMB''   
 LEFT JOIN INVMD AS INVMD ON MD001=MB001 and MD002=MB072   
 Where 1=1  AND C.MC004=''1''   
GROUP BY INVMA.MA002,INVMA.MA003,INVMA.MA004,MB001,MB002,MB003,MB004,MB072,MB090,MB057,MB058,MB059,MB060,  
          A.MA003,MF004,MF005,MD003,MD004,  
          CASE WHEN INVMA.MA001=''1'' THEN INVMB.MB005   
               WHEN INVMA.MA001=''2'' THEN INVMB.MB006  
               WHEN INVMA.MA001=''3'' THEN INVMB.MB007   
               WHEN INVMA.MA001=''4'' THEN INVMB.MB008 END,LC004,LC005,LC030,I.MC002,C.MC002   
HAVING 1=1  AND   
      ((FLOOR(ABS(ISNULL(LC004,0)))*SIGN(ISNULL(LC004,0))+SUM(ISNULL(INVLA.LA005*FLOOR(ABS(INVLA.LA011))*SIGN(INVLA.LA011),0))<>0 OR 
		ISNULL(LC004,0) - FLOOR(ABS(ISNULL(LC004,0)))*SIGN(ISNULL(LC004,0))+SUM(ISNULL(INVLA.LA005*(INVLA.LA011-FLOOR(ABS(INVLA.LA011))*SIGN(INVLA.LA011)),0))<>0) OR   
       (ISNULL(LC030,0) + SUM(ISNULL(INVLA.LA021,0)*ISNULL(INVLA.LA005,0)))<>0 OR   
       (ISNULL(LC005,0) + SUM(ISNULL(INVLA.LA013,0)*ISNULL(INVLA.LA005,0)))<>0)   
ORDER BY  MA002,MB001,MC002')

GO

sp_helptext V_KCMX

SELECT * FROM LSKCB
SELECT * FROM LSZCB




select *from V_KCMX where INVNUMA<0

select sum(INVMONEY) from V_KCMX

select *from AHRD..INVMB A JOIN INVMB S ON A.MB001=S.MB001
SELECT *FROM LSSJ..LSKCB  where 库存金额<>0
--DELETE FROM LSSJ..LSKCB
--DELETE FROM LSSJ..LSZCB

DELETE FROM LSSJ..LSKCB
insert into  LSSJ..LSKCB 
select rtrim(MB001),MB002,MB003,MB004,rtrim(MC002) ,MC002C,INVNUMA,CASE INVNUMA WHEN 0 THEN INVMONEY ELSE INVMONEY/INVNUMA END ,INVMONEY,NULL,NULL from V_KCMX

CASE WHEN SUBSTRING(MB001,1,1)< '3' THEN MB057*1.13 ELSE INVMB.UDF54 END
CASE WHEN SUBSTRING(MB001,1,1)< '3' THEN  单价*1.13 ELSE case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end END

SELECT 品号,品名,规格,单位,仓库编号,仓库名称,库存数量,
case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end ,库存数量*(case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 END)
FROM LSSJ..LSKCB INNER JOIN  INVMB ON MB001 = 品号
WHERE 库存数量 >0 ORDER BY 仓库编号

SELECT 工单编号,产品品号,开工日,预计产量,已生产量,工作中心编号,工作中心名称,材料品号,品名,规格,单位,
已发料量,已耗用量,在产品数量,case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end,
在产品数量*case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end
FROM LSSJ..LSZCB INNER JOIN INVMB ON 材料品号 = MB001
ORDER BY 工作中心编号

SELECT TA021,MD002,LSZCB.* FROM LSSJ..LSZCB INNER JOIN MOCTA ON TA001+'-'+TA002 = 工单编号
INNER JOIN CMSMD ON MD001 = TA021
WHERE 工作中心编号 IS NULL

UPDATE LSSJ..LSZCB SET 工作中心编号 = TA021,工作中心名称 = MD002 FROM LSSJ..LSZCB INNER JOIN MOCTA ON TA001+'-'+TA002 = 工单编号
INNER JOIN CMSMD ON MD001 = TA021
WHERE 工作中心编号 IS NULL







-------------------------------------------------浙江瑞德---------------------------------------------------
SELECT 品号,品名,规格,单位,仓库编号,仓库名称,库存数量,
case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end,库存数量*(case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end)
FROM LSSJ..LSKCB INNER JOIN ZJRD..INVMB ON MB001 = 品号
WHERE 库存数量 >0 ORDER BY 仓库编号

SELECT 工单编号,产品品号,开工日,预计产量,已生产量,工作中心编号,工作中心名称,材料品号,品名,规格,单位,
已发料量,已耗用量,在产品数量,case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end,
在产品数量*case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end
FROM LSSJ..LSZCB INNER JOIN ZJRD..INVMB ON 材料品号 = MB001
ORDER BY 工作中心编号


SELECT TA021,MD002,LSZCB.* FROM LSZCB INNER JOIN ZJRD..MOCTA ON TA001+'-'+TA002 = 工单编号
INNER JOIN ZJRD..CMSMD ON MD001 = TA021
WHERE 工作中心编号 IS NULL

UPDATE LSZCB SET 工作中心编号 = TA021,工作中心名称 = MD002 FROM LSZCB INNER JOIN ZJRD..MOCTA ON TA001+'-'+TA002 = 工单编号
INNER JOIN ZJRD..CMSMD ON MD001 = TA021
WHERE 工作中心编号 IS NULL


select *from INVLA WHERE LA001='200123530000'

-------------------------------------------------浙江瑞德---------------------------------------------------
SELECT 品号,品名,规格,单位,仓库编号,仓库名称,库存数量,
case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end,库存数量*(case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end)
FROM LSSJ..LSKCB INNER JOIN AHRD..INVMB ON MB001 = 品号
WHERE 库存数量 >0 ORDER BY 仓库编号

SELECT 工单编号,产品品号,开工日,预计产量,已生产量,工作中心编号,工作中心名称,材料品号,品名,规格,单位,
已发料量,已耗用量,在产品数量,case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end,
在产品数量*case INVMB.UDF54 when 0 then 单价*1.13 else INVMB.UDF54 end
FROM LSSJ..LSZCB INNER JOIN AHRD..INVMB ON 材料品号 = MB001
ORDER BY 工作中心编号

select UDF54 from  ZJRD..INVMB where MB001='200123530000'

SELECT  * FROM LSZCB
SELECT TA021,MD002,LSZCB.* FROM LSZCB INNER JOIN AHRD..MOCTA ON TA001+'-'+TA002 = 工单编号
INNER JOIN AHRD..CMSMD ON MD001 = TA021
WHERE 工作中心编号 IS NULL

UPDATE LSZCB SET 工作中心编号 = TA021,工作中心名称 = MD002 FROM LSZCB INNER JOIN AHRD..MOCTA ON TA001+'-'+TA002 = 工单编号
INNER JOIN AHRD..CMSMD ON MD001 = TA021
WHERE 工作中心编号 IS NULL


 select *from RDSJK..Material_zlwz
 update RDSJK..Material_zlwz set PH = PH+'-QC'
 update RDSJK..Material_zlwz set   PH = replace(PH,'-QC','')

 select DISTINCT RTRIM(MB001),MB002,MB003 from RDSJK..Material_zlwz join SDRD..INVMB ON MB001=PH


	delete from LSSJ..KCSJHS
	insert into LSSJ..KCSJHS exec SDRD.dbo.[KCSJHS] '20250731','1=1'


	SELECT *FROM   LSSJ..KCSJHS

	SELECT *FROM   LSSJ..KCSJHS where MB001='305030035000'


	 DROP TABLE #KC
SELECT MX.* INTO #KC FROM [Fn_GetKCMX]('20250731','') MX 

SELECT *FROM  #KC

SELECT SUM(库存金额) FROM LSSJ..KCSJHS WHERE LEFT(MB001,1) IN('5','3','6','7')

SELECT SUM(MC08) FROM #KC WHERE LEFT(MC01,1) IN('5','3','6','7')


select  *  from  LSSJ..KCSJHS

select  *  from  LSSJ..KCSJHS where MB001 

select 所属事业部,客户名称 仓库编号,分析原因 仓库名称,sum(库存金额)库存金额  from  LSSJ..KCSJHS where 备注 ='按仓别分' group by 所属事业部,客户名称 ,分析原因  
union all
select  '事业一部','000',备注,sum(事业一部金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union all
select  '事业二部','000',备注,sum(事业二部金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union all
select  '事业三部','000',备注,sum(事业三部金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union all
select  '供应中心','000',备注,sum(供应中心金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union all
select  '新能源部','000',备注,sum(新能源部金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union all
select  '浙江瑞德','000',备注,sum(浙江瑞德金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union all
select  '营销中心','000',备注,sum(营销中心金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union ALL
select  '瑞德物联','000',备注,sum(瑞德物联金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union all
select  '锂电板块','000',备注,sum(锂电板块金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union all
select  '安徽瑞德','000',备注,sum(安徽瑞德金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union all
select  '未知归属','000',备注,sum(未知归属金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注
union all
select  '战略物资','000',备注,sum(战略物资金额)库存金额 from  LSSJ..KCSJHS where 备注 <>'按仓别分'  group by  备注

order by 所属事业部,客户名称




									

/*浙江库存**/
SELECT MB001 品号,MB002 品名,MB003 规格,MB004 单位,
case WHEN isnull(PH,'')<>'' and CMSMC.UDF01 LIKE '%良品%' THEN 'AAA'  ELSE MC02 end 仓库编号,case WHEN isnull(PH,'')<>'' and CMSMC.UDF01 LIKE '%良品%' THEN '战略物资'  ELSE MC002 end 仓库名称
--MC02 仓库编号,MC002 仓库名称

,MC07 库存数量, CAST(CASE MC07 WHEN 0 THEN 0 ELSE ROUND(MC08/MC07,4) END AS float) 单价 ,MC08 库存金额,LEFT(MB001,1) 料别   FROM ZJRD.dbo.[Fn_GetKCMX]('20230930','') MX join ZJRD.dbo.CMSMC on MX.MC02=CMSMC.MC001 join ZJRD..INVMB ON MB001=MC01 left join RDSJK..Material_zlwz on MB001=PH where CMSMC.MC004='1'  
/*浙江库存**/



/*安徽库存**/
SELECT MB001 品号,MB002 品名,MB003 规格,MB004 单位,
case WHEN isnull(PH,'')<>'' and CMSMC.UDF01 LIKE '%良品%' THEN 'AAA'  ELSE MC02 end 仓库编号,case WHEN isnull(PH,'')<>'' and CMSMC.UDF01 LIKE '%良品%' THEN '战略物资'  ELSE MC002 end 仓库名称
--MC02 仓库编号,MC002 仓库名称

,MC07 库存数量, CAST(CASE MC07 WHEN 0 THEN 0 ELSE ROUND(MC08/MC07,4) END AS float) 单价 ,MC08 库存金额,LEFT(MB001,1) 料别   FROM [AHRD].dbo.[Fn_GetKCMX]('20230930','') MX join [AHRD].dbo.CMSMC on MX.MC02=CMSMC.MC001 join AHRD..INVMB ON MB001=MC01 left join RDSJK..Material_zlwz on MB001=PH where CMSMC.MC004='1'  
/*安徽库存**/



select *from    RDSJK..Material_zlwz

--select  *  from  LSSJ..KCSJHS

drop table #CPKC

SELECT MB001, 品名, 规格, 客户名称 仓库编号 , 分析原因  仓库名称,  总库存,  库存金额  into #CPKC
FROM LSSJ.dbo.KCSJHS where LEFT(MB001,1) IN ('1','A') and  物料状态='良品'



alter table #CPKC add 客户编号 VARchar(20)
alter table #CPKC add 客户全称 VARchar(80)
alter table #CPKC add 部门编号 VARchar(10)
alter table #CPKC add 部门全称 VARchar(60)
alter table #CPKC add 所在地 VARchar(60)
alter table #CPKC add 单价  numeric(15,7)


insert into #CPKC
SELECT MC01,MB002,MB003,MC02,MC002,MC07,MC08,'','','','','浙江',0 FROM  ZJRD.dbo.[Fn_GetKCMX]('20210131','') MX join  ZJRD.dbo.CMSMC on MX.MC02=CMSMC.MC001
join ZJRD..INVMB ON MC01=MB001  where CMSMC.MC004='1' and CMSMC.MC018='Y' and CMSMC.UDF01 like '%-良品' and LEFT(MC01,1) IN ('1','A')

insert into #CPKC
SELECT MC01,MB002,MB003,MC02,MC002,MC07,MC08,'','','','','安徽',0 FROM  AHRD.dbo.[Fn_GetKCMX]('20210131','') MX join  AHRD.dbo.CMSMC on MX.MC02=CMSMC.MC001
join AHRD..INVMB ON MC01=MB001  where CMSMC.MC004='1' and CMSMC.MC018='Y' and CMSMC.UDF01 like '%-良品' and  LEFT(MC01,1) IN ('1','A')
--select *from  #CPKC
--SELECT TOP 1 MB001, 品名, 规格, 备注, 物料状态, 所属事业部, 客户名称, 分析原因, 总计, 总库存, 单价, 库存金额,CPZL004,CPZL006,CPZL007,CPZL008 
--FROM LSSJ.dbo.KCSJHS 
--LEFT  JOIN  (select CPZL001,CPZL004,CPZL005,CPZL006,CPZL007,CPZL008,MAX(CREATE_NUM) NUM from  web_lnk.RDSJK.dbo.CPZLB  group by  CPZL001,CPZL004,CPZL005,CPZL006,CPZL007,CPZL008) AS ZLB
--ON MB001=CPZL001
--where LEFT(MB001,1) IN ('1','A')  



--select * from web_lnk.RDSJK.dbo.CPZLB 

--SELECT TOP 1 MB001, 品名, 规格,  客户名称 仓库编号 , 分析原因  仓库名称, 总计, 总库存, 单价, 库存金额,ZLB.*
--FROM LSSJ.dbo.KCSJHS 
--LEFT  JOIN  (select CPZL001,CPZL004,CPZL005,CPZL006,CPZL007,CPZL008,MAX(CREATE_NUM) NUM from  web_lnk.RDSJK.dbo.CPZLB  group by  CPZL001,CPZL004,CPZL005,CPZL006,CPZL007,CPZL008) AS ZLB
--ON MB001=CPZL001
--where LEFT(MB001,1) IN ('1','A') 



--select *from  #CPKC join (select TC004,TC005,TD004,MAX(RQ) RQ from (
--select TC004,TC005,TD004,MAX(TC003) RQ from  COPTC JOIN  COPTD ON TC001=TD001 AND TC002=TD002 where LEFT(TD004,1) IN ('1','A')  GROUP BY TC004,TC005,TD004
--union all
--select TG004,TG005,TH004,MAX(TG003) from  COPTG JOIN  COPTH ON TG001=TH001 AND TG002=TH002 where LEFT(TH004,1) IN ('1','A')  GROUP BY TG004,TG005,TH004 
--) as BMKH GROUP BY TC004,TC005,TD004 ) as KH on MB001=TD004



--alter table #CPKC add 客户编号 VARchar(20)
--alter table #CPKC add 客户全称 VARchar(60)
--alter table #CPKC add 部门编号 VARchar(10)
--alter table #CPKC add 部门全称 VARchar(60)
--alter table #CPKC add 所在地 VARchar(60)


UPDATE  #CPKC SET
  客户编号=TC004,客户全称=MA003 , 部门编号=MA015, 部门全称=ME002,所在地='顺德',单价=TD011
 from  #CPKC join (select TC004,TD004,MAX(RQ) RQ,TD011 from (
select TC004,TD004,MAX(TC003) RQ,TD011 from  SDRD..COPTC JOIN  SDRD..COPTD ON TC001=TD001 AND TC002=TD002 where LEFT(TD004,1) IN ('1','A')  GROUP BY TC004,TD004,TD011
union all
select TG004,TH004,MAX(TG003),TH012 from  SDRD..COPTG JOIN  SDRD..COPTH ON TG001=TH001 AND TG002=TH002 where LEFT(TH004,1) IN ('1','A')  GROUP BY TG004,TG005,TH004 ,TH012
) as BMKH GROUP BY TC004,TD004,TD011 ) as KH on MB001=TD004
 LEFT  join SDRD..COPMA ON MA001=TC004 LEFT JOIN SDRD..CMSME ON ME001=MA015 where (部门全称 is null or 部门全称='')

 
UPDATE  #CPKC SET
  客户编号=TC004,客户全称=MA003 , 部门编号=MA015, 部门全称=ME002,所在地='浙江',单价=TD011
 from  #CPKC join (select TC004,TD004,MAX(RQ) RQ,TD011 from (
select TC004,TD004,MAX(TC003) RQ,TD011 from  ZJRD..COPTC JOIN  ZJRD..COPTD ON TC001=TD001 AND TC002=TD002 where LEFT(TD004,1) IN ('1','A')  GROUP BY TC004,TD004,TD011
union all
select TG004,TH004,MAX(TG003),TH012 from  ZJRD..COPTG JOIN  ZJRD..COPTH ON TG001=TH001 AND TG002=TH002 where LEFT(TH004,1) IN ('1','A')  GROUP BY TG004,TG005,TH004 ,TH012
) as BMKH GROUP BY TC004,TD004,TD011 ) as KH on MB001=TD004
 LEFT  join ZJRD..COPMA ON MA001=TC004 LEFT JOIN ZJRD..CMSME ON ME001=MA015 where (部门全称 is null or 部门全称='')

 
UPDATE  #CPKC SET
  客户编号=TC004,客户全称=MA003 , 部门编号=MA015, 部门全称=ME002,所在地='安徽',单价=TD011
 from  #CPKC join (select TC004,TD004,MAX(RQ) RQ,TD011 from (
select TC004,TD004,MAX(TC003) RQ,TD011 from  AHRD..COPTC JOIN  AHRD..COPTD ON TC001=TD001 AND TC002=TD002 where LEFT(TD004,1) IN ('1','A')  GROUP BY TC004,TD004,TD011
union all
select TG004,TH004,MAX(TG003),TH012 from  AHRD..COPTG JOIN  AHRD..COPTH ON TG001=TH001 AND TG002=TH002 where LEFT(TH004,1) IN ('1','A')  GROUP BY TG004,TG005,TH004 ,TH012
) as BMKH GROUP BY TC004,TD004,TD011 ) as KH on MB001=TD004
 LEFT  join AHRD..COPMA ON MA001=TC004 LEFT JOIN AHRD..CMSME ON ME001=MA015 where (部门全称 is null or 部门全称='')




 --SELECT *FROM  #CPKC  where (客户编号 is null or 客户编号='')



UPDATE  #CPKC SET
  客户编号=CPZL004,客户全称=CPZL006 , 部门编号=CPZL007, 部门全称=CPZL008,所在地='顺德' 
FROM #CPKC
LEFT  JOIN  (select CPZL001,CPZL004,CPZL005,CPZL006,CPZL007,CPZL008,MAX(CREATE_NUM) NUM from  web_lnk.RDSJK.dbo.CPZLB  group by  CPZL001,CPZL004,CPZL005,CPZL006,CPZL007,CPZL008) AS ZLB
ON MB001=CPZL001
where  (客户编号 is null or 客户编号='') and CPZL004 <>''



UPDATE  #CPKC SET
  客户编号=CPZL004,客户全称=CPZL006 , 部门编号=CPZL007, 部门全称=CPZL008,所在地='浙江' 
FROM #CPKC
LEFT  JOIN  (select CPZL001,CPZL004,CPZL005,CPZL006,CPZL007,CPZL008,MAX(CREATE_NUM) NUM from  web_lnk.RDSJK.dbo.ZJCPZLB  group by  CPZL001,CPZL004,CPZL005,CPZL006,CPZL007,CPZL008) AS ZLB
ON MB001=CPZL001
where  (客户编号 is null or 客户编号='') and CPZL004 <>''


UPDATE  #CPKC SET
  客户编号=CPZL004,客户全称=CPZL006 , 部门编号=CPZL007, 部门全称=CPZL008,所在地='浙江' 
FROM #CPKC
LEFT  JOIN  (select CPZL001,CPZL004,CPZL005,CPZL006,CPZL007,CPZL008,MAX(CREATE_NUM) NUM from  web_lnk.RDSJK.dbo.AHCPZLB  group by  CPZL001,CPZL004,CPZL005,CPZL006,CPZL007,CPZL008) AS ZLB
ON MB001=CPZL001
where  (客户编号 is null or 客户编号='') and CPZL004 <>''





 update #CPKC  set 单价 = 库存金额/总库存*1.30 where (isnull(单价,0)=0) and 总库存>0
update #CPKC  set 库存金额 = 单价*总库存 

select left(规格,Charindex('-',规格,0)),* from #CPKC  where (部门全称 is null or 部门全称='')

 select left(规格,Charindex('-',规格,0)) ,* from #CPKC  where (部门全称 <>'')



 
select left(A.规格,Charindex('-',A.规格,0)),* from #CPKC A
join 
#CPKC B on left(A.规格,Charindex('-',A.规格,0))=left(B.规格,Charindex('-',B.规格,0))
 where (A.部门全称 is null or A.部门全称='') AND  (B.部门全称 <>'')

 update  A set 部门全称=B.部门全称  from #CPKC A
join 
#CPKC B on left(A.规格,Charindex('-',A.规格,0))=left(B.规格,Charindex('-',B.规格,0))
 where ( (A.部门全称 is null or A.部门全称='') or A.部门全称 in('市场二部销售二部','市场二部销售一部','市场三部销售二部','市场三部销售三部','事业三部市场部')) AND  (B.部门全称 <>''
 and  B.部门全称 not in('市场二部销售二部','市场二部销售一部','市场三部销售二部','市场三部销售三部','事业三部市场部')
 )


 
 SELECT *FROM  #CPKC  where (isnull(单价,0)<>0) and 总库存>0



SELECT MB001 品号,MB002 品名,MB003 规格,MB004 库存单位,MB017 主要仓库,MB064 库存数量
FROM INVMB 
WHERE MB019 = 'Y' ORDER BY MB017 ASC