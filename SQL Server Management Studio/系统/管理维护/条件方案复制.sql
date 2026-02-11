/******复制易飞ERP查询条件方案******/-- 2025-9-2 BY ZIYANG ZHANG


  /****** SSMS 的 SelectTopNRows 命令的脚本  ******/
INSERT INTO [DSCSYS].[dbo].[DocuSave]([NCONDITION]
      ,[CREATOR]
      ,[CREATE_DATE]
      ,[PROGRAMME]
      ,[ActivePage]
      ,[VCONDITION])
	SELECT [NCONDITION]
      ,'10108865'
      ,FORMAT(GETDATE(), 'yyyyMMdd')
      ,[PROGRAMME]
      ,[ActivePage]
      ,[VCONDITION] FROM [DSCSYS].[dbo].[DocuSave]
	  WHERE CREATOR = '10056458' 
		AND [NCONDITION] NOT IN 
			(SELECT [NCONDITION] FROM [DSCSYS].[dbo].[DocuSave] WHERE CREATOR = '10107634')


	    SELECT *
  --DELETE 
  FROM [DSCSYS].[dbo].[DocuSave] WHERE CREATOR = '10040210 '

  /****** SSMS 的 SelectTopNRows 命令的脚本  ******/
INSERT INTO [DSCSYS].[dbo].[GeneSave](
       [NCONDITION]
      ,[CREATOR]
      ,[CREATE_DATE]
      ,[PROGRAMME]
      ,[SCONDITION]
      ,[VCONDITION]
  ) 
	SELECT [NCONDITION]
      ,'10108300'
      ,FORMAT(GETDATE(), 'yyyyMMdd')
      ,[PROGRAMME]
      ,[SCONDITION]
      ,[VCONDITION]
  FROM [DSCSYS].[dbo].[GeneSave]
  WHERE CREATOR = '10040210'
  AND [NCONDITION] NOT IN 
	(SELECT [NCONDITION] FROM [DSCSYS].[dbo].[GeneSave] WHERE CREATOR = '10108300')

  SELECT *
  --DELETE 
  FROM [DSCSYS].[dbo].[GeneSave] WHERE CREATOR = '10108300'


SELECT * 
FROM [DSCSYS].[dbo].[DSCMA] 
WHERE MA005 = 'Y' 
AND NOT EXISTS (
	SELECT 1 
	FROM master.dbo.OA_Hrm 
	WHERE MA001 = workcode COLLATE Chinese_PRC_BIN
)


SELECT * FROM [DSCSYS].[dbo].[RGRMB] WHERE MB001 = '10056458'

SELECT * FROM [DSCSYS].[dbo].[RPTGRIDFMT] WHERE FMTNAME = '10056458'

SELECT * FROM [DSCSYS].[dbo].[DSCMD] WHERE MD002 = '10105978'