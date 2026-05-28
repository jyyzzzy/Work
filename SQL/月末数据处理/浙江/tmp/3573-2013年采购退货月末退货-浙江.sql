
----更新对应币种、单价、仓库、汇率
UPDATE LSSJ..MonPrice_Update SET 单价=TH018,币种=TG007,汇率=TG008
 from   LSSJ..MonPrice_Update
 JOIN 
 (
 SELECT TH001+'-'+TH002+'-'+TH003 AS DH ,TH018,TG008,TG007,TH009 FROM ZJRD.dbo.PURTH JOIN PURTG ON TH001=TG001 AND TH002=TG002
UNION ALL
SELECT TB001+'-'+TB002+'-'+TB003,TB010,'1.0000000','RMB',TB012 AS DH FROM ZJRD.dbo.INVTB)A ON cgdh=A.DH
WHERE LSSJ..MonPrice_Update.cgdh=A.DH

/**更新仓库*/
update LSSJ..MonPrice_Update  set 仓库=MB017
from LSSJ..MonPrice_Update  join  ZJRD..INVMB on 品号=MB001 

--插入转月临时表
delete FROM LSSJ..LSCGTH
INSERT LSSJ..LSCGTH (单号,序号,供应商,品号,单价,数量,仓库,币种,汇率)
SELECT '20260231001','0001',供应商,品号,单价,SUM(数量 )数量,仓库,币种,汇率 
FROM  LSSJ..MonPrice_Update
INNER JOIN SDRD..PURMA ON 供应商 = PURMA.MA001
GROUP BY 供应商,品号,单价,仓库,币种,汇率

SELECT * FROM LSSJ..LSCGTH
SELECT distinct 单号 FROM LSSJ..LSCGTH
--delete FROM LSSJ..LSCGTH

--UPDATE LSSJ..LSCGTH SET 序号 = RIGHT(序号,4)

UPDATE LSSJ..LSCGTH SET 单号 = replace(单号,'202602','202602')

select*from  LSSJ..LSCGTH where isnull(品号,'')=''
update    LSSJ..LSCGTH set 品号='315009263400' where isnull(品号,'')=''

/**主要仓库**/
 update LSSJ..LSCGTH set 仓库=MB017
  --select *
  from LSSJ..LSCGTH join  INVMB on 品号=MB001   --and  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) 
/**主要仓库**/


/**赋值最后一次交易单价*/

UPDATE  B SET  单价=dj,币种=TG007,汇率=TG008
-- select*
from LSSJ..LSCGTH B join  (
select TH014,TG005,TH004,TG007,TG008,max(cast((TH048+TH047)/TH015 as numeric(18,6))) dj FROM ZJRD..PURTH INNER JOIN ZJRD..PURTG on TH001=TG001 AND TH002=TG002 
WHERE TH030 = 'Y' AND TH016 > 0 AND ( TH001= '3471'OR TH001= '3405' ) AND TH014 like '202602%'   AND TH014+TG005+TH004  IN(
select MAX(TH014)+TG005+TH004  FROM ZJRD..PURTH INNER JOIN ZJRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 AND ( TH001= '3471' OR TH001= '3405') AND TH014 like '202602%'
AND TG007='RMB'
group by TG005,TH004 )group by TH014,TG005,TH004,TG007,TG008) as jhdj on TG005=供应商 and  品号=TH004 


UPDATE  B SET  单价=dj,币种=TG007,汇率=TG008
-- select*
from LSSJ..LSCGTH B join  (
select TH014,TG005,TH004,TG007,TG008,max(cast((TH048+TH047)/TH015 as numeric(18,6))) dj FROM ZJRD..PURTH INNER JOIN ZJRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 
--AND ( TH001= '3471'OR TH001= '3405' ) AND TH014 like '201908%'
--AND TG007='RMB'
 AND TH014+TG005+TH004  IN(
select MAX(TH014)+TG005+TH004  FROM ZJRD..PURTH INNER JOIN ZJRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 
--AND TG007='RMB'
--AND ( TH001= '3471' OR TH001= '3405') AND TH014 like '201908%'
group by TG005,TH004 )group by TH014,TG005,TH004,TG007,TG008) as jhdj on TG005=供应商 and  品号=TH004 AND  isnull(单价,0)=0

