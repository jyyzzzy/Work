
SELECT * FROM SDRD..EscrowMaterialDetail
SELECT * FROM SDRD..v_EscrowMaterial

  /***加入当月代管物料***/
  --delete FROM  SDRD..EscrowMaterialDetail WHERE 月份='202604'
  SELECT *  FROM  SDRD..EscrowMaterialDetail WHERE 月份='202604' 
  --delete FROM  LSSJ..zjdj
  
  --SELECT * into SDRD..EscrowMaterialDetailbak  FROM   SDRD..EscrowMaterialDetail WHERE 月份='202604'
  --delete FROM LSSJ..zjdj
  --------------------------------------------------第一步---------------------------------------------------
INSERT INTO SDRD..EscrowMaterialDetail
SELECT '202604' ,TG005,MA002,TH004,I.MB002,I.MB003,0,0,0,0,0,0,0,''  
FROM (
	SELECT TG005,TH004,TH015 
	FROM SDRD..PURTH 
	INNER JOIN SDRD..PURTG on TH001=TG001 AND TH002=TG002 
	JOIN SDRD..v_EscrowMaterial E on MA001=TG005 AND E.MB001=TH004  
	WHERE TH030 = 'Y' 
	AND TH016 > 0 
	AND TH001 <> '3402'  
	AND TH014 >= '20260401' 
	AND TH014 <= '20260430'
	--UNION ALL
	--SELECT TG005,TH004,TH016 
	--FROM  SDRD..PURTG JOIN SDRD..PURTH ON TG001=TH001 AND TG002=TH002 
	--WHERE (PURTG.TG001 = '3403') AND (TH014 LIKE '202604%')  AND (PURTG.TG016 = '代管料转月月初入库单') 
	UNION ALL
	SELECT TG005,TH004,TH016 
	FROM  SDRD..PURTG JOIN SDRD..PURTH 
	ON TG001=TH001 AND TG002=TH002 
	WHERE (PURTG.TG001 = '3403')
	AND (TH014 LIKE '202604%') 
)   as PUR JOIN SDRD..PURMA ON TG005=MA001 JOIN  SDRD..INVMB I ON MB001=TH004
WHERE (
	SELECT COUNT(*) 
	FROM SDRD..EscrowMaterialDetail 
	WHERE 月份='202604' 
	AND 供应商编号=TG005 
	AND 品号=TH004 
) = 0
AND (
	SELECT COUNT(*) 
	FROM  RDSJK..TYGYS 
	WHERE TY01=TG005 AND TY05='SDRD'
) = 0
--  AND ( SELECT COUNT(*) FROM  LSSJ..zjdj WHERE ph=TH004)=0 --剔除时打开
GROUP BY TG005,MA002,TH004,I.MB002,I.MB003 

  /***加入当月代管物料结束***/
    --------------------------------------------------第一步---------------------------------------------------



  /***上月结存***/

  --SELECT *FROM   SDRD..EscrowMaterialDetail Z JOIN   SDRD190501..SDRD..EscrowMaterialDetail B ON Z.供应商编号=B.供应商编号 AND Z.品号=B.品号
  --UPDATE  SDRD..EscrowMaterialDetail SET 上月结存=B.上月结存 FROM SDRD..EscrowMaterialDetail Z JOIN SDRD190501..SDRD..EscrowMaterialDetail B ON Z.供应商编号=B.供应商编号 AND Z.品号=B.品号
    --------------------------------------------------第二步---------------------------------------------------
  UPDATE   SDRD..EscrowMaterialDetail SET 上月结存=0 WHERE  月份='202604'
   UPDATE   SDRD..EscrowMaterialDetail SET 上月结存=TH016
