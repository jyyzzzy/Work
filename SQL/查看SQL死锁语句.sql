
/***查临时数据库增长问题*/
--查看数据库中有无长时间运行的事务
DBCC OPENTRAN(tempdb) ;
--由于数据库开启了快照，可通过快照信息查找耗时的查询：

SELECT * FROM sys.dm_tran_active_snapshot_database_transactions ORDER BY elapsed_time_seconds DESC
--发现top 1 的session_id与dbcc opentran结果吻合

--4.获取该session_id对应的查询语句
DBCC INPUTBUFFER(278)


--5.kill 查询：
KILL 998;
--数据库 unused space开始回升。

/***查临时数据库增长问题*/


	WITH CTE_SID ( BSID, SID, sql_handle )
			  AS ( SELECT   blocking_session_id ,
							session_id ,
							sql_handle
				   FROM     sys.dm_exec_requests
				   WHERE    blocking_session_id <> 0
				   UNION ALL
				   SELECT   A.blocking_session_id ,
							A.session_id ,
							A.sql_handle
				   FROM     sys.dm_exec_requests A
							JOIN CTE_SID B ON A.session_id = B.BSID
				 )
		SELECT  C.BSID ,
				C.SID ,
				S.login_name ,
				S.host_name ,
				S.status ,
				S.cpu_time ,
				S.memory_usage ,
				S.last_request_start_time ,
				S.last_request_end_time ,
				S.logical_reads ,
				S.row_count ,
				Q.text  --into #temp
		FROM    CTE_SID C 
				JOIN sys.dm_exec_sessions S ON C.SID = S.session_id
				CROSS APPLY sys.dm_exec_sql_text(C.sql_handle) Q

				--WHERE   S.host_name='ERP-SVR'
		ORDER BY S.last_request_start_time 
	  
	
	

	

	SELECT DISTINCT  [Spid] = session_id  ,
        start_time start_time2  ,
                hostname=sp.hostname,
        ecid ,
        [Database] = DB_NAME(sp.dbid) ,
        [User] = nt_username ,
        [Status] = er.status ,
        [Wait] = wait_type ,
        [Individual Query] = SUBSTRING(qt.text, er.statement_start_offset / 2,
                                       ( CASE WHEN er.statement_end_offset = -1
                                              THEN LEN(CONVERT(NVARCHAR(MAX), qt.text))
                                                   * 2
                                              ELSE er.statement_end_offset
                                         END - er.statement_start_offset ) / 2) ,
        [Parent Query] = qt.text ,
        Program = program_name ,
        nt_domain,*
FROM    sys.dm_exec_requests er
        INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
        CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
--WHERE   session_id > 50 -- Ignore system spids.
--        AND session_id NOT IN ( @@SPID ) -- Ignore this current statement.
--                --and sp.hostname like '%APS%'

			--WHERE   hostname='WEB-SVR'
ORDER BY start_time2 





--先运行下方的select语句，查询出  锁的进程；
SELECT request_session_id spid,OBJECT_NAME(resource_associated_entity_id) tableName ,*
FROM sys.dm_tran_locks WHERE resource_type='OBJECT'  AND OBJECT_NAME(resource_associated_entity_id) IS NOT NULL




--SELECT *FROM  (
--SELECT request_session_id spid,OBJECT_NAME(resource_associated_entity_id) tableName ,*
--FROM sys.dm_tran_locks WHERE resource_type='OBJECT'  AND OBJECT_NAME(resource_associated_entity_id) IS NOT NULL  ) a WHERE tableName  NOT LIKE 'DF%'

 
--第二步：






--解锁语句，需要将锁表进程 @spid换成 上面查询出来的锁表进程；
DECLARE @spid INT 
SET @spid = 591
 --锁表进程
DECLARE @sql VARCHAR(1000)
SET @sql='kill '+CAST(@spid AS VARCHAR)
EXEC(@sql)


/***

	declare @spid  int 
Set @spid  = 209                                                                                                                           --锁表进程
declare @sql varchar(1000)
set @sql='kill '+cast(@spid  as varchar)
exec(@sql)

***/

SELECT DISTINCT  [Spid] = session_id  ,
        start_time start_time2  ,
                hostname=sp.hostname,
        ecid ,
        [Database] = DB_NAME(sp.dbid) ,
        [User] = nt_username ,
        [Status] = er.status ,
        [Wait] = wait_type ,
        [Individual Query] = SUBSTRING(qt.text, er.statement_start_offset / 2,
                                       ( CASE WHEN er.statement_end_offset = -1
                                              THEN LEN(CONVERT(NVARCHAR(MAX), qt.text))
                                                   * 2
                                              ELSE er.statement_end_offset
                                         END - er.statement_start_offset ) / 2) ,
        [Parent Query] = qt.text ,
        Program = program_name ,
        nt_domain,*
