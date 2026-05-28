

select *from  AHRD..v_EscrowMaterial
  /***加入当月代管物料***/
  --delete from  AHRD..EscrowMaterialDetail where 月份='202604'
  select *  from   AHRD..EscrowMaterialDetail where 月份='202604'
  --delete from  LSSJ..zjdj
  
  --select * into AHRD..EscrowMaterialDetailbak  from   AHRD..EscrowMaterialDetail where 月份='202604'
  --delete from LSSJ..zjdj
  INSERT INTO AHRD..EscrowMaterialDetail
  select '202604' ,TG005,MA002,TH004,I.MB002,I.MB003,0,0,0,0,0,0,0,''  from (
  select TG005,TH004,TH015 FROM AHRD..PURTH INNER JOIN AHRD..PURTG on TH001=TG001 AND TH002=TG002 join AHRD..v_EscrowMaterial E on MA001=TG005 AND E.MB001=TH004  
  WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3472'  AND TH014 >= '20260401' AND TH014 <= '20260430'

  -- UNION ALL
  --select TG005,TH004,TH016 from  AHRD..PURTG join AHRD..PURTH ON TG001=TH001 AND TG002=TH002 where (PURTG.TG001 = '3474') AND (TH014 LIKE '202604%')  AND (PURTG.TG016 = '代管料转月月初入库单') 

  UNION ALL
  select TG005,TH004,TH016 from  AHRD..PURTG join AHRD..PURTH ON TG001=TH001 AND TG002=TH002 where (PURTG.TG001 = '3474') AND (TH014 LIKE '202604%') 
  )   as PUR join AHRD..PURMA ON TG005=MA001 JOIN  AHRD..INVMB I ON MB001=TH004
  WHERE (SELECT count(*) FROM AHRD..EscrowMaterialDetail WHERE 月份='202604' and 供应商编号=TG005 and 品号=TH004 )=0
  AND (
	SELECT COUNT(*) 
	FROM  RDSJK..TYGYS 
	WHERE TY01=TG005 AND TY05='AHRD'
) = 0
--  AND ( SELECT COUNT(*) FROM  LSSJ..zjdj WHERE ph=TH004)=0 --剔除时打开
   GROUP BY TG005,MA002,TH004,I.MB002,I.MB003 

  /***加入当月代管物料结束***/


  
  /***上月结存***/

  --SELECT *FROM   AHRD..EscrowMaterialDetail Z JOIN   AHRD190501..AHRD..EscrowMaterialDetail B ON Z.供应商编号=B.供应商编号 and Z.品号=B.品号
  --UPDATE  AHRD..EscrowMaterialDetail SET 上月结存=B.上月结存 FROM AHRD..EscrowMaterialDetail Z JOIN AHRD190501..AHRD..EscrowMaterialDetail B ON Z.供应商编号=B.供应商编号 and Z.品号=B.品号
  update   AHRD..EscrowMaterialDetail SET 上月结存=0 WHERE  月份='202604'
   update   AHRD..EscrowMaterialDetail SET 上月结存=TH016