--SELECT *
  FROM  SDRD..EscrowMaterialDetail right JOIN
 ( SELECT TG005,TH004,SUM(TH016) TH016,TH018 FROM  SDRD..PURTG JOIN SDRD..PURTH ON TG001=TH001 AND TG002=TH002 WHERE (PURTG.TG001 = '3403') AND (TH014 LIKE '202604%') 
  AND (PURTG.TG016 = '代管料转月月初入库单') GROUP BY TG005,TH004,TH018) AS RK on 品号=TH004 AND TG005=供应商编号 AND 月份='202604'

      --------------------------------------------------第二步---------------------------------------------------

  SELECT  品号,供应商编号 FROM   SDRD..EscrowMaterialDetail WHERE 月份='202604'  GROUP BY  品号,供应商编号

  /***上月结存***/

  SELECT * FROM SDRD.dbo.PURMAFROMSRM WHERE MA001='29001738'
 
     --------------------------------------------------第三步---------------------------------------------------
  /***本月入库开始**/
  UPDATE SDRD..EscrowMaterialDetail set 本月入库=0 WHERE  月份='202604'
  UPDATE SDRD..EscrowMaterialDetail set 本月入库=SL
  --SELECT * 
  FROM SDRD..EscrowMaterialDetail JOIN   
    (SELECT TG005,TH004, SUM(TH015) SL  FROM  (
		SELECT TG005,TH004,TH015 FROM SDRD..PURTH JOIN SDRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 AND TH014 LIKE '202604%' AND( TH001<>'3403' OR (TG016 <> '代管料转月月初入库单')) 
		 ) as PUR JOIN SDRD..EscrowMaterialDetail E on 供应商编号=TG005 AND 品号=TH004 WHERE 月份='202604'  GROUP BY TG005,TH004  having SUM(TH015)<>0  
 ) as PUR on TG005=供应商编号 AND TH004=品号 WHERE 月份='202604'
      --------------------------------------------------第三步---------------------------------------------------
  
 SELECT *FROM  SDRD..EscrowMaterialDetail WHERE 月份='202604'
   /***本月入库结束**/

  /***本月退货开始**/
   UPDATE SDRD..EscrowMaterialDetail set 本月退货=0 WHERE  月份='202604'
    UPDATE SDRD..EscrowMaterialDetail set 本月退货=SL
  --SELECT * 
  FROM SDRD..EscrowMaterialDetail JOIN   (
  SELECT TI004,TJ004, SUM(TJ009) SL   FROM  SDRD..PURTJ INNER JOIN SDRD..PURTI on TI001=TJ001 AND TI002=TJ002 JOIN SDRD..EscrowMaterialDetail E on 供应商编号=TI004 AND 品号=TJ004 WHERE TJ020 = 'Y' AND TJ009 > 0 AND TI003 like '202604%' AND 月份='202604' GROUP BY TI004,TJ004  having SUM(TJ009)<>0  ) AS PUR on TI004=供应商编号 AND TJ004=品号 WHERE 月份='202604'

  /***本月入库结束**/
  SELECT *FROM SDRD..EscrowMaterialDetail WHERE  月份='202604'

  SELECT *FROM SDRD..EscrowMaterialDetail WHERE  月份='202604' AND  品号='350030006200'
  /***本月单价**/
       --------------------------------------------------第四步---------------------------------------------------
   UPDATE SDRD..EscrowMaterialDetail set 本月单价=0 WHERE  月份='202604'

     UPDATE SDRD..EscrowMaterialDetail set 本月单价=dj
  --SELECT 上月结存+本月入库-本月退货 ,SL,上月结存+本月入库-本月退货 -SL,*
  --SELECT * 
  FROM SDRD..EscrowMaterialDetail JOIN   (
SELECT TG005,TH004,I.MB002,I.MB003,SUM(TH015) SL ,SUM(je)/SUM(TH015) dj  
   FROM (

SELECT TG005,TH004,TH015,TH048+TH047 je FROM SDRD..PURTH INNER JOIN SDRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3402'  AND TH014 like '202604%'

--AND TH004='350030006200'
union all
SELECT TI004,TJ004,-TJ009,-(TJ032+TJ033) FROM SDRD..PURTJ INNER JOIN SDRD..PURTI on TI001=TJ001 AND TI002=TJ002  WHERE TJ020 = 'Y' AND TJ009 > 0 AND TI003 like '202604%' AND ((TI001<>'3504' OR TI012 <> '代管料转月月末退货单') AND TI001<>'3503')
--AND TJ004='350030006200'

 ) as PUR JOIN  SDRD..INVMB I  ON MB001=TH004 JOIN SDRD..EscrowMaterialDetail E on 供应商编号=TG005 AND 品号=TH004  AND 月份='202604' 
  
  GROUP BY    TG005,TH004,I.MB002,I.MB003  having SUM(TH015)>0  
 )  as PUR on 供应商编号=TG005 AND 品号=TH004  AND 月份='202604'  WHERE  dj>0
 --AND 上月结存+本月入库-本月退货 <>SL
        --------------------------------------------------第四步---------------------------------------------------
  /***本月单价**/

  /********数据排查开始*******/
  SELECT *FROM   SDRD..EscrowMaterialDetail WHERE 本月单价=0  AND 月份='202604'  AND 上月结存+本月入库-本月退货<>0
  SELECT *   FROM SDRD..EscrowMaterialDetail JOIN   (
SELECT TG005,TH004,I.MB002,I.MB003,SUM(TH015) SL ,SUM(je)/SUM(TH015) dj  
   FROM (

SELECT TG005,TH004,TH015,TH048+TH047 je FROM SDRD..PURTH INNER JOIN SDRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3402'  AND TH014 like '202604%'
union all
SELECT TI004,TJ004,-TJ009,-(TJ032+TJ033) FROM SDRD..PURTJ INNER JOIN SDRD..PURTI on TI001=TJ001 AND TI002=TJ002  WHERE TJ020 = 'Y' AND TJ009 > 0 AND TI003 like '202604%'

 ) as PUR JOIN  SDRD..INVMB I  ON MB001=TH004 JOIN SDRD..EscrowMaterialDetail E on 供应商编号=TG005 AND 品号=TH004  AND 月份='202604' 
  
  GROUP BY TG005,TH004,I.MB002,I.MB003   )  as PUR on 供应商编号=TG005 AND 品号=TH004  AND 月份='202604' 
  
  --AND 品号='300070003300'

  /********数据排查结束*******/


 SELECT *FROM  SDRD..EscrowMaterialDetail  WHERE  总库存=0 AND 月份='202604'

 
 SELECT *FROM  SDRD..EscrowMaterialDetail  WHERE   月份='202604'

 /***更新仓别开始****/
