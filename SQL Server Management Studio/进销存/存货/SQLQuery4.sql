USE [LSSJ]
GO

="INSERT INTO [LSSJ].[dbo].[TmpItemTransfer]([ItemCode],[FromWarehouse],[ToWarehouse],[TransferQty])VALUES('"&&"','"&&"' ,'"&&"' ,"&&")"
GO


DELETE FROM [LSSJ].[dbo].[TmpItemTransfer]

SELECT * FROM [LSSJ].[dbo].[TmpItemTransfer]