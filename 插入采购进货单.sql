USE [AHRD]
GO

INSERT INTO [dbo].[PURTH]
           ([COMPANY]
           ,[CREATOR]
           ,[USR_GROUP]
           ,[CREATE_DATE]
           ,[MODIFIER]
           ,[MODI_DATE]
           ,[FLAG]
           ,[TH001]
           ,[TH002]
           ,[TH003]
           ,[TH004]
           ,[TH007]
           ,[TH008]
           ,[TH009]
           ,[TH010]
           ,[TH011]
           ,[TH012]
           ,[TH013]
           ,[TH014]
           ,[TH015]
           ,[TH016]
           ,[TH017]
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
     SELECT [COMPANY]
      ,[CREATOR]
      ,[USR_GROUP]
      ,[CREATE_DATE]
      ,[MODIFIER]
      ,[MODI_DATE]
      ,[FLAG]
      ,[TH001]
      ,'20260701705'
      ,[TH003]
      ,[TH004]
      ,[TH007]
      ,[TH008]
      ,[TH009]
      ,[TH010]
      ,[TH011]
      ,[TH012]
      ,[TH013]
      ,[TH014]
      ,[TH015]
      ,[TH016]
      ,[TH017]
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
  FROM [dbo].[PURTHFROMWMS]
  WHERE NOT EXISTS(
    SELECT 1 FROM PURTH TH INNER JOIN PURTG TG ON TG.TG001 = TH.TH001 AND TG.TG002 = TH.TH002 WHERE [PURTHFROMWMS].TH001 = TH.TH001 AND [PURTHFROMWMS].TH002 = TG.TG016 AND [PURTHFROMWMS].TH003 = TH.TH003
  )AND [PURTHFROMWMS].TH002 = 'TA260723062'
GO


SELECT * FROM PURTA WHERE TA001 = '3102' AND ISNULL(UDF06,'') = '' ORDER BY TA003 DESC


SELECT TOP 1000 * FROM PURTH where TH002 = '20260701705'ORDER BY CREATE_DATE DESC

SELECT TOP 1000 * FROM PURTH WHERE TH001 = '3471' AND ISNULL(UDF01,'') <> '' ORDER BY CREATE_DATE DESC

SELECT TOP 1000 * FROM PURTHFROMWMS WHERE status <> 'Y' ORDER BY TH014 DESC

SELECT E.* FROM PURTH E
INNER JOIN PURTG ON TG001 = E.TH001 AND TG002 = E.TH002
WHERE E.TH014 >= '20260701'
AND NOT EXISTS(
	SELECT 1 FROM PURTHFROMWMS W WHERE W.TH001 = E.TH001 AND W.TH002 = TG016 AND E.TH003 = W.TH003
) AND TG001 = '3471' AND E.CREATOR <> '10105978'

ORDER BY CREATE_DATE


SELECT TOP 1000 * FROM PURTH where TH002 = '20260701705'ORDER BY CREATE_DATE DESC

UPDATE PURTH 
SET UDF01 = 'TA260723062-'+ TH003
where TH001 = '3471' AND TH002 = '20260701705' AND UDF01 IS NULL