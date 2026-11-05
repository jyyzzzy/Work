
/**20240307获取单据上的单价数据，
临时表:
MonPrice_Update   存储可转月数据检查
LSSJ..LSCGTH    转月单据

1.通知采购出最后一稿采购单价。
2.将对应的采购单号保存，检查交易数量=数量（转月数量）。
3.数量相等，关联采购单上的币种、单价、仓库、汇率。
4.客供无单价，删除数据。
5.查看币种不为RMB的数据，需要通知采购确认是否转月。
6.插入临时表 LSSJ..LSCGTH 更新单号
7.插入采购单据，ERP前端审核。
8.审核完毕生成瑞德采购降价表，提供给采购查看，确认好后财务进行转月计划
*/ 
SELECT * FROM LSSJ..MonPrice_Update WHERE 品号='315009088800'


="insert into  LSSJ..MonPrice_Update(cgdh,品号,供应商,数量,单价)values('"&A2&"','"&B2&"','"&C2&"',"&D2&","&E2&")"

--删除不需要转月的数据:数量对应转月数量
DELETE  LSSJ..MonPrice_Update WHERE ISNULL(数量,0)=0



SELECT * FROM LSSJ..MonPrice_Update WHERE ISNULL(交易数量,0)<>ISNULL(数量,0)

--对应币种、单价、仓库、汇率查询
select cgdh,品号,ISNULL(数量,0),DH,TH018,TG008,TG007,TH009,TH031,TH015,TH054
 from   LSSJ..MonPrice_Update
 JOIN 
 (
 SELECT TH001+'-'+TH002+'-'+TH003 AS DH ,TH015,TH018,TG008,TG007,TH009,TH031,TH054 FROM AHRD.dbo.PURTH JOIN PURTG ON TH001=TG001 AND TH002=TG002
UNION ALL
SELECT TB001+'-'+TB002+'-'+TB003,TB007,TB010,'1.0000000','RMB',TB012 AS DH,'',0 FROM AHRD.dbo.INVTB)A ON cgdh=A.DH
WHERE 品号 IN ('309000002700','309000039900','309000056200','309000057700','309000074400','309000085600','309000089300','309010000600')
and
TH015=TH054

----更新对应币种、单价、仓库、汇率
UPDATE LSSJ..MonPrice_Update SET 单价=TH018,币种=TG007,汇率=TG008
-- select *
from   LSSJ..MonPrice_Update
 JOIN 
 (
 SELECT TH001+'-'+TH002+'-'+TH003 AS DH ,TH018,TG008,TG007,TH009,TH054 FROM AHRD.dbo.PURTH 
 JOIN AHRD.dbo.PURTG ON TH001=TG001 AND TH002=TG002
UNION ALL
SELECT TB001+'-'+TB002+'-'+TB003,TB010,'1.0000000','RMB',TB012 AS DH,'' FROM AHRD.dbo.INVTB)A ON cgdh=A.DH
WHERE LSSJ..MonPrice_Update.cgdh=A.DH
--and 单价<>TH018
 

 DELETE FROM    LSSJ..zjcgrk

 INSERT INTO LSSJ..zjcgrk(cgdh,dj)
  SELECT TH001+'-'+TH002+'-'+TH003 AS DH ,MAX(单价) FROM AHRD.dbo.PURTH 
 JOIN PURTG ON TH001=TG001 AND TH002=TG002  
 JOIN  LSSJ..MonPrice_Update  ON TG005=供应商 and 品号=TH004  
 where  TH001='3471' AND TG016 = '采购月末退货月初进仓' AND TG003='20251201' 
 AND 单价<>TH018 
 GROUP BY TH001+'-'+TH002+'-'+TH003 


INSERT INTO LSSJ..zjcgrk(cgdh,dj) SELECT DISTINCT TJ001+'-'+TJ002+'-'+TJ003 ,MAX(单价)
--select TI004,TJ004,TJ009,(TJ032+TJ033)
 from AHRD..PURTJ INNER JOIN AHRD..PURTI on TI001=TJ001 AND TI002=TJ002 
