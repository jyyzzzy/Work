USE [RDSJK]
GO

SELECT [ZLDZ01]
      ,[ZLDZ02]
      ,[ZLDZ03]
      ,[ZLDZ04]
      ,[ZLDZ05]
      ,[ZLDZ06]
      ,[ZLDZ07]
      ,[ZLDZ08]
      ,[ZLDZ00]
  FROM [dbo].[ZLDZYY]

GO
drop table #DZ
 select ZLDZ01 DZ01,ZLDZ02 DZ02 into #DZ FROM [dbo].[ZLDZYY] where 1=2

 
 select * FROM [dbo].[ZLDZYY] where  exists (select * from  #DZ where ZLDZ01=DZ01 and  ZLDZ02= DZ02)

 
 select  ZLDZ01 DZ01,ZLDZ02 DZ02,max(ZLDZ03) DZ03 into #D FROM [dbo].[ZLDZYY] where  exists (select * from  #DZ where ZLDZ01=DZ01 and  ZLDZ02= DZ02) group by 
 ZLDZ01,ZLDZ02 

 select * FROM [dbo].[ZLDZYY] where  exists (select * from  #D where ZLDZ01=DZ01 and  ZLDZ02= DZ02 and ZLDZ03=DZ03)

 update  [dbo].[ZLDZYY] set  ZLDZ03='2025-03-31 00:00:00'  where  exists (select * from  #D where ZLDZ01=DZ01 and  ZLDZ02= DZ02 and ZLDZ03=DZ03)
  update  [dbo].[ZLDZYY] set  ZLDZ03='2025-03-31 00:00:00'  where  ZLDZ03='2025-01-31 00:00:00' 
 insert into  #DZ
 values
 ('AHRD','304110044600')



select *from  RDSJK.dbo.CLZLB where CLZL017='2025-03-31 00:00:00'and CLZL016<='2024-12-31 00:00:00'and CLZL021='良品'and CLZL001 not like '2%'


select *from  RDSJK.dbo.CLZLB where CLZL017='2026-02-03 00:00:00' and CLZL016<='2025-03-31 00:00:00' and CLZL021='良品' and CLZL001 not like '2%'

drop table #tem2
select * into #temy   from  [dbo].[ZLDZYY] A where exists(
select *from  RDSJK.dbo.CLZLB where CLZL017='2025-03-31 00:00:00'and CLZL016<='2024-12-31 00:00:00'and CLZL021='良品'and CLZL001 not like '2%'
and CLZL001=ZLDZ02)
and  exists( select max(ZLDZ00) from  [dbo].[ZLDZYY] B where B.ZLDZ01='SDRD' group by ZLDZ02 having(max(ZLDZ00)) =A.ZLDZ00) and ZLDZ01='SDRD'




select * into #temx  from  [dbo].[ZLDZYY] A where exists(
select *from  RDSJK.dbo.CLZLB where CLZL017='2026-02-03 00:00:00' and CLZL016<='2025-03-31 00:00:00' and CLZL021='良品' and CLZL001 not like '2%'
and CLZL001=ZLDZ02)
and exists( select max(ZLDZ00) from  [dbo].[ZLDZYY] B where B.ZLDZ01='SDRD' group by ZLDZ02 having(max(ZLDZ00)) =A.ZLDZ00) and ZLDZ01='SDRD'


SELECT *FROM  #tem1 ORDER BY ZLDZ03

select  MAX(ZLDZ00) from     [dbo].[ZLDZYY]

44160 处理前ZLDZ00

SELECT *FROM  #temx A WHERE not exists(SELECT *FROM  #temy B WHERE A.ZLDZ00=B.ZLDZ00)

insert into  [dbo].[ZLDZYY]	SELECT    ZLDZ01, ZLDZ02,'2025-06-30' ZLDZ03, ZLDZ04, ZLDZ05, ZLDZ06, ZLDZ07, ZLDZ08  FROM  #temy A WHERE not exists(SELECT *FROM  #temx B WHERE A.ZLDZ00=B.ZLDZ00)




select *from    [dbo].[ZLDZYY] where ZLDZ02='598900121690'



select *from    [dbo].[ZLDZYY] where ZLDZ02='305030035000'

select *from    [dbo].[ZLDZYY] where ZLDZ02='303000596300'

select *from    [dbo].[ZLDZYY] where ZLDZ03='2025-03-31' and ZLDZ01='SDRD' and ZLDZ04='浙江瑞德'

select *from [dbo].[ZLDZYY] where   ZLDZ01='SDRD-' and ZLDZ02='303000423100'

select *from    [dbo].[ZLDZYY] where ZLDZ03='2025-03-31' and ZLDZ01='SDRD' and (ZLDZ04 like '安徽%' or ZLDZ04 like'浙江%')


into #temx 

select *  from  [dbo].[ZLDZYY] A where exists(
    select *from  RDSJK.dbo.CLZLB 
    where CLZL017='2026-02-03 00:00:00' and CLZL016>='2026-01-01 00:00:00' and CLZL021='良品' and CLZL001 not like '2%'
    and CLZL001=ZLDZ02
   )
    and exists(
    select max(ZLDZ00) from  [dbo].[ZLDZYY] B where B.ZLDZ01='SDRD' group by ZLDZ02 having(max(ZLDZ00)) =A.ZLDZ00
    )
    and ZLDZ01='SDRD'
    --and  ZLDZ03='2025-03-31'
    --and ZLDZ01='SDRD' 
    --and (ZLDZ04 like '安徽%' or ZLDZ04 like'浙江%')


update A set ZLDZ01='SDRD-' from  [dbo].[ZLDZYY] A where exists(
select *from  RDSJK.dbo.CLZLB where CLZL017='2026-02-03 00:00:00' and CLZL016>='2026-01-01 00:00:00' and CLZL021='良品' and CLZL001 not like '2%'
and CLZL001=ZLDZ02)
and exists( select max(ZLDZ00) from  [dbo].[ZLDZYY] B where B.ZLDZ01='SDRD' group by ZLDZ02 having(max(ZLDZ00)) =A.ZLDZ00) and ZLDZ01='SDRD'
and  ZLDZ03='2025-03-31' and ZLDZ01='SDRD' and (ZLDZ04 like '安徽%' or ZLDZ04 like'浙江%')




select *from    [dbo].[ZLDZYY] where ZLDZ03='2025-03-31' and ZLDZ01='SDRD-' and ZLDZ04='浙江瑞德'