--SELECT *
  FROM  AHRD..EscrowMaterialDetail right join
 ( select TG005,TH004,SUM(TH016) TH016,TH018 from  AHRD..PURTG join AHRD..PURTH ON TG001=TH001 AND TG002=TH002 where (PURTG.TG001 = '3474') AND (TH014 LIKE '202604%') 
  AND (PURTG.TG016 = '代管料转月月初入库单') GROUP BY TG005,TH004,TH018) AS RK on 品号=TH004 AND TG005=供应商编号 and 月份='202604'



  SELECT  品号,供应商编号 FROM   AHRD..EscrowMaterialDetail WHERE 月份='202604'  GROUP BY  品号,供应商编号

  /***上月结存***/




  /***本月入库开始**/
  update AHRD..EscrowMaterialDetail set 本月入库=0 WHERE  月份='202604'
  update AHRD..EscrowMaterialDetail set 本月入库=SL
  --select * 
  from AHRD..EscrowMaterialDetail join   
    (select TG005,TH004, SUM(TH015) SL  from  (
		select TG005,TH004,TH015 FROM AHRD..PURTH JOIN AHRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 AND TH014 LIKE '202604%' and( TH001<>'3474' OR (TG016 <> '代管料转月月初入库单')) 
		 ) as PUR join AHRD..EscrowMaterialDetail E on 供应商编号=TG005 AND 品号=TH004 where 月份='202604'  GROUP BY TG005,TH004  having SUM(TH015)<>0  
 ) as PUR on TG005=供应商编号 and TH004=品号 where 月份='202604'

  
 select *from  AHRD..EscrowMaterialDetail where 月份='202604'
   /***本月入库结束**/

  /***本月退货开始**/
   update AHRD..EscrowMaterialDetail set 本月退货=0 WHERE  月份='202604'
    update AHRD..EscrowMaterialDetail set 本月退货=SL
  --select * 
  from AHRD..EscrowMaterialDetail join   (
  select TI004,TJ004, SUM(TJ009) SL   from  AHRD..PURTJ INNER JOIN AHRD..PURTI on TI001=TJ001 AND TI002=TJ002 join AHRD..EscrowMaterialDetail E on 供应商编号=TI004 AND 品号=TJ004 
  WHERE TJ020 = 'Y' AND TJ009 > 0 AND TI003 like '202604%' AND 月份='202604' GROUP BY TI004,TJ004  having SUM(TJ009)<>0  ) AS PUR on TI004=供应商编号 and TJ004=品号 where 月份='202604'

  /***本月入库结束**/
  select *from AHRD..EscrowMaterialDetail WHERE  月份='202604'

  /***本月单价**/
   update AHRD..EscrowMaterialDetail set 本月单价=0 WHERE  月份='202604'

     update AHRD..EscrowMaterialDetail set 本月单价=dj
  --select 上月结存+本月入库-本月退货 ,SL,上月结存+本月入库-本月退货 -SL,*
  --select * 
  from AHRD..EscrowMaterialDetail join   (
select TG005,TH004,I.MB002,I.MB003,SUM(TH015) SL ,SUM(je)/SUM(TH015) dj  
   from (

select TG005,TH004,TH015,TH048+TH047 je FROM AHRD..PURTH INNER JOIN AHRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3472'  AND TH014 like '202604%'
union all
select TI004,TJ004,-TJ009,-(TJ032+TJ033) from AHRD..PURTJ INNER JOIN AHRD..PURTI on TI001=TJ001 AND TI002=TJ002  WHERE TJ020 = 'Y' AND TJ009 > 0 AND TI003 like '202604%' and (TI001<>'3574' OR TI012 <> '代管料转月月末退货单')

 ) as PUR JOIN  AHRD..INVMB I  ON MB001=TH004 join AHRD..EscrowMaterialDetail E on 供应商编号=TG005 AND 品号=TH004  AND 月份='202604' 
  
  GROUP BY    TG005,TH004,I.MB002,I.MB003  having SUM(TH015)>0 
 )  as PUR on 供应商编号=TG005 AND 品号=TH004  AND 月份='202604' 
 
 --and 上月结存+本月入库-本月退货 <>SL

  /***本月单价**/

  /********数据排查开始*******/
  select *from   AHRD..EscrowMaterialDetail where 本月单价=0  AND 月份='202604'  and 上月结存+本月入库-本月退货<>0
  select *   from AHRD..EscrowMaterialDetail join   (
select TG005,TH004,I.MB002,I.MB003,SUM(TH015) SL ,SUM(je)/SUM(TH015) dj  
   from (

select TG005,TH004,TH015,TH048+TH047 je FROM AHRD..PURTH INNER JOIN AHRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3472'  AND TH014 like '202604%'
union all
select TI004,TJ004,-TJ009,-(TJ032+TJ033) from AHRD..PURTJ INNER JOIN AHRD..PURTI on TI001=TJ001 AND TI002=TJ002  WHERE TJ020 = 'Y' AND TJ009 > 0 AND TI003 like '202604%'

 ) as PUR JOIN  AHRD..INVMB I  ON MB001=TH004 join AHRD..EscrowMaterialDetail E on 供应商编号=TG005 AND 品号=TH004  AND 月份='202604' 
  
  GROUP BY TG005,TH004,I.MB002,I.MB003   )  as PUR on 供应商编号=TG005 AND 品号=TH004  AND 月份='202604' 
  
  --and 品号='300070003300'
 
  /********数据排查结束*******/


 SELECT *FROM  AHRD..EscrowMaterialDetail  WHERE  总库存=0 AND 月份='202604'

 
 SELECT *FROM  AHRD..EscrowMaterialDetail  WHERE   月份='202604'

