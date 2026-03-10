use ZJRD
Declare @DataStr as Varchar(2000)
Declare @DateText as varchar(2000)
Declare @DataStr1 as Varchar(2000)
Declare @DataStr2 as varchar(2000)
Declare @DataStr3 as varchar(2000)
Declare @DataStr4 as varchar(2000)
Declare @DataStr5 as varchar(2000)
Declare @DataStr6 as varchar(2000)
Declare @Status as Int 
Declare @data as Varchar(max)
Declare @ResponseText as Varchar(max)
declare @col varchar(200)
set @DataStr='领料单开单未审核单据:'
set @DateText='5481回写空白有单头无单身:'
set @DataStr1='非生产领料单异常数据:'
set @DataStr2='销货单异常数据:'
set @DataStr3='WMS退料单和ERP数量不一致单据:'
set @DataStr4='领料单WMS有数据ERP无数据:'
set @DataStr5='挪料单对应的领退料单未审核单据：'
set @DataStr6='退料单异常数据：'
DECLARE #point_cursor CURSOR
for
                    			   select 'WMS:'+TC001+'-'+TC002+'-'+status+'|ERP:'+ERPTC001+'-'+ERPTC002+'-'+TC009 from(
                        select distinct WMS.TC001,WMS.TC002,WMS.status, ERP.TC001 ERPTC001, ERP.TC002 ERPTC002,ERP.TC009 from
                        (select TC001,TC002,TC003,TE003,TE004,TE005,TE008,MOCTCFROMWMS.status from ZJRD.dbo.MOCTCFROMWMS join ZJRD.dbo.MOCTEFROMWMS on TC001=TE001 and TC002=TE002)WMS 
                        join 
                        (select TC001,TC002,TE003,TE004,TE005,TE008,TE019,TC009,TE011,TE012,MOCTC.CREATOR from ZJRD.dbo.MOCTC join ZJRD.dbo.MOCTE on TC001=TE001 and TC002=TE002)ERP
                         on WMS.TC001=ERP.TC001 and WMS.TC002=ERP.TC002 and WMS.TE003=ERP.TE003 
                         WHERE TC009<>'Y' and TC009<>'V' 
						 AND WMS. TE005>0 and WMS.TC002 like '20%' 
						-- AND WMS.status='Y'
						 and WMS.TC002>'202509'
                        union all
                        select distinct WMS.TC001,WMS.TC002,WMS.status, ERP.TC001 ERPTC001, ERP.TC002 ERPTC002,ERP.TC009 from 
                        (select TC001,TC002,TC003,TE003,TE004,TE005,TE008,MOCTCFROMWMS.status from ZJRD.dbo.MOCTCFROMWMS join ZJRD.dbo.MOCTEFROMWMS on TC001=TE001 and TC002=TE002)WMS 
                        join 
                        (select TC001,TC002,TE003,TE004,TE005,TE008,TE019,TC009,TC007,TE011,TE012 from ZJRD.dbo.MOCTC join ZJRD.dbo.MOCTE on TC001=TE001 and TC002=TE002)ERP 
                        on WMS.TC001=ERP.TC001 and WMS.TC002=ERP.TC007 and WMS.TE003=ERP.TE003 and TC009<>'Y'  and (WMS.TC002 like 'W%' or  WMS.TC002 like 'F%' ) --AND WMS.status='Y' 
                        WHERE  WMS.TC003>'20250901' 
                        and TC009<>'V' 
                         ) A;
begin
OPEN #point_cursor
FETCH NEXT FROM #point_cursor INTO @col

while @@fetch_status=0 
begin
        set @DataStr=@DataStr+'\n'+@col
        FETCH NEXT FROM #point_cursor INTO @col
 end

close #point_cursor
Deallocate #point_cursor
end 

