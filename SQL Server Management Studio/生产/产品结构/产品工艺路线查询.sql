--2025/9/19 BY ZIYANG ZHANG
SELECT [供应商编号]
      ,[品号]
  FROM [LSSJ].[dbo].[cgdj]

  DELETE FROM [LSSJ].[dbo].[cgdj]

--="INSERT INTO [LSSJ].[dbo].[cgdj](品号) VALUES('"&&"');"



SELECT 
	MF001 AS 工艺路线品号,
	MF002 AS 工艺路线编号,
	MF003 AS 加工顺序,
	MF004 AS 工艺
FROM BOMMF
WHERE 
	EXISTS(
		SELECT 1 FROM LSSJ..cgdj WHERE 品号 = MF001
	)
	AND MF004 = 'P005'
