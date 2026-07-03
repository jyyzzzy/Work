SELECT * FROM COPTH WHERE TH001 = '2371' AND TH002 = '20260516001'


SELECT * FROM DSCSYS..ADMMD WHERE MD001 = 'COPTH'

SELECT * FROM ADMMG WHERE (ADMMG.MG001 = '10037089') AND MG002 IN ('PURI05','PURI06','PURI07','PURR14','PURR16')


BEGIN TRAN;

WITH EMP AS (
    SELECT MG001
    FROM (VALUES
        ('10037089'),
        ('10040350'),
        ('10045571'),
        ('10046361'),
        ('10053055'),
        ('10053182'),
        ('10056458'),
        ('10062786'),
        ('10063234'),
        ('10072301'),
        ('10079951'),
        ('10080363'),
        ('10080879'),
        ('10085962'),
        ('10108865'),
        ('30048549'),
        ('30098328'),
        ('30112208'),
        ('30112328'),
        ('50060644'),
        ('50067187'),
        ('50074874'),
        ('50086237'),
        ('50086453'),
        ('50094145')
    ) V(MG001)
),
SRC AS (
    SELECT *
    FROM ADMMG
    WHERE MG001 = '10037089'
      AND MG002 IN ('PURI05','PURI06','PURI07','PURR14','PURR16')
),
NEED AS (
    SELECT 
        E.MG001 AS NEW_MG001,
        S.*
    FROM EMP E
    CROSS JOIN SRC S
    WHERE NOT EXISTS (
        SELECT 1
        FROM ADMMG M WITH (UPDLOCK, HOLDLOCK)
        WHERE M.MG001 = E.MG001
          AND M.MG002 = S.MG002
    )
)
INSERT INTO ADMMG (
    COMPANY,
    CREATOR,
    USR_GROUP,
    CREATE_DATE,
    MODIFIER,
    MODI_DATE,
    FLAG,
    MG001,
    MG002,
    MG003,
    MG004,
    MG005,
    MG006,
    MG007,
    MG008,
    MG009,
    MG010,
    MG011,
    MG012,
    MG013,
    MG014,
    MG015,
    MG016,
    MG017,
    UDF01,
    UDF02,
    UDF03,
    UDF04,
    UDF05,
    UDF06,
    UDF51,
    UDF52,
    UDF53,
    UDF54,
    UDF55,
    UDF56
)
SELECT
    COMPANY,
    CREATOR,
    USR_GROUP,
    CREATE_DATE,
    MODIFIER,
    MODI_DATE,
    FLAG,
    NEW_MG001 AS MG001,
    MG002,
    MG003,
    MG004,
    MG005,
    MG006,
    MG007,
    MG008,
    MG009,
    MG010,
    MG011,
    MG012,
    MG013,
    MG014,
    MG015,
    MG016,
    MG017,
    UDF01,
    UDF02,
    UDF03,
    UDF04,
    UDF05,
    UDF06,
    UDF51,
    UDF52,
    UDF53,
    UDF54,
    UDF55,
    UDF56
FROM NEED;

SELECT @@ROWCOUNT AS 本次补插行数;

-- 确认无误后执行
COMMIT TRAN;

-- 有问题执行
-- ROLLBACK TRAN;


WITH EMP AS (
    SELECT MG001
    FROM (VALUES
        ('10037089'),
        ('10040350'),
        ('10045571'),
        ('10046361'),
        ('10053055'),
        ('10053182'),
        ('10056458'),
        ('10062786'),
        ('10063234'),
        ('10072301'),
        ('10079951'),
        ('10080363'),
        ('10080879'),
        ('10085962'),
        ('10108865'),
        ('30048549'),
        ('30098328'),
        ('30112208'),
        ('30112328'),
        ('50060644'),
        ('50067187'),
        ('50074874'),
        ('50086237'),
        ('50086453'),
        ('50094145')
    ) V(MG001)
)
SELECT 
    E.MG001 AS 工号,
    'ADMMF无资料，跳过' AS 说明
FROM EMP E
WHERE NOT EXISTS (
    SELECT 1
    FROM ADMMF F
    WHERE F.MF001 = E.MG001
)
ORDER BY E.MG001;


