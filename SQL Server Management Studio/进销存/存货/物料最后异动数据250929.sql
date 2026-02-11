SET NOCOUNT ON;



--------------------------
-- 1) 库存集合 #MC
--------------------------
--DROP TABLE #MC
SELECT MC001, MC002, MC007
INTO #MC
FROM (
    SELECT MC.MC001, MC.MC002, MC.MC007
    FROM SDRD..INVMC MC JOIN SDRD..CMSMC C ON C.MC001=MC.MC002
    WHERE MC.MC007>0 AND C.UDF01 NOT LIKE N'%不良品%'
    UNION ALL
    SELECT MC.MC001, MC.MC002, MC.MC007
    FROM AHRD..INVMC MC JOIN AHRD..CMSMC C ON C.MC001=MC.MC002
    WHERE MC.MC007>0 AND C.UDF01 NOT LIKE N'%不良品%'
    UNION ALL
    SELECT MC.MC001, MC.MC002, MC.MC007
    FROM ZJRD..INVMC MC JOIN ZJRD..CMSMC C ON C.MC001=MC.MC002
    WHERE MC.MC007>0 AND C.UDF01 NOT LIKE N'%不良品%'
    UNION ALL
    SELECT MC.MC001, MC.MC002, MC.MC007
    FROM YNRD..INVMC MC JOIN YNRD..CMSMC C ON C.MC001=MC.MC002
    WHERE MC.MC007>0 AND C.UDF01 NOT LIKE N'%不良品%'
) S;

-----------------------------------------
-- 2) 有效异动明细 #V
-----------------------------------------

-- 常量
--DROP TABLE #V
DECLARE @dt char(8) = CONVERT(char(6), DATEADD(month,-25,GETDATE()),112)+'01';
SELECT v.LA001, v.LA004, v.LA006, v.LA007, v.LA008, v.LA011, v.CREATE_DATE, v.CREATOR
INTO #V
FROM (
    SELECT * FROM SDRD..INVLA WHERE LA004>@dt
    UNION ALL
    SELECT * FROM AHRD..INVLA WHERE LA004>@dt
    UNION ALL
    SELECT * FROM ZJRD..INVLA WHERE LA004>@dt
    UNION ALL
    SELECT * FROM YNRD..INVLA WHERE LA004>@dt
) v
JOIN #MC m ON m.MC001 = v.LA001
WHERE NOT (
    (v.LA006>='34' AND v.LA006<'35' AND EXISTS(
        SELECT 1 FROM SDRD..PURTG t
        WHERE t.TG001=v.LA006 AND t.TG002=v.LA007
          AND t.TG016 IN (N'代管料转月月初入库单',N'采购月末退货月初进仓')
    ))
 OR (v.LA006>='35' AND v.LA006<'36' AND EXISTS(
        SELECT 1 FROM SDRD..PURTI i
        WHERE i.TI001=v.LA006 AND i.TI002=v.LA007
          AND i.TI012 IN (N'代管料转月末退货单',N'月末批量开退货单')
    ))
);

-----------------------------------------
-- 3) 每品号取最新一条
-----------------------------------------
SELECT m.MC001, m.MC002, m.MC007,
       vv.LA001, vv.LA004, vv.LA006, vv.LA007, vv.LA008, vv.LA011, vv.CREATE_DATE, vv.CREATOR
INTO #BASE
FROM #MC m
CROSS APPLY (
    SELECT TOP (1) v.*
    FROM #V v
    WHERE v.LA001 = m.MC001
    ORDER BY v.LA004 DESC, v.LA006, v.LA007, v.LA008
) vv;

-----------------------------------------
-- 4) 递归向上找顶层主件
-----------------------------------------
SELECT b.LA001 AS COMP, m.MD001 AS P
INTO #U
FROM #BASE b
LEFT JOIN SDRD..BOMMD m ON m.MD003 = b.LA001;

DECLARE @step int = 0;
WHILE 1=1
BEGIN
    SET @step += 1;
    INSERT INTO #U (COMP, P)
    SELECT u.COMP, m.MD001
    FROM #U u
    JOIN SDRD..BOMMD m ON m.MD003 = u.P
    LEFT JOIN #U x ON x.COMP=u.COMP AND x.P=m.MD001
    WHERE x.COMP IS NULL;
END;

-----------------------------------------
-- 5) 顶层主件与计数
-----------------------------------------
SELECT DISTINCT U.P AS 主件, U.COMP AS 元件
INTO #FATHER
FROM #U U
LEFT JOIN SDRD..BOMMD Z ON Z.MD003 = U.P
WHERE U.P IS NOT NULL
  AND Z.MD003 IS NULL
  AND SUBSTRING(U.P,1,1) IN ('1','A');

SELECT 元件, COUNT(DISTINCT 主件) AS CNT
INTO #FC
FROM #FATHER
GROUP BY 元件;

-----------------------------------------
-- 6) 结果
-----------------------------------------
SELECT 
  b.LA001 AS 品号,
  mb.MB002 AS 品名,
  mb.MB003 AS 规格,
  mb.MB004 AS 库存单位,
  SUM(b.MC007) AS 库存总数量,
  ISNULL(fc.CNT,0) AS 顶阶主件数量,
  mb.UDF05 AS 采购选型,
  LEFT(mb.CREATE_DATE,8) AS 物料创建时间,
  mb.MB109 AS 核准状况,
  mb.CREATOR AS 创建者编号,
  ISNULL(H.MV002,'') AS 创建者名称,
  b.LA006 AS 最后交易单别,
  b.LA007 AS 最后交易单号,
  b.LA004 AS 最后交易日,
  b.LA011 AS 最后交易数量
FROM #BASE b
LEFT JOIN #FC   fc ON fc.元件 = b.LA001
JOIN SDRD..INVMB mb ON mb.MB001 = b.LA001
LEFT OUTER JOIN (
    SELECT DISTINCT * FROM
    (
        SELECT * FROM SDRD..CMSMV
        UNION ALL
        SELECT  * FROM AHRD..CMSMV
        UNION ALL
        SELECT * FROM ZJRD..CMSMV
        UNION ALL
        SELECT * FROM YNRD..CMSMV
    ) AS CMSMV
)AS H ON MV001 = mb.CREATOR 
WHERE mb.MB109='Y' and LEFT(mb.MB001,2)<>'LS' and mb.MB001 not like 'P%'
GROUP BY 
  b.LA001, mb.MB002, mb.MB003, mb.MB004,
  ISNULL(fc.CNT,0), mb.UDF05, b.CREATE_DATE, mb.MB109,
  mb.CREATOR, b.LA006, b.LA007, b.LA004, b.LA011,
H.MV002,mb.CREATE_DATE
ORDER BY b.LA001;

SELECT * FROM master..OA_Hrm