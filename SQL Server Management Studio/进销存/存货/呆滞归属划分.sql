USE [SDRD]
GO
/****** Object:  StoredProcedure [dbo].[KCSJHS]    Script Date: 2025/11/8 18:09:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[KCSJHS]---库存数据核算
    @month2 varchar(8),
    @where varchar(100)
AS

--declare @month2 varchar(8),
--	@where varchar(100)
--	set  @month2='20250228'
--	set  @where='1=1'
BEGIN 
SET NOCOUNT ON

--declare @month2 varchar(8),@where varchar(100)
----set @month=left(convert(varchar ,DATEADD(month,-3 ,getdate()),112),6)

--set @month2= convert(varchar ,getdate(),112)
--set @month2= '20220930'
----select @month,@month2
--set @where='1=1'

declare @month varchar(6)
declare @month3 varchar(6)
set @month=left(convert(varchar ,DATEADD(month,-3 ,@month2),112),6)

set @month3=left(convert(varchar ,DATEADD(month,-12 ,@month2),112),6)



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
FROM INVMC I WITH( NOLOCK) 
LEFT JOIN INVMB AS INVMB WITH( NOLOCK)  ON MB001=I.MC001   
 LEFT JOIN INVLC AS INVLC WITH( NOLOCK)  ON LC001=I.MC001 AND LC002='''+@month+''' AND LC003=I.MC002   --取前三个月数据
 LEFT JOIN INVLA AS INVLA WITH( NOLOCK)  ON LA001=I.MC001 AND LA009=I.MC002 AND (LA004 BETWEEN '''+@month+'01'' AND '''+@month2+''')  
 LEFT JOIN CMSMC C WITH( NOLOCK)  ON C.MC001=I.MC002 LEFT JOIN INVMA AS INVMA ON MA001=''1'' AND MA002=MB005  LEFT JOIN ACTMA A ON A.MA001 =INVMA.MA004   
 LEFT JOIN CMSMF AS CMSMF WITH( NOLOCK)  ON MF001=''RMB''   
 LEFT JOIN INVMD AS INVMD WITH( NOLOCK)  ON MD001=MB001 and MD002=MB072   
 Where 1=1 and ('+@where+') AND C.MC004=''1''   
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

if @@ERROR > 0              
begin                              
  --select '../RptNext/Mygrid/FormEditNew?opeid=840004&billno='+@newcode                              
   select '传入的条件异常，请查实' as error    
   return                          
end 

--sp_helptext V_KCMX
--select *from  SDRD..V_KCMX

--select *from  LSSJ..LSKCB 
--drop table #LSKCB
select rtrim(MB001) 品号,MB002 品名,MB003 规格,MB004 单位,rtrim(MC002) 仓库编号 ,MC002C 仓库名称,INVNUMA 库存数量,
CASE INVNUMA WHEN 0 THEN 0 ELSE ROUND(INVMONEY/INVNUMA,4) END 单价,INVMONEY 库存金额,INVNUMAQ 三月前库存数量,
INVMONEYQ 三月库前存金额,INVNUMAH 三月库存数量,INVMONEYH 三月库存金额 
into #LSKCB  
from SDRD..V_KCMX 
where ( INVNUMA<>0 or INVMONEY<>0 or INVNUMAQ<>0 or INVMONEYQ<>0 or INVNUMAH<>0 or INVMONEYH<>0  )

--select * from  #LSKCB 

--select distinct DZYY.* 
--into #ZLDZYY from web_lnk.RDSJK.dbo.[ZLDZYY] DZYY  WITH( NOLOCK) where  ZLDZ03>='2019-06-29 00:00:00'  and ZLDZ03<=left(convert(varchar ,DATEADD(month,-3 ,@month2),112),8)--'2019-06-29 00:00:00'  

--select distinct DZYY.* 
--into #ZLDZYY from web_lnk.RDSJK.dbo.[ZLDZYY] DZYY  WITH( NOLOCK) where  ZLDZ03>='2019-06-29 00:00:00'  and ZLDZ03<= convert(varchar , EOMONTH(DATEADD(month,-3 ,@month2)),121) --'2019-06-29 00:00:00' /**20250228改**/