--创建回写空白的游标
DECLARE #point_cursor1 CURSOR
for
        select TC001+''+TC002+''+TC007 from 
        ( select WMS.TC001,ERP.TC002, ERP.TC007 from        ZJRD.dbo.MOCTCFROMWMS WMS join ZJRD.dbo.MOCTC ERP on 
                WMS.TC001=ERP.TC001 and WMS.TC002=ERP.TC007 and TC009='Y' and WMS.TC002 like 'W%' AND WMS.status='Y' )abc2
        where (select count(1) as num from
                        (select abc.TC002 FROM ( select WMS.TC001,ERP.TC002 from ZJRD.dbo.MOCTCFROMWMS WMS join ZJRD.dbo.MOCTC ERP on 
                                WMS.TC001=ERP.TC001 and WMS.TC002=ERP.TC007 and TC009='Y' and WMS.TC002 like 'W%' AND WMS.status='Y' )abc,
                 MOCTE  where abc.TC001=MOCTE.TE001 AND abc.TC002=MOCTE.TE002  group by abc.TC002, abc.TC001) b
                        where abc2.TC002 = b.TC002
                        ) = 0 and TC002>'202509'
                order by TC007 desc                
begin
OPEN #point_cursor1
FETCH NEXT FROM #point_cursor1 INTO @col

while @@fetch_status=0 
begin
        set @DateText=@DateText+'\n'+@col
        FETCH NEXT FROM #point_cursor1 INTO @col
 end

close #point_cursor1
Deallocate #point_cursor1
end 

--创建非生产领料单异常数据
DECLARE #point_cursor2 CURSOR
for
        select 'WMS:'+WTA001+'-'+WTA002+'-'+WSTATUS+'|ERP:'+ETA001+'-'+ETA002+'-'+ETA006 from
        ( select WMS.TA001 WTA001,WMS.TA002 WTA002,WMS.status WSTATUS,ERP.TA001 ETA001,ERP.TA002 ETA002,ERP.TA006 ETA006 from ZJRD.dbo.INVTAFROMWMS WMS  join ZJRD.dbo.INVTA ERP on  WMS.TA001=ERP.TA001 and WMS.TA002=ERP.TA002  and TA006<>'Y' and WMS.TA003>'202509' AND ( WMS.TA001='1173' OR  WMS.TA001='1203') --and WMS.TA002 <> '20220200339' and WMS.TA002 <> '20220300287'
		union all select WMS.TA001 WTA001,WMS.TA002 WTA002,WMS.status WSTATUS,'' ETA001,'' ETA002,'' ETA006 from  ZJRD.dbo.INVTAFROMWMS WMS where ( WMS.TA001='1173' OR  WMS.TA001='1203') AND WMS.TA002 not in (select TA002 from ZJRD.dbo.INVTA ERP WHERE ERP.TA001=WMS.TA001) and WMS.TA003>'202509'-- and WMS.TA002 <> '20220200339' and WMS.TA002 <> '20220300287' 
		)A   
                order by WTA002 desc                
begin
OPEN #point_cursor2
FETCH NEXT FROM #point_cursor2 INTO @col

while @@fetch_status=0 
begin
        set @DataStr1=@DataStr1+'\n'+@col
        FETCH NEXT FROM #point_cursor2 INTO @col
 end

close #point_cursor2
Deallocate #point_cursor2
end

--创建销货单异常数据
DECLARE #point_cursor3 CURSOR
for
        select 'WMS:'+WTG001+'-'+WTG002+'-'+WSTATUS+'|ERP:'+ETG001+'-'+ETG002+'-'+ETG006 from
        ( select WMS.TA001 WTG001,WMS.TA002 WTG002,WMS.status WSTATUS,ERP.TG001 ETG001,ERP.TG002 ETG002,ERP.TG023 ETG006 from ZJRD.dbo.INVTAFROMWMS WMS  join ZJRD.dbo.COPTG ERP on  WMS.TA001=ERP.TG001 and WMS.TA002=ERP.TG002 and ERP.TG023<>'V' and ERP.TG023<>'Y' and ERP.TG003>'202509' 
		union all select WMS.TA001 WTG001,WMS.TA002 WTG002,WMS.status WSTATUS,'' ETG001,'' ETG002,'' ETG006 from  ZJRD.dbo.INVTAFROMWMS WMS where  WMS.TA002 not in (select TG002 from ZJRD.dbo.COPTG ERP WHERE ERP.TG001=WMS.TA001) 
		and WMS.processDate>'2025-09' 
		and WMS.TA001 LIKE '23%')A   
                order by WTG002 desc               
