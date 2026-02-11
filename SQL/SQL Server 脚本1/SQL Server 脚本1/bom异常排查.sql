select *from BOMMD_GJ where MD001='100705920000' and MD003='301030062000'

301030062000

select *from  ZJRD..MOCTA where TA002 = '24110700071'  OR (TA002 = '24082000281')

 update   ZJRD..MOCTA set TA011='2' where TA002 = '24110700071'  OR (TA002 = '24082000281')




 SELECT  *from  real_sit.ERP_BOMMD_ODS where trim(MD001)='100705920000'  and trim(MD003)='301030062000' order by INSERT_TIME 
 
 select *from cpc_eco_interface where batch_session_id='2774931_1750399201211_1013636' 
 select *from cpc_eco_interface where asmcode='1M4700010000'   order by last_update_time desc 
 select *from cpc_eco_interface where asmcode='237702800000' and itemcode  in ('303000354900','') order by last_update_time desc 

 select *from cpc_bom_interface where asmcode='1N9700020000'
 and itemcode  in ('303000354900','')
 
 select *from BOMMC_GJ where MC001 in('272701850000','172701140000        ')
 SELECT  *from  BOMMD_GJ where trim(MD001)='237702800000' and trim(MD003) in ('303000354900','303010017700','303000184900')

 SELECT  *from  BOMMC_GJ where trim(MC001)='237702800000' and trim(MD003) in ('303000354900','303010017700','303000184900')
 

 select *from BOMMD_GJ where MD003='107908920000'
    
 
 select *from BOMMC_GJ where MC001 in('107908920000','')
 UPDATE   BOMMC_GJ SET UDF05='N' WHERE MC001='172701140000        '




 select *from  WorkOrderDataCheck1 where WO='5102-24112700539'
 and WO_MaterialCode='300080371900'

 select *from cpc_eco_interface where asmcode='1N9700020000' and location='R12,R27,R31'

 select*from  BOMMC WHERE MC001='2C6700670000                '
 
 select MB110,*from  INVMB WHERE MB001='2M4700030AX0'
 
 SELECT  *from  BOMMC_GJ where trim(MC001)='2M4700020000                ' 


 SELECT  * FROM BOMMD_GJ WHERE MD001 IN ('1M4700010000','1M4700020000','1M4700030000','2M4700010000','2M4700040000','2M4700030000','2M4700020000')

 SELECT  *from  BOMMD_GJ where trim(MD003)='1C6700530000                                ' 
 SELECT  *from  BOMMD_GJ where trim(MD001)='2M4700040000                                ' 
 SELECT  *from  BOMMC_GJ where trim(MC001)='100706350000' 

 SELECT  *from  cpc_bom_interface where batch_session_id='958021_1745201520291_975681'  and itemcode like '%P%'
 SELECT  *from  cpc_bom_interface where batch_session_id='958021_1745201520291_975681'  and asmcode='2M4700010000'

 SELECT  *from  cpc_bom_interface where batch_session_id='4234764_1745476233212_978162' and trim(location) like '%C117%' 
 
 SELECT  *from  cpc_bom_interface where trim(itemcode)='1M4700010000' or trim(asmcode)='107908920000' order by last_update_time desc
 SELECT  *from  cpc_bom_interface where trim(itemcode)='1M4700010000'   order by last_update_time desc
 SELECT  *from  cpc_bom_interface where trim(asmcode)='1M4700010000'   order by last_update_time desc
 SELECT  *from  cpc_bom_interface where trim(asmcode)='136208660000'  and trim(itemcode)='303000300400'  order by last_update_time desc
 
 SELECT  *from  cpc_bom_interface order by last_update_time desc
  SELECT left(last_update_time,10) from  cpc_bom_interface order by last_update_time desc
  
  SELECT left(last_update_time,10),COUNT(*) from  cpc_bom_interface group by left(last_update_time,10)order by left(last_update_time,10) desc


 SELECT  *from  cpc_bom_interface where trim(asmcode)='114294380010' order by last_update_time desc

 SELECT  *from  cpc_bom_interface where trim(asmcode)='2H1700400000' and location like '%U2%' order by last_update_time desc
 SELECT  *from  cpc_bom_interface where trim(asmcode)=' ' and location like '%R133,R134,R141,R144%' order by last_update_time desc

 SELECT  *from  cpc_bom_interface where trim(itemcode)='134010170000'  and trim(location) like '%C117%' 
 
 SELECT  *from  BOMMD  where trim(MD001)='207908920AX0' and MD019 like '%C117%' ---正式BOM

 SELECT  *from  BOMMD_GJ where trim(MD001)='100706350000' and trim(MD003)='401000001100'
 
 select *from [cdc].[dbo_BOMMD_CT] where trim(MD001)='2E1700680AX0'  and trim(MD003)='401000001100'

 
 select MAX(CREATE_DATE),MIN(CREATE_DATE) from [cdc].[dbo_BOMMD_CT]
 
 select top 1000 * from [cdc].[dbo_BOMMD_CT] order by CREATE_DATE desc 


 
 SELECT  *from  real_sit.ERP_BOMMD_DW where trim(MD001)='200705920AX0'  and trim(MD003)='401000001100' order by INSERT_TIME 



 