select*from   LSSJ..LSCGTH where  isnull(单价,0)=0
--update   LSSJ..LSCGTH set 单价=0
DELETE from   LSSJ..LSCGTH where  isnull(单价,0)=0
select sum(数量*单价) from LSSJ..LSCGTH

 update   LSSJ..LSCGTH set 仓库=StorageID
  --select *
  from     LSSJ..LSCGTH join  SDRD..v_Material_Checked on MaterialID=品号 where   ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) 

update LSSJ..LSCGTH set 仓库=ck from  LSSJ..LSCGTH join  (select MC01,min(MX.MC02) ck from [Fn_GetKCMX]('20260231','')  MX join  ZJRD.dbo.CMSMC on MX.MC02=CMSMC.MC001 where CMSMC.MC004='1' and CMSMC.MC018='Y' and CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%'AND CMSMC.MC002 not like '%非ROHS%'AND CMSMC.MC002 not like '%辅料%' AND MC07>0 group by  MC01) as sj on 品号=MC01

update LSSJ..LSCGTH set 仓库=ck from  LSSJ..LSCGTH join  (select MC01,min(MX.MC02) ck from [Fn_GetKCMX]('20260231','')  MX join  ZJRD.dbo.CMSMC on MX.MC02=CMSMC.MC001 where CMSMC.MC004='1' and CMSMC.MC018='Y' and CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%'AND CMSMC.MC002 not like '%非ROHS%'  AND MC07>0 group by  MC01) as sj on 品号=MC01 and isnull(仓库,'')=''

update LSSJ..LSCGTH set 仓库=ck from  LSSJ..LSCGTH join  (select MC01,min(MX.MC02) ck from [Fn_GetKCMX]('20260231','')  MX join  ZJRD.dbo.CMSMC on MX.MC02=CMSMC.MC001 where CMSMC.MC004='1' and CMSMC.MC018='Y' and CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%' AND MC07>0 group by  MC01) as sj on 品号=MC01 and isnull(仓库,'')=''




/**主要仓库**/
 update LSSJ..LSCGTH set 仓库=MB017
  --select *
  from LSSJ..LSCGTH join  INVMB on 品号=MB001  
/**主要仓库**/
select*from   LSSJ..LSCGTH where isnull(仓库,'')=''
select*from   LSSJ..LSCGTH where  数量>0 AND 单价>0
update LSSJ..LSCGTH set 单号=20260200001 where  isnull(单号,'')=''  
/**赋值最后一次交易单价*/

select*from   LSSJ..LSCGTH WHERE 品号='361010049700'
update   LSSJ..LSCGTH set 供应商='20900079'  WHERE 品号='361010049700'



declare @No int--单号编号
declare @FormNo varchar(11)--单号前缀

set @FormNo='202602'--本月月份
select @No=right(rtrim(isnull(MAX(TI002),'00000')),5) FROM ZJRD..PURTI  where TI001='3573' and left(TI002,6)=@FormNo

select @No
 update B set 单号=xindan ,序号=xinxu
 -- select xindan ,xinxu 
 from (select 单号 dan,序号 xu,@FormNo + right(cast((100000+@No+DENSE_RANK() OVER(ORDER BY 供应商 asc,币种,汇率 )) as varchar(6)),5) xindan,10000+ROW_NUMBER() over(partition by  供应商,币种,汇率  order by 品号) xinxu,品号 ph,供应商 gys,币种 bz,汇率 hl,数量 sl
from  LSSJ..LSCGTH) AS A join LSSJ..LSCGTH B on A.dan=B.单号  and 品号= ph and 供应商= gys and 币种= bz and 汇率 =hl and 数量=sl AND  isnull(单价,0)>0--AND ISNULL(A.xu,'')=ISNULL(B.序号,'')





UPDATE LSSJ..LSCGTH SET 序号 = RIGHT(序号,4)






SELECT 供应商,MA002 from LSSJ..LSCGTH INNER JOIN ZJRD..PURMA ON 供应商=MA001

SELECT * FROM LSSJ..LSCGTH WHERE 品号 NOT IN (SELECT  MB001 FROM ZJRD..INVMB) 

select MAX(TI002)  FROM ZJRD..PURTI  where TI001='3573' and left(TI003,6)='202602'


--采购退货单头
insert into ZJRD.dbo.PURTI
	(COMPANY,CREATOR,USR_GROUP,CREATE_DATE,MODIFIER,MODI_DATE,FLAG,
TI001,TI002,TI003,TI004,TI005,TI006,TI007,TI008,TI009,TI010,
TI011,TI012,TI013,TI014,TI015,TI016,TI017,TI018,TI019,TI020,
TI021,TI022,TI023,TI024,TI025,TI026,TI027,TI028,TI029,TI030,
TI031,TI032,TI033,TI034,TI035,TI036,TI037,TI038,TI039,TI040,
TI041,TI042,TI043,TI044,TI045,
UDF01,UDF02,UDF03,UDF04,UDF05,UDF06,UDF51,UDF52,UDF53,UDF54,UDF55,UDF56) 
SELECT
'0001','10105978','90001','20260301000000000','','',1,
'3573',单号,'20260231',供应商,'000201','RMB',1,'S','1',0,
SUM(单价*数量)/1.13,'月末批量开退货单','N','20260231',SUM(单价*数量)-SUM(单价*数量)/1.13,PURMA.MA003,PURMA.MA005,'','',''
,0,SUM(数量),'','N','','',0.13,SUM(单价*数量)/1.13,SUM(单价*数量)-SUM(单价*数量)/1.13,PURMA.MA055
,0,'N','',0,'N','N','','','','N'
,'N','',0,0,0,'','','','','','',0,0,0,0,0,0
FROM LSSJ..LSCGTH INNER JOIN ZJRD..PURMA ON 供应商 = PURMA.MA001
INNER JOIN ZJRD..INVMB ON 品号 = INVMB.MB001  where 单价 is not null --where 单号>='20121200021'
GROUP BY 单号,供应商,PURMA.MA003,PURMA.MA055,PURMA.MA005



--采购退货单身
insert into ZJRD..PURTJ
  (COMPANY, CREATOR, USR_GROUP, CREATE_DATE, MODIFIER, MODI_DATE, FLAG,
	TJ001,TJ002,TJ003,TJ004,TJ005,TJ006,TJ007,TJ008,TJ009,TJ010
	,TJ011,TJ012,TJ013,TJ014,TJ015,TJ016,TJ017,TJ018,TJ019,TJ020,
	TJ021,TJ022,TJ023,TJ024,TJ025,TJ026,TJ027,TJ028,TJ029,TJ030,
	TJ031,TJ032,TJ033,TJ034,TJ035,TJ036,TJ037,TJ038,TJ039,TJ040,

	TJ041,TJ042,TJ043,TJ044,TJ045,TJ046,TJ047,TJ048,TJ049,TJ050,
	TJ051,TJ052,TJ053,TJ054,TJ055,TJ056,
	UDF01,UDF02,UDF03,UDF04,UDF05,UDF06,UDF51,UDF52,UDF53,UDF54,UDF55,UDF56)
SELECT 
'0001','10105978','90001','20260231113934473','','',1,
'3573',单号,序号,品号,INVMB.MB002,INVMB.MB003,INVMB.MB004,单价,数量,单价*数量
,仓库,'********************','','','','','','','','N'
,'N',数量,'',0,'','','','N','',单价*数量/1.13
,单价*数量-单价*数量/1.13,单价*数量/1.13,单价*数量-单价*数量/1.13,'','1',0,'','',0,0

,0.13,'','','','','##########',INVMB.MB004,数量,INVMB.MB004,''
,'','',0,0,0,''
,'','','','','','',0,0,0,0,0,0
FROM LSSJ..LSCGTH INNER JOIN ZJRD..PURMA ON 供应商 = PURMA.MA001
INNER JOIN ZJRD..INVMB ON 品号 = INVMB.MB001 where   isnull(单价,0)>0--where 单号>='20121200021'
--SELECT *FROM PURTJ where  CREATE_DATE='20260231113934473' and TJ001='3573'
--DELETE from  PURTJ where  CREATE_DATE='20260231113934473' and TJ001='3573'
--DELETE FROM PURTI where  CREATE_DATE='20260231113934473' and TI001='3573'
--select   * from   LSSJ..LSCGTH  where 单价 is not null