begin
OPEN #point_cursor3
FETCH NEXT FROM #point_cursor3 INTO @col

while @@fetch_status=0 
begin
        set @DataStr2=@DataStr2+'\n'+@col
        FETCH NEXT FROM #point_cursor3 INTO @col
 end

close #point_cursor3
Deallocate #point_cursor3
end

--WMS退料单明细数量和ERP退料数量不一致单据  
DECLARE #point_cursor4 CURSOR
for
	
	
select * from(
select a.TB001+'-'+a.TB002+',序号：'+a.TB003+',料号：'+rtrim(a.TB004)+',WMS数量:'+convert(varchar(25),a.TB007)+
'，ERP数量：'+convert(varchar(25),b.TE005)  as str1 from (
select B.TB001,B.TB002,A.processDate,B.TB003,B.TB004,
B.TB005,B.TB006,B.TB007,B.TB008,B.TB009,B.TB012,B.TB013
 from INVTAFROMWMS A left join INVTBFROMWMS B on TA001=TB001 and TA002=TB002
where TA001 like '56%' and  A.status='Y' AND A.processDate>'2025-09-01' )
a left join  (
SELECT TC001,TC002,C.CREATE_DATE,TE003,TE004,TE005,TE006,TE007,TE008 FROM MOCTC C LEFT JOIN MOCTE E ON TC001=TE001 AND TC002=TE002
where TC001 like '56%'  AND C.CREATE_DATE >'202509'
) b on a.TB001=b.TC001 and a.TB002=b.TC002 and a.TB003=b.TE003
where a.TB007<>b.TE005) r
               
begin
OPEN #point_cursor4
FETCH NEXT FROM #point_cursor4 INTO @col

while @@fetch_status=0 
begin
        set @DataStr3=@DataStr3+'\n'+@col
        FETCH NEXT FROM #point_cursor4 INTO @col
 end

close #point_cursor4
Deallocate #point_cursor4
end

--领料单WMS有数据ERP无数据
DECLARE #point_cursor5 CURSOR
for
			
select  'WMS:'+MOCTCFROMWMS.TC001+'-'+MOCTCFROMWMS.TC002+'-'+MOCTCFROMWMS.status+'|ERP:空-空-空' from MOCTCFROMWMS 
left join MOCTC on MOCTCFROMWMS.TC001=MOCTC.TC001 AND MOCTCFROMWMS.TC002=MOCTC.TC002
  left join MOCTR on MOCTR.TR004=MOCTCFROMWMS.TC001 and MOCTR.TR005=MOCTCFROMWMS.TC002
 WHERE MOCTCFROMWMS.TC002 NOT IN(SELECT TC002 FROM MOCTC WHERE TC001=MOCTCFROMWMS.TC001)
 AND MOCTCFROMWMS.TC001 IN('5471','5472')
 AND MOCTCFROMWMS.TC002 LIKE '2025%'  AND MOCTCFROMWMS.TC002 > '202509'
 AND MOCTCFROMWMS.status='N'
 AND MOCTCFROMWMS.TC002 NOT IN(SELECT TR005 FROM MOCTR WHERE TR004=MOCTCFROMWMS.TC001 AND TR004='5471')
	
               
begin
OPEN #point_cursor5
FETCH NEXT FROM #point_cursor5 INTO @col

while @@fetch_status=0 
begin
        set @DataStr4=@DataStr4+'\n'+@col
        FETCH NEXT FROM #point_cursor5 INTO @col
 end