SELECT MC001 FROM BOMMC_GJ with(nolock) WHERE MC001=UDF04 AND UDF05='U' 

SELECT *FROM INVMB WHERE EXISTS (SELECT MC001 FROM BOMMC_GJ with(nolock) WHERE MC001=UDF04 AND UDF05='U' AND MC001=asmcode  ) 

DROP TABLE #CPB
SELECT * INTO #CPB FROM (
SELECT MC001 FROM BOMMC_GJ with(nolock) WHERE MC001=UDF04 AND UDF05='U' 

UNION ALL
SELECT MD003 FROM BOMMD_GJ B WHERE EXISTS (SELECT MC001 FROM BOMMC_GJ with(nolock) WHERE MC001=UDF04 AND UDF05='U' AND MC001=MD001  ) AND LEFT(MD003,1) IN('2','1','A')
UNION ALL
SELECT MD003 FROM BOMMD_GJ A WHERE EXISTS (
SELECT MD003 FROM BOMMD_GJ B WHERE EXISTS (SELECT MC001 FROM BOMMC_GJ with(nolock) WHERE MC001=UDF04 AND UDF05='U' AND MC001=MD001  ) AND LEFT(MD003,1) IN('2','1','A')
AND A.MD001=B.MD003
) AND LEFT(MD003,1) IN('2','1','A')
)CP


 select *from cpc_eco_interface  WHERE itemcode='107908920000' ORDER BY last_update_time DESC
 select *from cpc_eco_interface  WHERE EXISTS (SELECT MC001 FROM #CPB with(nolock) WHERE  MC001=asmcode  ) ORDER BY last_update_time DESC

 
 SELECT  *from  cpc_bom_interface  WHERE EXISTS (SELECT MC001 FROM #CPB with(nolock) WHERE  MC001=asmcode  ) ORDER BY last_update_time DESC



 
update BOMMC_GJ set  UDF05='N' WHERE MC001=UDF04 AND UDF05='U'
SELECT count(*) FROM BOMMC_GJ with(nolock) WHERE MC001=UDF04 AND UDF05='U' 

 DECLARE @INT INT  
SET  @INT=1
While (( SELECT count(*) FROM BOMMC_GJ with(nolock) WHERE MC001=UDF04 AND UDF05='N' and  MODI_DATE<=dbo.fn_cpc_date_to_char( Dateadd(MINUTE,-5,GETDATE()))  ) > 0  AND @INT<=10000 )--找未处理数据，如果传入的主键品号非空时，处理当前主键品号
begin	 
   DECLARE  @GJMC01 varchar(12)
   select Top 1  @GJMC01= MC001 From  BOMMC_GJ with(nolock) WHERE MC001=UDF04 AND UDF05='N' and  MODI_DATE<=dbo.fn_cpc_date_to_char( Dateadd(MINUTE,-5,GETDATE())) order by CREATE_DATE desc
   exec [bom_gj_struct_change] @GJMC01
   SET  @INT=@INT+1
end




update BOMMC_GJ set  UDF05='N' where MC001='1M4700010000'
  exec [bom_gj_struct_change] '1M4700010000'


--  20250417181519180
 SELECT  *from  cpc_bom_interface where batch_session_id='7504609_1744884913899_973565' 



select *from  BOMMC_GJ where MC001='1N9700020000'

   select  MC001,* From  BOMMC_GJ with(nolock) WHERE MC001=UDF04 AND UDF05='N'  order by CREATE_DATE desc



   
			select *from  BOMMD  WHERE MD001='1C6700530000'
		
select *from  BOMMD_GJ where MD001='1C6700530000'  and MD003 like '2%'

select *from  BOMMD_GJ where MD001='1C6700530000' and MD003 like '2%'
select *from  BOMMD_GJ where MD001='2C6700670000        ' and MD003 like '2%'


			select *from  BOMMD  WHERE MD001='2C6700530AX0'

			select *from BOMMD_GJ where MD001 in('2C6700681000' ,'2C6700670000')
			select *from BOMMD_GJ where MD001 in('2C6700681000' ,'2C6700670000','1C6700530000')
			and MD003 in('300140040700','361030004400')


			select *from   Fn_GJ_GetBOMIDs_For_GJ('1M4700010000')WHERE MD01='1M4700030000        '

			select *from   Fn_GetBOMIDs_For_GJ('1M4700010000') WHERE MD01='1M4700030000        '

			select *from   Fn_GJ_GetBOMIDs_For_GJ('137705320000')

			select *from   Fn_GetBOMIDs_For_GJ('137705320000') 

/**第一步**/
--PLM数据同步表（新BOM结构）：select *from   cpc_bom_interface
--调用处理逻辑：[dbo].[sp_cpc_bom_create]

--PLM数据同步表（BOM变更）：select *from cpc_eco_interface
--调用处理逻辑：[dbo].[sp_cpc_eco_create]

/**第一步**/

/**第二步**/
--处理结果存入：BOMMC_GJ（BOM转换表头） ;BOMMD_GJ(BOM表转换单身)
/**第二步**/

/**第三步**/

--调用处理逻辑：bom_gj_struct_change 

--处理结果存入：BOMMC（BOM表头） ;BOMMD(BOM表单身)
/**第三步**/