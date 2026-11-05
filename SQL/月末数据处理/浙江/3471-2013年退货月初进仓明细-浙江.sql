SELECT * FROM LSSJ..LSCGTH ORDER BY 单号,序号

--delete FROM LSSJ..LSCGTH WHERE ISNULL(单号,'')=''


select MAX(TG002) FROM ZJRD..PURTG  where TG001='3471' and left(TG003,6)='202610'

--UPDATE LSSJ..LSCGTH SET 序号 = RIGHT(序号,4)
UPDATE LSSJ..LSCGTH SET 单号 = replace(单号,'202609','202610')
SELECT 供应商,MA002 from LSSJ..LSCGTH INNER JOIN ZJRD..PURMA ON 供应商=MA001

SELECT * FROM LSSJ..LSCGTH order by 单号,序号
	
 declare @No int--单号编号
declare @FormNo varchar(11)--单号前缀

set @FormNo='202610'--次月月份
select @No=right(rtrim(isnull(MAX(TG002),'00000')),5) FROM AHRD..PURTG  where TG001='3471' and left(TG002,6)=@FormNo
select @No
 update B set 单号=xindan ,序号=xinxu
 -- select xindan ,xinxu 
 from (SELECT 单号 dan,序号 xu,@FormNo + right(cast((100000+@No+DENSE_RANK() OVER(ORDER BY 供应商 asc,币种,汇率 )) as varchar(6)),5) xindan,10000+ROW_NUMBER() over(partition by  供应商,币种,汇率  order by 品号) xinxu,品号 ph,供应商 gys,币种 bz,汇率 hl,数量 sl,单价 dj
from  LSSJ..LSCGTH) AS A join LSSJ..LSCGTH B on A.dan=B.单号  and 品号= ph and 供应商= gys and 币种= bz and 汇率 =hl and 数量=sl AND 单价=dj--AND ISNULL(A.xu,'')=ISNULL(B.序号,'')






--UPDATE  LSSJ..LSCGTH SET 单价=0
--UPDATE  B SET  单价=djj,币种=TG007,汇率=TG008
---- select*
--from LSSJ..LSCGTH B join  (
--select TH014,TG005,TH004,max(cast(TH018 as numeric(18,6))) djj,TG007,TG008 FROM ZJRD..PURTH INNER JOIN ZJRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 AND ( TH001= '3471' 
--OR TH001= '3405'
-- ) AND TH014 like '202304%' AND TH014+TG005+TH004  IN(
--select MAX(TH014)+TG005+TH004  FROM ZJRD..PURTH INNER JOIN ZJRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0  AND TH014 like '202304%' AND TH001 IN ( '3471','3403','3404','3405'  )
--group by TG005,TH004)group by TH014,TG005,TH004,TG007,TG008 ) as jhdj on TG005=供应商 and  品号=TH004 
--AND isnull(单价,0)=0


--select TH014,TG005,TH004,max(cast(TH018 as numeric(18,6))) djj,TG007,TG008 FROM ZJRD..PURTH INNER JOIN ZJRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 AND ( TH001= '3471' 
--OR TH001= '3405'
-- ) AND TH014 like '202302%' AND TH014+TG005+TH004  IN(
--select MAX(TH014)+TG005+TH004  FROM ZJRD..PURTH INNER JOIN ZJRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0  AND TH014 like '202302%' AND TH001 IN ( '3471','3403','3404','3405'  )
-- AND TH004='362040006700'
--group by TG005,TH004)group by TH014,TG005,TH004,TG007,TG008 

--SELECT *FROM LSSJ..LSCGTH WHERE 单价=0 

--SELECT * FROM LSSJ..LSCGTH  WHERE 单号='20230200017' AND 序号='0012   '



select * delete  from PURTG where (PURTG.TG016 = '采购月末退货月初进仓')
  AND (PURTG.TG013 = 'N')


--采购进货单头
insert into ZJRD..PURTG
   ( COMPANY , CREATOR , USR_GROUP , CREATE_DATE , MODIFIER , MODI_DATE , FLAG , 
TG001 , TG002 , TG003 , TG004 , TG005 , TG006 , TG007 , TG008 , TG009 , TG010 , 
TG011 , TG012 , TG013 , TG014 , TG015 , TG016 , TG017 , TG018 , TG019 , TG020 , 
TG021 , TG022 , TG023 , TG024 , TG025 , TG026 , TG027 , TG028 , TG029 , TG030 , 
TG031 , TG032 , TG033 , TG034 , TG035 , TG036 , TG037 , TG038 , TG039 , TG040 , 
TG041 , TG042 , TG043 , TG044 , TG045 , TG047 , TG048 , TG049 , TG050 , TG053 , 
TG054 , TG056 , TG057 , TG058 , UDF01 , UDF02 , UDF03 , UDF04 , UDF05 , UDF06 , UDF51 , UDF52 , UDF53 , UDF54 , UDF55 , UDF56  ) 
SELECT
'0001','10105978','90001',FORMAT(GETDATE(), 'yyyyMMddHHmmssfff')
,'','',1,
'3471',单号,'20261001','000201',供应商,'','RMB',1,'S','1',
'',0,'N','20261001','N','采购月末退货月初进仓',SUM(单价*数量),0,SUM(单价*数量)-SUM(单价*数量)/1.13,0,
PURMA.MA003,'','1','N',0,SUM(数量),'',SUM(单价*数量)/1.13,'',0.13,
SUM(单价*数量)/1.13,SUM(单价*数量)-SUM(单价*数量)/1.13,PURMA.MA055,'','','','',0,0,0,
0,'N','','',0,'','','','N',SUM(数量),
0,'','','0','','','','','','',0,0,0,0,0,0
FROM LSSJ..LSCGTH INNER JOIN ZJRD..PURMA ON 供应商 = PURMA.MA001
INNER JOIN ZJRD..INVMB ON 品号 = INVMB.MB001 where 单价 is not null --where 单号>='20121200021'
GROUP BY 单号,供应商,PURMA.MA003,PURMA.MA055