close #point_cursor5
Deallocate #point_cursor5
end

--挪料单所生成的退料单未审核
DECLARE #point_cursor6 CURSOR
for
select*
 
from
	(select   '挪料单：'+MR.TR001+'-'+MR.TR002+'-'+MR.TR010+',领料单：'+MT.TC001+'-'+MT.TC002+'-'+MT.TC009+',退料单：'+MC.TC001+'-'+MC.TC002+'-'+MC.TC009 str1 
	
	FROM   MOCTR  MR	
	join DSCSYS..DSCMA ds on MR.CREATOR=ds.MA001
	 JOIN    MOCTC  MC ON MR.TR006=MC.TC001  AND MR.TR007=MC.TC002    
	 JOIN    MOCTC  MT ON MR.TR004=MT.TC001 AND MR.TR005=MT.TC002    
--join  MOCTC  Ma ON MR.TR004=Ma.TC001  AND MR.TR005=Ma.TC002    
	WHERE MR.TR010='Y'  AND MC.TC009 in ('N','U','V')
	--and Ma.TC009='Y'  
	AND LEFT(MR.CREATE_DATE,8)>'202509' 
	) a
--挪料单所生成的领料单未审核
union (
	SELECT '挪料单：'+MR.TR001+'-'+MR.TR002+'-'+MR.TR010+',领料单：'+MC.TC001+'-'+MC.TC002+'-'+MC.TC009+',退料单：'+MT.TC001+'-'+MT.TC002+'-'+MT.TC009	str1
	FROM   MOCTR  MR 
	join DSCSYS..DSCMA ds on MR.CREATOR=ds.MA001
	JOIN    MOCTC  MC ON MR.TR004=MC.TC001 AND MR.TR005=MC.TC002    
	JOIN    MOCTC  MT ON MR.TR006=MT.TC001 AND MR.TR007=MT.TC002    
--	 join  MOCTC  Ma ON MR.TR006=Ma.TC001  AND MR.TR007=Ma.TC002    
	WHERE MR.TR010='Y'  
	AND MC.TC009 in ('N','U','V')
	-- and Ma.TC009='Y'  
	 AND LEFT(MR.CREATE_DATE,8)>'202509'
	) 
	begin
OPEN #point_cursor6
FETCH NEXT FROM #point_cursor6 INTO @col

while @@fetch_status=0 
begin
        set @DataStr5=@DataStr5+'\n'+@col
        FETCH NEXT FROM #point_cursor6 INTO @col
 end

close #point_cursor6
Deallocate #point_cursor6
end