-- /***更新仓别开始****/
--	update AHRD..EscrowMaterialDetail set 交易仓别='' WHERE  月份='202604'

--    update AHRD..EscrowMaterialDetail set 交易仓别=TH009
--  --select *
--  from  AHRD..EscrowMaterialDetail join   (

-- select TG005,TH004,max(rtrim(TH009)) TH009 from (
--select TG005,TH004,TH015,TH048+TH047 je ,TH009 FROM AHRD..PURTH INNER JOIN AHRD..PURTG on TH001=TG001 AND TH002=TG002
--WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3472'  AND TH014 >= '20260401' AND TH014 <= '20260430'  ) as PUR join AHRD..EscrowMaterialDetail E on 供应商编号=TG005 AND 品号=TH004 AND 月份='202604'
--   GROUP BY TG005,TH004  having SUM(TH015)>0  )as  CB  on 供应商编号=TG005 AND 品号=TH004  AND 月份='202604' 

-- --update AHRD..EscrowMaterialDetail set 交易仓别=case left(品号,1) when '5' then '053'else '052' end 
-- -- --select *
-- -- from AHRD..EscrowMaterialDetail join  [v_Material_SMT] on MaterialID=品号 where 月份='202604' and  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) 


-- update AHRD..EscrowMaterialDetail set 交易仓别=StorageID
--  --select *
--  from AHRD..EscrowMaterialDetail join  AHRD.dbo.v_Material_Checked on MaterialID=品号 where 月份='202604' --and  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) 


  /**主要仓库**/
 update AHRD..EscrowMaterialDetail set 交易仓别=MB017
  --select *
  from AHRD..EscrowMaterialDetail join  AHRD..INVMB on 品号=MB001 where 月份='202604' --and  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) 
/**主要仓库**/

  --select *from  v_Material_Checked

 /****更新仓别结束*******/

 

-- select *  from  AHRD..EscrowMaterialDetail join   (
--select RTRIM(LA001) MC001, SUM(CASE LA005 WHEN '1' THEN LA011 ELSE 0-LA011 END) MC007 FROM  AHRD..INVLA WHERE LA004 <= '20260430'
-- AND (select count(*) from CMSMC where CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%' and CMSMC.MC001=LA009)>0 
-- GROUP BY  LA001) tb on  MC001=品号  where MC007>0  AND 月份='202604'


/*************更新本月用量与本月结存***/


UPDATE AHRD..EscrowMaterialDetail SET 本月结存=0,本月用量=0 WHERE  月份='202604'



 
 --drop table  #TEMP

-- ----次月领料扣数
-- --DROP TABLE #CYLL
--      SELECT * INTO #TEMP FROM WMS..IMS.IMS_IN_OUT_LOG_VIEW WHERE  (1=0)-- and  TRANSACTION_TIME>'2021-08-20'
	 
--	SELECT PH,GYS,SUM(SL) SL into #CYLL FROM (
--	SELECT PART_NO PH,QUANTITY SL,VENDOR_CODE GYS FROM COPTHHBTOWMS  JOIN #TEMP ON 领料批次=WMS_BILL_NO AND 品号=PART_NO join COPTHHBMX M on 领料批次=LLPC AND TH004=PART_NO JOIN  COPTG C ON C.TG001=M.TH001 AND C.TG002=M.TH002 AND VENDOR_CODE<>'无' WHERE TG003>='20260401'
--	and  (1=0)
--	UNION ALL
--	SELECT PART_NO,QUANTITY,VENDOR_CODE  FROM #TEMP JOIN MOCTC ON ('IMS-'+TC007=WMS_BILL_NO OR TC001+'-'+TC002=WMS_BILL_NO ) AND ERP_BILL_TYPE LIKE '54%' where TC003>='20260401' and CREATOR='DS' AND VENDOR_CODE<>'无'
--	and  (1=0)
--	) AS YF	 GROUP BY PH,GYS

