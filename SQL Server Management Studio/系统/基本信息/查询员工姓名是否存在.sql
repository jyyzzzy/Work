/******复制OA员工信息至ERP******/--2025/9/8 BY ZIYANG ZHANG
SELECT * 
FROM [DSCSYS].[dbo].[DSCMA] 
INNER JOIN [192.168.8.24].[ecology].[dbo].OA_Hrm AS OH ON OH.workcode COLLATE Chinese_PRC_BIN = MA001
WHERE MA005 = 'Y' AND MA001 NOT IN (
	SELECT MV001 FROM CMSMV
    )
AND OH.subcompanyid1 = 148
    
    --AND SUBSTRING(MA001,1,1) = '1';
--SELECT * FROM [DSCSYS].[dbo].[DSCMA] WHERE LEN(MA001) <> 8 AND MA005 = 'Y';



--select * from [192.168.8.24].[ecology].[dbo].OA_Hrm 

--SELECT * FROM [192.168.8.24].[ecology].INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'VIEW' ORDER BY TABLE_NAME;
--SELECT departmentname,COUNT(*) FROM WORKERS GROUP BY departmentid ORDER BY departmentid;


--SELECT * FROM master.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'VIEW' ORDER BY TABLE_NAME;
--SELECT * FROM master.dbo.OA_COMPLETEDEP_Vcode
SELECT MA001,MA002,DEPT.departmentcode,DEPT.departmentID,DEPT.departmentname,DEPT.subcompanyname
	FROM [DSCSYS].[dbo].[DSCMA] 
		INNER JOIN master.dbo.OA_Hrm AS HRM ON workcode COLLATE Chinese_PRC_BIN = MA001
		INNER JOIN master.dbo.OA_COMPLETEDEP_Vcode AS DEPT ON DEPT.departmentID = HRM.departmentid 
	WHERE MA005 = 'Y' 
		AND MA001 NOT IN (
			SELECT MV001 
				FROM CMSMV
			)  
		AND MA001 IN ('10004855')

--SELECT * FROM INFORMATION_SCHEMA.COLUMNS
--WHERE TABLE_NAME = 'OA_COMPLETEDEP_Vcode'
SELECT [id]
      ,[subcompanyname]
      ,[subcompanydesc]
      ,[companyid]
      ,[supsubcomid]
      ,[url]
      ,[showorder]
      ,[canceled]
      ,[subcompanycode]
      ,[level]
  FROM [192.168.8.24].[ecology].[dbo].[HrmSubCompanyView]
  ORDER BY id
GO


--关闭无效账号
SELECT * 
--UPDATE [DSCSYS].[dbo].[DSCMA] SET MA005 = 'N' 
FROM [DSCSYS].[dbo].[DSCMA] 
WHERE MA005 = 'Y' 
AND NOT EXISTS (
	SELECT 1 
	FROM master.dbo.OA_Hrm 
	WHERE MA001 = workcode COLLATE Chinese_PRC_BIN
) AND MA001 NOT IN ('DS','01001')



--BEGIN 插入员工信息
DROP TABLE #CMSMV