--创建退料单异常数据
DECLARE #point_cursor7 CURSOR
for

				
		select 'WMS:'+TA001+'-'+TA002+'-'+status+'|ERP:'+TC001+'-'+TC002+'-'+TC009+'-'+TE004   from (
		select TA001, TA002,INVTAFROMWMS.status
,MOCTC.TC001,MOCTC.TC002,MOCTC.TC009,'' TE004  from MOCTC left  join INVTAFROMWMS on TC001=TA001 AND TA002=TC002 WHERE TC001 LIKE '56%' and MOCTC.CREATE_DATE>'202509' 
		AND TC009<>'Y' and TC009<>'V' 
		AND INVTAFROMWMS.status='Y'
		and TC001+TC002 not in(
			SELECT  TC001+TC002
        from MOCTC 
        LEFT JOIN MOCTE ON MOCTC.TC001=MOCTE.TE001 AND MOCTC.TC002=MOCTE.TE002
        LEFT JOIN MOCTB ON TE011=TB001 AND TE012=TB002 AND TE004=TB003  AND TB006=TE009
		left join INVTAFROMWMS on MOCTC.TC001=INVTAFROMWMS.TA001 AND MOCTC.TC002=INVTAFROMWMS.TA002
        where TC009<>'Y' and TC009<>'V' 
		and MOCTC.CREATE_DATE>'202509' 
		AND MOCTC.TC001 LIKE '56%' 
		and TC002 NOT IN
		(SELECT MT.TC002
	FROM   MOCTR  MR 
	JOIN    MOCTC  MT ON MR.TR006=MT.TC001 AND MR.TR007=MT.TC002    
	WHERE MR.TR010 in ('N','U') 
	 AND LEFT(MR.CREATE_DATE,8)>'20250901'
	 and MT.TC001=MOCTC.TC001

	)
	GROUP BY TB002,TE004,TE009,TB005,TB004,MOCTC.TC001,MOCTC.TC002,MOCTC.TC009,TA001, TA002,INVTAFROMWMS.status
		HAVING TB005-TB004<SUM(TE005)
		and TC001 IN (SELECT TA001 FROM INVTAFROMWMS WHERE TA002=TC002)
		)
		UNION 

			SELECT  TA001, TA002,INVTAFROMWMS.status,MOCTC.TC001,MOCTC.TC002,MOCTC.TC009,TE004
        from MOCTC 
        LEFT JOIN MOCTE ON MOCTC.TC001=MOCTE.TE001 AND MOCTC.TC002=MOCTE.TE002
        LEFT JOIN MOCTB ON TE011=TB001 AND TE012=TB002 AND TE004=TB003 AND TB006=TE009
		left join INVTAFROMWMS on MOCTC.TC001=INVTAFROMWMS.TA001 AND MOCTC.TC002=INVTAFROMWMS.TA002
        where TC009<>'Y' and TC009<>'V' 
		and MOCTC.CREATE_DATE>'202509'
		 AND MOCTC.TC001 LIKE '56%' 
		and TC002 NOT IN
		(SELECT MT.TC002
	FROM   MOCTR  MR 
	JOIN    MOCTC  MT ON MR.TR006=MT.TC001 AND MR.TR007=MT.TC002    
	WHERE MR.TR010 in ('N','U') 
	 AND LEFT(MR.CREATE_DATE,8)>'20250901'
	 and MT.TC001=MOCTC.TC001
	)
		and TC001 IN (SELECT TA001 FROM INVTAFROMWMS WHERE TA002=TC002)

		GROUP BY TB002,TE004,TE009,TB005,TB004,MOCTC.TC001,MOCTC.TC002,MOCTC.TC009,TA001, TA002,INVTAFROMWMS.status
		HAVING TB005-TB004<SUM(TE005)
			)A

	begin
OPEN #point_cursor7
FETCH NEXT FROM #point_cursor7 INTO @col

while @@fetch_status=0 
begin
        set @DataStr6=@DataStr6+'\n'+@col
        FETCH NEXT FROM #point_cursor7 INTO @col
 end

close #point_cursor7
Deallocate #point_cursor7
end

set @DataStr=@DataStr+'\n'+@DateText+'\n'+@DataStr1+'\n'+@DataStr2+'\n'+@DataStr3+'\n'+@DataStr4+'\n'+@DataStr5+'\n'+@DataStr6

--发送到企业微信
if(isnull( @DataStr,'')<>'')
begin        

        set @data = '{  "msgtype": "markdown",
                "markdown": {
                        "content": " '+@DataStr +'",
                        "mentioned_list":["wangqing","@all"],
                        "mentioned_mobile_list":["13800001111","@all"]
                }
        }'

        select @data

        Exec sp_OACreate 'Msxml2.ServerXMLHTTP.3.0', @Status OUT;
        Exec sp_OAMethod @Status, 'open', NULL, 'POST','https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=9789795f-7d3e-4a9e-b1c4-c1dce18995df','false'
        Exec sp_OAMethod @Status, 'setRequestHeader', NULL, 'Content-Type','application/x-www-form-urlencoded'
        Exec sp_OAMethod @Status, 'send', NULL,@data
        Exec sp_OAMethod @Status, 'responseText', @ResponseText OUTPUT
        if @Status<>0
          begin
                EXEC sp_OAGetErrorInfo @Status
          end
        Exec sp_OADestroy @Status
END