select distinct DZYY.* 
into #ZLDZYY 
from web_lnk.RDSJK.dbo.[ZLDZYY] DZYY  WITH( NOLOCK)--'2019-06-29 00:00:00' 
join (select ZLDZ02 ZLDZ2,max(ZLDZ00)ZLDZ0 from web_lnk.RDSJK.dbo.[ZLDZYY] DZYY  WITH( NOLOCK) where  ZLDZ03>='2019-06-29 00:00:00' and   ZLDZ01='SDRD'  and ZLDZ03<= EOMONTH(@month2, -3) group by ZLDZ02) as b on  ZLDZ02= ZLDZ2 and ZLDZ00=ZLDZ0 and   ZLDZ01='SDRD'  /**20250228改**/

--DROP TABLE #ZLDZYY
--select *from  #ZLDZYY

/***材料分摊**/
--drop table #FTSJ
select * into #FTSJ from  #LSKCB WHERE ( SELECT COUNT(*) FROM  SDRD.dbo.CMSMC WITH( NOLOCK)  where CMSMC.MC004='1' and CMSMC.MC018='Y' 
and CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%'
AND CMSMC.MC002 not like '%非ROHS%'AND CMSMC.MC002 not like '%辅料%' AND rtrim(MC001)=仓库编号 )>0 and LEFT(品号,1) in('3','5','6')
 order by 品号
/***材料分摊**/

/***其他数据**/
--drop table #QTSJ
select * INTO #QTSJ from  #LSKCB WHERE ((( SELECT COUNT(*) FROM  SDRD.dbo.CMSMC WITH( NOLOCK)  where CMSMC.MC004='1' and CMSMC.MC018='Y' 
and CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%'
AND CMSMC.MC002 not like '%非ROHS%'AND CMSMC.MC002 not like '%辅料%' AND rtrim(MC001)=仓库编号 )=0 
and LEFT(品号,1) in('3','5','6')) or LEFT(品号,1) not in('3','5','6')) 
/***其他数据**/


/***呆滞归属**/
--drop table #DZGS
select DISTINCT  zfs.品号,zfs.品名,zfs.规格,zfs.单位,zfs.单价,
--CASE WHEN ZLDZ02 IS NULL THEN 0 ELSE CASE WHEN isnull(三月前库存数量,0)>0 THEN 库存数量 ELSE 0 END END  呆滞库存量/***20250312原来*/ 
CASE WHEN ZLDZ02 IS NULL THEN 0 ELSE  库存数量  END  呆滞库存量/***20250312改后*/ 
,zfs.库存数量,库存金额,'非呆滞' 备注 into #DZGS  from (

select 品号,品名,规格,单位,case sum(库存数量) when 0 then 0 else  sum(库存金额)/sum(库存数量) end 单价,
sum(库存数量) 库存数量,SUM(三月前库存数量) 三月前库存数量,sum(库存金额) 库存金额 from  #FTSJ group by  品号,品名,规格,单位 having(sum(库存数量))<>0

) as zfs
 --left join #SYQ syn on zfs.品号=syn.品号