SELECT DISTINCT
    CAST('0001' AS CHAR(10))              AS [COMPANY],
    CAST('10105978' AS CHAR(10))          AS [CREATOR],
    CAST('90001' AS CHAR(10))             AS [USR_GROUP],
    CAST(FORMAT(GETDATE(),'yyyyMMddHHmmssfff') AS CHAR(17)) AS [CREATE_DATE],
    CAST('' AS CHAR(10))                  AS [MODIFIER],
    CAST('' AS CHAR(17))                  AS [MODI_DATE],
    CAST(1 AS NUMERIC(3,0))               AS [FLAG],
    CAST(MA001 AS CHAR(10))               AS [MV001],
    CAST(MA002 AS CHAR(10))               AS [MV002],
    CAST('' AS CHAR(10))                  AS [MV003],
    CAST(departmentcode COLLATE Chinese_PRC_BIN AS CHAR(6)) AS [MV004],
    CAST('' AS CHAR(8))                   AS [MV005],
    CAST('' AS CHAR(6))                   AS [MV006],
    CAST(CASE WHEN sex='0' THEN '1' WHEN sex='1' THEN '2' END AS CHAR(1)) AS [MV007],
    CAST('' AS CHAR(8))  AS [MV008],
    CAST('' AS CHAR(18))                  AS [MV009],
    CAST('' AS CHAR(1))                   AS [MV010],
    CAST('' AS CHAR(1))                   AS [MV011],
    CAST('' AS CHAR(8))                   AS [MV012],
    CAST('' AS CHAR(72))                  AS [MV013],
    CAST('' AS CHAR(1))                   AS [MV014],
    CAST(ISNULL(mobile,'') AS CHAR(20))   AS [MV015],
    CAST(ISNULL(mobilecall,'') AS CHAR(20)) AS [MV016],
    CAST('' AS CHAR(60))                  AS [MV017],
    CAST('' AS CHAR(10))                  AS [MV018],
    CAST('' AS CHAR(72))                  AS [MV019],
    CAST(ISNULL(email,'') AS CHAR(36))    AS [MV020],
    CAST('' AS CHAR(8)) AS [MV021],
    CAST('' AS CHAR(8))                   AS [MV022],
    CAST('' AS CHAR(8))                   AS [MV023],
    CAST('' AS CHAR(1))                   AS [MV024],
    CAST('' AS CHAR(10))                  AS [MV025],
    CAST('' AS CHAR(1))                   AS [MV026],
    CAST('' AS CHAR(3))                   AS [MV027],
    CAST('' AS CHAR(10))                  AS [MV028],
    CAST('' AS CHAR(10))                  AS [MV029],
    CAST('' AS CHAR(10))                  AS [MV030],
    CAST(0 AS NUMERIC(4,2))               AS [MV031],
    CAST('' AS CHAR(1))                   AS [MV032],
    CAST(0 AS NUMERIC(15,2))              AS [MV033],
    CAST('' AS CHAR(1))                   AS [MV034],
    CAST('' AS CHAR(10))                  AS [MV035],
    CAST('' AS CHAR(30))                  AS [MV036],
    CAST(0 AS NUMERIC(2,0))               AS [MV037],
    CAST('' AS CHAR(1))                   AS [MV038],
    CAST(0 AS NUMERIC(15,2))              AS [MV039],
    CAST(0 AS NUMERIC(5,4))               AS [MV040],
    CAST('' AS CHAR(1))                   AS [MV041],
    CAST('' AS CHAR(1))                   AS [MV042],
    CAST(0 AS NUMERIC(15,2))              AS [MV043],
    CAST('' AS CHAR(1))                   AS [MV044],
    CAST(0 AS NUMERIC(15,2))              AS [MV045],
    CAST('' AS VARCHAR(255))              AS [MV046],
    CAST('' AS CHAR(30))                  AS [MV047],
    CAST('' AS CHAR(8))                   AS [MV048],
    CAST('' AS CHAR(8))                   AS [MV049],
    CAST('' AS CHAR(8))                   AS [MV050],
    CAST('' AS CHAR(12))                  AS [MV051],
    CAST('' AS CHAR(8))                   AS [MV052],
    CAST('' AS CHAR(8))                   AS [MV053],
    CAST('' AS CHAR(2))                   AS [MV054],
    CAST(0 AS NUMERIC(15,2))              AS [MV055],
    CAST(0 AS NUMERIC(15,2))              AS [MV056],
    CAST('' AS CHAR(12))                  AS [MV057],
    CAST('' AS CHAR(10))                  AS [MV058],
    CAST('' AS CHAR(8))                   AS [MV059],
    CAST('' AS CHAR(8))                   AS [MV060],
    CAST('' AS CHAR(1))                   AS [MV061],
    CAST('' AS CHAR(20))                  AS [MV062],
    CAST('' AS VARCHAR(255))              AS [MV063],
    CAST('' AS CHAR(1))                   AS [MV064],
    CAST('' AS CHAR(12))                  AS [MV065],
    CAST('' AS CHAR(1))                   AS [MV066],
    CAST('' AS CHAR(10))                  AS [MV067],
    CAST('' AS CHAR(10))                  AS [MV068],
    CAST('' AS CHAR(6))                   AS [MV069],
    CAST('' AS CHAR(10))                  AS [MV070],
    CAST('' AS CHAR(6))                   AS [MV071],
    CAST('' AS CHAR(6))                   AS [MV072],
    CAST('' AS CHAR(6))                   AS [MV073],
    CAST('' AS CHAR(60))                  AS [MV074],
    CAST('' AS CHAR(10))                  AS [MV075],
    CAST('' AS CHAR(10))                  AS [MV076],
    CAST('' AS CHAR(1))                   AS [MV077],
    CAST('' AS CHAR(8))                   AS [MV078],
    CAST('' AS VARCHAR(30))               AS [MV079],
    CAST(0 AS NUMERIC(13,2))              AS [MV080],
    CAST(0 AS NUMERIC(13,2))              AS [MV081],
    CAST(0 AS NUMERIC(13,2))              AS [MV082],
    CAST('' AS VARCHAR(255))              AS [UDF01],
    CAST('' AS VARCHAR(255))              AS [UDF02],
    CAST('' AS VARCHAR(255))              AS [UDF03],
    CAST('' AS VARCHAR(255))              AS [UDF04],
    CAST('' AS VARCHAR(255))              AS [UDF05],
    CAST('' AS VARCHAR(255))              AS [UDF06],
    CAST(0 AS NUMERIC(15,6))              AS [UDF51],
    CAST(0 AS NUMERIC(15,6))              AS [UDF52],
    CAST(0 AS NUMERIC(15,6))              AS [UDF53],
    CAST(0 AS NUMERIC(15,6))              AS [UDF54],
    CAST(0 AS NUMERIC(15,6))              AS [UDF55],
    CAST(0 AS NUMERIC(15,6))              AS [UDF56]