--	UPDATE SDRD..EscrowMaterialDetail set 交易仓别='' WHERE  月份='202604'

--    UPDATE SDRD..EscrowMaterialDetail set 交易仓别=TH009
--  --SELECT *
--  FROM  SDRD..EscrowMaterialDetail JOIN   (

-- SELECT TG005,TH004,max(rtrim(TH009)) TH009 FROM (
--SELECT TG005,TH004,TH015,TH048+TH047 je ,TH009 FROM SDRD..PURTH INNER JOIN SDRD..PURTG on TH001=TG001 AND TH002=TG002
--WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3402'  AND TH014 >= '20260401' AND TH014 <= '20260430'  ) as PUR JOIN SDRD..EscrowMaterialDetail E on 供应商编号=TG005 AND 品号=TH004 AND 月份='202604'
--   GROUP BY TG005,TH004  having SUM(TH015)>0  )as  CB  on 供应商编号=TG005 AND 品号=TH004  AND 月份='202604' 

 --UPDATE SDRD..EscrowMaterialDetail set 交易仓别=case left(品号,1) when '5' then '053'else '052' end 
 -- --SELECT *
 -- FROM SDRD..EscrowMaterialDetail JOIN  [v_Material_SMT] on MaterialID=品号 WHERE 月份='202604' AND  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) 


 --UPDATE SDRD..EscrowMaterialDetail set 交易仓别=StorageID
 -- --SELECT *
 -- FROM SDRD..EscrowMaterialDetail JOIN  v_Material_Checked on MaterialID=品号 WHERE 月份='202604' --AND  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) 

  --SELECT *FROM  v_Material_Checked

 /****更新仓别结束*******/

 

-- SELECT *  FROM  SDRD..EscrowMaterialDetail JOIN   (
--SELECT RTRIM(LA001) MC001, SUM(CASE LA005 WHEN '1' THEN LA011 ELSE 0-LA011 END) MC007 FROM  SDRD..INVLA WHERE LA004 <= '20260430'
-- AND (SELECT COUNT(*) FROM CMSMC WHERE CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%' AND CMSMC.MC001=LA009)>0 
-- GROUP BY  LA001) tb on  MC001=品号  WHERE MC007>0  AND 月份='202604'


/*************更新本月用量与本月结存***/

       --------------------------------------------------第五步---------------------------------------------------
UPDATE SDRD..EscrowMaterialDetail SET 本月结存=0,本月用量=0 WHERE  月份='202604'
 --drop table  #TEMP

 -------------------次月领料扣数:找出
 --DROP TABLE #CYLL
      SELECT * INTO #TEMP FROM WMS..IMS.IMS_IN_OUT_LOG_VIEW WHERE  (1=0)-- TRANSACTION_TIME>'2022-12-20'
	  	--select MB001 PH,MB002 GYS,FLAG SL  INTO #WMSKC from INVMB WHERE 1=2
		--SELECT ERP_BILL_TYPE,WMS_BILL_NO,PART_NO,TRANSACTION_TIME,ENDOR_CODE,QUANTITY INTO #TEMP
	SELECT PH,GYS,SUM(SL) SL into #CYLL FROM (
	SELECT PART_NO PH,QUANTITY SL,VENDOR_CODE GYS FROM COPTHHBTOWMS  JOIN #TEMP ON 领料批次=WMS_BILL_NO AND 品号=PART_NO JOIN COPTHHBMX M on 领料批次=LLPC AND TH004=PART_NO JOIN  COPTG C ON C.TG001=M.TH001 AND C.TG002=M.TH002 AND VENDOR_CODE<>'无' WHERE TG003>='20260401'
	UNION ALL
	SELECT PART_NO,QUANTITY,VENDOR_CODE  FROM #TEMP JOIN MOCTC ON ('IMS-'+TC007=WMS_BILL_NO OR TC001+'-'+TC002=WMS_BILL_NO ) AND ERP_BILL_TYPE LIKE '54%' WHERE TC003>='20260401' AND CREATOR='DS' AND VENDOR_CODE<>'无'
	) AS YF GROUP BY PH,GYS

