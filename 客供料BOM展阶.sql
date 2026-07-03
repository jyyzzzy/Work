USE SDRD;
SET NOCOUNT ON;

------------------------------------------------------------
-- 清理临时表
------------------------------------------------------------
IF OBJECT_ID('tempdb..#TEM') IS NOT NULL DROP TABLE #TEM;
IF OBJECT_ID('tempdb..#COPINVMB') IS NOT NULL DROP TABLE #COPINVMB;
IF OBJECT_ID('tempdb..#CP') IS NOT NULL DROP TABLE #CP;
IF OBJECT_ID('tempdb..#TEMQD') IS NOT NULL DROP TABLE #TEMQD;
IF OBJECT_ID('tempdb..#QDSC') IS NOT NULL DROP TABLE #QDSC;

------------------------------------------------------------
-- 1. 纯米物料来源
------------------------------------------------------------
SELECT DISTINCT
    TB004 AS ZJ,
    '' + TB004 AS CL,
    1 AS YL
INTO #TEM
FROM
(
    SELECT TB004
    FROM SDRD..INVTA
    JOIN SDRD..INVTB
        ON TA001 = TB001
       AND TA002 = TB002
    WHERE INVTA.TA001 = '1102'
      AND (
            INVTA.TA005 LIKE '%纯米%'
         OR INVTA.UDF01 LIKE '%纯米%'
          )

    UNION ALL

    SELECT TH004
    FROM SDRD..PURTG
    JOIN SDRD..PURTH
        ON TG001 = TH001
       AND TG002 = TH002
    JOIN SDRD..PURMA
        ON MA001 = TG005
    WHERE PURMA.MA002 LIKE '%纯米%'
      AND TH015 > 0
) AS CMLH;

-- 加入客供材料
INSERT INTO #TEM
SELECT
    MB001,
    MB001,
    1
FROM SDRD..INVMB
WHERE (
        MB003 LIKE '%CM%客供%'
     OR MB003 LIKE '%纯米%客供%'
      )
  AND LEFT(MB001, 1) IN ('3', '6')
  AND NOT EXISTS (
        SELECT 1
        FROM #TEM
        WHERE ZJ = MB001
      );

------------------------------------------------------------
-- 2. 纯米成品来源
------------------------------------------------------------
SELECT DISTINCT
    RTRIM(TH004) AS MB01
INTO #COPINVMB
FROM
(
    SELECT
        '广东' AS SZD,
        LEFT(TG003, 6) AS TG003,
        TH004,
        TH005,
        TH006,
        TH008,
        TH037 + TH038 AS TH012,
        MA002
    FROM SDRD..COPTG
    JOIN SDRD..COPTH
        ON TG001 = TH001
       AND TG002 = TH002
    JOIN SDRD..COPMA
        ON TG004 = MA001
    WHERE TG003 >= '20250701'
      AND TG003 <= '20251231'
      AND LEFT(TH004, 1) IN ('A', '1')
      AND TG023 = 'Y'

    UNION ALL

    SELECT
        '安徽',
        LEFT(TG003, 6),
        TH004,
        TH005,
        TH006,
        TH008,
        TH037 + TH038,
        MA002
    FROM AHRD..COPTG
    JOIN AHRD..COPTH
        ON TG001 = TH001
       AND TG002 = TH002
    JOIN AHRD..COPMA
        ON TG004 = MA001
    WHERE TG003 >= '20250701'
      AND TG003 <= '20251231'
      AND LEFT(TH004, 1) IN ('A', '1')
      AND TG023 = 'Y'

    UNION ALL

    SELECT
        '浙江',
        LEFT(TG003, 6),
        TH004,
        TH005,
        TH006,
        TH008,
        TH037 + TH038,
        MA002
    FROM ZJRD..COPTG
    JOIN ZJRD..COPTH
        ON TG001 = TH001
       AND TG002 = TH002
    JOIN ZJRD..COPMA
        ON TG004 = MA001
    WHERE TG003 >= '20250701'
      AND TG003 <= '20251231'
      AND LEFT(TH004, 1) IN ('A', '1')
      AND TG023 = 'Y'
) AS COPINV
WHERE MA002 LIKE '%纯米%'
GROUP BY SZD, TG003, TH004, TH005, TH006;

-- 加入规格 CM- 的成品
INSERT INTO #COPINVMB
SELECT MB001
FROM SDRD..INVMB
WHERE MB003 LIKE 'CM-%'
  AND LEFT(MB001, 1) IN ('A', '1')
  AND NOT EXISTS (
        SELECT 1
        FROM #COPINVMB
        WHERE MB01 = MB001
      );

------------------------------------------------------------
-- 3. 需要展 BOM 的成品
------------------------------------------------------------
SELECT ZJ AS MB01
INTO #CP
FROM
(
    SELECT ZJ
    FROM #TEM

    UNION ALL

    SELECT MB01
    FROM #COPINVMB
) AS WL
JOIN SDRD..INVMB
    ON MB001 = ZJ
WHERE LEFT(MB001, 1) IN ('A', '1');

------------------------------------------------------------
-- 4. 生成 BOM 明细临时表
------------------------------------------------------------
SELECT
    MD01 AS CLPH,
    MD01,
    MD03,
    MD06,
    MD07
INTO #TEMQD
FROM SDRD.[dbo].[Fn_GetBOMIDs]('');

DECLARE @CLPH VARCHAR(12);

