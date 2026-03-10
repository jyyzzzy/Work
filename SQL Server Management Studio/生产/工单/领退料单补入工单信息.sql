/******补录领退料工单信息******/
-- 2025/9/27 BY ZIYANG ZHANG

INSERT INTO [MOCTD]
           ([COMPANY]
           ,[CREATOR]
           ,[USR_GROUP]
           ,[CREATE_DATE]
           ,[MODIFIER]
           ,[MODI_DATE]
           ,[FLAG]
           ,[TD001]
           ,[TD002]
           ,[TD003]
           ,[TD004]
           ,[TD005]
           ,[TD006]
           ,[TD007]
           ,[TD008]
           ,[TD009]
           ,[TD010]
           ,[TD011]
           ,[TD012]
           ,[TD013]
           ,[TD014]
           ,[TD015]
           ,[TD016]
           ,[TD017]
           ,[TD018]
           ,[TD019]
           ,[TD020]
           ,[TD021]
           ,[TD022]
           ,[TD023]
           ,[TD024]
           ,[TD025]
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
SELECT
  'SDRD' AS COMPANY,
  '10105978' AS CREATOR,
  '90001' AS USR_GROUP,
  FORMAT(GETDATE(),'yyyyMMddHHmmssfff') AS CREATE_DATE,
  '' AS MODIFIER,
  '' AS MODI_DATE,
  1  AS FLAG,
  TE001 AS TD001,
  TE002 AS TD002,
  TA001 AS TD003,
  TA002 AS TD004,
  '1' AS TD005,
  MAX(FLOOR(TE005/BOMMD.MD006))  AS TD006,
  '' AS TD007,
  '1' AS TD008,
  '' AS TD009,
  '' AS TD010,
  '' AS TD011,
  '' AS TD012,
  'N' AS TD013,
  '' AS TD014,
  '1' AS TD015,
  '' AS TD016,
  '1' AS TD017,
  '' AS TD018,
  'Y' AS TD019,
  '' AS TD020,
  '' AS TD021,
  '' AS TD022,
  0  AS TD023,
  0  AS TD024,
  0  AS TD025,
  '' AS UDF01,
  '' AS UDF02,
  '' AS UDF03,
  '' AS UDF04,
  '' AS UDF05,
  '' AS UDF06,
  0  AS UDF51,
  0  AS UDF52,
  0  AS UDF53,
  0  AS UDF54,
  0  AS UDF55,
  0  AS UDF56
FROM MOCTE
INNER JOIN MOCTA ON MOCTA.TA001 = TE011 AND MOCTA.TA002 = TE012
INNER JOIN MOCTB ON MOCTB.TB001 = TE011 AND MOCTB.TB002 = TE012
INNER JOIN MOCTC ON TC001 = TE001 AND TC002 = TE002
INNER JOIN BOMMD ON BOMMD.MD001 = TA006 AND BOMMD.MD003 = TE004
WHERE --MOCTE.TE001 = '5481'
--AND MOCTC.TC003 >= '20250901' AND 
TE011 = '5102' AND TE012 = '25093001069'
AND NOT EXISTS(
        SELECT 1 FROM MOCTD WHERE TD001 = MOCTE.TE001 AND TD002 = MOCTE.TE002
    )
AND TE005 <> 0 
AND (MOCTA.TA011 <> 'Y' AND MOCTA.TA011 <> 'y')
GROUP BY TE001,TE002,TA001,TA002
ORDER BY TD001,TD002,TD003,TD004;
