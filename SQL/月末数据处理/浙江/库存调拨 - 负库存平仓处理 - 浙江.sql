--select * From (
--select RTRIM(LA001) MC001,RTRIM(LA009) MC002, SUM(LA011*LA005) MC007 FROM  .INVLA WHERE LA004 <= '20190331' GROUP BY  LA001,LA009-- HAVING(SUM(CASE LA005 WHEN '1' THEN LA011 ELSE 0-LA011 END))>0 OR SUM(CASE LA005 WHEN '1' THEN LA013 ELSE 0-LA013 END)>0  
--) tb where MC007<0




--select * From (
--select RTRIM(LA001) MC01,RTRIM(LA009) MC02, SUM(LA011*LA005) MC07 FROM  .INVLA WHERE LA004 >= '20190331' GROUP BY  LA001,LA009 HAVING(SUM(LA011*LA005))<>0 
--) tb where (select count(*) from CMSMC where CMSMC.UDF01 like '%-良品'  AND CMSMC.MC002 not like '%车间仓%' and MC001=MC02)>0 and (select COUNT(*) from v_SMTWL where MB01=MC01)>0 AND MC02<>'052' AND MC07<>0


--select * from CMSMC where CMSMC.UDF01 like '%-良品'  AND CMSMC.MC002 not like '%车间仓%'

--select * From (
--select MC001 MC01,MC002 MC02, MC007 MC07 FROM  .INVMC WHERE MC007 <>0 
--) tb where (select count(*) from CMSMC where CMSMC.UDF01 like '%-良品'  AND CMSMC.MC002 not like '%车间仓%' and MC001=MC02)>0 and (select COUNT(*) from v_SMTWL where MB01=MC01)>0 AND MC02<>'052' AND MC07<>0




--select *from v_SMTWL 


declare @FormID varchar(4)--审核人ID
declare @FormNo varchar(11)--审核人ID
declare @dt varchar(11)--审核人ID
declare @dt1 varchar(11)--审核人ID
set @FormID='1271'
set @dt1='20260131'
set @dt=left(@dt1,6)
select @FormNo=isnull(  left(Rtrim(max(TA002)),len(@dt))+Rtrim(right('00000'+cast(convert(int,Right(max(TA002),11-len(@dt)))+1 as varchar),11-len(@dt)))  , @dt+'00001')  from dbo.INVTA where TA001=@FormID and left(TA002,len(@dt)) = @dt
select @FormNo

insert into INVTA
SELECT   '0001','01001','01001','20260131113934473','','',1, @FormID TA001, @FormNo TA002, @dt1 TA003, TA004, 
                TA005,'N' TA006 , TA007, TA008, TA009, TA010, TA011, TA012, TA013, @dt1 TA014, TA015, TA016, TA017, TA018, TA019, TA020, 
                TA021, TA022, TA023, TA024, TA025, TA026, TA027, TA028, TA029, TA030, TA031, UDF01, UDF02, UDF03, UDF04, 
                UDF05, UDF06, UDF51, UDF52, UDF53, UDF54, UDF55, UDF56
FROM      INVTA
WHERE   (TA001 = @FormID) AND (TA002 = '20200900003')


--select tb.* into #tempStock from (
--select * From (
--select MC001 MC01,MC002 MC02, MC007 MC07 FROM  .INVMC WHERE MC007 <>0 
--) tb where (select count(*) from CMSMC where  CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%'AND CMSMC.MC002 not like '%非ROHS%' and MC001=MC02)>0 and (select count(*) from [v_Material_SMT] where  ((MaterialID  LIKE '5%') or (Type like 'SMT' AND MaterialID LIKE '3%')) AND MaterialID=MC01)>0 AND MC02<>'052' AND MC07<>0

--) tb  join dbo.CMSMC on tb.MC02=CMSMC.MC001 where CMSMC.MC004='1' 

DROP TABLE #tempStock

select tb.* 
into #tempStock
 from (
   select MC001 MC01,MC002  as inCK,MC007 MC07,ROW_NUMBER() over(partition by 1 order by MC007 desc) as rows from (
select INVLA.* from (
--select RTRIM(LA001) MC001,RTRIM(LA009) MC002, SUM(LA011*LA005) MC007 FROM  .INVLA WHERE LA004 <= '20190530' GROUP BY  LA001,LA009 

SELECT MC01 MC001,MC02 MC002,MC07 MC007 FROM [Fn_GetKCMX]('20260131','')  

) INVLA  join dbo.CMSMC on INVLA.MC002=CMSMC.MC001 where CMSMC.MC004='1' and CMSMC.MC018='Y' and CMSMC.UDF01 like '%-良品'  and INVLA.MC007<0 --AND CMSMC.MC002 not like '%车间仓%'
AND CMSMC.MC002 not like '%外协仓%'AND CMSMC.MC002 not like '%非ROHS%'
) INVLA 

) as tb order by MC07