INTO #CMSMV
	FROM [DSCSYS].[dbo].[DSCMA] AS MA
		INNER JOIN master.dbo.OA_Hrm AS HRM ON workcode COLLATE Chinese_PRC_BIN = MA001
		INNER JOIN master.dbo.OA_COMPLETEDEP_Vcode AS DEPT ON DEPT.departmentID = HRM.departmentid 
	WHERE birthday IS NOT NULL
	AND NOT EXISTS (SELECT 1 FROM CMSMV WHERE MV001 = MA001)
	AND EXISTS (
		SELECT 1
		FROM [DSCSYS].[dbo].[DSCMA] AS A 
		INNER JOIN master.dbo.OA_Hrm AS HRM ON workcode COLLATE Chinese_PRC_BIN = MA001
		INNER JOIN master.dbo.OA_COMPLETEDEP_Vcode AS DEPT ON DEPT.departmentID = HRM.departmentid 
		WHERE MA.MA001 = A.MA001 
		AND MA005 = 'Y' 
		AND NOT EXISTS (
			SELECT 1
				FROM CMSMV
				WHERE MV001 = MA001
		)
		--AND EXISTS (
		--	SELECT 1 
		--	FROM CMSME 
		--	WHERE ME001 = DEPT.departmentcode COLLATE Chinese_PRC_BIN
		--)
		--AND subcompanyname IN ('瑞沃电子')
	)

INSERT INTO CMSMV SELECT * FROM #CMSMV WHERE MV001 <> '10044323';
--END



SELECT * FROM #CMSMV
		SELECT 
    a.name AS ColumnName,
    TYPE_NAME(a.user_type_id) AS SrcType,
    a.max_length AS SrcLength,
    a.precision AS SrcPrecision,
    a.scale AS SrcScale,
    TYPE_NAME(b.user_type_id) AS DestType,
    b.max_length AS DestLength,
    b.precision AS DestPrecision,
    b.scale AS DestScale
FROM tempdb.sys.columns a
JOIN sys.columns b 
    ON a.name = b.name
   AND b.object_id = OBJECT_ID('dbo.MOCTE')   -- 目标表
WHERE a.object_id = OBJECT_ID('tempdb..#MOCTE')   -- 临时表
  AND (
        a.user_type_id <> b.user_type_id
     OR a.max_length   <> b.max_length
     OR a.precision    <> b.precision
     OR a.scale        <> b.scale
  )
ORDER BY a.name;

--UPDATE CMSMV SET MV004 = '100000' 
SELECT *
FROM CMSMV 
WHERE NOT EXISTS (
	SELECT 1
	 FROM CMSME 
	 WHERE ME001 = MV004
)
ORDER BY CREATE_DATE

--DELETE
--FROM CMSMK
--WHERE NOT EXISTS(
--    SELECT 1 FROM [192.168.8.24].[ecology].[dbo].[OA_Hrm] WHERE workcode COLLATE Chinese_PRC_BIN = MK002
--)
--AND MU003 NOT IN ('01001','Admin_JG','DS')
--GROUP BY MU003
--ORDER BY MU003

--更新员工信息

SELECT DEPT.departmentcode,CMSMV.*
FROM CMSMV
INNER JOIN [192.168.8.24].[ecology].[dbo].[OA_Hrm] AS HRM ON HRM.workcode COLLATE Chinese_PRC_BIN = MV001
INNER JOIN [192.168.8.24].[ecology].dbo.OA_COMPLETEDEP_Vcode AS DEPT ON DEPT.departmentID = HRM.departmentid 
WHERE MV004 <>DEPT.departmentcode COLLATE Chinese_PRC_BIN