JOIN  LSSJ..MonPrice_Update  ON TI004=供应商 and 品号=TJ004  
 WHERE TI001='3573'  AND TI003 like '202512%' AND  TJ020 = 'Y' AND TJ009 > 0 and TI012 ='月末批量开退货单' 
 AND 单价<>TJ008 
 GROUP BY TJ001+'-'+TJ002+'-'+TJ003 
 

/**更新仓库*/
update LSSJ..MonPrice_Update  set 仓库=MB017
--select *
from LSSJ..MonPrice_Update  join  AHRD..INVMB on 品号=MB001 


SELECT * FROM  LSSJ..MonPrice_Update-- WHERE 品号='309000002700'

--客供无单价，删除数据
select*from   LSSJ..MonPrice_Update where isnull(单价,0)=0 AND 规格 LIKE '%客供%'
--DELETE from   LSSJ..MonPrice_Update where isnull(单价,0)=0 AND 规格 LIKE '%客供%'

--查看币种不为RMB的数据
--SELECT * FROM LSSJ..MonPrice_Update WHERE 供应商='20533537'
SELECT * FROM LSSJ..MonPrice_Update WHERE 币种<> 'RMB' --AND 品号='305030034200'
--DELETE FROM LSSJ..MonPrice_Update WHERE 币种='USD'
--插入转月临时表
delete FROM LSSJ..LSCGTH

INSERT LSSJ..LSCGTH (单号,序号,供应商,品号,单价,数量,仓库,币种,汇率)
SELECT '20260930001','0001',供应商,品号,单价,SUM(数量 )数量,仓库,币种,汇率 FROM  LSSJ..MonPrice_Update INNER JOIN AHRD..PURMA ON 供应商 = PURMA.MA001
GROUP BY 供应商,品号,单价,仓库,币种,汇率 

SELECT * FROM LSSJ..LSCGTH 
ORDER BY 单号,序号
--更新单号
declare @No int--单号编号
declare @FormNo varchar(11)--单号前缀

set @FormNo='202609'--本月月份
select @No=right(rtrim(isnull(MAX(TI002),'00000')),5) FROM AHRD..PURTI  where TI001='3573' and left(TI002,6)=@FormNo

 update B set 单号=xindan ,序号=xinxu
  --select xindan ,xinxu,*
 from (select 单号 dan,序号 xu,@FormNo + right(cast((100000+@No+DENSE_RANK() OVER(ORDER BY 供应商 asc,币种,汇率 )) as varchar(6)),5) xindan,10000+ROW_NUMBER() over(partition by  供应商,币种,汇率  order by 品号) xinxu,品号 ph,供应商 gys,币种 bz,汇率 hl,单价 dj,数量 sl
FROM  LSSJ..LSCGTH) AS A join LSSJ..LSCGTH B on  单号=A.dan AND 品号= ph and 供应商= gys and 币种= bz and 汇率 =hl and 数量=sl AND 单价=dj


--转月数据检查开始
SELECT * FROM LSSJ..LSCGTH ORDER BY 单号,序号
SELECT SUM(数量) FROM LSSJ..LSCGTH 
--

UPDATE LSSJ..LSCGTH SET 序号 = RIGHT(序号,4)

--查看供应商是否存在基础资料中
SELECT 供应商 from LSSJ.dbo.LSCGTH 
WHERE NOT EXISTS(
	SELECT 1 FROM AHRD.dbo.PURMA WHERE 供应商=MA001
)

--查看品号是否存在基础资料中
SELECT * FROM LSSJ..LSCGTH WHERE 品号 NOT IN (SELECT  MB001 FROM AHRD..INVMB) 

--查看本月最大单号
select MAX(TI002) FROM AHRD..PURTI  where TI001='3573'  AND TI002 LIKE '202609%'

select * from   LSSJ..LSCGTH WHERE 单号='20240300046'
 
select * from   LSSJ..LSCGTH WHERE  汇率<>1

select DISTINCT 单号 from   LSSJ..LSCGTH order  by 单号 DESC