LEFT JOIN ( select distinct ZLDZ02,ZLDZ04 SYB,ZLDZ05,ZLDZ06 from #ZLDZYY  join ( select ZLDZ02 ZLDZ2,MAX(ZLDZ03) ZLDZ3   
  from #ZLDZYY  GROUP BY ZLDZ02)as dz on ZLDZ02=ZLDZ2 and ZLDZ3 =ZLDZ03 AND ISNULL(ZLDZ04,'')<>'' ) AS HZ ON ZLDZ02=zfs.品号


 
/***呆滞归属**/

--select *from  #DZGS where (select count(*) from [web_lnk].RDSJK.dbo.[ZLDZYY] where ZLDZ02=品号)>0
update #DZGS set 备注='呆滞'  where (select count(*) from #ZLDZYY where ZLDZ02=品号)>0 and 呆滞库存量>0 
--select *from  #DZGS



  --DROP TABLE #KCSJ
SELECT gsb,rtrim(品号) TH004,SUM(SL)SL 
INTO #KCSJ 
FROM #DZGS join (
SELECT '浙江瑞德' gsb,TH004,TH008 SL FROM SDRD..COPTG WITH( NOLOCK)  JOIN SDRD..COPTH WITH( NOLOCK)  ON TG001=TH001 AND TG002=TH002 
JOIN SDRD..CMSMC ON TH007=MC001 WHERE TG003 >= @month3+'01' AND TG004='10900003' AND TH020='Y' 
UNION
SELECT '浙江瑞德',TJ004,-TJ039 FROM SDRD..COPTI WITH( NOLOCK)  JOIN SDRD..COPTJ WITH( NOLOCK)  ON TI001=TJ001 AND TI002=TJ002 
JOIN SDRD..CMSMC ON TJ013=MC001 WHERE TI003 >= @month3+'01'  AND TI004='10900003' AND TJ021='Y' 
UNION
SELECT '安徽瑞德' gsb,TH004,TH008 SL FROM SDRD..COPTG WITH( NOLOCK)  JOIN SDRD..COPTH WITH( NOLOCK)  ON TG001=TH001 AND TG002=TH002 
JOIN SDRD..CMSMC ON TH007=MC001 WHERE TG003 >= @month3+'01'  AND TG004='11400010' AND TH020='Y' 
UNION
SELECT '安徽瑞德',TJ004,-TJ039 FROM SDRD..COPTI WITH( NOLOCK)  JOIN SDRD..COPTJ WITH( NOLOCK)  ON TI001=TJ001 AND TI002=TJ002 
JOIN SDRD..CMSMC ON TJ013=MC001 WHERE TI003 >= @month3+'01'  AND TI004='11400010' AND TJ021='Y'  
UNION  
SELECT '越南瑞德' gsb,TH004,TH008 SL FROM SDRD..COPTG JOIN SDRD..COPTH ON TG001=TH001 AND TG002=TH002 JOIN SDRD..CMSMC ON TH007=MC001  
 WHERE TG003 >= @month2+'01' AND TG004='19000001' AND TH020='Y'   
UNION  
SELECT '越南瑞德',TJ004,-TJ039 FROM SDRD..COPTI JOIN SDRD..COPTJ ON TI001=TJ001 AND TI002=TJ002 JOIN SDRD..CMSMC ON TJ013=MC001  
 WHERE TI003 >= @month2+'01' AND TI004='19000001' AND TJ021='Y'  
UNION
SELECT left(CM2.UDF01,4),TE004,(CASE LEFT(TE001,2) WHEN '54' THEN TE005 ELSE -TE005 END ) FROM SDRD..MOCTC  WITH( NOLOCK) 
JOIN SDRD..MOCTE WITH( NOLOCK)  ON TC001=TE001 AND TC002=TE002 JOIN SDRD..CMSMC CM1 WITH( NOLOCK)  ON TE008=CM1.MC001 
join SDRD..MOCTA WITH( NOLOCK)  ON TE011=TA001 AND TE012=TA002 JOIN SDRD..CMSMC CM2 WITH( NOLOCK)  ON TA020=CM2.MC001 WHERE TC003 >=@month3+'01'  and TE019='Y' 
UNION 
select E.UDF01,LA001,LA005*-LA011 from INVLA A WITH( NOLOCK)  JOIN  CMSME E WITH( NOLOCK)  ON ME001=LEFT(A.UDF06,6)  WHERE LA004>= @month3+'01' AND  LA006 IN ('1103','1111','1113','1123','1133','1143','1163','1183','11L1')
AND  (left(LA001,1)='3' or left(LA001,1)='5' or left(LA001,1)='6')  and E.UDF01 in('事业一部','新能源部','浙江瑞德','事业二部','事业三部','安徽瑞德','营销中心','供应中心','瑞德物联','锂电储能','越南瑞德')
 --AND CM1.UDF01 LIKE '事业一部%' AND CM2.UDF01 NOT LIKE '事业一部%' 
) AS COP on 品号=TH004 
WHERE  (备注='非呆滞' or (备注='呆滞' and 库存数量-呆滞库存量>0) )
GROUP BY 品号,gsb  having SUM(SL)>500  ---由制造中心20240504提出，呆滞物料领用<500，默认为打样 by hhl