WITH EMP AS (
    SELECT MG001
    FROM (VALUES
        ('10037089'),
        ('10040350'),
        ('10045571'),
        ('10046361'),
        ('10053055'),
        ('10053182'),
        ('10056458'),
        ('10062786'),
        ('10063234'),
        ('10072301'),
        ('10079951'),
        ('10080363'),
        ('10080879'),
        ('10085962'),
        ('10108865'),
        ('30048549'),
        ('30098328'),
        ('30112208'),
        ('30112328'),
        ('50060644'),
        ('50067187'),
        ('50074874'),
        ('50086237'),
        ('50086453'),
        ('50094145')
    ) V(MG001)
),
SRC AS (
    SELECT MG002
    FROM SDRD..ADMMG
    WHERE MG001 = '10037089'
      AND MG002 IN ('PURI05','PURI06','PURI07','PURR14','PURR16')
)
SELECT 
    E.MG001 AS 工号,
    S.MG002 AS 缺失权限
FROM EMP E
CROSS JOIN SRC S
WHERE EXISTS (
    SELECT 1
    FROM ADMMF F
    WHERE F.MF001 = E.MG001
)
AND NOT EXISTS (
    SELECT 1
    FROM ADMMG G
    WHERE G.MG001 = E.MG001
      AND G.MG002 = S.MG002
)
ORDER BY E.MG001, S.MG002;


BEGIN TRAN;

WITH EMP AS (
    SELECT MG001
    FROM (VALUES
        ('10037089'),
        ('10040350'),
        ('10045571'),
        ('10046361'),
        ('10053055'),
        ('10053182'),
        ('10056458'),
        ('10062786'),
        ('10063234'),
        ('10072301'),
        ('10079951'),
        ('10080363'),
        ('10080879'),
        ('10085962'),
        ('10108865'),
        ('30048549'),
        ('30098328'),
        ('30112208'),
        ('30112328'),
        ('50060644'),
        ('50067187'),
        ('50074874'),
        ('50086237'),
        ('50086453'),
        ('50094145')
    ) V(MG001)
),
SRC AS (
    SELECT *
    FROM SDRD..ADMMG
    WHERE MG001 = '10037089'
      AND MG002 IN ('PURI05','PURI06','PURI07','PURR14','PURR16')
),
NEED AS (
    SELECT 
        E.MG001 AS NEW_MG001,
        S.*
    FROM EMP E
    CROSS JOIN SRC S
    WHERE EXISTS (
        SELECT 1
        FROM ADMMF F
        WHERE F.MF001 = E.MG001
    )
    AND NOT EXISTS (
        SELECT 1
        FROM ADMMG G WITH (UPDLOCK, HOLDLOCK)
        WHERE G.MG001 = E.MG001
          AND G.MG002 = S.MG002
    )
)
INSERT INTO ADMMG (
    COMPANY,
    CREATOR,
    USR_GROUP,
    CREATE_DATE,
    MODIFIER,
    MODI_DATE,
    FLAG,
    MG001,
    MG002,
    MG003,
    MG004,
    MG005,
    MG006,
    MG007,
    MG008,
    MG009,
    MG010,
    MG011,
    MG012,
    MG013,
    MG014,
    MG015,
    MG016,
    MG017,
    UDF01,
    UDF02,
    UDF03,
    UDF04,
    UDF05,
    UDF06,
    UDF51,
    UDF52,
    UDF53,
    UDF54,
    UDF55,
    UDF56
)
SELECT
    COMPANY,
    CREATOR,
    USR_GROUP,
    CREATE_DATE,
    MODIFIER,
    MODI_DATE,
    FLAG,
    NEW_MG001 AS MG001,
    MG002,
    MG003,
    MG004,
    MG005,
    MG006,
    MG007,
    MG008,
    MG009,
    MG010,
    MG011,
    MG012,
    MG013,
    MG014,
    MG015,
    MG016,
    MG017,
    UDF01,
    UDF02,
    UDF03,
    UDF04,
    UDF05,
    UDF06,
    UDF51,
    UDF52,
    UDF53,
    UDF54,
    UDF55,
    UDF56
FROM NEED;

SELECT @@ROWCOUNT AS 本次补插行数;

-- 确认没问题：
COMMIT TRAN;

-- 有问题改执行：
-- ROLLBACK TRAN;


