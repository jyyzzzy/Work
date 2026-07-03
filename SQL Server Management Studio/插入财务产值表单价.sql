/******财务产值表导入******/
USE [LSSJ]
GO
SELECT * FROM LSSJ..Product_Price
WHERE company = 'ZJRD'
AND month = '202606'
--="INSERT INTO [dbo].[Product_Price]([company] ,[productno] ,[price],[date],[month]) VALUES ('"&A2&"' ,'"&B2&"' ,"&C2&" ,'"&D2&"' ,'"&E2&"' );"
GO