--select *from  #KCSJ

--select *from #SYQ 

--drop table #TEMPZB
SELECT rtrim(ZLDZ02) 品号,'呆滞标注' 备注,CASE SYB WHEN '事业二部' THEN 1 ELSE 0 END [事业二部],CASE SYB WHEN '事业三部' THEN 1 ELSE 0 END [事业三部]
,CASE SYB WHEN '事业一部' THEN 1 ELSE 0 END [事业一部]
,CASE SYB WHEN '新能源部' THEN 1 ELSE 0 END [新能源部]
,CASE SYB WHEN '浙江瑞德' THEN 1 ELSE 0 END [浙江瑞德]
,CASE SYB WHEN '安徽瑞德' THEN 1 ELSE 0 END [安徽瑞德]
,CASE SYB WHEN '营销中心' THEN 1 ELSE 0 END [营销中心]
,CASE SYB WHEN '供应中心' THEN 1 ELSE 0 END [供应中心]
,CASE SYB WHEN '瑞德物联' THEN 1 ELSE 0 END [瑞德物联]
,CASE SYB WHEN '锂电储能' THEN 1 ELSE 0 END [锂电储能]
,CASE SYB WHEN '越南瑞德' THEN 1 ELSE 0 END [越南瑞德] 
,CASE SYB WHEN '未知归属' THEN 1 ELSE 0 END [未知归属]

