--1.月初工单负领料查询sql,查询出审核到下月的领退料单
--2.将领退料单对应的工单状态改为未完工的状态
--3.将领退料单的工单属性改为不核对工单
--4.在ERP中批量查询出这些领退料单，批量撤销审核
--5.执行update语句将领退料单的单据时间改为当月月底如：20220531
--6.在ERP中批量查询出这些领退料单，批量审核
--7.update语句将工单状态改成临时表中查出来的状态
--最后记得将工单属性改为核对工单
---------------------------------------------- 第一步----------------------------------------------
--drop table #tempWO
--drop table #tempWO
declare @date date
set @date='2024-11-30'-- 
--,sum(TG011)TG011
select distinct TG014 as WOID,TG015 WONO
into #tempWO
from MOCTG
join MOCTF on TG001=TF001 and TG002=TF002
where TG022='Y'
and convert(date,TF003,0) between DateAdd(Month,-1,@date) and DateAdd(Month,1,@date)
--group by TG014,TG015
--select * From #tempWO where WOID='5102' and WONO='20211227017'

insert into #tempWO
select distinct TE011,TE012 
From MOCTC 
join MOCTE on TC001=TE001 and TC002=TE002
join INVLA on TE001=LA006 and TE002=LA007 and TE003=LA008
where convert(date,LA004,0) between DateAdd(Month,-1,@date) and DateAdd(Month,1,@date)
and not exists(select * from #tempWO where WOID=TE011 and WONO=TE012)



--drop table #tempWO1
select WO.WOID,WO.WONO,sum(isnull(LA011,0)) Qty1
into #tempWO1
from #tempWO WO 
left join MOCTG TG on TG.TG014=WO.WOID and TG.TG015=WO.WONO
left join MOCTF TF on TG.TG001=TF.TF001 and TG.TG002=TF.TF002
left join INVLA on LA006=TG001 and LA007=TG002 and LA008=TG003 and convert(date,TF003,0) <= DateAdd(Day,-1,@date)
where 1=1
--and exists(select '*' from #tempWO T where T.WOID=TG.TG014 and T.WONO=TG.TG015)
group by WO.WOID,WO.WONO
--select * From #tempWO1 where WOID='5102' and WONO='20211227017'


--DROP table #temp1
select TB001,TB002,TB003,TB006
,(case  when TA015=0 then 0 else TB004/TA015*WO.Qty1 end) Qty_Need  --
,sum(-1*isnull(LA011,0)*isnull(LA005,0)) Qty_Pick
,TA011,TA014
into #temp
from MOCTA 
join MOCTB on TA001=TB001 and TA002=TB002 and TB011<>'4'
join #tempWO1 WO on TA001=WOID and TA002=WONO
left join MOCTE on TE011=TB001 and TE012=TB002 and TE004=TB003 and TE009=TB006
left join INVLA on TE001=LA006 and TE002=LA007 and TE003=LA008 and convert(date,LA004,0)<=DateAdd(Day,-1,@date)
where TB004>=0 --and TA005>0
group by TB001,TB002,TB003,TB006,TA015
,(case  when TA015=0 then 0 else TB004/TA015*WO.Qty1 end)
,TA011,TA014
--5101        20170306042        303000117900 
--select * From #temp

select TB001,TB002,TB003,TB006
,(case  when TA015=0 then 0 else TB004/TA015*WO.Qty1 end) Qty_Need  --
,sum(-1*isnull(LA011,0)*isnull(LA005,0)) Qty_Pick
,TA011,TA014
into #temp1
from MOCTA 
join MOCTB on TA001=TB001 and TA002=TB002 and TB011<>'4'
join #tempWO1 WO on TA001=WOID and TA002=WONO
left join MOCTE on TE011=TB001 and TE012=TB002 and TE004=TB003 and TE009=TB006
left join INVLA on TE001=LA006 and TE002=LA007 and TE003=LA008 
where TB004>=0 --and TA005>0
group by TB001,TB002,TB003,TB006,TA015
,(case  when TA015=0 then 0 else TB004/TA015*WO.Qty1 end)
,TA011,TA014


select TB001 '单头' ,TB002 '单号' ,TB003 '物料',TB006 '工艺',Qty_Need '需求量',Qty_Pick '领用量',Qty_Need-Qty_Pick '差异',TA011 '工单状态' ,TA014 '完工日期' from #temp1 where Qty_Need>Qty_Pick

select * from #temp 
where 1=1
--and TB001='5101' and TB002='20220311082'
and Qty_Need-Qty_Pick>0
--and UPPER(TA011)='Y'
--and Convert(date,TA014,0)>=@date


----------------------------------------------end 第一步----------------------------------------------
drop table #tempWO
drop table #tempWO1
drop table #temp
drop table #temp1





select * from #temp


--查询工单跨月审核的领退料单
--select distinct TC.TC001+TC.TC002 ,TC.TC003,TC.TC009 ,t.TB001+t.TB002,t.TA011

DROP TABLE  #temptc
select distinct TC.TC001 TC01,TC.TC002 TC02, '20261031' TC03,TC.TC003,TC.TC009 ,t.TB001,t.TB002,t.TA011
INTO #temptc
from #temp t
left join MOCTE TE  on t.TB001=TE.TE011 and t.TB002=TE.TE012 and TE.TE004=t.TB003 and TE.TE009=t.TB006
left join MOCTC TC on TC.TC001=TE.TE001 and TC.TC002=TE.TE002
where TC.TC003>='20231001' 
and  Qty_Need-Qty_Pick>0
 --and TB001='5101' and TB002='20220311082'

 --将工单状态改成未完工状态
 update MOCTA
set  MOCTA.TA011='N'
	--MOCTA.TA011=T.TA011 --set TA011='Y'
--select * --distinct T.TB001+T.TB002
 from #temp T join dbo.MOCTA MOCTA on T.TB001=MOCTA.TA001 and T.TB002=MOCTA.TA002   and  Qty_Need-Qty_Pick>0
 --where MOCTA.TA001+MOCTA.TA002 in('510120220412071','510120220326055')
 --将领料单改成上月月底
 update MOCTC 
 set TC003='20261031'
 --select * from MOCTC
  where TC001+TC002 in
  (
'547120231000002',
''
)
and TC001+TC002 like '54%'
and TC009='N'

SELECT *FROM  #temptc


SELECT*FROM MOCTC JOIN  #temptc ON TC001=TC01 AND TC002=TC02
UPDATE MOCTC SET TC003=TC03 , TC014=TC03  FROM MOCTC JOIN  #temptc ON TC001=TC01 AND TC002=TC02

SELECT *FROM INVLA JOIN #temptc ON  LA006=TC01 AND LA007=TC02
UPDATE INVLA SET LA004=TC03  FROM INVLA JOIN #temptc ON  LA006=TC01 AND LA007=TC02

SELECT  TOP 100*FROM   MOCTE ORDER BY TE002 DESC



select * from MOCTC join INVLA on TC001=LA006 and TC002=LA007 
update MOCTC set TC003=LA004 from MOCTC join INVLA on TC001=LA006 and TC002=LA007 

select * from MOCTC where TC003='20220731' and TC016<>'Y'
update MOCTC set TC003=TC014 where TC003='20220731' and TC016<>'Y'


 update MOCTC 
 set TC003='20221101' where TC001+TC002 in
 ('540220221100050',
 '540220221100051')












 
----DROP table #temp1
--select TB001,TB002,TB003,TB006
--,(case  when TA015=0 then 0 else TB004/TA015*WO.Qty1 end) Qty_Need  --
--,sum(-1*isnull(LA011,0)*isnull(LA005,0)) Qty_Pick
--,TA011,TA014
--into #temp
--from MOCTA 
--join MOCTB on TA001=TB001 and TA002=TB002 and TB011<>'4'
--join #tempWO1 WO on TA001=WOID and TA002=WONO
--left join MOCTE on TE011=TB001 and TE012=TB002 and TE004=TB003 and TE009=TB006
--left join INVLA on TE001=LA006 and TE002=LA007 and TE003=LA008 and convert(date,LA004,0)<=DateAdd(Day,-1,@date)
--where TB004>=0 --and TA005>0
--group by TB001,TB002,TB003,TB006,TA015
--,(case  when TA015=0 then 0 else TB004/TA015*WO.Qty1 end)
--,TA011,TA014




--select TB001,TB002,TB003,TB006
--,(case  when TA015=0 then 0 else TB004/TA015*WO.Qty1 end) Qty_Need  --
--,sum(-1*isnull(LA011,0)*isnull(LA005,0)) Qty_Pick
--,TA011,TA014
--into #temp1
--from MOCTA 
--join MOCTB on TA001=TB001 and TA002=TB002 and TB011<>'4'
--join #tempWO1 WO on TA001=WOID and TA002=WONO
--left join MOCTE on TE011=TB001 and TE012=TB002 and TE004=TB003 and TE009=TB006
--left join INVLA on TE001=LA006 and TE002=LA007 and TE003=LA008 
--where TB004>=0 --and TA005>0
--group by TB001,TB002,TB003,TB006,TA015
--,(case  when TA015=0 then 0 else TB004/TA015*WO.Qty1 end)
--,TA011,TA014



--SELECT *FROM  SDRD..INVLA WHERE   LA024 = '5101-20241113007'




--SELECT *FROM  SDRD..INVLA WHERE LA004 LIKE '202411%' and  LA024 like '5%'


--SELECT *FROM INVLA WHERE LA004 LIKE '202411%'  AND LEFT(LA006,2) IN('58','56') and LA024 like '5%'




--SELECT *FROM  dbo.MOCTA WHERE TA001+'-'+TA002 IN(
--SELECT distinct LA024 FROM INVLA WHERE LA004 LIKE '202411%'  AND LEFT(LA006,2) IN('58','56') and LA024 like '5%')




/**负领料处理***/



--SELECT *FROM  dbo.MOCTA WHERE TA001+'-'+TA002 IN(
DROP TABLE #GDRK


SELECT  
	LA024 AS GDDH,--对象 工单单号 Manufacturing Order MO_TYPE_NO
	SUM(LA011) AS RKSL --单据交易库存数量 入库数量 RECEIVED_QTY
INTO 
	#GDRK --工单入库
FROM 
	INVLA --交易明细信息档
WHERE 
	LA004 BETWEEN '20261001' AND '20261031' --日期
	AND LEFT(LA006,2) IN('58','56') --单别（入库）
	AND LEFT(LA024,1) = '5' --对象
GROUP BY LA024 --对象



--SELECT *FROM  #GDRK GD left JOIN (
--SELECT GDDH,SUM(LA011) SL FROM #GDRK JOIN INVLA  ON LA024=GDDH  WHERE LA004 <= '20261031'  AND LEFT(LA006,2) IN('58') and LA024 like '5%' GROUP BY GDDH) AS RK ON GD.GDDH=RK.GDDH

--递归更新临时表中入库数量为NULL的值
UPDATE GD 
SET RKSL=ISNULL(RK.SL,0)    
FROM  #GDRK GD 
	LEFT OUTER JOIN (
		SELECT 
			GDDH,
			SUM(LA011) AS SL 
		FROM 
			#GDRK 
			INNER JOIN INVLA  
			ON LA024=GDDH  
		WHERE 
			LA004 <= '20261031'  
			AND LEFT(LA006,2) = '58' --
			AND LEFT(LA024,1) = '5'
		GROUP BY GDDH
	) AS RK --RECEIVED_QTY 入库
	ON GD.GDDH=RK.GDDH

--SELECT *FROM  #GDRK


--  UPDATE  GD SET LLSL=ISNULL(RK.SL,0)    FROM  #GDRK GD left JOIN (
--SELECT GDDH,SUM(LA011) SL FROM #GDRK JOIN INVLA  ON LA024=GDDH  WHERE LA004 <= '20261031'  AND LEFT(LA006,2) IN('54','56') and LA024 like '5%' GROUP BY GDDH) AS RK ON GD.GDDH=RK.GDDH


--SELECT *FROM #GDRK WHERE GDDH='5102-20230517023'


--SELECT TE.* FROM MOCTC JOIN MOCTE TE ON TC001=TE001 AND TC002=TE002 WHERE TC003<='20261031'  AND   TE011='5102' and TE012='20230517023' and TE004='300080145700        ' and TE009=TB006


--select TB001,TB002,TB003,TB006
--,(case  when TA015=0 then 0 else TB004/TA015*RKSL end) XQSL  --
--,(ISNULL((CASE WHEN LEFT(TE001,2) ='54' THEN 1 ELSE -1 END ) *TE005,0)) LLS

--,TA011,TA014

--from MOCTA 
--join MOCTB on TA001=TB001 and TA002=TB002 and TB011<>'4'
--join #GDRK WO on GDDH=TA001+'-'+TA002
--left join (SELECT TE.* FROM MOCTC JOIN MOCTE TE ON TC001=TE001 AND TC002=TE002 WHERE TC003<='20261031'  AND TE019='Y' )  WL  on TE011=TB001 and TE012=TB002 and TE004=TB003 and TE009=TB006
--WHERE  TB001+'-'+TB002='5102-20230517023' 
--ORDER BY TB003



DROP TABLE #GDWL --工单未领

SELECT 
	TB001,
	TB002,
	TB003,
	TB006,
	(
		CASE
			WHEN TA015=0 
				THEN 0 
			ELSE TB004/TA015*RKSL 
		END
	) AS XQSL,--实际材料需求数量
	SUM(
		ISNULL(
			(
				CASE WHEN LEFT(TE001,2) ='54' THEN 1 ELSE -1 END 
			) *TE005,
			0
		)
	) AS LLS,--领料数
	TA011,
	TA014
INTO #GDWL -- 工单未领
FROM
	MOCTA --工单单头
	INNER JOIN MOCTB --工单单身
	ON TA001=TB001 
		AND TA002=TB002 
		AND TB011<>'4'--材料类型非不发料
	INNER JOIN #GDRK WO --材料入库明细
	ON GDDH=TA001+'-'+TA002
	LEFT OUTER JOIN (
		SELECT TE.* 
		FROM MOCTC 
			JOIN MOCTE TE 
			ON TC001=TE001 
				AND TC002=TE002 
		WHERE TC003<='20261031'  --领退料日期
			AND TE019='Y' --已审核
	) AS WL  --未领？
	ON TE011=TB001 --单别
		AND TE012=TB002 --单号
		AND TE004=TB003 --品号
		AND TE009=TB006 --工艺
GROUP BY  
	TB001,
	TB002,
	TB003,
	TB006,
	(
		CASE
			WHEN TA015=0 
				THEN 0 
			ELSE TB004/TA015*RKSL --材料单位用量*成品入库数量
		END
	),
	TA011,
	TA014


SELECT * FROM  #GDWL WHERE XQSL>LLS --实际需求数量大于实际领料数量


--AND TB001+'-'+TB002='5102-25051300299'


--DELETE FROM  #GDWL WHERE TB001+'-'+TB002 <>'5102-24091300588'

--SELECT *FROM  #GDWL
--JOIN  (SELECT TE.* FROM MOCTC JOIN MOCTE TE ON TC001=TE001 AND TC002=TE002 WHERE TE019='Y'AND TC003='20231001'  AND TC007 NOT LIKE '%扣出车间仓%'AND TC007 NOT LIKE '%扣出车间仓%' 
--	--AND LEFT(TE.CREATE_DATE,6)<='202411' 
--	AND LEFT(TE.CREATE_DATE,8)<='20231001' 
--)  WL  on TE011=TB001 and TE012=TB002 and TE004=TB003 and TE009=TB006 AND  TE001 LIKE '54%'
--WHERE XQSL>LLS


DROP TABLE #LLD--领料单
SELECT TE001,TE002,TE003 
INTO #LLD  
FROM  #GDWL
INNER JOIN (
	SELECT TE.* 
	FROM MOCTC 
		INNER JOIN MOCTE AS TE 
		ON TC001=TE001 
			AND TC002=TE002 
	WHERE  TE019='Y'
	AND TC003>'20261031'  
	AND TC007 NOT LIKE '%扣出车间仓%'
	AND TC007 NOT LIKE '%扣出车间仓%' 
	AND LEFT(TE.CREATE_DATE,8)<='20261031' 
) AS WL 
ON TE011=TB001 
	AND TE012=TB002 
	AND TE004=TB003 
	AND TE009=TB006 
	AND LEFT(TE001,2) = '54'
WHERE XQSL>LLS

--SELECT *FROM  #LLD JOIN MOCTC  ON  TE001=TC001 AND TE002=TC002 where TC001='5481' AND TC002='20250702007'

UPDATE TC SET TC.TC003='20261031' FROM  #LLD JOIN MOCTC TC  ON  TE001=TC001 AND TE002=TC002
UPDATE LA SET LA004='20261031'  FROM #LLD JOIN INVLA LA ON TE001=LA006 AND TE002=LA007 



--UPDATE TC SET TC.TC003='20261031' FROM   MOCTC TC  where TC003='20261031' 
--update LA set LA004='20261031'  from INVLA LA where LA004='20261031'  


select*from MOCTC JOIN MOCTE ON TC001=TE001 AND TC002=TE002  WHERE  TC007 LIKE '扣出车间仓20261031%' 

SELECT *FROM  MOCTA WHERE EXISTS(
select*from MOCTC JOIN MOCTE ON TC001=TE001 AND TC002=TE002  WHERE  TC007 LIKE '扣出车间仓20261031%'  AND TA001=TE011 AND TA002=TE012)
AND TA011 IN('y','Y')

SELECT *FROM  MOCTA WHERE TA011 IN('y','Y') AND MOCTA.TA012 like '202507%' AND
TA001+TA002 IN(
select TE011+TA012 from MOCTC JOIN MOCTE ON TC001=TE001 AND TC002=TE002  WHERE  TC007 LIKE '扣出车间仓20261031%'  )
AND TA011 IN('y','Y')



SELECT *FROM  MOCTA WHERE EXISTS(
select*from MOCTC JOIN MOCTE ON TC001=TE001 AND TC002=TE002  WHERE  TC007 LIKE '扣出车间仓20261031%'  AND TA001=TE011 AND TA002=TE012)
AND TA011 IN('y','Y')

select*from  MOCTE where exists( select *from  MOCTA where  TA011 IN('y','Y')AND MOCTA.TA012 like '202507%' and   TA001=TE011 AND TA002=TE012 )






select  TA001 TA01,TA002 TA02 INTO #MOC from MOCTA where EXISTS(
select*from SDRD..MOCTC JOIN SDRD..MOCTE ON TC001=TE001 AND TC002=TE002  WHERE  TC007 LIKE '车间仓还原20250701%'  AND TA001=TE011 AND TA002=TE012)
AND TA011 IN('y','')

update   MOCTA SET TA011='2' FROM  #MOC JOIN  MOCTA ON TA001 =TA01 AND  TA002= TA02 