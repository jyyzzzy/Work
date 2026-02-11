USE [SDRD]
GO

/****** Object:  UserDefinedFunction [dbo].[Fn_ZDHDS]    Script Date: 2025/12/26 15:07:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE Function [dbo].[Fn_ZDHDS](@StartDay CHAR(10),@EndtDay CHAR(10))  

Returns @tbReturn Table (
	MOCTFTF003 CHAR(20) 
	,MOCTGTG001 CHAR(4)
	,MOCTGTG002 CHAR(11)
	,MOCTGTG004 CHAR(12)
	,MOCTGTG005 CHAR(60)
	,MOCTGTG006 CHAR(60)
	,MOCTGTG007 CHAR(10)
	,MOCTGTG011 numeric(15, 6) 
	,WHS1105001 numeric(15, 6)
	,WHS1105002 numeric(15, 6)
	,MOCTGTG010 CHAR(4)
	,CMSMCMC002 CHAR(25) 
	,MOCTGTG014 CHAR(4) 
	,MOCTGTG015 CHAR(15)
	,MOCTATA015 numeric(15, 6) 
	,MOCTATA017 numeric(15, 6)  
	,MOCTFTF011 CHAR(15) 
	,CMSMDMD002 CHAR(30) 
	,MOCTFTF012 CHAR(15) 
	,MOCTACOMPANY CHAR(20)
)												

As  
Begin

declare @tb table (OrderID varchar(4), OrderNo varchar(20))
declare @ProductPoint table (
	MD001 varchar(20)
	,MD009 varchar(10)
	,Point float
)

declare @APS_Output table (
	OrderOutPutID bigint
	,WorkCenterID varchar(10)
	,WorkCenterName varchar(50)
	,OrderID varchar(4)
	,OrderNo varchar(11)
	,Qty float
	,ProcessID varchar(4)
	,WorkDay varchar(8)
	,CreateDay varchar(8)
)

insert into @ProductPoint
select MD.MD001,MD.MD009,sum(convert(float,Rtrim(case isnull(MB3.MB180,'') when '' then '-99999' else MB3.MB180 end),0)*MD006/MD007 )as Point 
From SDRD.dbo.BOMMD MD 
join SDRD.dbo.INVMB MB3  on MD.MD003=MB3.MB001 
where MD006>0 and MD007>=1 
and MD001='216701320AX0'
and left(MD003,1) not in ('A','1','2','5','P')
--and convert(float,Rtrim(case isnull(MB3.MB180,'') when '' then '-99999' else MB3.MB180 end),0)>0 
group by MD.MD001,MD.MD009



/************取消24年之前的数据 20250312************/
/*
insert into @APS_Output
select A.OrderOutPutID, A.WorkCenterID, A.WorkCenterName, A.OrderID, A.OrderNo, A.Qty, (case isnull(B.Process_New,'') when '' then A.ProcessID else B.Process_New end)ProcessID, A.WorkDay, A.CreateDay 
from SDRD.dbo.V_ERP_WO_AutoPoint A with(nolock) 
left join SDRD.dbo.AutoPoint_NoProcessName B  with(nolock) on A.OrderOutPutID=B.OrderOutPutID
where A.WorkDay>=@StartDay and A.WorkDay<=@EndtDay

--select * from @APS_Output




	insert into @tbReturn	
	SELECT MOCTF.TF003 as MOCTFTF003
	,MOCTG.TG001 as MOCTGTG001
	,MOCTG.TG002 as MOCTGTG002
	,MOCTG.TG004 as MOCTGTG004
	,MOCTG.TG005 as MOCTGTG005
	,MOCTG.TG006 as MOCTGTG006
	,MOCTG.TG007 as MOCTGTG007
	,MOCTG.TG011 as MOCTGTG011
	,INVMB.MB096 * 100 as WHS1105001
	,INVMB.MB096 * 100 * MOCTG.TG011 as WHS1105002
	,MOCTG.TG010 as MOCTGTG010,CMSMC.MC002 as CMSMCMC002
	,MOCTG.TG014 as MOCTGTG014,MOCTG.TG015 as MOCTGTG015,MOCTA.TA015 as MOCTATA015
	,MOCTA.TA017 as MOCTATA017,MOCTF.TF011 as MOCTFTF011,CMSMD.MD002 as CMSMDMD002,MOCTF.TF012 as MOCTFTF012 
	,CMSME.UDF01 as MOCTACOMPANY
	FROM SDRD.dbo.MOCTG as MOCTG with(nolock) 
	Left JOIN SDRD.dbo.MOCTF as MOCTF with(nolock)  On MOCTG.TG001=MOCTF.TF001 and MOCTG.TG002=MOCTF.TF002 
	Left JOIN SDRD.dbo.MOCTA as MOCTA with(nolock)  On MOCTG.TG014=MOCTA.TA001 and MOCTG.TG015=MOCTA.TA002 

	Left JOIN SDRD.dbo.INVMB as INVMB with(nolock)  On MOCTG.TG004=INVMB.MB001 
	Left JOIN SDRD.dbo.CMSMC as CMSMC with(nolock)  On MOCTG.TG010=CMSMC.MC001 
 
	Left JOIN SDRD.dbo.CMSMD as CMSMD with(nolock)  On MOCTF.TF011=CMSMD.MD001 
	
	left join SDRD.dbo.CMSME as CMSME with(nolock)  On CMSMD.MD015=CMSME.ME001
	--Left Join @ProductPoint ProductPoint on ProductPoint.MD001=MOCTA.TA006 and ProductPoint.MD009=MOCTG.TG004
	WHERE 1=1
	AND (
			(CMSMD.MD001 IN ('21111','21112','21113','21121','21122','21123','21124','21125','21920','21083','21082','21108','21109','21128','21129','21130')  and CMSMD.COMPANY='0001')
					or (CMSMD.MD001 like '230%' and CMSMD.COMPANY='0011' )  or ((CMSMD.MD011 like '自动化%' or CMSMD.MD002 like '%舜力衡%') and CMSMD.COMPANY='0006') )
	AND (MOCTG.TG022 = 'Y')
	and Rtrim(MOCTG.TG004) not like '2%X_'
	and  MOCTF.TF003 >= @StartDay and MOCTF.TF003<=@EndtDay

if @StartDay<'2023-08-01' 
begin
	insert into @tbReturn
	SELECT APS.WorkDay as MOCTFTF003
	,'-' as MOCTGTG001
	,APS.OrderOutPutID as MOCTGTG002
	,Rtrim(MOCTA.TA006) as MOCTGTG004
	,MOCTA.TA034 as MOCTGTG005
	,MOCTA.TA035 as MOCTGTG006
	,MOCTA.TA007 as MOCTGTG007
	,APS.Qty as MOCTGTG011
	,(case when MOCTA.TA006 not like '2%X_' then INVMB.MB096 * 100 else (case when ProductPoint.Point is null then -1 when ProductPoint.Point>=0 then ProductPoint.Point else 0 end) end) as WHS1105001
	,(case when MOCTA.TA006 not like '2%X_' then INVMB.MB096 * 100 else (case when ProductPoint.Point is null then -1 when ProductPoint.Point>=0 then ProductPoint.Point else 0 end) end) * APS.Qty as WHS1105002
	,APS.ProcessID as MOCTGTG010
	,Rtrim(CMSMW.MW002) as CMSMCMC002
	,MOCTA.TA001 as MOCTGTG014
	,MOCTA.TA002 as MOCTGTG015
	,MOCTA.TA015 as MOCTATA015
	,MOCTA.TA017 as MOCTATA017
	,APS.WorkCenterID as MOCTFTF011
	,APS.WorkCenterName as CMSMDMD002
	,APS.CreateDay as MOCTFTF012  
	,CMSME.UDF01 as MOCTACOMPANY
	FROM @APS_Output APS
	Left JOIN SDRD.dbo.MOCTA as MOCTA with(nolock)  On APS.OrderID=MOCTA.TA001 and APS.OrderNo=MOCTA.TA002 
	Left Join @ProductPoint ProductPoint on ProductPoint.MD001=MOCTA.TA006 and ProductPoint.MD009=APS.ProcessID
	Left JOIN SDRD.dbo.INVMB as INVMB with(nolock)  On MOCTA.TA006=INVMB.MB001 
	Left Join SDRD.dbo.CMSMW CMSMW with(nolock)  on CMSMW.MW001=APS.ProcessID 
	left join SDRD.dbo.CMSMD as CMSMD with(nolock)  On CMSMD.MD015=APS.WorkCenterID
	left join SDRD.dbo.CMSME as CMSME with(nolock)  On CMSMD.MD015=CMSME.ME001
	WHERE 1=1
	and Rtrim(MOCTA.TA006) like '2%X_' 
	and convert(date,APS.WorkDay,0)<'2023-08-01'
	and convert(date,APS.WorkDay,0) >= convert(date,@StartDay,0) and  convert(date,APS.WorkDay,0) <=  convert(date,@EndtDay,0)
end


	insert into @tb
	select distinct  A.OrderID, A.OrderNo
	from SDRD.dbo.V_ERP_WO_AutoPoint A with(nolock) 
	where 1=1
	and convert(date,WorkDay,0) >= convert(date,'2023-06-01',0) and  convert(date,WorkDay,0) <=  convert(date,'2023-07-31',0)
	and OrderID in ('5102','5104')


	insert into @tbReturn
	SELECT APS.WorkDay as MOCTFTF003
	,'-' as MOCTGTG001
	,APS.OrderOutPutID as MOCTGTG002
	,Rtrim(MOCTA.TA006) as MOCTGTG004
	,MOCTA.TA034 as MOCTGTG005
	,MOCTA.TA035 as MOCTGTG006
	,MOCTA.TA007 as MOCTGTG007
	,APS.Qty as MOCTGTG011
	,(case when MOCTA.TA006 not like '2%X_' then INVMB.MB096 * 100 else (case when ProductPoint.Point is null then -1 when ProductPoint.Point>=0 then ProductPoint.Point else 0 end) end) as WHS1105001
	,(case when MOCTA.TA006 not like '2%X_' then INVMB.MB096 * 100 else (case when ProductPoint.Point is null then -1 when ProductPoint.Point>=0 then ProductPoint.Point else 0 end) end) * APS.Qty as WHS1105002
	,APS.ProcessID as MOCTGTG010
	,Rtrim(CMSMW.MW002) as CMSMCMC002
	,MOCTA.TA001 as MOCTGTG014
	,MOCTA.TA002 as MOCTGTG015
	,MOCTA.TA015 as MOCTATA015
	,MOCTA.TA017 as MOCTATA017
	,APS.WorkCenterID as MOCTFTF011
	,APS.WorkCenterName as CMSMDMD002
	,APS.CreateDay as MOCTFTF012  
	,CMSME.UDF01 as MOCTACOMPANY
	FROM @APS_Output APS
	Left JOIN SDRD.dbo.MOCTA as MOCTA with(nolock)  On APS.OrderID=MOCTA.TA001 and APS.OrderNo=MOCTA.TA002 
	Left Join @ProductPoint ProductPoint on ProductPoint.MD001=MOCTA.TA006 and ProductPoint.MD009=APS.ProcessID
	Left JOIN SDRD.dbo.INVMB as INVMB with(nolock)  On MOCTA.TA006=INVMB.MB001 
	Left Join SDRD.dbo.CMSMW CMSMW with(nolock)  on CMSMW.MW001=APS.ProcessID 
	left join SDRD.dbo.CMSMD as CMSMD with(nolock)  On CMSMD.MD015=APS.WorkCenterID
	left join SDRD.dbo.CMSME as CMSME with(nolock)  On CMSMD.MD015=CMSME.ME001
	WHERE 1=1
	and Rtrim(MOCTA.TA006) like '2%X_' 
	and convert(date,APS.WorkDay,0)>='2023-08-01'
	and convert(date,APS.WorkDay,0) >= convert(date,@StartDay,0) and  convert(date,APS.WorkDay,0) <=  convert(date,@EndtDay,0)
	and exists (select * from @tb T where APS.OrderID=T.OrderID and APS.OrderNo=T.OrderNo);
*/
/************取消24年之前的数据 20250312************/
	

	insert into @tbReturn	
	SELECT MOCTF.TF003 as MOCTFTF003
	,MOCTG.TG001 as MOCTGTG001
	,MOCTG.TG002 as MOCTGTG002
	,MOCTG.TG004 as MOCTGTG004
	,MOCTG.TG005 as MOCTGTG005
	,MOCTG.TG006 as MOCTGTG006
	,MOCTG.TG007 as MOCTGTG007
	,MOCTG.TG011 as MOCTGTG011
	,(case when ProductPoint.Point is null then -1 when ProductPoint.Point>=0 then ProductPoint.Point else 0 end) as WHS1105001
	,(case when ProductPoint.Point is null then -1 when ProductPoint.Point>=0 then ProductPoint.Point else 0 end) * MOCTG.TG011 as WHS1105002
	--,MOCTG.TG010 as MOCTGTG010
	,CMSMW.MW001 as MOCTGTG010
	--,CMSMC.MC002 as CMSMCMC002
	,CMSMW.MW002 as CMSMCMC002
	,MOCTG.TG014 as MOCTGTG014
	,MOCTG.TG015 as MOCTGTG015
	,MOCTA.TA015 as MOCTATA015
	,MOCTA.TA017 as MOCTATA017
	,MOCTF.TF011 as MOCTFTF011
	--,(case CMSMD.MD015 when '130200' then (case when CMSMW.MW011 in ('AI','RI') then '21125' else '21124' end)
	--	when '220200' then (case when CMSMW.MW011 in ('AI','RI') then '21131' else '21130' end)
	--	else (case when CMSMW.MW011 in ('AI','RI') then '21108' else '21109' end) -- 一部
	--end) as MOCTFTF011
	,CMSMD.MD002 as CMSMDMD002
	--,'' as CMSMDMD002
	,MOCTF.TF012 as MOCTFTF012 
	,CMSME.UDF01 as MOCTACOMPANY
	FROM SDRD.dbo.MOCTG as MOCTG with(nolock) 
	Left JOIN SDRD.dbo.MOCTF as MOCTF with(nolock)  On MOCTG.TG001=MOCTF.TF001 and MOCTG.TG002=MOCTF.TF002 
	Left JOIN SDRD.dbo.MOCTA as MOCTA with(nolock)  On MOCTG.TG014=MOCTA.TA001 and MOCTG.TG015=MOCTA.TA002 

	Left JOIN SDRD.dbo.INVMB as INVMB with(nolock)  On MOCTG.TG004=INVMB.MB001 
	Left JOIN SDRD.dbo.CMSMC as CMSMC with(nolock)  On MOCTG.TG010=CMSMC.MC001 
	Left JOIN SDRD.dbo.CMSMD as CMSMD with(nolock)  On MOCTF.TF011=CMSMD.MD001  
	
	Left Join @ProductPoint ProductPoint on ProductPoint.MD001=MOCTG.TG004
	--Left Join (select MD001,MD009,sum(Point)Point from @ProductPoint group by MD001,MD009)ProductPoint on ProductPoint.MD001=MOCTG.TG004
	left join CMSMW as CMSMW with(nolock) on CMSMW.MW001=ProductPoint.MD009
	left join SDRD.dbo.CMSME as CMSME with(nolock)  On CMSMD.MD015=CMSME.ME001
	WHERE 1=1
	and Rtrim(MOCTG.TG004) like '2%X_'
	and MOCTF.TF003>='20230801'
	and  MOCTF.TF003 >= @StartDay and MOCTF.TF003<=@EndtDay
	and not exists (select * From @tb T where T.OrderID=MOCTG.TG014 and T.OrderNo=MOCTG.TG015);


	--select * 
	update @tbReturn
	set MOCTFTF011=(case CMSMD.MD015 when '130200' then (case when CMSMW.MW011 in ('AI','RI') then '21125' else MOCTFTF011 end)
		when '220200' then (case when CMSMW.MW011 in ('AI','RI') then '21131' else MOCTFTF011 end)
		else (case when CMSMW.MW011 in ('AI','RI') then '21108' else MOCTFTF011 end) -- 一部
	end)
	from @tbReturn
	join SDRD.dbo.CMSMD as CMSMD with(nolock)  On MOCTFTF011=CMSMD.MD001  
	join CMSMW as CMSMW with(nolock) on CMSMW.MW001=MOCTGTG010

	update @tbReturn
	set CMSMDMD002=Rtrim(MD002)
	from @tbReturn 
	join SDRD.dbo.CMSMD  with(nolock) On MOCTFTF011=CMSMD.MD001  

	

	--浙江瑞德
	insert into @tbReturn	
	SELECT MOCTF.TF003 as MOCTFTF003
	,MOCTG.TG001 as MOCTGTG001
	,MOCTG.TG002 as MOCTGTG002
	,MOCTG.TG004 as MOCTGTG004
	,MOCTG.TG005 as MOCTGTG005
	,MOCTG.TG006 as MOCTGTG006
	,MOCTG.TG007 as MOCTGTG007
	,MOCTG.TG011 as MOCTGTG011
	,(case when ProductPoint.Point is null then -1 when ProductPoint.Point>=0 then ProductPoint.Point else 0 end) as WHS1105001
	,(case when ProductPoint.Point is null then -1 when ProductPoint.Point>=0 then ProductPoint.Point else 0 end) * MOCTG.TG011 as WHS1105002
	--,MOCTG.TG010 as MOCTGTG010
	,CMSMW.MW001 as MOCTGTG010
	--,CMSMC.MC002 as CMSMCMC002
	,CMSMW.MW002 as CMSMCMC002
	,MOCTG.TG014 as MOCTGTG014
	,MOCTG.TG015 as MOCTGTG015
	,MOCTA.TA015 as MOCTATA015
	,MOCTA.TA017 as MOCTATA017
	,MOCTF.TF011 as MOCTFTF011
	--,(case CMSMD.MD015 when '130200' then (case when CMSMW.MW011 in ('AI','RI') then '21125' else '21124' end)
	--	when '220200' then (case when CMSMW.MW011 in ('AI','RI') then '21131' else '21130' end)
	--	else (case when CMSMW.MW011 in ('AI','RI') then '21108' else '21109' end) -- 一部
	--end) as MOCTFTF011
	,CMSMD.MD002 as CMSMDMD002
	--,'' as CMSMDMD002
	,MOCTF.TF012 as MOCTFTF012 
	,CMSME.UDF01 as MOCTACOMPANY
	FROM ZJRD.dbo.MOCTG as MOCTG with(nolock) 
	Left JOIN ZJRD.dbo.MOCTF as MOCTF with(nolock)  On MOCTG.TG001=MOCTF.TF001 and MOCTG.TG002=MOCTF.TF002 
	Left JOIN ZJRD.dbo.MOCTA as MOCTA with(nolock)  On MOCTG.TG014=MOCTA.TA001 and MOCTG.TG015=MOCTA.TA002 

	Left JOIN ZJRD.dbo.INVMB as INVMB with(nolock)  On MOCTG.TG004=INVMB.MB001 
	Left JOIN ZJRD.dbo.CMSMC as CMSMC with(nolock)  On MOCTG.TG010=CMSMC.MC001 
	Left JOIN ZJRD.dbo.CMSMD as CMSMD with(nolock)  On MOCTF.TF011=CMSMD.MD001  

	Left Join @ProductPoint ProductPoint on ProductPoint.MD001=MOCTG.TG004
	--Left Join (select MD001,MD009,sum(Point)Point from @ProductPoint group by MD001,MD009)ProductPoint on ProductPoint.MD001=MOCTG.TG004

	left join ZJRD.dbo.CMSMW as CMSMW with(nolock) on CMSMW.MW001=ProductPoint.MD009
	left join ZJRD.dbo.CMSME as CMSME with(nolock)  On CMSMD.MD015=CMSME.ME001
	WHERE 1=1
	and Rtrim(MOCTG.TG004) like '2%X_'
	and MOCTF.TF003>='20230801'
	and  MOCTF.TF003 >= @StartDay and MOCTF.TF003<=@EndtDay
	
	

	--安徽瑞德
	insert into @tbReturn	
	SELECT MOCTF.TF003 as MOCTFTF003
	,MOCTG.TG001 as MOCTGTG001
	,MOCTG.TG002 as MOCTGTG002
	,MOCTG.TG004 as MOCTGTG004
	,MOCTG.TG005 as MOCTGTG005
	,MOCTG.TG006 as MOCTGTG006
	,MOCTG.TG007 as MOCTGTG007
	,MOCTG.TG011 as MOCTGTG011
	,(case when ProductPoint.Point is null then -1 when ProductPoint.Point>=0 then ProductPoint.Point else 0 end) as WHS1105001
	,(case when ProductPoint.Point is null then -1 when ProductPoint.Point>=0 then ProductPoint.Point else 0 end) * MOCTG.TG011 as WHS1105002
	--,MOCTG.TG010 as MOCTGTG010
	,CMSMW.MW001 as MOCTGTG010
	--,CMSMC.MC002 as CMSMCMC002
	,CMSMW.MW002 as CMSMCMC002
	,MOCTG.TG014 as MOCTGTG014
	,MOCTG.TG015 as MOCTGTG015
	,MOCTA.TA015 as MOCTATA015
	,MOCTA.TA017 as MOCTATA017
	,MOCTF.TF011 as MOCTFTF011
	--,(case CMSMD.MD015 when '130200' then (case when CMSMW.MW011 in ('AI','RI') then '21125' else '21124' end)
	--	when '220200' then (case when CMSMW.MW011 in ('AI','RI') then '21131' else '21130' end)
	--	else (case when CMSMW.MW011 in ('AI','RI') then '21108' else '21109' end) -- 一部
	--end) as MOCTFTF011
	,CMSMD.MD002 as CMSMDMD002
	--,'' as CMSMDMD002
	,MOCTF.TF012 as MOCTFTF012 
	,CMSME.UDF01 as MOCTACOMPANY
	FROM AHRD.dbo.MOCTG as MOCTG with(nolock) 
	Left JOIN AHRD.dbo.MOCTF as MOCTF with(nolock)  On MOCTG.TG001=MOCTF.TF001 and MOCTG.TG002=MOCTF.TF002 
	Left JOIN AHRD.dbo.MOCTA as MOCTA with(nolock)  On MOCTG.TG014=MOCTA.TA001 and MOCTG.TG015=MOCTA.TA002 

	Left JOIN AHRD.dbo.INVMB as INVMB with(nolock)  On MOCTG.TG004=INVMB.MB001 
	Left JOIN AHRD.dbo.CMSMC as CMSMC with(nolock)  On MOCTG.TG010=CMSMC.MC001 
	Left JOIN AHRD.dbo.CMSMD as CMSMD with(nolock)  On MOCTF.TF011=CMSMD.MD001  

	Left Join @ProductPoint ProductPoint on ProductPoint.MD001=MOCTG.TG004
	--Left Join (select MD001,MD009,sum(Point)Point from @ProductPoint group by MD001,MD009)ProductPoint on ProductPoint.MD001=MOCTG.TG004

	left join AHRD.dbo.CMSMW as CMSMW with(nolock) on CMSMW.MW001=ProductPoint.MD009
	left join AHRD.dbo.CMSME as CMSME with(nolock)  On CMSMD.MD015=CMSME.ME001
	WHERE 1=1
	and Rtrim(MOCTG.TG004) like '2%X_'
	and MOCTF.TF003>='20230801'
	and  MOCTF.TF003 >= @StartDay and MOCTF.TF003<=@EndtDay



	--select * from CMSMW

	--select * 
	--from @tbReturn
	--left join CMSMW on 

	
--21108     	事业一部AI          
--21109     	事业一部SMT          
--21125     	事业二部AI         
--21124     	事业二部SMT         
--21131     	事业三部AI    
--21130     	事业三部SMT               

 Return  
End  


GO