WITH EMP AS (
    SELECT MG001
    FROM (VALUES
        ('10037089'),
        ('10040350'),
        ('10045571'),
        ('10046361'),
        ('10053055'),
        ('10053182'),
        ('10056458'),
        ('10062786'),
        ('10063234'),
        ('10072301'),
        ('10079951'),
        ('10080363'),
        ('10080879'),
        ('10085962'),
        ('10108865'),
        ('30048549'),
        ('30098328'),
        ('30112208'),
        ('30112328'),
        ('50060644'),
        ('50067187'),
        ('50074874'),
        ('50086237'),
        ('50086453'),
        ('50094145')
    ) V(MG001)
)
SELECT 
    E.MG001 AS 工号
FROM EMP E
WHERE E.MG001 NOT IN (
    SELECT D.MA001
    FROM DSCSYS..DSCMA D
    WHERE ISNULL(D.MA001, '') <> ''
)
ORDER BY E.MG001;

SELECT * FROM ADMMF

BEGIN TRAN;

IF OBJECT_ID('tempdb..#EMP') IS NOT NULL
    DROP TABLE #EMP;

CREATE TABLE #EMP (
    MG001 VARCHAR(20) NOT NULL PRIMARY KEY
);

INSERT INTO #EMP (MG001)
VALUES
    ('10037089'),
    ('10040350'),
    ('10045571'),
    ('10046361'),
    ('10053055'),
    ('10053182'),
    ('10056458'),
    ('10062786'),
    ('10063234'),
    ('10072301'),
    ('10079951'),
    ('10080363'),
    ('10080879'),
    ('10085962'),
    ('10108865'),
    ('30048549'),
    ('30098328'),
    ('30112208'),
    ('30112328'),
    ('50060644'),
    ('50067187'),
    ('50074874'),
    ('50086237'),
    ('50086453'),
    ('50094145');

------------------------------------------------------------
-- 1. 先补 ADMMF
-- 来源：SDRD..ADMMF，模板 MF001 = '10037089'
-- 目标：当前库 dbo.ADMMF
-- 只替换 MF001，其它字段照抄
------------------------------------------------------------

DECLARE @cols NVARCHAR(MAX);
DECLARE @selectCols NVARCHAR(MAX);
DECLARE @sql NVARCHAR(MAX);
DECLARE @ADMMF_ROWS INT;

