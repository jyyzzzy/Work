WITH ProductSolderpaste AS (--有锡膏半成品，并带出锡膏信息和用量
    SELECT
        MC.MC001 AS PRODNO,
        MD.MD009 AS PROCESSNO,
        MD.MD003 AS SOLDERPASTE_NO,
        MB.MB002 AS SOLDERPASTE_NAME,
        MB.MB003 AS SOLDERPASTE_SPEC,
        MB.MB004 AS SOLDERPASTE_UNIT,
        MD.MD006 AS SOLDERPASTE_QTY,
        MD.MD007 AS SOLDERPASTE_BASE_QTY,
        CONVERT(decimal(18,8), MD.MD006) / NULLIF(CONVERT(decimal(18,8), MD.MD007), 0) AS SOLDERPASTE_USAGE
    FROM BOMMC MC
    INNER JOIN BOMMD MD
        ON MD.MD001 = MC.MC001
    INNER JOIN INVMB MB
        ON MB.MB001 = MD.MD003
    WHERE LEFT(MC.MC001, 1) = '2'
      AND MB.MB002 LIKE '%锡膏%'
),
ProductPoint AS (--自动化点数
    SELECT
        MD.MD001,
        MD.MD009,
        SUM(CONVERT(float, RTRIM(CASE ISNULL(MB3.MB180,'') WHEN '' THEN '-99999' ELSE MB3.MB180 END), 0) * MD006 / MD007) AS Point 
    FROM SDRD.dbo.BOMMD AS MD
    JOIN SDRD.dbo.INVMB AS MB3
        ON MD.MD003 = MB3.MB001
    WHERE MD006 > 0
      AND MD007 >= 1
      AND MB3.MB006 <> '220' 
      AND LEFT(MD.MD003, 1) NOT IN ('A', '1', '2', '5', 'P')
    GROUP BY MD.MD001, MD.MD009
),
ReceiptHeader AS (--三年内入库
    SELECT 
        MOCTF.TF001,
        MOCTF.TF002
    FROM MOCTF
    WHERE TF003 BETWEEN           
        CONVERT(char(8), DATEFROMPARTS(YEAR(DATEADD(YEAR, -3, GETDATE())), 1, 1), 112)
        AND CONVERT(char(8), GETDATE(), 112)
),
ReceiptLines AS (--入库仓库
    SELECT DISTINCT 
        MOCTG.TG004 AS PRODNO,
        MOCTG.TG010 AS WarehouseNo
    FROM MOCTG
    INNER JOIN ReceiptHeader RH
        ON MOCTG.TG001 = RH.TF001
       AND MOCTG.TG002 = RH.TF002
),
BusinessUnit AS (--事业部
    SELECT
        K.PRODNO,
        STUFF((
            SELECT ',' + X.DEPT
            FROM (
                SELECT DISTINCT 
                    LEFT(MC.UDF01, 4) AS DEPT
                FROM ReceiptLines D
                INNER JOIN CMSMC MC 
                    ON MC.MC001 = D.WarehouseNo
                WHERE D.PRODNO = K.PRODNO
                  AND ISNULL(MC.UDF01, '') <> ''
            ) X
            ORDER BY X.DEPT
            FOR XML PATH(''), TYPE
        ).value('.', 'nvarchar(max)'), 1, 1, '') AS DEPT
    FROM (
        SELECT DISTINCT PRODNO 
        FROM ReceiptLines
    ) K
),
Result AS(--汇总
    SELECT DISTINCT 
        MF001,
        MB002,
        MB003,
        MF004,
        MW002,
        BU.DEPT,
        IIF(
            MB110 = '',
            MB001,
            IIF(
                LEFT(MB110, 1) = 'K',
                SUBSTRING(MB110, 2, 13),
                SUBSTRING(MB110, 1, 12)
            )
        ) AS PLMNO
    FROM BOMMF 
    INNER JOIN CMSMW 
        ON MW001 = BOMMF.MF004
    INNER JOIN INVMB 
        ON MB001 = MF001
    INNER JOIN BusinessUnit AS BU 
        ON BU.PRODNO = MF001
    WHERE BOMMF.MF004 IN ('P030', 'P040')
)
SELECT 
    TRIM(T.MF001) AS ERP品号,
    T.MB002 AS 品名,
    T.MB003 AS 规格,
    T.MF004 AS 工艺编号,
    T.MW002 AS 工艺名称,
    CASE
        WHEN PP.Point IS NULL THEN -1
        WHEN PP.Point >= 0 THEN PP.Point
        ELSE 0
    END AS 自动化点数,
    T.DEPT AS 事业部,
    TRIM(T.PLMNO) AS PLM品号,

    TRIM(PS.SOLDERPASTE_NO) AS 锡膏品号,
    PS.SOLDERPASTE_NAME AS 锡膏品名,
    PS.SOLDERPASTE_SPEC AS 锡膏规格,
    PS.SOLDERPASTE_UNIT AS 锡膏单位,
    PS.SOLDERPASTE_QTY AS 锡膏用量分子,
    PS.SOLDERPASTE_BASE_QTY AS 锡膏用量基数,
    PS.SOLDERPASTE_USAGE AS 锡膏单位用量

FROM Result AS T
LEFT JOIN ProductPoint AS PP 
    ON PP.MD001 = T.MF001 
   AND PP.MD009 = T.MF004
INNER JOIN ProductSolderpaste AS PS 
    ON PS.PRODNO = T.MF001
   AND PS.PROCESSNO = T.MF004
ORDER BY 
    TRIM(T.MF001),
    T.MF004,
    TRIM(PS.SOLDERPASTE_NO);