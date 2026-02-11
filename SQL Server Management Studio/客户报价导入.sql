SELECT 
    '0001' AS COMPANY,
    '10105978' AS CREATOR,
    '90001' AS USR_GROUP,
    FORMAT(GETDATE(), 'yyyyMMddHHmmssfff') AS CREATE_DATE,
    '' AS [MODIFIER],
    '' AS [MODI_DATE],
    1 AS [FLAG],

    '2101' AS TB001,
    NXT.NewTB002 AS TB002,   -- 现在：本批“每个客户一个、且全局不重复”

    RIGHT('0000' + CAST(
        ROW_NUMBER() OVER (
            PARTITION BY S.客户简称
            ORDER BY S.内部料号1
        ) AS varchar(4)
    ), 4) AS TB003,

    S.内部料号1 AS TB004,
    INVMB.MB002 AS TB005,
    INVMB.MB003 AS TB006,
    0 AS TB007,
    INVMB.MB004 AS TB008,
    S.含税价格 AS TB009,
    0 * S.含税价格 AS TB010,
    'N' AS TB011,
    '' AS TB012,
    'N' AS TB013,
    INVMB.MB072 AS TB014,
    0 AS TB015,
    S.生效时间 AS TB016,
    S.失效时间 AS TB017,
    COPMG1.MG003 AS TB018,
    '' AS TB019,
    INVMB.MB075 AS TB020,
    INVMB.MB071 AS TB021,
    0 AS TB022,
    0 AS TB023,
    INVMB.MB090 AS TB024,
    COPMA.MA036 AS TB025,
    COPMA.MA101 AS TB026,
    0 AS TB027,
    0 AS TB028,
    '' AS TB029,
    '' AS TB030,
    '' AS TB031,
    0 AS TB032,
    0 AS TB033,
    0 AS TB034,
    '' AS TB035,
    0 AS TB036,
    0 AS TB037,
    0 AS TB038,
    0 AS TB039,
    '' AS UDF01,
    '' AS UDF02,
    '' AS UDF03,
    '' AS UDF04,
    '' AS UDF05,
    '' AS UDF06,
    0 AS UDF51,
    0 AS UDF52,
    0 AS UDF53,
    0 AS UDF54,
    0 AS UDF55,
    0 AS UDF56
FROM (
    SELECT *
    FROM LSSJ..TJD
) AS S
INNER JOIN INVMB ON S.内部料号1 = INVMB.MB001
INNER JOIN COPMA ON COPMA.MA001 = S.客户简称
INNER JOIN (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY MG001, MG002 ORDER BY CREATE_DATE DESC) AS RN
        FROM COPMG
    ) X
    WHERE X.RN = 1
) AS COPMG1
    ON COPMG1.MG001 = S.客户简称
   AND COPMG1.MG002 = S.内部料号1

-- 给本批“客户”编号：1..N（每个客户一个编号）
INNER JOIN (
    SELECT 客户简称,
           ROW_NUMBER() OVER (ORDER BY 客户简称) AS CustIdx
    FROM (SELECT DISTINCT 客户简称 FROM LSSJ..TJD) D
) AS CUST
    ON CUST.客户简称 = S.客户简称

-- 取当天最大流水号（全局），并在一个批次里按客户数“顺延”
CROSS APPLY (
    SELECT
        BaseSeq =
            ISNULL(
                MAX(
                    CASE
                        WHEN RIGHT(COPTA.TA002, 3) LIKE '[0-9][0-9][0-9]'
                        THEN CONVERT(int, RIGHT(COPTA.TA002, 3))
                        ELSE NULL
                    END
                ),
            0) + 1
    FROM COPTA WITH (UPDLOCK, HOLDLOCK)   -- 强烈建议：防并发抢号
    WHERE COPTA.TA001 = '2101'
      AND LEFT(COPTA.TA002, 8) = CONVERT(char(8), GETDATE(), 112)
) AS SEQ
CROSS APPLY (
    SELECT
        NewTB002 =
            CONVERT(char(8), GETDATE(), 112)
            + RIGHT('000' + CONVERT(varchar(3), SEQ.BaseSeq + CUST.CustIdx - 1), 3)
) AS NXT

ORDER BY
    S.客户简称,
    S.内部料号1;