--进货单单身信息
insert into ZJRD..PURTH
  (COMPANY, CREATOR, USR_GROUP, CREATE_DATE, MODIFIER, MODI_DATE, FLAG,
TH001, TH002, TH003, TH004, TH005, TH006, TH007, TH008, TH009, TH010, 
TH011, TH012, TH013, TH014, TH015, TH016, TH017, TH018, TH019, TH020, 
TH021, TH022, TH023, TH024, TH025, TH026, TH027, TH028, TH029, TH030, 
TH031, TH032, TH033, TH034, TH035, TH036, TH037, TH038, TH039, TH040, 
TH041, TH042, TH043, TH044, TH045, TH046, TH047, TH048, TH049, TH050, 
TH051, TH052, TH053, TH054, TH055, TH056, TH057, TH058, TH059, TH060, 
TH061, TH062, TH063, TH064, TH065, TH066, TH067, TH068, TH069, TH070, 
TH071, TH072, TH073, TH080, UDF01, UDF02, UDF03, UDF04, UDF05, UDF06, UDF51, UDF52, 
UDF53, UDF54, UDF55, UDF56)
SELECT 
'0001','10105978','90001',FORMAT(GETDATE(), 'yyyyMMddHHmmssfff')
,'','',1,
'3471',单号,序号,品号,INVMB.MB002,INVMB.MB003,数量,INVMB.MB004,仓库,'********************',
'','','','20261001',数量,数量,0,单价,单价*数量,0,
'','','',0,'','N','N','2','N','N',
'N','N','',数量,'','','','','','',
'','','N','N',单价*数量/1.13,单价*数量-单价*数量/1.13,单价*数量/1.13,单价*数量-单价*数量/1.13,0,0,
0,0,'',0,0,'','',0,0,0.13,
0,0,'',INVMB.MB004,INVMB.MB004,'','',0,0,'N',
1,'##########','','N','','','','','','',0,0,0,0,0,0
FROM LSSJ..LSCGTH INNER JOIN ZJRD..PURMA ON 供应商 = PURMA.MA001
INNER JOIN ZJRD..INVMB ON 品号 = INVMB.MB001 where 单价 is not null--where 单号>='20121200021'


SELECT * FROM   ZJRD..PURTG WITH(NOLOCK)WHERE TG001='3471' AND TG002 LIKE '202407%' and CREATE_DATE='20261001113934473'


--DELETE FROM ZJRD..PURTH WHERE  TH001='3471' AND  CREATE_DATE='20261001113934473'
--DELETE  FROM ZJRD..PURTG WHERE  TG001='3471' AND  CREATE_DATE='20261001113934473'

SELECT * FROM   ZJRD..PURTH WITH(NOLOCK)WHERE TH001='3471' AND TH002 LIKE '202407%' and CREATE_DATE='20261001113934473'
AND TH030 <> 'Y'

select * from LSSJ..LSCGTH where 单号='20250200013'
 
SELECT * FROM   ZJRD..PURTG WHERE TG002='20250200013'

declare @No int--单号编号
declare @FormNo varchar(11)--单号前缀

set @FormNo='202610'--次月月份
select @No=right(rtrim(isnull(MAX(TG002),'00000')),5) FROM ZJRD..PURTG  where TG001='3471' and left(TG002,6)=@FormNo


select @No,@FormNo

 update B set 单号=xindan ,序号=xinxu
  --select xindan ,xinxu,*
 from (select 单号 dan,序号 xu,@FormNo + right(cast((100000+@No+DENSE_RANK() OVER(ORDER BY 供应商 asc,币种,汇率 )) as varchar(6)),5) xindan,10000+ROW_NUMBER() over(partition by  供应商,币种,汇率  order by 品号) xinxu,品号 ph,供应商 gys,币种 bz,汇率 hl,单价 dj,数量 sl
FROM  LSSJ..LSCGTH) AS A join LSSJ..LSCGTH B on  单号=A.dan AND 品号= ph and 供应商= gys and 币种= bz and 汇率 =hl and 数量=sl AND 单价=dj


select * from LSSJ..LSCGTH ORDER BY 单号

SELECT *  FROM ZJRD..PURTG  ORDER BY CREATE_DATE DESC




;