FROM    sys.dm_exec_requests er
        INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
        CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
WHERE   session_id > 50 -- Ignore system spids.
        AND session_id NOT IN ( @@SPID ) -- Ignore this current statement.
                --and sp.hostname like '%APS%'
ORDER BY start_time2 

SELECT invorgid,itemcode,strdef20 FROM vw_cpciteminv_sync_erp WHERE 1
SELECT invorgid,itemcode,strdef20 FROM vw_cpciteminv_sync_erp WHERE 1
SELECT invorgid,itemcode,strdef20 FROM vw_cpciteminv_sync_erp WHERE 1=1 






--select TD007,StorageID,*   update SDRD.dbo.PURTD SET TD007=StorageID  from SDRD.dbo.PURTD join SDRD.dbo.v_Material_Checked on MaterialID=TD004 where TD016 = 'N' and TD007<>StorageID    --select *   update SDRD.dbo.PURTH SET TH009=StorageID  from SDRD.dbo.PURTH join SDRD.dbo.v_Material_Checked on MaterialID=TH004 where TH030 = 'N' and TH009<>StorageID      --select *   update SDRD.dbo.INVMB SET MB017=StorageID  from SDRD.dbo.INVMB join SDRD.dbo.v_Material_Checked on MaterialID=MB001 where MB017<>StorageID      --select *   --update SDRD.dbo.INVTB set TB012=StorageID  --from SDRD.dbo.INVTB join SDRD.dbo.v_Material_Checked on MaterialID=TB004 where TB018='N' and TB012<>StorageID and TB001 NOT  IN('1101','1105','1106','1110','1201','1202')       -- select *   --update SDRD.dbo.COPTH set TH007=StorageID  --  from SDRD.dbo.COPTH join SDRD.dbo.v_Material_Checked on MaterialID=TH004 WHERE TH020='N'  and TH007<>StorageID         -- select *    UPDATE SDRD.dbo.MOCTB SET TB009=StorageID   From SDRD.dbo.MOCTA JOIN SDRD.dbo.MOCTB ON TA001=TB001 AND TA002=TB002 join SDRD.dbo.v_Material_Checked on MaterialID=TB003 WHERE TA011 IN('1','2','3')  and TB009<>StorageID         --select *    --UPDATE SDRD.dbo.MOCTE SET  TE008=StorageID  -- from SDRD.dbo.MOCTE join SDRD.dbo.v_Material_Checked on MaterialID=TE004 WHERE TE019='N' and TE008<>StorageID                 --ZJRD  --select TD007,MB017,*   update ZJRD.dbo.PURTD SET TD007=MB017  from ZJRD.dbo.PURTD join ZJRD.dbo.INVMB on MB001=TD004 where TD016 = 'N' and TD007<>MB017    --select *   update ZJRD.dbo.PURTH SET TH009=MB017  from ZJRD.dbo.PURTH join ZJRD.dbo.INVMB on MB001=TH004 where TH030 = 'N' and TH009<>MB017      ----select *   --update ZJRD.dbo.INVMB SET MB017=MB017  --from ZJRD.dbo.INVMB join ZJRD.dbo.INVMB on MB001=MB001 where MB017<>MB017      --select *   --update ZJRD.dbo.INVTB set TB012=MB017  --from ZJRD.dbo.INVTB join ZJRD.dbo.INVMB on MB001=TB004 where TB018='N' and TB012<>MB017 and TB001 NOT  IN('1101','1105','1106','1110','1201','1202')       -- select *   --update ZJRD.dbo.COPTH set TH007=MB017  --  from ZJRD.dbo.COPTH join ZJRD.dbo.INVMB on MB001=TH004 WHERE TH020='N'  and TH007<>MB017         -- select *    UPDATE ZJRD.dbo.MOCTB SET TB009=MB017   From ZJRD.dbo.MOCTA JOIN ZJRD.dbo.MOCTB ON TA001=TB001 AND TA002=TB002 join ZJRD.dbo.INVMB on MB001=TB003 WHERE TA011 IN('1','2','3')  and TB009<>MB017     
--SELECT * FROM "v_ProductType"