------WMS剩余库存数量
----DROP TABLE #WMSKC
--	select PART_NO PH,VENDOR_CODE GYS,QTY+isnull(SL,0) SL INTO #WMSKC from(
--	SELECT PART_NO ,VENDOR_CODE,SUM(STOCK_QTY) QTY FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE ) WMSKC LEFT JOIN  #CYLL ON PART_NO=PH AND GYS=VENDOR_CODE WHERE VENDOR_CODE<>'无'
--	and (1=0)

	select MB001 PH,MB002 GYS,FLAG SL  INTO #WMSKC from INVMB WHERE 1=2
	--select  DISTINCT TG005 from PURTH JOIN PURTG ON TH001=TG001 AND TH002=TG002 WHERE TG003>'20190301' ---半年内有采购进货的供应商

	/***检测半年内内是否有交易过数据****/

	--delete FROM  LSSJ..zjdj 

	  INSERT INTO AHRD..EscrowMaterialDetail
  select '202604' ,TG005,MA002,TH004,I.MB002,I.MB003,0,0,0,0,0,0,0,''  from (
  select TG005,TH004,TH015 FROM AHRD..PURTH INNER JOIN AHRD..PURTG on TH001=TG001 AND TH002=TG002 join AHRD..EscrowMaterialDetail E on 供应商编号=TG005 AND 品号=TH004  
  WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3472'  AND TH014 >= '20210801' AND TH014 <= '20260430'

  -- UNION ALL
  --select TG005,TH004,TH016 from  AHRD..PURTG join AHRD..PURTH ON TG001=TH001 AND TG002=TH002 where (PURTG.TG001 = '3474') AND (TH014 LIKE '202604%')  AND (PURTG.TG016 = '代管料转月月初入库单') 

  UNION ALL
  select TG005,TH004,TH016 from  AHRD..PURTG join AHRD..PURTH ON TG001=TH001 AND TG002=TH002 where (PURTG.TG001 = '3474') AND (TH014 >= '20260401' AND TH014 <= '20260430') 
  )   as PUR  join AHRD..PURMA ON TG005=MA001 JOIN  AHRD..INVMB I ON MB001=TH004
  WHERE (SELECT count(*) FROM AHRD..EscrowMaterialDetail WHERE 月份='202604' and 供应商编号=TG005 and 品号=TH004 )=0  
  --and (SELECT count(*) FROM  #WMSKC where TG005=GYS and TH004=PH  and SL >0)>0
    -- AND( SELECT COUNT(*) FROM  LSSJ..zjdj WHERE ph=TH004)=0
   GROUP BY TG005,MA002,TH004,I.MB002,I.MB003  ---半年内有采购进货的供应商
   
	/****检测半年内内是否有交易过数据****/



  /**总库存核算**/
  update AHRD..EscrowMaterialDetail set 总库存=0 WHERE  月份='202604'

   update AHRD..EscrowMaterialDetail set 总库存= MC007 --case when MC007>QTY then QTY else MC007 END 
  --select *
    from  AHRD..EscrowMaterialDetail join (

  --select MB001 LA001,MC002 LA009,INVNUMA LA011,INVMONEY LA013 from  V_KCMX  
select RTRIM(MC01) MC001, sum(MC07) MC007 FROM  AHRD..[Fn_GetKCMX]('20260430','')  v WHERE (
select count(*) from AHRD..CMSMC where CMSMC.UDF01 like '%-良品' AND AHRD..CMSMC.MC002 not like '%车间仓%'AND AHRD..CMSMC.MC002 not like '%外协仓%' and AHRD..CMSMC.MC001=v.MC02)>0 
 GROUP BY  MC01) tb on  MC001=品号 
 --join (SELECT PART_NO,VENDOR_CODE,SUM(STOCK_QTY) QTY FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE  ) B on 品号=PART_NO AND 供应商编号=VENDOR_CODE
  where MC007>0  AND 月份='202604'


--  --select *
--  from  AHRD..EscrowMaterialDetail join (
--select RTRIM(LA001) MC001, SUM(CASE LA005 WHEN '1' THEN LA011 ELSE 0-LA011 END) MC007 FROM  AHRD..INVLA WHERE LA004 <= '20260430'
-- AND (select count(*) from CMSMC where CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%' and CMSMC.MC001=LA009)>0 
-- GROUP BY  LA001) tb on  MC001=品号 
-- --join (SELECT PART_NO,VENDOR_CODE,SUM(STOCK_QTY) QTY FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE  ) B on 品号=PART_NO AND 供应商编号=VENDOR_CODE
--  where MC007>0  AND 月份='202604'


  SELECT * FROM WMS..IMS.IMS_IN_OUT_LOG_VIEW

  
--select  供应商简称,品号,品名,规格, 本月结存,QTY,本月单价  from   AHRD..EscrowMaterialDetail 
--left join (SELECT PART_NO,VENDOR_CODE,SUM(STOCK_QTY) QTY FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE  ) B on 品号=PART_NO AND 供应商编号=VENDOR_CODE
--where 月份='202604' and 供应商简称='恒辉电阻' 
 /**总库存核算**/




	
 --select*from  AHRD..EscrowMaterialDetail where 月份='202604' and 上月结存=0 and 本月入库=0 
 --select*from  AHRD..EscrowMaterialDetail where 月份='202604' and 总库存=0
 --SELECT *FROM  #WMSKC where  SL<=0

	--SELECT *FROM  #WMSKC where PH='300080103800'
	--select *from  v_EscrowMaterial where MB001='300080006700' AND MA001='20533685'  


	 update B set 本月单价=dj
-- select*
from AHRD..EscrowMaterialDetail B join  (
select TH014,TG005,TH004,max(cast((TH048+TH047)/TH015 as numeric(18,6))) dj FROM AHRD..PURTH INNER JOIN AHRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 
--AND ( TH001= '3401'  OR TH001= '3405' )-- AND TH014 like '201908%' 
AND TH014+TG005+TH004  IN(
select MAX(TH014)+TG005+TH004  FROM AHRD..PURTH INNER JOIN AHRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 --AND ( TH001= '3401' OR TH001= '3405' ) --AND TH014 like '201908%'
group by TG005,TH004 )group by TH014,TG005,TH004) as jhdj on TG005=供应商编号 and  品号=TH004 and  月份='202604' AND isnull(本月单价,0)=0

DROP TABLE #WMSKC 

	select MB001 PH,MB002 GYS,FLAG SL  INTO #WMSKC from AHRD..INVMB WHERE 1=2


 UPDATE AHRD..EscrowMaterialDetail SET 本月结存=本月结存1,本月用量=本月用量1 
-- select Z.*  ,本月结存1,本月用量1,KCSL,isnull(SL,0)
from  AHRD..EscrowMaterialDetail Z join   (

select W.*,KCSL
,case when 入库数量-总库存>0 then cast(总库存 as int) else 入库数量 end 本月结存1
--,case when 入库数量-isnull(SL/KCSL,0)*总库存>0 then cast(isnull(SL/KCSL,0)*总库存 as int) else 入库数量 end 本月结存1
--,case when isnull(SL,0)>=总库存 then cast(isnull(isnull(SL,0)/KCSL,0)*总库存 as int) else isnull(SL,0) end  本月结存1
--,isnull(SL,0),总库存
--,入库数量-case when 入库数量-isnull(SL/KCSL,0)*总库存>0 then cast(isnull(SL/KCSL,0)*总库存 as int) else 入库数量 end 本月用量1
,入库数量-case when isnull(SL,0)>=总库存 then cast(isnull(isnull(SL,0)/KCSL,0)*总库存 as int) else isnull(SL,0) end  本月用量1
--,入库数量
 from (
select  *,(上月结存+本月入库-本月退货) 入库数量 from AHRD..EscrowMaterialDetail left JOIN #WMSKC ON  供应商编号=GYS AND 品号=PH) W  left join ( select PH,SUM(SL) KCSL from  AHRD..EscrowMaterialDetail left JOIN #WMSKC ON  供应商编号=GYS AND 品号=PH where 月份='202604' group by PH) as NL on  W.品号=NL.PH  and KCSL>0 where 月份='202604'

 ) as HZ on HZ.月份= Z.月份 AND HZ.供应商编号=Z.供应商编号 AND HZ.品号=Z.品号 
 --and Z.品号='300080178800'


 select*from  AHRD..EscrowMaterialDetail where 月份='202604' and 品号='301000113600'
 SELECT *FROM  #WMSKC where PH='300080006700'

select  W.*,(上月结存+本月入库-本月退货) 入库数量,总入库数
 from   AHRD..EscrowMaterialDetail W join ( select N.品号,SUM(上月结存+本月入库-本月退货) 总入库数 from AHRD..EscrowMaterialDetail N where N.月份='202604' group by N.品号) as NL on  W.品号=NL.品号  
 where 月份='202604' and 总入库数>0

/*************更新本月用量与本月结存***/

/**主要仓库**/
 update AHRD..EscrowMaterialDetail set 交易仓别=StorageID
  --select *
  from AHRD..EscrowMaterialDetail join  AHRD..v_Material_Checked on MaterialID=品号 where 月份='202604' --and  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) 
/**主要仓库**/


  /**主要仓库**/
 update AHRD..EscrowMaterialDetail set 交易仓别=MB017
  --select *
  from AHRD..EscrowMaterialDetail join  AHRD..INVMB on 品号=MB001 where 月份='202604' --and  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) 
/**主要仓库**/



  
  select sum(本月结存*本月单价)  from   AHRD..EscrowMaterialDetail where 月份='202604'  and 本月结存>0 --and 供应商简称='恒辉电阻'



  select *from   AHRD..EscrowMaterialDetail where 月份='202604'  


SELECT * FROM LSSJ..LSCGTH 
--select *from  AHRD..EscrowMaterialDetail where 月份='202604' 

delete FROM LSSJ..LSCGTH

declare @No int--单号编号
declare @FormNo varchar(11)--单号前缀
set @FormNo='202604'--本月月份
select @No=right(rtrim(isnull(MAX(TI002),'00000')),5) FROM AHRD..PURTI  where TI001='3574' and left(TI002,6)=@FormNo
--select @No
insert into LSSJ..LSCGTH(单号, 序号, 供应商, 品号, 品名, 规格, 单位, 数量, 单价, 仓库)
select @FormNo + right(cast((100000+@No+DENSE_RANK() OVER(ORDER BY 供应商编号 asc )) as varchar(6)),5),10000+ROW_NUMBER() over(partition by 供应商编号 order by 品号)
,供应商编号,品号,品名,规格,'',本月结存,本月单价,  交易仓别  交易仓别 from AHRD..EscrowMaterialDetail  where 月份='202604' and 本月结存>0   order by 供应商编号,品号

select *from   AHRD..EscrowMaterialDetail where  月份='202203' and 供应商编号='20500018' and 品号 in('301000154800','301000155400') and 供应商编号='20500018' and 品号 in('301000154800','301000155400')

select * from [v_Material_Checked]
--select *from   LSSJ..LSCGTH where 单价=0


delete FROM LSSJ..LSCGTH

declare @No int--单号编号
declare @FormNo varchar(11)--单号前缀
set @FormNo='202604'--次月月份
select @No=right(rtrim(isnull(MAX(TG002),'00000')),5) FROM AHRD..PURTG  where TG001='3474' and left(TG002,6)=@FormNo
--select @No

insert into LSSJ..LSCGTH(单号, 序号, 供应商, 品号, 品名, 规格, 单位, 数量, 单价, 仓库)
select @FormNo + right(cast((100000+@No+DENSE_RANK() OVER(ORDER BY 供应商编号 asc )) as varchar(6)),5),10000+ROW_NUMBER() over(partition by 供应商编号 order by 品号)
,供应商编号,品号,品名,规格,'',本月结存,本月单价,CASE WHEN StorageID IS NULL THEN 交易仓别 ELSE StorageID END  交易仓别 from AHRD..EscrowMaterialDetail LEFT join AHRD.[dbo].[v_Material_Checked] 
on 品号=MaterialID where 月份='202604'  and 本月结存>0  and 供应商简称<>'盛中' and 供应商简称<>'恒辉电阻'  and 供应商简称<>'恒辉电阻'  order by 供应商编号,品号


select *  from   AHRD..EscrowMaterialDetail where 月份='202604' and 供应商简称='盛中'

select sum((本月结存)*本月单价)  from   AHRD..EscrowMaterialDetail where 月份='202604'

select *from  LSSJ..LSCGTH where  供应商='20533714'


select *from AHRD..EscrowMaterialDetail where 月份='202604' and  品号='304090081300'

select *from  PURTH JOIN PURTG ON TH001=TG001 AND TH002=TG002 WHERE TH001='3474' AND TG016='代管料转月月初入库单' and TG003='20260401'

DELETE FROM  LSSJ..zjcgrk

SELECT *FROM  LSSJ..zjcgrk  
SELECT *FROM  AHRD..EscrowMaterialDetail where 月份='202604' and 本月结存>0   and 供应商简称<>'盛中' and 供应商简称<>'恒辉电阻' AND (SELECT COUNT(*)FROM   LSSJ..zjcgrk
join PURTH ON TH001+'-'+TH002+'-'+TH003=cgdh WHERE TH004=品号  )>0
  

INSERT INTO LSSJ..zjcgrk(cgdh,dj) SELECT TH001+'-'+TH002+'-'+TH003,本月单价
--select 本月单价,TH018 
from  AHRD..PURTH JOIN AHRD..PURTG ON TH001=TG001 AND TH002=TG002 
JOIN  AHRD..EscrowMaterialDetail ON TG005=供应商编号 and 品号=TH004 AND 月份='202604' WHERE TH001='3474' AND TG016='代管料转月月初入库单' and TG003='20260501' AND 本月单价<>TH018


INSERT INTO LSSJ..zjcgrk(cgdh,dj) SELECT TJ001+'-'+TJ002+'-'+TJ003,本月单价
--select 本月单价,TJ008,TI004,TJ004,TJ009,(TJ032+TJ033)
 from AHRD..PURTJ INNER JOIN AHRD..PURTI on TI001=TJ001 AND TI002=TJ002 
 JOIN  AHRD..EscrowMaterialDetail ON TI004=供应商编号 and 品号=TJ004 AND 月份='202604'  WHERE TI001='3574'  AND TI003 like '202604%' AND  TJ020 = 'Y' AND TJ009 > 0 and TI012 ='代管料转月月末退货单' AND 本月单价<>TJ008

 
select  供应商简称,品号,品名,规格, 本月结存,QTY,本月单价  from   AHRD..EscrowMaterialDetail 
left join (SELECT PART_NO,VENDOR_CODE,SUM(STOCK_QTY) QTY FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE  ) B on 品号=PART_NO AND 供应商编号=VENDOR_CODE
where 月份='202604' and 供应商简称='恒辉电阻' and 品号='300080051100'


--SELECT * FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE 

-- select *
--from  PURTH JOIN PURTG ON TH001=TG001 AND TH002=TG002 
--JOIN  PURMB ON MB001=TH004 AND MB002=TH004 AND (PURMB.MB015 >= '20260401' OR  ISNULL(PURMB.MB015,'')='') WHERE TH001='3474' AND TG016='代管料转月月初入库单' and TG003='20260401' AND MB011<TH018


--SELECT *FROM  PURMB WHERE (PURMB.MB015 >= '20260401' OR  ISNULL(PURMB.MB015,'')='')
















/**
供应商代号	料号	品名	规格	本月用量	单价	仓库


select TG005,TH004,I.MB002,I.MB003,SUM(TH015) SL ,SUM(je)/SUM(TH015) dj ,rtrim(TH009)  from (
select TG005,TH004,TH015,TH048+TH047 je ,TH009
FROM AHRD..PURTH INNER JOIN AHRD..PURTG on TH001=TG001 AND TH002=TG002
WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3472'  AND TH014 >= '20260401' AND TH014 <= '20260430'  

union all
select TI004,TJ004,-TJ009,-(TJ032+TJ033),

(select MAX( TH009)
FROM AHRD..PURTH INNER JOIN AHRD..PURTG on TH001=TG001 AND TH002=TG002
WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3472'  AND TH014 >= '20260401' AND TH014 <= '20260430' and TI004=TG005 AND TJ004=TH004   )


 from AHRD..PURTJ INNER JOIN AHRD..PURTI on TI001=TJ001 AND TI002=TJ002--退货不加仓别
 WHERE TJ020 = 'Y' AND TJ009 > 0 AND TI003 >= '20260401' AND TI003 <= '20260430' 
 ) as PUR JOIN  AHRD..INVMB I  ON MB001=TH004 join v_EscrowMaterial E on MA001=TG005 AND E.MB001=TH004
 
  GROUP BY    TG005,TH004,I.MB002,I.MB003,TH009  having SUM(TH015)>0  order by TG005,TH004

  --SELECT *FROM  v_EscrowMaterial


  select *from  AHRD..EscrowMaterialDetail 
  UPDATE  AHRD..EscrowMaterialDetail SET 规格=MB003
from  AHRD..EscrowMaterialDetail join INVMB ON 品号=MB001



--SELECT *FROM  INVTB WHERE TB002='20260400042' 


  select *from  AHRD..EscrowMaterialDetail 
  select *
  update   AHRD..EscrowMaterialDetail SET 上月结存=TB007
  from  AHRD..EscrowMaterialDetail JOIN (SELECT INVTA.UDF02 ,TB004,TB007 FROM  INVTB join INVTA ON TA001=TB001 AND TA002=TB002 WHERE  TB001='1112'AND INVTB.CREATE_DATE='20260401104834473') AS ZY ON 品号=TB004 AND UDF02=供应商编号
  

  SELECT INVTA.UDF02 ,TB004,TB007 FROM  INVTB join INVTA ON TA001=TB001 AND TA002=TB002 WHERE  TB001='1112' and TA003 LIKE '202604%'
 
  update   AHRD..EscrowMaterialDetail SET 本月入库=TB007
  from  AHRD..EscrowMaterialDetail JOIN (SELECT INVTA.UDF02 ,TB004,sum(TB007) TB007 FROM  INVTB join INVTA ON TA001=TB001 AND TA002=TB002 WHERE  TB001='1112' and TA003 like '202604%' AND INVTB.CREATE_DATE not  like '%104834473' group by  INVTA.UDF02 ,TB004) AS ZY ON 品号=TB004 AND UDF02=供应商编号
 
  update   AHRD..EscrowMaterialDetail SET 本月结存=0TB007
  from  AHRD..EscrowMaterialDetail JOIN (SELECT INVTA.UDF02 ,TB004,sum(TB007)TB007 FROM  INVTB join INVTA ON TA001=TB001 AND TA002=TB002 WHERE  TB001='1112' and TA003 like '202604%' AND INVTB.CREATE_DATE   like '20260430104834473' group by  INVTA.UDF02 ,TB004) AS ZY ON 品号=TB004 AND UDF02=供应商编号


   update   AHRD..EscrowMaterialDetail SET 本月用量=TH016,本月单价=TH018
  --SELECT *
  FROM  AHRD..EscrowMaterialDetail right join
 ( select TG005,TH004,SUM(TH016) TH016,TH018 from  AHRD..PURTG join AHRD..PURTH ON TG001=TH001 AND TG002=TH002 where TG001 = '3474' AND (TH014 = '20260430') GROUP BY TG005,TH004,TH018) AS RK on 品号=TH004 AND TG005=供应商编号 where 品号='304090138400'

 update   AHRD..EscrowMaterialDetail SET 本月结存=TH016
--SELECT *
  FROM  AHRD..EscrowMaterialDetail right join
 ( select TG005,TH004,SUM(TH016) TH016,TH018 from  AHRD..PURTG join AHRD..PURTH ON TG001=TH001 AND TG002=TH002 where (PURTG.TG001 = '3401')
  AND (PURTG.TG014 = '20260401')
  AND (PURTG.TG016 = '代管料转月入库单') GROUP BY TG005,TH004,TH018) AS RK on 品号=TH004 AND TG005=供应商编号



SELECT *,(上月结存+本月入库)-(本月用量+本月结存)
  FROM  AHRD..EscrowMaterialDetail where (上月结存+本月入库)<>(本月用量+本月结存) order by 供应商编号,品号

  update AHRD..EscrowMaterialDetail set 上月结存=(本月用量+本月结存) -本月入库
  --select *
  from  AHRD..EscrowMaterialDetail where 供应商编号='20533661'

  select *from  v_EscrowMaterial

  ***/
 
  /*ddd**/