--UPDATE CMSMV
--SET MV004 = '282300'
--WHERE MV001 = '10044323'


UPDATE CMSMV
SET CMSMV.MV004 = HR.departmentcode COLLATE Chinese_PRC_BIN
--SELECT HR.departmentcode,CMSMV.*
FROM CMSMV 
INNER JOIN [dhr_lnk].[GCYDHR1].[dbo].[V_OA_renshixinxi] AS HR ON HR.workcode COLLATE Chinese_PRC_BIN = MV001
WHERE HR.departmentcode COLLATE Chinese_PRC_BIN <> MV004





SELECT DISTINCT
    CAST('0001' AS CHAR(10))              AS [COMPANY],
    CAST('10105978' AS CHAR(10))          AS [CREATOR],
    CAST('90001' AS CHAR(10))             AS [USR_GROUP],
    CAST(FORMAT(GETDATE(),'yyyyMMddHHmmssfff') AS CHAR(17)) AS [CREATE_DATE],
    CAST('' AS CHAR(10))                  AS [MODIFIER],
    CAST('' AS CHAR(17))                  AS [MODI_DATE],
    CAST(1 AS NUMERIC(3,0))               AS [FLAG],
    CAST(HRM.workcode AS CHAR(10))               AS [MV001],
    CAST(HRM.lastname AS CHAR(10))               AS [MV002],
    CAST('' AS CHAR(10))                  AS [MV003],
    CAST(departmentcode COLLATE Chinese_PRC_BIN AS CHAR(6)) AS [MV004],
    CAST('' AS CHAR(8))                   AS [MV005],
    CAST('' AS CHAR(6))                   AS [MV006],
    CAST(CASE WHEN sex='0' THEN '1' WHEN sex='1' THEN '2' END AS CHAR(1)) AS [MV007],
    CAST('' AS CHAR(8))  AS [MV008],
    CAST('' AS CHAR(18))                  AS [MV009],
    CAST('' AS CHAR(1))                   AS [MV010],
    CAST('' AS CHAR(1))                   AS [MV011],
    CAST('' AS CHAR(8))                   AS [MV012],
    CAST('' AS CHAR(72))                  AS [MV013],
    CAST('' AS CHAR(1))                   AS [MV014],
    CAST(ISNULL(mobile,'') AS CHAR(20))   AS [MV015],
    CAST(ISNULL(mobilecall,'') AS CHAR(20)) AS [MV016],
    CAST('' AS CHAR(60))                  AS [MV017],
    CAST('' AS CHAR(10))                  AS [MV018],
    CAST('' AS CHAR(72))                  AS [MV019],
    CAST(ISNULL(email,'') AS CHAR(36))    AS [MV020],
    CAST('' AS CHAR(8)) AS [MV021],
    CAST('' AS CHAR(8))                   AS [MV022],
    CAST('' AS CHAR(8))                   AS [MV023],
    CAST('' AS CHAR(1))                   AS [MV024],
    CAST('' AS CHAR(10))                  AS [MV025],
    CAST('' AS CHAR(1))                   AS [MV026],
    CAST('' AS CHAR(3))                   AS [MV027],
    CAST('' AS CHAR(10))                  AS [MV028],
    CAST('' AS CHAR(10))                  AS [MV029],
    CAST('' AS CHAR(10))                  AS [MV030],
    CAST(0 AS NUMERIC(4,2))               AS [MV031],
    CAST('' AS CHAR(1))                   AS [MV032],
    CAST(0 AS NUMERIC(15,2))              AS [MV033],
    CAST('' AS CHAR(1))                   AS [MV034],
    CAST('' AS CHAR(10))                  AS [MV035],
    CAST('' AS CHAR(30))                  AS [MV036],
    CAST(0 AS NUMERIC(2,0))               AS [MV037],
    CAST('' AS CHAR(1))                   AS [MV038],
    CAST(0 AS NUMERIC(15,2))              AS [MV039],
    CAST(0 AS NUMERIC(5,4))               AS [MV040],
    CAST('' AS CHAR(1))                   AS [MV041],
    CAST('' AS CHAR(1))                   AS [MV042],
    CAST(0 AS NUMERIC(15,2))              AS [MV043],
    CAST('' AS CHAR(1))                   AS [MV044],
    CAST(0 AS NUMERIC(15,2))              AS [MV045],
    CAST('' AS VARCHAR(255))              AS [MV046],
    CAST('' AS CHAR(30))                  AS [MV047],
    CAST('' AS CHAR(8))                   AS [MV048],
    CAST('' AS CHAR(8))                   AS [MV049],
    CAST('' AS CHAR(8))                   AS [MV050],
    CAST('' AS CHAR(12))                  AS [MV051],
    CAST('' AS CHAR(8))                   AS [MV052],
    CAST('' AS CHAR(8))                   AS [MV053],
    CAST('' AS CHAR(2))                   AS [MV054],
    CAST(0 AS NUMERIC(15,2))              AS [MV055],
    CAST(0 AS NUMERIC(15,2))              AS [MV056],
    CAST('' AS CHAR(12))                  AS [MV057],
    CAST('' AS CHAR(10))                  AS [MV058],
    CAST('' AS CHAR(8))                   AS [MV059],
    CAST('' AS CHAR(8))                   AS [MV060],
    CAST('' AS CHAR(1))                   AS [MV061],
    CAST('' AS CHAR(20))                  AS [MV062],
    CAST('' AS VARCHAR(255))              AS [MV063],
    CAST('' AS CHAR(1))                   AS [MV064],
    CAST('' AS CHAR(12))                  AS [MV065],
    CAST('' AS CHAR(1))                   AS [MV066],
    CAST('' AS CHAR(10))                  AS [MV067],
    CAST('' AS CHAR(10))                  AS [MV068],
    CAST('' AS CHAR(6))                   AS [MV069],
    CAST('' AS CHAR(10))                  AS [MV070],
    CAST('' AS CHAR(6))                   AS [MV071],
    CAST('' AS CHAR(6))                   AS [MV072],
    CAST('' AS CHAR(6))                   AS [MV073],
    CAST('' AS CHAR(60))                  AS [MV074],
    CAST('' AS CHAR(10))                  AS [MV075],
    CAST('' AS CHAR(10))                  AS [MV076],
    CAST('' AS CHAR(1))                   AS [MV077],
    CAST('' AS CHAR(8))                   AS [MV078],
    CAST('' AS VARCHAR(30))               AS [MV079],
    CAST(0 AS NUMERIC(13,2))              AS [MV080],
    CAST(0 AS NUMERIC(13,2))              AS [MV081],
    CAST(0 AS NUMERIC(13,2))              AS [MV082],
    CAST('' AS VARCHAR(255))              AS [UDF01],
    CAST('' AS VARCHAR(255))              AS [UDF02],
    CAST('' AS VARCHAR(255))              AS [UDF03],
    CAST('' AS VARCHAR(255))              AS [UDF04],
    CAST('' AS VARCHAR(255))              AS [UDF05],
    CAST('' AS VARCHAR(255))              AS [UDF06],
    CAST(0 AS NUMERIC(15,6))              AS [UDF51],
    CAST(0 AS NUMERIC(15,6))              AS [UDF52],
    CAST(0 AS NUMERIC(15,6))              AS [UDF53],
    CAST(0 AS NUMERIC(15,6))              AS [UDF54],
    CAST(0 AS NUMERIC(15,6))              AS [UDF55],
    CAST(0 AS NUMERIC(15,6))              AS [UDF56]
INTO #CMSMV
	FROM master.dbo.OA_Hrm AS HRM 
		INNER JOIN master.dbo.OA_COMPLETEDEP_Vcode AS DEPT ON DEPT.departmentID = HRM.departmentid 
	WHERE birthday IS NOT NULL
	AND NOT EXISTS (SELECT 1 FROM CMSMV WHERE MV001 = HRM.workcode COLLATE Chinese_PRC_BIN)
	AND EXISTS (
		SELECT 1
		FROM master.dbo.OA_Hrm AS HRM 
		INNER JOIN master.dbo.OA_COMPLETEDEP_Vcode AS DEPT ON DEPT.departmentID = HRM.departmentid 
		WHERE 
		NOT EXISTS (
			SELECT 1
				FROM CMSMV
				WHERE MV001 = HRM.workcode COLLATE Chinese_PRC_BIN
		)
		--AND EXISTS (
		--	SELECT 1 
		--	FROM CMSME 
		--	WHERE ME001 = DEPT.departmentcode COLLATE Chinese_PRC_BIN
		--)
		--AND subcompanyname IN ('瑞沃电子')
	)