/***

drop table #temp
go
WITH    CTE_SID ( BSID, SID, sql_handle )
          AS ( SELECT   blocking_session_id ,
                        session_id ,
                        sql_handle
               FROM     sys.dm_exec_requests
               WHERE    blocking_session_id <> 0
               UNION ALL
               SELECT   A.blocking_session_id ,
                        A.session_id ,
                        A.sql_handle
               FROM     sys.dm_exec_requests A
                        JOIN CTE_SID B ON A.session_id = B.BSID
             )
    SELECT  C.BSID ,
            C.SID ,
            S.login_name ,
            S.host_name ,
            S.status ,
            S.cpu_time ,
            S.memory_usage ,
            S.last_request_start_time ,
            S.last_request_end_time ,
            S.logical_reads ,
            S.row_count ,
            Q.text  into #temp
    FROM    CTE_SID C 
            JOIN sys.dm_exec_sessions S ON C.SID = S.session_id
            CROSS APPLY sys.dm_exec_sql_text(C.sql_handle) Q
    ORDER BY S.last_request_start_time 

	
	select *from #temp

	 
 DECLARE MyCursor CURSOR	
	FOR  select distinct SID from #temp
--打开一个游标	
OPEN MyCursor
--循环一个游标
DECLARE  @TB04 int
	FETCH NEXT FROM  MyCursor INTO @TB04
WHILE @@FETCH_STATUS =0
	BEGIN
	

		declare @spid  int 
Set @spid  = @TB04 --锁表进程
declare @sql varchar(1000)
set @sql='kill '+cast(@spid  as varchar)
exec(@sql)

		FETCH NEXT FROM  MyCursor INTO @TB04
	END	
--关闭游标
CLOSE MyCursor
--释放资源
DEALLOCATE MyCursor



*********/



SELECT request_session_id spid,OBJECT_NAME(resource_associated_entity_id) tableName ,*
FROM sys.dm_tran_locks WHERE resource_type='OBJECT'  AND OBJECT_NAME(resource_associated_entity_id) IS NOT NULL







SELECT request_session_id spid,OBJECT_NAME(resource_associated_entity_id) tableName,request_status,* FROM
(

SELECT [Spid] = session_id  ,
        start_time start_time2  ,
                hostname=sp.hostname,
        ecid ,
        [Database] = DB_NAME(sp.dbid) ,
        [User] = nt_username ,
        [Status] = er.status ,
        [Wait] = wait_type ,
        [Individual Query] = SUBSTRING(qt.text, er.statement_start_offset / 2,
                                       ( CASE WHEN er.statement_end_offset = -1
                                              THEN LEN(CONVERT(NVARCHAR(MAX), qt.text))
                                                   * 2
                                              ELSE er.statement_end_offset
                                         END - er.statement_start_offset ) / 2) ,
        [Parent Query] = qt.text ,
        Program = program_name ,
        nt_domain,text--,*
		
FROM    sys.dm_exec_requests er
        INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
        CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
WHERE   session_id > 50 -- Ignore system spids.
        AND session_id NOT IN ( @@SPID ) -- Ignore this current statement. --and sp.hostname like '%APS%'

				) AS b JOIN  sys.dm_tran_locks ON request_session_id=[Spid] WHERE resource_type='OBJECT'
				--and Spid not in('485','605','434')

				--AND b.hostname='ERP-SVR'
ORDER BY start_time2 





 DECLARE @spid INT 
SET @spid = 1505 --锁表进程
DECLARE @sql VARCHAR(1000)
SET @sql='kill '+CAST(@spid AS VARCHAR)
EXEC(@sql)


SELECT   request_session_id   spid,OBJECT_NAME(resource_associated_entity_id) tableName   
,* FROM   sys.dm_tran_locks WHERE resource_type='OBJECT'

EXEC sp_executesql N'SELECT TB003,TB001,TB002,TA006,TB006,TB004,TB005,TB004-TB005 as TB0405
FROM SDRD..MOCTB AS MOCTB
Left join SDRD..MOCTA as MOCTA on TA001=TB001 and TA002=TB002
WHERE  TB003=@P1 AND TA019=@P2 and
TB018=''Y''  and @P3 IN ('''',TA030) and
((TA011<>''Y'' and  TA011<>''y'' )  or  left(MOCTA.TA014,6)=CONVERT(varchar(6), GETDATE(), 112)) and
TB005>0
order by
TB003,TB001,TB002,TB006
',N'@P1 varchar(20),@P2 varchar(6),@P3 varchar(1)','300080102800','000101',''





	USE [msdb]
-- 删除 90 天前的日志
DELETE FROM [sysmaintplan_logdetail] 
WHERE [start_time] < DATEADD(DAY, -90, GETDATE())