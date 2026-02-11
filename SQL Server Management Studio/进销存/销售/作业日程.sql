USE msdb;
GO
EXEC msdb.dbo.sp_delete_job @job_name = N'APS_ShedulDetails_DeltaLoad';

EXEC msdb.dbo.sp_add_job
  @job_name=N'APS_ShedulDetails_DeltaLoad',
  @enabled=1,
  @description=N'从 [APS_RDKJ_PRD] 同步 v_aps_sheduldetails 的新增/变动记录',
  @start_step_id=1;
GO

EXEC msdb.dbo.sp_add_jobstep
  @job_name=N'APS_ShedulDetails_DeltaLoad',
  @step_id=1,
  @step_name=N'InsertDelta',
  @subsystem=N'TSQL',
  @database_name=N'RDSJK',
  @command=N'
INSERT INTO RDSJK..APS_ShedulDetails (
  ID, make_order_num, classes_start_time, plan_qty, processName,
  DESCRIPTIONS, REQ_NUMBER, CREATION_DATE, C_REATE
)
SELECT E.ID, E.make_order_num, E.classes_start_time, E.plan_qty, E.processName,
       E.DESCRIPTIONS, E.REQ_NUMBER, E.CREATION_DATE, GETDATE()
FROM (
  SELECT ID, make_order_num, classes_start_time, plan_qty, processName,
         DESCRIPTIONS, REQ_NUMBER, CREATION_DATE
  FROM OPENQUERY([APS_RDKJ_PRD],
  ''SELECT ID,make_order_num,classes_start_time,plan_qty,processName,DESCRIPTIONS,REQ_NUMBER,CREATION_DATE
    FROM v_aps_sheduldetails
    WHERE CREATION_DATE >= DATE_ADD(NOW(), INTERVAL -3 DAY)'')
  EXCEPT
  SELECT ID, make_order_num, classes_start_time, plan_qty, processName,
         DESCRIPTIONS, REQ_NUMBER, CREATION_DATE
  FROM RDSJK..APS_ShedulDetails
  WHERE CREATION_DATE >= DATEADD(DAY, -3, GETDATE())
) AS E;
';
GO

EXEC msdb.dbo.sp_add_schedule @schedule_name=N'APS_0500_Daily', @freq_type=4, @freq_interval=1, @active_start_time=050000;
EXEC msdb.dbo.sp_add_schedule @schedule_name=N'APS_1230_Daily', @freq_type=4, @freq_interval=1, @active_start_time=123000;
EXEC msdb.dbo.sp_add_schedule @schedule_name=N'APS_1830_Daily', @freq_type=4, @freq_interval=1, @active_start_time=183000;
GO

EXEC msdb.dbo.sp_attach_schedule @job_name=N'APS_ShedulDetails_DeltaLoad', @schedule_name=N'APS_0500_Daily';
EXEC msdb.dbo.sp_attach_schedule @job_name=N'APS_ShedulDetails_DeltaLoad', @schedule_name=N'APS_1230_Daily';
EXEC msdb.dbo.sp_attach_schedule @job_name=N'APS_ShedulDetails_DeltaLoad', @schedule_name=N'APS_1830_Daily';
EXEC msdb.dbo.sp_add_jobserver  @job_name=N'APS_ShedulDetails_DeltaLoad', @server_name=N'(LOCAL)';
GO