--SELECT *FROM #tempStock

drop table #tempStock2

select tb.* 
into #tempStock2
 from (
   select MC001 ,MC002  as outCK,MC007 ,ROW_NUMBER() over(partition by 1 order by MC007 desc) as rows1 from (
select INVLA.* from (
--select RTRIM(LA001) MC001,RTRIM(LA009) MC002, SUM(LA011*LA005) MC007 FROM  .INVLA WHERE LA004 <= '20190530' and (select count(*)from  #tempStock where RTRIM(LA001)=MC01  )>0 GROUP BY  LA001,LA009 
SELECT MC01 MC001,MC02 MC002,MC07 MC007 FROM [Fn_GetKCMX]('20260131','') mx  WHERE  (select count(*)from  #tempStock s where RTRIM(mx.MC01)=s.MC01  )>0 


) INVLA  join dbo.CMSMC on INVLA.MC002=CMSMC.MC001 where CMSMC.MC004='1' and CMSMC.MC018='Y' and CMSMC.UDF01 like '%-良品' and INVLA.MC007>0 --AND CMSMC.MC002 not like '%车间仓%'
	AND CMSMC.MC002 not like '%外协仓%'AND CMSMC.MC002 not like '%非ROHS%'
) INVLA 

) as tb order by MC007

--SELECT *FROM #tempStock2

--
--select *from  #tempStock WHERE  MC01='302020002100'


insert into INVTB
SELECT  '0001','01001','01001','20260131113934473','','',1, @FormID TB001,  @FormNo TB002, RIGHT('0000'+CAST(rows as varchar(4)),4) as TB003, MB001 as TB004, 
                MB002 as TB005, MB003 as TB006, MC07 as TB007, MB004 as TB008, TB009, 0 as TB010, 0 as TB011, outCK as TB012, inCK as TB013, TB014, TB015, TB016, TB017, 'N' TB018, @dt1 TB019, 
                TB020, TB021, TB022, TB023, TB024, TB025, TB026, TB027, TB028, TB029, TB030, TB031, TB032, TB033, TB034, 
                TB035, TB036, TB037, UDF01, UDF02, UDF03, UDF04, UDF05, UDF06, UDF51, UDF52, UDF53, UDF54, UDF55, 
                UDF56
FROM  INVTB
join (

select MC2.MC01, outCK, inCK,MC2.MC07,ROW_NUMBER() over(partition by 1 order by MC2.MC07 desc) as rows From  

(
select A.MC01,A.inCK,outCK,-A.MC07 MC07 from #tempStock A JOIN (select MC001 MC1,outCK,MC007 from #tempStock2 B where MC007>0) AS B ON B.MC1=MC01

) MC2 

) tb
join (select MB001,MB002,MB003,MB004 From INVMB ) tb1 on MC01=MB001
 on 
   (TB001 = '1271') AND (TB002 = '20200900003') 
   order by MB001











    DROP TABLE #KC
SELECT MX.* INTO #KC FROM [Fn_GetKCMX]('20260131','') MX 

delete from  #tempStock2

insert into  #tempStock2

SELECT MX.MC01,MC001,(MX.MC07) MC07,ROW_NUMBER() over(partition by 1 order by MX.MC07 desc) as rows  FROM #KC MX JOIN  dbo.CMSMC ON MX.MC02=CMSMC.MC001 WHERE CMSMC.MC004='1' AND CMSMC.MC018='Y' 
AND CMSMC.UDF01 LIKE '%-良品'
 AND CMSMC.MC002  like '%车间仓%' and MC01 not like '1%' and MC07>0

 select *from #tempStock2 
 
delete from  #tempStock
   
   INSERT INTO #tempStock
   select MC001,MB017 outCK,-MC007,rows1 from #tempStock2 join INVMB  on  MC001=MB001

   #tempStock2





   SELECT *FROM  CMSMC WHERE MC006 = 'Y'
   
   UPDATE CMSMC SET MC006 = 'Y'
   UPDATE CMSMC SET MC006 = 'N'


   --INSERT INTO  INVTB
   --SELECT COMPANY, CREATOR, USR_GROUP, CREATE_DATE, MODIFIER, MODI_DATE, FLAG, TB001, '20200600003', TB003, TB004, 
   --             TB005, TB006, TB007, TB008, TB009, TB010, TB011, TB013, TB012,  TB014, TB015, TB016, TB017, TB018, TB019, 
   --             TB020, TB021, TB022, TB023, TB024, TB025, TB026, TB027, TB028, TB029, TB030, TB031, TB032, TB033, TB034, 
   --             TB035, TB036, TB037, UDF01, UDF02, UDF03, UDF04, UDF05, UDF06, UDF51, UDF52, UDF53, UDF54, UDF55, 
   --             UDF56 FROM  INVTB WHERE TB001='1271' AND TB002='20200500024'

   --INSERT INTO  INVTA
   --SELECT COMPANY, CREATOR, USR_GROUP, CREATE_DATE, MODIFIER, MODI_DATE, FLAG, TA001, '20200600003', TA003, TA004, 
   --             TA005, TA006, TA007, TA008, TA009, TA010, TA011, TA012, TA013, TA014, TA015, TA016, TA017, TA018, TA019, TA020, 
   --             TA021, TA022, TA023, TA024, TA025, TA026, TA027, TA028, TA029, TA030, TA031, UDF01, UDF02, UDF03, UDF04, 
   --             UDF05, UDF06, UDF51, UDF52, UDF53, UDF54, UDF55, UDF56 FROM  INVTA WHERE  TA001='1271' AND TA002='20200500024'




--   select MC001,MC002  as inCK,MC007,ROW_NUMBER() over(partition by 1 order by MC007 desc) as rows from (
--select INVLA.* from (
--select RTRIM(LA001) MC001,RTRIM(LA009) MC002, SUM(LA011*LA005) MC007 FROM  .INVLA WHERE LA004 <= '20260131' and (select count(*)from  EscrowMaterialDetail where 月份='201904' and 品号=RTRIM(LA001))>0 GROUP BY  LA001,LA009 
--) INVLA  join dbo.CMSMC on INVLA.MC002=CMSMC.MC001 where CMSMC.MC004='1' and CMSMC.MC018='Y' and CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%'AND CMSMC.MC002 not like '%非ROHS%' and INVLA.MC007<>0
--) INVLA 
--join 
--(
--select 品号 MaterialID,交易仓别 CB from  EscrowMaterialDetail where 月份='201904'

--) MaterialID on MC001=MaterialID









--select *from  EscrowMaterialDetail where 月份='201904'









--   select *from INVTB WHERE TB002='20190300143' AND TB001='1271'
   
--   select *from INVTA WHERE TA002='20190300143' AND TA001='1271'
--   update  INVTA set TA006 = 'N' WHERE TA002='20190300143' AND TA001='1271'
--UPDATE  INVTB SET TB018='N' WHERE TB002='20190300143' AND TB001='1271'
--   select *from  



--UPDATE  CMSMC SET MC006='N' WHERE MC006 = 'Y'



/*******次月原材料转车间仓********/

declare @FormID varchar(4)--审核人ID
declare @FormNo varchar(11)--审核人ID
declare @dt varchar(11)--审核人ID
declare @dt1 varchar(11)--审核人ID
set @FormID='1271'
set @dt1='20260201'
set @dt=left(@dt1,6)
select @FormNo=isnull(  left(Rtrim(max(TA002)),len(@dt))+Rtrim(right('00000'+cast(convert(int,Right(max(TA002),11-len(@dt)))+1 as varchar),11-len(@dt)))  , @dt+'00001')  from ZJRD.dbo.INVTA where TA001=@FormID and left(TA002,len(@dt)) = @dt
select @FormNo

insert into INVTA
SELECT   '0006','01001','01001','20260201113934473','','',1, @FormID TA001, @FormNo TA002, @dt1 TA003, TA004, 
                TA005,'N' TA006 , TA007, TA008, TA009, TA010, TA011, TA012, TA013, @dt1 TA014, TA015, TA016, TA017, TA018, TA019, TA020, 
                TA021, TA022, TA023, TA024, TA025, TA026, TA027, TA028, TA029, TA030, TA031, UDF01, UDF02, UDF03, UDF04, 
                UDF05, UDF06, UDF51, UDF52, UDF53, UDF54, UDF55, UDF56
FROM      INVTA WHERE   (TA001 = @FormID) AND (TA002 = '20260100032')


insert into INVTB
SELECT  '0006','01001','01001','20260201113934473','','',1, @FormID TB001,  @FormNo TB002,  TB003, TB004, 
                 TB005, TB006,  TB007,  TB008, TB009, 0 as TB010, 0 as TB011, TB013,  TB012, TB014, TB015, TB016, TB017, 'N' TB018, @dt1 TB019, 
                TB020, TB021, TB022, TB023, TB024, TB025, TB026, TB027, TB028, TB029, TB030, TB031, TB032, TB033, TB034, 
                TB035, TB036, TB037, UDF01, UDF02, UDF03, UDF04, UDF05, UDF06, UDF51, UDF52, UDF53, UDF54, UDF55, 
                UDF56
FROM  INVTB where   (TB001 = '1271') AND (TB002 = '20260100032')  --and TB013 in('005')
   
/*******次原材料转车间仓********/