,SYB [所属事业部],isnull(ZLDZ05,'') ZLDZ05,isnull(ZLDZ06,'') ZLDZ06,1 [总计] ,呆滞库存量 总库存,单价,库存金额 INTO #TEMPZB
  FROM (  select distinct ZLDZ02,ZLDZ04 SYB,ZLDZ05,ZLDZ06 from #ZLDZYY  join ( select ZLDZ02 ZLDZ2,MAX(ZLDZ03) ZLDZ3   
  from #ZLDZYY  GROUP BY ZLDZ02)as dz on ZLDZ02=ZLDZ2 and ZLDZ3 =ZLDZ03 )AS HZ join #DZGS dz on HZ.ZLDZ02=dz.品号 where  备注='呆滞'


insert into #TEMPZB
SELECT rtrim(品号),case when HZSL is null then'无领用' else '领用比例' end,isnull(SUM(SYB1),0),isnull(SUM(SYB2),0),
isnull(SUM(SYB3),1),isnull(SUM(SYB4),0),isnull(SUM(SYB5),0),isnull(SUM(SYB6),0),isnull(SUM(SYB7),0),isnull(SUM(SYB8),0),isnull(SUM(SYB9),0),isnull(SUM(SYB10),0),isnull(SUM(SYB11),0),0 [未知归属],'','','',isnull(HZSL,1),
case when 备注='非呆滞' then 库存数量 else 库存数量-呆滞库存量 end ,单价,库存金额 FROM
 #DZGS left join
 (
SELECT DISTINCT TH04,
CASE gsb WHEN '事业二部' THEN SL ELSE 0 END SYB1 ,CASE gsb WHEN '事业三部' THEN SL ELSE 0 END SYB2
,CASE gsb WHEN '事业一部' THEN SL ELSE 0 END SYB3
,CASE gsb WHEN '新能源部' THEN SL ELSE 0 END SYB4
,CASE gsb WHEN '浙江瑞德' THEN SL ELSE 0 END SYB5
,CASE gsb WHEN '安徽瑞德' THEN SL ELSE 0 END SYB6
,CASE gsb WHEN '营销中心' THEN SL ELSE 0 END SYB7
,CASE gsb WHEN '供应中心' THEN SL ELSE 0 END SYB8
,CASE gsb WHEN '瑞德物联' THEN SL ELSE 0 END SYB9
,CASE gsb WHEN '锂电储能' THEN SL ELSE 0 END SYB10
,CASE gsb WHEN '越南瑞德' THEN SL ELSE 0 END SYB11
,HZSL
FROM (SELECT TH004 TH04,SUM(SL) HZSL FROM  #KCSJ GROUP BY TH004) AS HZ JOIN #KCSJ ON TH004 =TH04 ) AS Z on  品号=TH04 
where (备注='非呆滞' or (备注='呆滞' and 库存数量-呆滞库存量>0) )
 GROUP BY 品号,HZSL,备注,库存数量,呆滞库存量,单价,库存金额

  --select *from  #TEMPZB
   insert into #TEMPZB 
      SELECT 品号,'按仓别分',
   CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '事业二部' THEN 1 ELSE 0 END SYB1 ,
   CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '事业三部' THEN 1 ELSE 0 END SYB2
,CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '事业一部' THEN 1 ELSE 0 END SYB3
,CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '新能源部' THEN 1 ELSE 0 END SYB4
,CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '浙江瑞德' THEN 1 ELSE 0 END SYB5
,CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '安徽瑞德' THEN 1 ELSE 0 END SYB6
,CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '营销中心' THEN 1 ELSE 0 END SYB7
,CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '供应中心' THEN 1 ELSE 0 END SYB8
,CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '瑞德物联' THEN 1 ELSE 0 END SYB9
,CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '锂电储能' THEN 1 ELSE 0 END SYB10
,CASE left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1) WHEN '越南瑞德' THEN 1 ELSE 0 END SYB11
,0 [未知归属]
,left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1),仓库编号,仓库名称, 1 HZSL,库存数量,单价,库存金额 
    --FROM  #QTSJ JOIN  SDRD.dbo.CMSMC ON 仓库编号=MC001  
    FROM  #QTSJ JOIN SDRD.dbo.INVMB  WITH( NOLOCK) ON MB001=品号  JOIN  SDRD.dbo.CMSMC WITH( NOLOCK)  ON MC001= (case LEFT(品号,1) WHEN '7' THEN MB017 ELSE  仓库编号 end  ) ---判断锂电的做特殊处理
    



    UPDATE TEM SET [事业二部]= CASE ME.UDF01 WHEN '事业二部' THEN 1 ELSE 0 END ,[事业三部]= CASE ME.UDF01 WHEN '事业三部' THEN 1 ELSE 0 END   
,[事业一部]=CASE ME.UDF01 WHEN '事业一部' THEN 1 ELSE 0 END   
,[新能源部]=CASE ME.UDF01 WHEN '新能源部' THEN 1 ELSE 0 END   
,[浙江瑞德]=CASE ME.UDF01 WHEN '浙江瑞德' THEN 1 ELSE 0 END   
,[安徽瑞德]=CASE ME.UDF01 WHEN '安徽瑞德' THEN 1 ELSE 0 END   
,[营销中心]=CASE ME.UDF01 WHEN '营销中心' THEN 1 ELSE 0 END   
,[供应中心]=CASE ME.UDF01 WHEN '供应中心' THEN 1 ELSE 0 END  
,[瑞德物联]=CASE ME.UDF01 WHEN '瑞德物联' THEN 1 ELSE 0 END  
,[锂电储能]=CASE ME.UDF01 WHEN '锂电储能' THEN 1 ELSE 0 END   
,[越南瑞德]=CASE ME.UDF01 WHEN '越南瑞德' THEN 1 ELSE 0 END
,[未知归属]=CASE ME.UDF01 WHEN '制造中心' THEN 1 ELSE 0 END  
,[总计]=1 
,备注 ='请购部门'
,[所属事业部]= left(ME.UDF01,4)
 from  #TEMPZB TEM
  JOIN  PURTB WITH( NOLOCK)  ON TB004=品号 JOIN PURTA WITH( NOLOCK)   ON TA001=TB001 AND TA002=TB002 JOIN CMSMV  WITH( NOLOCK) ON  MV001 = TA014 JOIN CMSME ME  WITH( NOLOCK) ON MV004=ME001 
   where  备注='无领用' 

  --select * from  #TEMPZB where (备注='无领用'  or  所属事业部='制造中心') 



  
    UPDATE TEM SET [事业二部]= CASE ME.UDF01 WHEN '事业二部' THEN 1 ELSE 0 END ,[事业三部]= CASE ME.UDF01 WHEN '事业三部' THEN 1 ELSE 0 END   
,[事业一部]=CASE ME.UDF01 WHEN '事业一部' THEN 1 ELSE 0 END   
,[新能源部]=CASE ME.UDF01 WHEN '新能源部' THEN 1 ELSE 0 END   
,[浙江瑞德]=CASE ME.UDF01 WHEN '浙江瑞德' THEN 1 ELSE 0 END   
,[安徽瑞德]=CASE ME.UDF01 WHEN '安徽瑞德' THEN 1 ELSE 0 END   
,[营销中心]=CASE ME.UDF01 WHEN '营销中心' THEN 1 ELSE 0 END   
,[供应中心]=CASE ME.UDF01 WHEN '供应中心' THEN 1 ELSE 0 END  
,[瑞德物联]=CASE ME.UDF01 WHEN '瑞德物联' THEN 1 ELSE 0 END  
,[锂电储能]=CASE ME.UDF01 WHEN '锂电储能' THEN 1 ELSE 0 END   
,[越南瑞德]=CASE ME.UDF01 WHEN '越南瑞德' THEN 1 ELSE 0 END 
,[未知归属]=CASE ME.UDF01 WHEN '制造中心' THEN 1 ELSE 0 END  
,[总计]=1 
,备注 ='请购部门'
,[所属事业部]= left(ME.UDF01,4)
 from  #TEMPZB TEM
  JOIN  (select DISTINCT TB003,CASE TA001 WHEN '5109' THEN '浙江瑞德' WHEN '5111' THEN '安徽瑞德' WHEN '5113' THEN '越南瑞德' ELSE LEFT(MC.UDF01,4) END UDF01 from  #TEMPZB TEM join MOCTB WITH( NOLOCK)  ON 品号=TB003 JOIN MOCTA WITH( NOLOCK)  ON TA001=TB001 AND TB002=TA002 JOIN  CMSMC MC WITH( NOLOCK)  ON TA020 =MC001
   where (备注='无领用'  or  所属事业部='制造中心')  )ME ON TB003=品号
   --where  备注='无领用' 

  
   UPDATE  #TEMPZB SET [事业一部]=0, [未知归属]=1 where (备注='无领用'  )
   
 --SELECT * FROM #TEMPZB where (备注='无领用'  )

    --select *from  #TEMPZB
    SET NOCOUNT off
    
    
    --SELECT  品号 MB001,MB002 品名,MB003 规格,备注,case 备注 when '按仓别分' then right((CMSMC.UDF01),
    --len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)) else '良品' end  物料状态
    --,[事业二部],[事业三部],[事业一部],[新能源部],[浙江瑞德],[安徽瑞德],[营销中心],[供应中心],[瑞德物联],[未知归属],[所属事业部], ZLDZ05 客户名称
    --,ZLDZ06 分析原因, [总计] , 总库存,单价,库存金额
    --,(1.0*[事业二部])/总计*库存金额 [事业二部金额],
    --(1.0*[事业三部])/总计*库存金额	[事业三部金额],
    --(1.0*[事业一部])/总计*库存金额	[事业一部金额],
    --(1.0*[新能源部])/总计*库存金额	[新能源部金额],
    --(1.0*[浙江瑞德])/总计*库存金额	[浙江瑞德金额],
    --(1.0*[安徽瑞德])/总计*库存金额	[安徽瑞德金额],
    --(1.0*[营销中心])/总计*库存金额	[营销中心金额],
    --(1.0*[供应中心])/总计*库存金额	[供应中心金额] ,
    --(1.0*[瑞德物联])/总计*库存金额	[瑞德物联金额],
    --(1.0*[未知归属])/总计*库存金额	[未知归属金额]  ,0.0
    -- from  #TEMPZB join INVMB ON MB001=品号 left join  SDRD.dbo.CMSMC on ZLDZ05=MC001 where  总计*库存金额<>0

    -- union all


    select	 MB001,品名,规格,备注, 物料状态,[事业二部],[事业三部],[事业一部],[新能源部],[浙江瑞德],[安徽瑞德],[营销中心],[供应中心],[瑞德物联],[锂电储能],[越南瑞德],[未知归属],[所属事业部], 客户名称
    ,分析原因,[总计],总库存,单价,库存金额,case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [事业二部金额] end [事业二部金额],
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [事业三部金额] end [事业三部金额],
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [事业一部金额] end [事业一部金额],
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [新能源部金额] end [新能源部金额],
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [浙江瑞德金额] end [浙江瑞德金额],
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [安徽瑞德金额] end [安徽瑞德金额],
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [营销中心金额] end [营销中心金额],
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [供应中心金额] end [供应中心金额] ,
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [瑞德物联金额] end [瑞德物联金额],
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [锂电储能金额] end [锂电储能金额],
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [越南瑞德金额] end [越南瑞德金额],
    case  when isnull(PH,'')<>'' and 物料状态='良品' then 0 else [未知归属金额] end [未知归属金额]  
    ,case  when isnull(PH,'')<>'' and 物料状态='良品' then 库存金额 else 0.0 end 战略物资金额
    from(SELECT  品号 MB001,MB002 品名,MB003 规格,备注,case 备注 when '按仓别分' then right((CMSMC.UDF01),
    len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)) else '良品' end  物料状态
    ,[事业二部],[事业三部],[事业一部],[新能源部],[浙江瑞德],[安徽瑞德],[营销中心],[供应中心],[瑞德物联],[锂电储能],[越南瑞德],[未知归属],[所属事业部], ZLDZ05 客户名称
    ,ZLDZ06 分析原因, [总计] , 总库存,单价,库存金额
    ,(1.0*[事业二部])/总计*库存金额 [事业二部金额],
    (1.0*[事业三部])/总计*库存金额	[事业三部金额],
    (1.0*[事业一部])/总计*库存金额	[事业一部金额],
    (1.0*[新能源部])/总计*库存金额	[新能源部金额],
    (1.0*[浙江瑞德])/总计*库存金额	[浙江瑞德金额],
    (1.0*[安徽瑞德])/总计*库存金额	[安徽瑞德金额],
    (1.0*[营销中心])/总计*库存金额	[营销中心金额],
    (1.0*[供应中心])/总计*库存金额	[供应中心金额] ,
    (1.0*[瑞德物联])/总计*库存金额	[瑞德物联金额],
    (1.0*[锂电储能])/总计*库存金额	[锂电储能金额],
    (1.0*[越南瑞德])/总计*库存金额	[越南瑞德金额],
    (1.0*[未知归属])/总计*库存金额	[未知归属金额]  
     from  #TEMPZB join INVMB WITH( NOLOCK)  ON MB001=品号 left join  SDRD.dbo.CMSMC WITH( NOLOCK)  on ZLDZ05=MC001 where  总计*库存金额<>0) as KC left join (select DISTINCT PH FROM  RDSJK..Material_zlwz  WITH( NOLOCK) )AS WL on MB001=PH


end

--select RTRIM(MB001),MB002,MB003 from  RDSJK..Material_zlwz join SDRD..INVMB ON MB001=PH
-- select *from RDSJK..Material_zlwz where PH='303000313400'

--exec [KCSJHS] '20210630','1=1'

--drop table #ZLDZYY