----WMS剩余库存数量
--DROP TABLE #WMSKC
	SELECT PART_NO PH,VENDOR_CODE GYS,QTY+isnull(SL,0) SL INTO #WMSKC FROM(
	SELECT PART_NO ,VENDOR_CODE,SUM(STOCK_QTY) QTY FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE ) WMSKC LEFT JOIN  #CYLL ON PART_NO=PH AND GYS=VENDOR_CODE WHERE VENDOR_CODE<>'无' 
 
	       --------------------------------------------------第五步---------------------------------------------------
	--SELECT  DISTINCT TG005 FROM PURTH JOIN PURTG ON TH001=TG001 AND TH002=TG002 WHERE TG003>'20190301' ---半年内有采购进货的供应商

	/***检测半年内内是否有交易过数据****/

	--delete FROM  LSSJ..zjdj 
	       --------------------------------------------------第六步---------------------------------------------------
	  INSERT INTO SDRD..EscrowMaterialDetail
  SELECT '202604' ,TG005,MA002,TH004,I.MB002,I.MB003,0,0,0,0,0,0,0,''  FROM (
  SELECT TG005,TH004,TH015 FROM SDRD..PURTH INNER JOIN SDRD..PURTG on TH001=TG001 AND TH002=TG002 JOIN SDRD..EscrowMaterialDetail E on 供应商编号=TG005 AND 品号=TH004  
  WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3402'  AND TH014 >= '20230401' AND TH014 <= '20260430'
  AND TG005<>'21500002' --20260422剔除平伟
  UNION ALL
  SELECT TG005,TH004,TH016 FROM  SDRD..PURTG JOIN SDRD..PURTH ON TG001=TH001 AND TG002=TH002 
  WHERE (PURTG.TG001 = '3403') AND (TH014 >= '20230401' AND TH014 <= '20260430')  
  AND TG005<>'21500002'--20260422剔除平伟
  )   as PUR  JOIN SDRD..PURMA ON TG005=MA001 JOIN  SDRD..INVMB I ON MB001=TH004
  WHERE (
	SELECT COUNT(*) FROM SDRD..EscrowMaterialDetail 
	WHERE 月份='202604' AND 供应商编号=TG005 AND 品号=TH004 
)=0 
--AND    (
--	SELECT COUNT(*) FROM  #WMSKC 
--	WHERE TG005=GYS AND TH004=PH  AND SL >0
--	)>0 
	AND (
	SELECT COUNT(*) FROM  RDSJK..TYGYS WHERE TY01=TG005 AND TY05='SDRD')=0
   AND ( SELECT COUNT(*) FROM  LSSJ..zjdj WHERE ph=TH004)=0
   GROUP BY TG005,MA002,TH004,I.MB002,I.MB003  ---半年内有采购进货的供应商
   
	/****检测半年内内是否有交易过数据****/
 --------------------------------------------------第六步---------------------------------------------------



 --------------------------------------------------第七步---------------------------------------------------	 
  /**总库存核算**/
  UPDATE SDRD..EscrowMaterialDetail set 总库存=0 WHERE  月份='202604'

   UPDATE SDRD..EscrowMaterialDetail set 总库存= MC007 --case when MC007>QTY then QTY else MC007 END 
  --SELECT *
    FROM  SDRD..EscrowMaterialDetail JOIN (
  --SELECT MB001 LA001,MC002 LA009,INVNUMA LA011,INVMONEY LA013 FROM  V_KCMX  
  --注意修改日期，最后一天
SELECT RTRIM(MC01) MC001, sum(MC07) MC007 FROM  [Fn_GetKCMX]('20260430','')  v WHERE (SELECT COUNT(*) FROM CMSMC WHERE CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%' AND CMSMC.MC001=v.MC02)>0 
 GROUP BY  MC01) tb on  MC001=品号 
 --JOIN (SELECT PART_NO,VENDOR_CODE,SUM(STOCK_QTY) QTY FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE  ) B on 品号=PART_NO AND 供应商编号=VENDOR_CODE
  WHERE MC007>0  AND 月份='202604'


 --------------------------------------------------第七步---------------------------------------------------	 
--  --SELECT *
--  FROM  SDRD..EscrowMaterialDetail JOIN (
--SELECT RTRIM(LA001) MC001, SUM(CASE LA005 WHEN '1' THEN LA011 ELSE 0-LA011 END) MC007 FROM  SDRD..INVLA WHERE LA004 <= '20260430'
-- AND (SELECT COUNT(*) FROM CMSMC WHERE CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%' AND CMSMC.MC001=LA009)>0 
-- GROUP BY  LA001) tb on  MC001=品号 
-- --JOIN (SELECT PART_NO,VENDOR_CODE,SUM(STOCK_QTY) QTY FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE  ) B on 品号=PART_NO AND 供应商编号=VENDOR_CODE
--  WHERE MC007>0  AND 月份='202604'


  SELECT * FROM WMS..IMS.IMS_IN_OUT_LOG_VIEW

  
--SELECT  供应商简称,品号,品名,规格, 本月结存,QTY,本月单价  FROM   SDRD..EscrowMaterialDetail 
--left JOIN (SELECT PART_NO,VENDOR_CODE,SUM(STOCK_QTY) QTY FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE  ) B on 品号=PART_NO AND 供应商编号=VENDOR_CODE
--WHERE 月份='202604' AND 供应商简称='恒辉电阻' 
 /**总库存核算**/




	
 --SELECT*FROM  SDRD..EscrowMaterialDetail WHERE 月份='202604' AND 上月结存=0 AND 本月入库=0 
 --SELECT*FROM  SDRD..EscrowMaterialDetail WHERE 月份='202604' AND 总库存=0
 --SELECT *FROM  #WMSKC WHERE  SL<=0

	--SELECT *FROM  #WMSKC WHERE PH='300080103800'
	--SELECT *FROM  SDRD..v_EscrowMaterial WHERE MB001='300080006700' AND MA001='20533685'  
	--select MB001 PH,MB002 GYS,FLAG SL  INTO #WMSKC from INVMB WHERE 1=2

 --------------------------------------------------第八步---------------------------------------------------	 
	 UPDATE B set 本月单价=dj
-- SELECT*
FROM SDRD..EscrowMaterialDetail B JOIN  (
SELECT TH014,TG005,TH004,max(cast((TH048+TH047)/TH015 as numeric(18,6))) dj FROM SDRD..PURTH INNER JOIN SDRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 
--AND ( TH001= '3401'  OR TH001= '3405' )-- AND TH014 like '201908%' 
AND TH014+TG005+TH004  IN(
SELECT MAX(TH014)+TG005+TH004  FROM SDRD..PURTH INNER JOIN SDRD..PURTG on TH001=TG001 AND TH002=TG002 WHERE TH030 = 'Y' AND TH016 > 0 --AND ( TH001= '3401' OR TH001= '3405' ) --AND TH014 like '201908%'
group by TG005,TH004 )group by TH014,TG005,TH004) as jhdj on TG005=供应商编号 AND  品号=TH004 AND  月份='202604' AND isnull(本月单价,0)=0
	



 UPDATE SDRD..EscrowMaterialDetail SET 本月结存=本月结存1,本月用量=本月用量1 
-- SELECT Z.*  ,本月结存1,本月用量1,KCSL,isnull(SL,0)
FROM  SDRD..EscrowMaterialDetail Z JOIN   (

SELECT W.*,KCSL
--,case when 入库数量-isnull(SL/KCSL,0)*总库存>0 then cast(isnull(SL/KCSL,0)*总库存 as int) else 入库数量 end 本月结存1
,case when isnull(SL,0)>=总库存 then cast(isnull(isnull(SL,0)/KCSL,0)*总库存 as int) else isnull(SL,0) end  本月结存1

--,入库数量-case when 入库数量-isnull(SL/KCSL,0)*总库存>0 then cast(isnull(SL/KCSL,0)*总库存 as int) else 入库数量 end 本月用量1
,入库数量-case when isnull(SL,0)>=总库存 then cast(isnull(isnull(SL,0)/KCSL,0)*总库存 as int) else isnull(SL,0) end  本月用量1

 FROM (
SELECT  *,(上月结存+本月入库-本月退货) 入库数量 FROM SDRD..EscrowMaterialDetail left JOIN #WMSKC ON  供应商编号=GYS AND 品号=PH) W  left JOIN ( SELECT PH,SUM(SL) KCSL FROM  SDRD..EscrowMaterialDetail  JOIN #WMSKC ON  供应商编号=GYS AND 品号=PH WHERE 月份='202604' group by PH) as NL on  W.品号=NL.PH  AND KCSL>0 WHERE 月份='202604'

 ) as HZ on HZ.月份= Z.月份 AND HZ.供应商编号=Z.供应商编号 AND HZ.品号=Z.品号 
 --AND Z.品号='300080178800'

 
 --------------------------------------------------第八步---------------------------------------------------



 --DELETE SDRD..EscrowMaterialDetail WHERE 月份='202604' AND 供应商编号='21500002'
 --SELECT*FROM  SDRD..EscrowMaterialDetail WHERE 月份='202604' AND 供应商编号='21500002'
 SELECT *FROM  #WMSKC WHERE PH='300080006700'

SELECT  W.*,(上月结存+本月入库-本月退货) 入库数量,总入库数
 FROM   SDRD..EscrowMaterialDetail W JOIN ( SELECT N.品号,SUM(上月结存+本月入库-本月退货) 总入库数 FROM SDRD..EscrowMaterialDetail N WHERE N.月份='202604' group by N.品号) as NL on  W.品号=NL.品号  
 WHERE 月份='202604' AND 总入库数>0

/*************更新本月用量与本月结存***/


 --------------------------------------------------第九步---------------------------------------------------
/**主要仓库**/
 UPDATE SDRD..EscrowMaterialDetail set 交易仓别=MB017
  --SELECT *
  FROM SDRD..EscrowMaterialDetail JOIN  INVMB on 品号=MB001 WHERE 月份='202604' --AND  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%'))
/**主要仓库**/

--/**主要仓库**/
-- UPDATE SDRD..EscrowMaterialDetail set 交易仓别=StorageID
--  --SELECT *
--  FROM SDRD..EscrowMaterialDetail JOIN  v_Material_Checked on MaterialID=品号 WHERE 月份='202604' --AND  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) 
--/**主要仓库**/

 --------------------------------------------------第九步---------------------------------------------------  本月退仓后执行代管料处理开退货单
  SELECT sum(本月结存*本月单价)  FROM   SDRD..EscrowMaterialDetail WHERE 月份='202604'  AND 本月结存>0 --AND 供应商简称='恒辉电阻'
  SELECT *FROM SDRD..EscrowMaterialDetail WHERE 月份='202604'  
    SELECT *FROM SDRD..EscrowMaterialDetail WHERE 月份='202310'  

	  SELECT 供应商编号,品号 FROM SDRD..EscrowMaterialDetail WHERE 月份='202604'  

SELECT * FROM LSSJ..LSCGTH 
--SELECT *FROM  SDRD..EscrowMaterialDetail WHERE 月份='202604' AND 本月结存>0 AND 供应商简称 not in('盛中','恒辉电阻','呈林','粤翔','嘉凯') 


delete FROM LSSJ..LSCGTH

declare @No int--单号编号
declare @FormNo varchar(11)--单号前缀
set @FormNo='202604'--本月月份
SELECT @No=right(rtrim(isnull(MAX(TI002),'00000')),5) FROM SDRD..PURTI  WHERE TI001='3504' AND left(TI002,6)=@FormNo
--SELECT @No
insert into LSSJ..LSCGTH(单号, 序号, 供应商, 品号, 品名, 规格, 单位, 数量, 单价, 仓库)
SELECT @FormNo + right(cast((100000+@No+DENSE_RANK() OVER(ORDER BY 供应商编号 asc )) as varchar(6)),5),10000+ROW_NUMBER() over(partition by 供应商编号 order by 品号)
,供应商编号,品号,品名,规格,'',本月结存,本月单价,交易仓别 FROM SDRD..EscrowMaterialDetail WHERE 月份='202604' AND 本月结存>0   AND 供应商简称 not in('盛中','恒辉电阻','呈林','粤翔','嘉凯','安林电子','平伟','江盟')
AND (SELECT COUNT(*) FROM  RDSJK..TYGYS WHERE TY01=供应商编号 AND TY05='SDRD')=0
order by 供应商编号,品号


SELECT * FROM SDRD..EscrowMaterialDetail WHERE 月份='202604'
--SELECT *FROM   LSSJ..LSCGTH WHERE 单价=0


 --------------------------------------------------第十步---------------------------------------------------次月进仓执行代管料处理开进货单
delete FROM LSSJ..LSCGTH WHERE  品号='316010012300'
delete FROM LSSJ..LSCGTH 

declare @No int--单号编号
declare @FormNo varchar(11)--单号前缀
set @FormNo='202605'--次月月份 注意修改时间 次月
SELECT @No=right(rtrim(isnull(MAX(TG002),'00000')),5) FROM SDRD..PURTG  WHERE TG001='3403' AND left(TG002,6)=@FormNo
--SELECT @No
insert into LSSJ..LSCGTH(单号, 序号, 供应商, 品号, 品名, 规格, 单位, 数量, 单价, 仓库)
SELECT @FormNo + right(cast((100000+@No+DENSE_RANK() OVER(ORDER BY 供应商编号 asc )) as varchar(6)),5),10000+ROW_NUMBER() over(partition by 供应商编号 order by 品号)
,供应商编号,品号,品名,规格,'',本月结存,本月单价,CASE WHEN StorageID IS NULL THEN 交易仓别 ELSE StorageID END  交易仓别 FROM SDRD..EscrowMaterialDetail LEFT JOIN [dbo].[v_Material_Checked] on 品号=MaterialID WHERE 月份='202604' AND 本月结存>0  AND 供应商简称 not in('盛中','恒辉电阻','呈林','粤翔','嘉凯','安林电子','平伟','江盟') 
AND (SELECT COUNT(*) FROM  RDSJK..TYGYS WHERE TY01=供应商编号 AND TY05='SDRD')=0
order by 供应商编号,品号


SELECT *  FROM   SDRD..EscrowMaterialDetail WHERE 月份='202604' AND 供应商简称  in('盛中','恒辉电阻','呈林','粤翔','嘉凯')

SELECT *  FROM   SDRD..EscrowMaterialDetail WHERE 月份='202604' AND 本月用量<0

SELECT sum((本月结存)*本月单价)  FROM   SDRD..EscrowMaterialDetail WHERE 月份='202401'

SELECT *FROM  LSSJ..LSCGTH WHERE  供应商='20533714'


SELECT *FROM SDRD..EscrowMaterialDetail WHERE 月份='202604' AND  品号='304090081300'

SELECT *FROM  PURTH JOIN PURTG ON TH001=TG001 AND TH002=TG002 WHERE TH001='3403' AND TG016='代管料转月月初入库单' AND TG003='20260401'

DELETE FROM  LSSJ..zjcgrk

SELECT *FROM  LSSJ..zjcgrk  
SELECT *FROM  SDRD..EscrowMaterialDetail WHERE 月份='202604' AND 本月结存>0   AND 供应商简称 not in('盛中','恒辉电阻','呈林','粤翔','嘉凯') AND (SELECT COUNT(*)FROM   LSSJ..zjcgrk
JOIN PURTH ON TH001+'-'+TH002+'-'+TH003=cgdh WHERE TH004=品号  )>0
  

INSERT INTO LSSJ..zjcgrk(cgdh,dj) SELECT TH001+'-'+TH002+'-'+TH003,本月单价
--SELECT TH004,本月单价,TH018 
FROM  SDRD..PURTH JOIN SDRD..PURTG ON TH001=TG001 AND TH002=TG002 
JOIN  SDRD..EscrowMaterialDetail ON TG005=供应商编号 AND 品号=TH004 AND 月份='202604' WHERE TH001='3403' AND TG016='代管料转月月初入库单' AND TG003='20260501' AND 本月单价<>TH018


INSERT INTO LSSJ..zjcgrk(cgdh,dj) SELECT TJ001+'-'+TJ002+'-'+TJ003,本月单价
--SELECT 本月单价,TJ008,TI004,TJ004,TJ009,(TJ032+TJ033)
 FROM SDRD..PURTJ INNER JOIN SDRD..PURTI on TI001=TJ001 AND TI002=TJ002 
 JOIN  SDRD..EscrowMaterialDetail ON TI004=供应商编号 AND 品号=TJ004 AND 月份='202604'  WHERE TI001='3504'  AND TI003 = '20260430' AND  TJ020 = 'Y' AND TJ009 > 0 AND TI012 ='代管料转月月末退货单' AND 本月单价<>TJ008

 
SELECT  供应商简称,品号,品名,规格, 本月结存,QTY,本月单价  FROM   SDRD..EscrowMaterialDetail 
left JOIN (SELECT PART_NO,VENDOR_CODE,SUM(STOCK_QTY) QTY FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE  ) B on 品号=PART_NO AND 供应商编号=VENDOR_CODE
WHERE 月份='202604' AND 供应商简称='恒辉电阻' AND 品号='300080051100'


--SELECT * FROM  WMS..IMS.[IMS_VENDOR_STOCK_V] GROUP BY PART_NO,VENDOR_CODE 

-- SELECT *
--FROM  PURTH JOIN PURTG ON TH001=TG001 AND TH002=TG002 
--JOIN  PURMB ON MB001=TH004 AND MB002=TH004 AND (PURMB.MB015 >= '20260401' OR  ISNULL(PURMB.MB015,'')='') WHERE TH001='3403' AND TG016='代管料转月月初入库单' AND TG003='20260401' AND MB011<TH018


--SELECT *FROM  PURMB WHERE (PURMB.MB015 >= '20260401' OR  ISNULL(PURMB.MB015,'')='')
















/**
供应商代号	料号	品名	规格	本月用量	单价	仓库


SELECT TG005,TH004,I.MB002,I.MB003,SUM(TH015) SL ,SUM(je)/SUM(TH015) dj ,rtrim(TH009)  FROM (
SELECT TG005,TH004,TH015,TH048+TH047 je ,TH009
FROM SDRD..PURTH INNER JOIN SDRD..PURTG on TH001=TG001 AND TH002=TG002
WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3402'  AND TH014 >= '20260401' AND TH014 <= '20260430'  

union all
SELECT TI004,TJ004,-TJ009,-(TJ032+TJ033),

(SELECT MAX( TH009)
FROM SDRD..PURTH INNER JOIN SDRD..PURTG on TH001=TG001 AND TH002=TG002
WHERE TH030 = 'Y' AND TH016 > 0 AND TH001 <> '3402'  AND TH014 >= '20260401' AND TH014 <= '20260430' AND TI004=TG005 AND TJ004=TH004   )


 FROM SDRD..PURTJ INNER JOIN SDRD..PURTI on TI001=TJ001 AND TI002=TJ002--退货不加仓别
 WHERE TJ020 = 'Y' AND TJ009 > 0 AND TI003 >= '20260401' AND TI003 <= '20260430' 
 ) as PUR JOIN  SDRD..INVMB I  ON MB001=TH004 JOIN SDRD..v_EscrowMaterial E on MA001=TG005 AND E.MB001=TH004
 
  GROUP BY    TG005,TH004,I.MB002,I.MB003,TH009  having SUM(TH015)>0  order by TG005,TH004

  --SELECT *FROM  SDRD..v_EscrowMaterial


  SELECT *FROM  SDRD..EscrowMaterialDetail 
  UPDATE  SDRD..EscrowMaterialDetail SET 规格=MB003
FROM  SDRD..EscrowMaterialDetail JOIN INVMB ON 品号=MB001



--SELECT *FROM  INVTB WHERE TB002='20260400042' 


  SELECT *FROM  SDRD..EscrowMaterialDetail 
  SELECT *
  UPDATE   SDRD..EscrowMaterialDetail SET 上月结存=TB007
  FROM  SDRD..EscrowMaterialDetail JOIN (SELECT INVTA.UDF02 ,TB004,TB007 FROM  INVTB JOIN INVTA ON TA001=TB001 AND TA002=TB002 WHERE  TB001='1112'AND INVTB.CREATE_DATE='20260401104834473') AS ZY ON 品号=TB004 AND UDF02=供应商编号
  

  SELECT INVTA.UDF02 ,TB004,TB007 FROM  INVTB JOIN INVTA ON TA001=TB001 AND TA002=TB002 WHERE  TB001='1112' AND TA003 LIKE '202604%'
 
  UPDATE   SDRD..EscrowMaterialDetail SET 本月入库=TB007
  FROM  SDRD..EscrowMaterialDetail JOIN (SELECT INVTA.UDF02 ,TB004,sum(TB007) TB007 FROM  INVTB JOIN INVTA ON TA001=TB001 AND TA002=TB002 WHERE  TB001='1112' AND TA003 like '202604%' AND INVTB.CREATE_DATE not  like '%104834473' group by  INVTA.UDF02 ,TB004) AS ZY ON 品号=TB004 AND UDF02=供应商编号
 
  UPDATE   SDRD..EscrowMaterialDetail SET 本月结存=0TB007
  FROM  SDRD..EscrowMaterialDetail JOIN (SELECT INVTA.UDF02 ,TB004,sum(TB007)TB007 FROM  INVTB JOIN INVTA ON TA001=TB001 AND TA002=TB002 WHERE  TB001='1112' AND TA003 like '202604%' AND INVTB.CREATE_DATE   like '20260430104834473' group by  INVTA.UDF02 ,TB004) AS ZY ON 品号=TB004 AND UDF02=供应商编号


   UPDATE   SDRD..EscrowMaterialDetail SET 本月用量=TH016,本月单价=TH018
  --SELECT *
  FROM  SDRD..EscrowMaterialDetail right JOIN
 ( SELECT TG005,TH004,SUM(TH016) TH016,TH018 FROM  SDRD..PURTG JOIN SDRD..PURTH ON TG001=TH001 AND TG002=TH002 WHERE TG001 = '3403' AND (TH014 = '20260430') GROUP BY TG005,TH004,TH018) AS RK on 品号=TH004 AND TG005=供应商编号 WHERE 品号='304090138400'

 UPDATE   SDRD..EscrowMaterialDetail SET 本月结存=TH016
--SELECT *
  FROM  SDRD..EscrowMaterialDetail right JOIN
 ( SELECT TG005,TH004,SUM(TH016) TH016,TH018 FROM  SDRD..PURTG JOIN SDRD..PURTH ON TG001=TH001 AND TG002=TH002 WHERE (PURTG.TG001 = '3401')
  AND (PURTG.TG014 = '20260401')
  AND (PURTG.TG016 = '代管料转月入库单') GROUP BY TG005,TH004,TH018) AS RK on 品号=TH004 AND TG005=供应商编号



SELECT *,(上月结存+本月入库)-(本月用量+本月结存)
  FROM  SDRD..EscrowMaterialDetail WHERE (上月结存+本月入库)<>(本月用量+本月结存) order by 供应商编号,品号

  UPDATE SDRD..EscrowMaterialDetail set 上月结存=(本月用量+本月结存) -本月入库
  --SELECT *
  FROM  SDRD..EscrowMaterialDetail WHERE 供应商编号='20533661'

  SELECT *FROM  SDRD..v_EscrowMaterial

  ***/
 
  /*ddd**/


