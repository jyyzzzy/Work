/******复制自定义报表限定用户******/ --2025/9/11 BY ZIYANG ZHANG 

INSERT INTO [DSCSYS].[dbo].[RGRMB]
           ([COMPANY]
           ,[CREATOR]
           ,[USR_GROUP]
           ,[CREATE_DATE]
           ,[MODIFIER]
           ,[MODI_DATE]
           ,[FLAG]
           ,[MB001]
           ,[MB002]
           ,[UDF01]
           ,[UDF02]
           ,[UDF03]
           ,[UDF04]
           ,[UDF05]
           ,[UDF06]
           ,[UDF51]
           ,[UDF52]
           ,[UDF53]
           ,[UDF54]
           ,[UDF55]
           ,[UDF56])
SELECT '0001'
           ,'10105978'
           ,'90001'
           ,FORMAT(GETDATE(), 'yyyyMMddHHmmssfff')
           ,[MODIFIER]
           ,[MODI_DATE]
           ,'1'
           ,[MB001]
           ,'50104205'
           ,[UDF01]
           ,[UDF02]
           ,[UDF03]
           ,[UDF04]
           ,[UDF05]
           ,[UDF06]
           ,[UDF51]
           ,[UDF52]
           ,[UDF53]
           ,[UDF54]
           ,[UDF55]
           ,[UDF56]
FROM [DSCSYS].[dbo].[RGRMB] AS A
WHERE MB002 = '50064879'
 AND NOT EXISTS(SELECT 1 FROM [DSCSYS].[dbo].[RGRMB] AS B WHERE B.MB002 = '50104205' AND B.MB001 = A.MB001)