WHILE (SELECT COUNT(*) FROM #CP) > 0
BEGIN
    SELECT TOP 1
        @CLPH = MB01
    FROM #CP;

    INSERT INTO #TEMQD
    SELECT
        @CLPH,
        MD01,
        MD03,
        MD06,
        MD07
    FROM SDRD.[dbo].[Fn_GetBOMIDs](@CLPH);

    DELETE FROM #CP
    WHERE MB01 = @CLPH;
END;

------------------------------------------------------------
-- 5. BOM 展阶
------------------------------------------------------------
SELECT *
INTO #QDSC
FROM #TEMQD
WHERE EXISTS (
    SELECT 1
    FROM #TEM
    WHERE CL = MD03
);

INSERT INTO #QDSC
SELECT
    A.CLPH,
    C.MD01,
    D.MD03,
    D.MD06,
    D.MD07
FROM #TEMQD A
LEFT JOIN #TEMQD B
    ON A.MD03 = B.MD01
LEFT JOIN #TEMQD C
    ON B.MD03 = C.MD01
LEFT JOIN #TEMQD D
    ON C.MD03 = D.MD01
WHERE D.MD03 IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM #TEM
        WHERE CL = D.MD03
      );

INSERT INTO #QDSC
SELECT
    A.CLPH,
    B.MD01,
    D.MD03,
    D.MD06,
    D.MD07
FROM #TEMQD A
LEFT JOIN #TEMQD B
    ON A.MD03 = B.MD01
LEFT JOIN #TEMQD C
    ON B.MD03 = C.MD01
LEFT JOIN #TEMQD D
    ON C.MD03 = D.MD01
WHERE D.MD03 IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM #TEM
        WHERE CL = D.MD03
      );

INSERT INTO #QDSC
SELECT
    A.CLPH,
    A.MD01,
    D.MD03,
    D.MD06,
    D.MD07
FROM #TEMQD A
LEFT JOIN #TEMQD B
    ON A.MD03 = B.MD01
LEFT JOIN #TEMQD C
    ON B.MD03 = C.MD01
LEFT JOIN #TEMQD D
    ON C.MD03 = D.MD01
WHERE D.MD03 IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM #TEM
        WHERE CL = D.MD03
      );

INSERT INTO #QDSC
SELECT
    A.CLPH,
    B.MD01,
    C.MD03,
    C.MD06,
    C.MD07
FROM #TEMQD A
LEFT JOIN #TEMQD B
    ON A.MD03 = B.MD01
LEFT JOIN #TEMQD C
    ON B.MD03 = C.MD01
WHERE C.MD03 IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM #TEM
        WHERE CL = C.MD03
      );

INSERT INTO #QDSC
SELECT
    A.CLPH,
    A.MD01,
    C.MD03,
    C.MD06,
    C.MD07
FROM #TEMQD A
LEFT JOIN #TEMQD B
    ON A.MD03 = B.MD01
LEFT JOIN #TEMQD C
    ON B.MD03 = C.MD01
WHERE C.MD03 IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM #TEM
        WHERE CL = C.MD03
      );

INSERT INTO #QDSC
SELECT
    A.CLPH,
    A.MD01,
    B.MD03,
    B.MD06,
    B.MD07
FROM #TEMQD A
LEFT JOIN #TEMQD B
    ON A.MD03 = B.MD01
WHERE B.MD03 IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM #TEM
        WHERE CL = B.MD03
      );

------------------------------------------------------------
-- 导出表 1：BOM展阶
-- 字段：主键、材料品号、底数、用量
------------------------------------------------------------
SELECT DISTINCT
    RTRIM(MD01) AS 成品品号,
    RTRIM(MD03) AS 材料品号,
    MD07 AS 底数,
    MD06 AS 用量
FROM
(
    SELECT DISTINCT
        MD01,
        MD03,
        MD06,
        MD07
    FROM #QDSC

    UNION ALL

    SELECT
        ZJ,
        ZJ,
        1,
        1
    FROM #TEM
) AS BOM
ORDER BY 成品品号, 材料品号;

------------------------------------------------------------
-- 导出表 2：产品与物料
-- 字段：品号、品名、规格
------------------------------------------------------------
SELECT DISTINCT
    RTRIM(ZJ) AS 品号,
    MB002 AS 品名,
    MB003 AS 规格
FROM
(
    SELECT ZJ
    FROM #TEM

    UNION ALL

    SELECT MB01
    FROM #COPINVMB
) AS WL
JOIN SDRD..INVMB
    ON MB001 = ZJ
ORDER BY 品号;

------------------------------------------------------------
-- 导出表 3：新老半成品对照
-- 字段：原半成品品号、原半成品品名、原半成品规格、
--       新成品品号、新半成品品名、新半成品规格
------------------------------------------------------------
SELECT
    RTRIM(A.MB001) AS 原半成品品号,
    A.MB002 AS 原半成品品名,
    A.MB003 AS 原半成品规格,
    RTRIM(B.MB001) AS 新成品品号,
    B.MB002 AS 新半成品品名,
    B.MB003 AS 新半成品规格
FROM SDRD..INVMB A
JOIN SDRD..INVMB B
    ON B.MB001 = IIF(A.MB110 = '',A.MB001,IIF(LEFT(A.MB110,1) = 'K',SUBSTRING(A.MB110,2,13),SUBSTRING(A.MB110,1,12)))
WHERE A.MB001 LIKE '2%X_'
ORDER BY B.MB001, A.MB001;