SELECT DISTINCT TI002 FROM dbo.PURTI WHERE TI001='3505' AND CREATE_DATE='20231130113934473'


--采购退货单头
insert into AHRD.dbo.PURTI
	(COMPANY,CREATOR,USR_GROUP,CREATE_DATE,MODIFIER,MODI_DATE,FLAG,
TI001,TI002,TI003,TI004,TI005,TI006,TI007,TI008,TI009,TI010,
TI011,TI012,TI013,TI014,TI015,TI016,TI017,TI018,TI019,TI020,
TI021,TI022,TI023,TI024,TI025,TI026,TI027,TI028,TI029,TI030,
TI031,TI032,TI033,TI034,TI035,TI036,TI037,TI038,TI039,TI040,
TI041,TI042,TI043,TI044,TI045,
UDF01,UDF02,UDF03,UDF04,UDF05,UDF06,UDF51,UDF52,UDF53,UDF54,UDF55,UDF56) 
SELECT
'0001','10105978','90001',FORMAT(GETDATE(), 'yyyyMMddHHmmssfff')
,'','',1,
'3573',单号,'20260930',供应商,'000301','RMB',1,'S','1',0,
SUM(单价*数量)/1.13,'月末批量开退货单','N','20260930',SUM(单价*数量)-SUM(单价*数量)/1.13,PURMA.MA003,PURMA.MA005,'','',''
,0,SUM(数量),'','N','','',0.13,SUM(单价*数量)/1.13,SUM(单价*数量)-SUM(单价*数量)/1.13,PURMA.MA055
,0,'N','',0,'N','N','','','','N'
,'N','',0,0,0,'','','','','','',0,0,0,0,0,0
FROM LSSJ..LSCGTH INNER JOIN AHRD..PURMA ON 供应商 = PURMA.MA001
INNER JOIN AHRD..INVMB ON 品号 = INVMB.MB001  where 单价 is not null
GROUP BY 单号,供应商,PURMA.MA003,PURMA.MA055,PURMA.MA005


 
--采购退货单身
insert into AHRD..PURTJ
  (COMPANY, CREATOR, USR_GROUP, CREATE_DATE, MODIFIER, MODI_DATE, FLAG,
	TJ001,TJ002,TJ003,TJ004,TJ005,TJ006,TJ007,TJ008,TJ009,TJ010
	,TJ011,TJ012,TJ013,TJ014,TJ015,TJ016,TJ017,TJ018,TJ019,TJ020,
	TJ021,TJ022,TJ023,TJ024,TJ025,TJ026,TJ027,TJ028,TJ029,TJ030,
	TJ031,TJ032,TJ033,TJ034,TJ035,TJ036,TJ037,TJ038,TJ039,TJ040,

	TJ041,TJ042,TJ043,TJ044,TJ045,TJ046,TJ047,TJ048,TJ049,TJ050,
	TJ051,TJ052,TJ053,TJ054,TJ055,TJ056,
	UDF01,UDF02,UDF03,UDF04,UDF05,UDF06,UDF51,UDF52,UDF53,UDF54,UDF55,UDF56)
SELECT 
'0001','10105978','90001',FORMAT(GETDATE(), 'yyyyMMddHHmmssfff')
,'','',1,
'3573',单号,序号,品号,INVMB.MB002,INVMB.MB003,INVMB.MB004,单价,数量,单价*数量
,仓库,'********************','','','','','','','','N'
,'N',数量,'',0,'','','','N','',单价*数量/1.13
,单价*数量-单价*数量/1.13,单价*数量/1.13,单价*数量-单价*数量/1.13,'','1',0,'','',0,0

,0.13,'','','','','##########',INVMB.MB004,数量,INVMB.MB004,''
,'','',0,0,0,''
,'','','','','','',0,0,0,0,0,0
FROM LSSJ..LSCGTH INNER JOIN AHRD..PURMA ON 供应商 = PURMA.MA001
INNER JOIN AHRD..INVMB ON 品号 = INVMB.MB001 where   isnull(单价,0)>0


SELECT * FROM PURTI ORDER BY CREATE_DATE DESC