SELECT @cols = STUFF((
    SELECT ',' + QUOTENAME(C.name)
    FROM sys.columns C
    WHERE C.object_id = OBJECT_ID('dbo.ADMMF')
      AND C.is_identity = 0
      AND C.is_computed = 0
    ORDER BY C.column_id
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

SELECT @selectCols = STUFF((
    SELECT ',' +
           CASE 
               WHEN C.name = 'MF001' THEN 'E.MG001'
               ELSE 'S.' + QUOTENAME(C.name)
           END
    FROM sys.columns C
    WHERE C.object_id = OBJECT_ID('dbo.ADMMF')
      AND C.is_identity = 0
      AND C.is_computed = 0
    ORDER BY C.column_id
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'), 1, 1, '');

SET @sql = N'
INSERT INTO dbo.ADMMF (
    ' + @cols + N'
)
SELECT
    ' + @selectCols + N'
FROM #EMP E
CROSS JOIN SDRD..ADMMF S
WHERE S.MF001 = ''10037089''
  AND NOT EXISTS (
        SELECT 1
        FROM dbo.ADMMF F WITH (UPDLOCK, HOLDLOCK)
        WHERE F.MF001 = E.MG001
  );

SET @ROWS = @@ROWCOUNT;
';

EXEC sp_executesql
    @sql,
    N'@ROWS INT OUTPUT',
    @ROWS = @ADMMF_ROWS OUTPUT;

SELECT @ADMMF_ROWS AS ADMMF本次补插行数;

------------------------------------------------------------
-- 2. 再补 ADMMG
-- 来源：SDRD..ADMMG，模板 MG001 = '10037089'
-- 目标：当前库 dbo.ADMMG
-- 只替换 MG001，其它字段照抄
------------------------------------------------------------

WITH SRC AS (
    SELECT *
    FROM SDRD..ADMMG
    WHERE MG001 = '10037089'
      AND MG002 IN ('PURI05','PURI06','PURI07','PURR14','PURR16')
),
NEED AS (
    SELECT 
        E.MG001 AS NEW_MG001,
        S.*
    FROM #EMP E
    CROSS JOIN SRC S
    WHERE EXISTS (
        SELECT 1
        FROM dbo.ADMMF F
        WHERE F.MF001 = E.MG001
    )
    AND NOT EXISTS (
        SELECT 1
        FROM dbo.ADMMG G WITH (UPDLOCK, HOLDLOCK)
        WHERE G.MG001 = E.MG001
          AND G.MG002 = S.MG002
    )
)
INSERT INTO dbo.ADMMG (
    COMPANY,
    CREATOR,
    USR_GROUP,
    CREATE_DATE,
    MODIFIER,
    MODI_DATE,
    FLAG,
    MG001,
    MG002,
    MG003,
    MG004,
    MG005,
    MG006,
    MG007,
    MG008,
    MG009,
    MG010,
    MG011,
    MG012,
    MG013,
    MG014,
    MG015,
    MG016,
    MG017,
    UDF01,
    UDF02,
    UDF03,
    UDF04,
    UDF05,
    UDF06,
    UDF51,
    UDF52,
    UDF53,
    UDF54,
    UDF55,
    UDF56
)
SELECT
    COMPANY,
    CREATOR,
    USR_GROUP,
    CREATE_DATE,
    MODIFIER,
    MODI_DATE,
    FLAG,
    NEW_MG001 AS MG001,
    MG002,
    MG003,
    MG004,
    MG005,
    MG006,
    MG007,
    MG008,
    MG009,
    MG010,
    MG011,
    MG012,
    MG013,
    MG014,
    MG015,
    MG016,
    MG017,
    UDF01,
    UDF02,
    UDF03,
    UDF04,
    UDF05,
    UDF06,
    UDF51,
    UDF52,
    UDF53,
    UDF54,
    UDF55,
    UDF56
FROM NEED;

SELECT @@ROWCOUNT AS ADMMG本次补插行数;

------------------------------------------------------------
-- 3. 核对
------------------------------------------------------------

SELECT 
    E.MG001 AS 工号,
    CASE 
        WHEN F.MF001 IS NULL THEN 'ADMMF缺失'
        ELSE 'ADMMF已存在'
    END AS ADMMF状态,
    COUNT(G.MG002) AS ADMMG权限数量
FROM #EMP E
LEFT JOIN dbo.ADMMF F
    ON F.MF001 = E.MG001
LEFT JOIN dbo.ADMMG G
    ON G.MG001 = E.MG001
   AND G.MG002 IN ('PURI05','PURI06','PURI07','PURR14','PURR16')
GROUP BY E.MG001, F.MF001
ORDER BY E.MG001;

COMMIT TRAN;

-- 有问题时把上面 COMMIT TRAN 注释，改执行：
-- ROLLBACK TRAN;


SELECT * 
FROM ADMMF 
WHERE MF001 IN (
    '10037089','10040350','10045571','10046361','10053055',
    '10053182','10056458','10062786','10063234','10072301',
    '10079951','10080363','10080879','10085962','10108865',
    '30048549','30098328','30112208','30112328','50060644',
    '50067187','50074874','50086237','50086453','50094145'
);

DELETE 
--SELECT * 
FROM ADMMG
WHERE MG001 IN (
    '10037089','10040350','10045571','10046361','10053055',
    '10053182','10056458','10062786','10063234','10072301',
    '10079951','10080363','10080879','10085962','10108865',
    '30048549','30098328','30112208','30112328','50060644',
    '50067187','50074874','50086237','50086453','50094145'
) AND CREATE_DATE IN( '20260608162731940','20190720114959553')

SELECT * FROM ADMMG
WHERE NOT EXISTS(
    SELECT 1 FROM ADMMF WHERE MG001 = MF001
)

SELECT * FROM ADMMG
WHERE NOT EXISTS(
    SELECT 1 FROM ADMME WHERE MG009 = ME001
)

DELETE FROM ADMMF WHERE CREATE_DATE = '20190720114959550'

SELECT 
    MG001,
    MG002,
    COUNT(*) AS CNT
FROM ADMMG
WHERE MG001 IN (
    '10037089','10040350','10045571','10046361','10053055',
    '10053182','10056458','10062786','10063234','10072301',
    '10079951','10080363','10080879','10085962','10108865',
    '30048549','30098328','30112208','30112328','50060644',
    '50067187','50074874','50086237','50086453','50094145'
)
AND MG002 IN ('PURI05','PURI06','PURI07','PURR14','PURR16')
GROUP BY MG001, MG002
HAVING COUNT(*) > 1;