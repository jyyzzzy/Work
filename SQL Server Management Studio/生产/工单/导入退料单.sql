/******插入领/退料单******/ --20250910 BY ZIYANG ZHANG
CREATE TABLE LSSJ.dbo.MIR(
	工作中心 CHAR(6) NOT NULL,
	工单单别 CHAR(4) NOT NULL,
	工单单号 CHAR(12) NOT NULL,
	材料品号 CHAR(20) NOT NULL,
	领退料数量 NUMERIC(15,6) NOT NULL,
	领退料包装数量 NUMERIC(15,6) NULL
);
SELECT * FROM LSSJ..MIR
DELETE FROM LSSJ..MIR
--="INSERT INTO LSSJ..MIR(PLANTCODE,MOTYPE,MONO,ITEMNO,QUANTITY) VALUES('"&&"','"&&"','"&&"','"&&"',"&&")"

DROP TABLE #MOCTC
DROP TABLE #MOCTE


--大整数加法
CREATE OR ALTER FUNCTION dbo.BigIntAdd
(
    @a CHAR(11),   -- 第一个加数（11位数字字符串，可能有前导0）
    @b CHAR(11)    -- 第二个加数（11位数字字符串，可能有前导0）
)
RETURNS CHAR(11)
AS
BEGIN
    DECLARE @A VARCHAR(50) = LTRIM(@a);  -- 去除前导空格
    DECLARE @B VARCHAR(50) = LTRIM(@b);
	DECLARE @LA INT = LEN(@A);

    -- 去掉前导0，避免影响计算
    WHILE LEN(@A) > 1 AND LEFT(@A,1) = '0'
        SET @A = SUBSTRING(@A,2,LEN(@A)-1);
    WHILE LEN(@B) > 1 AND LEFT(@B,1) = '0'
        SET @B = SUBSTRING(@B,2,LEN(@B)-1);

    DECLARE @i INT = LEN(@A);
    DECLARE @j INT = LEN(@B);
    DECLARE @carry INT = 0;
    DECLARE @res VARCHAR(50) = '';
    DECLARE @da INT, @db INT, @sum INT;

    -- 从末位开始逐位相加
    WHILE (@i > 0 OR @j > 0 OR @carry > 0)
    BEGIN
        SET @da = CASE WHEN @i > 0 THEN ASCII(SUBSTRING(@A, @i, 1)) - 48 ELSE 0 END;
        SET @db = CASE WHEN @j > 0 THEN ASCII(SUBSTRING(@B, @j, 1)) - 48 ELSE 0 END;

        SET @sum = @da + @db + @carry;
        SET @res = CHAR(@sum % 10 + 48) + @res;
        SET @carry = @sum / 10;

        SET @i -= 1;
        SET @j -= 1;
    END

    -- 去掉前导零（避免返回空）
    WHILE LEN(@res) > 1 AND LEFT(@res,1) = '0'
        SET @res = SUBSTRING(@res,2,LEN(@res)-1);

    -- 始终返回11位，左侧补0
    RETURN RIGHT(REPLICATE('0', @LA) + @res, @LA);
END;
GO



--领/退料单头信息插入至临时表
SELECT 
    CAST('0001' AS CHAR(10))                                           AS COMPANY,
    CAST('10105978' AS CHAR(10))                                       AS CREATOR,
    CAST('90001' AS CHAR(10))                                          AS USR_GROUP,
    CAST(FORMAT(GETDATE(),'yyyyMMddHHmmssfff') AS CHAR(17))            AS CREATE_DATE,
    CAST('' AS CHAR(10))                                               AS MODIFIER,
    CAST('' AS CHAR(17))                                               AS MODI_DATE,
    CAST(1 AS NUMERIC(3,0))                                            AS FLAG,
    CAST('5601' AS CHAR(4))                                            AS TC001,
    CAST(
        RIGHT(
            '00000000000' +
            CAST(
                dbo.BigIntAdd(
                    (
                        SELECT ISNULL(
                                   MAX(TC002),
                                   CONVERT(CHAR(6), GETDATE(), 112) + '00000'   -- 6+5=11 位
                               )
                        FROM MOCTC
                        WHERE TC001 = '5601'
                          AND TC003 = CONVERT(CHAR(8), GETDATE(), 112)
                    ),
                    ROW_NUMBER() OVER (ORDER BY TMP.工单单号)
                ) AS VARCHAR(20)
            ),
            11
        ) AS CHAR(11)
    )                                                                  AS TC002,
    CAST(CONVERT(CHAR(8), GETDATE(), 112) AS CHAR(8))                  AS TC003,
    CAST(TA019 AS CHAR(6))                                             AS TC004,
    CAST(TA021 AS CHAR(10))                                            AS TC005,
    CAST('' AS CHAR(10))                                               AS TC006,
    CAST('' AS VARCHAR(255))                                           AS TC007,
    CAST('56' AS CHAR(2))                                              AS TC008,
    CAST('N' AS CHAR(1))                                               AS TC009,
    CAST(0 AS NUMERIC(1,0))                                            AS TC010,
    CAST('N' AS CHAR(1))                                               AS TC011,
    CAST('1' AS CHAR(1))                                               AS TC012,
    CAST('N' AS CHAR(1))                                               AS TC013,
    CAST(CONVERT(CHAR(8), GETDATE(), 112) AS CHAR(8))                  AS TC014,
    CAST('' AS CHAR(10))                                               AS TC015,
    CAST('N' AS CHAR(1))                                               AS TC016,
    CAST(0 AS NUMERIC(1,0))                                            AS TC017,
    CAST('1' AS CHAR(1))                                               AS TC018,
    CAST(TA001 AS CHAR(4))                                             AS TC019,
    CAST(TA002 AS CHAR(11))                                            AS TC020,
    CAST(TA064 AS CHAR(6))                                             AS TC021,
    CAST('' AS CHAR(1))                                                AS TC022,
    CAST('' AS CHAR(8))                                                AS TC023,
    CAST('' AS VARCHAR(30))                                            AS TC024,
    CAST(0 AS NUMERIC(13,2))                                           AS TC025,
    CAST(0 AS NUMERIC(13,2))                                           AS TC026,
    CAST(0 AS NUMERIC(13,2))                                           AS TC027,
    CAST('' AS VARCHAR(255))                                           AS UDF01,
    CAST('' AS VARCHAR(255))                                           AS UDF02,
    CAST('' AS VARCHAR(255))                                           AS UDF03,
    CAST('' AS VARCHAR(255))                                           AS UDF04,
    CAST('' AS VARCHAR(255))                                           AS UDF05,
    CAST('' AS VARCHAR(255))                                           AS UDF06,
    CAST(0 AS NUMERIC(15,6))                                           AS UDF51,
    CAST(0 AS NUMERIC(15,6))                                           AS UDF52,
    CAST(0 AS NUMERIC(15,6))                                           AS UDF53,
    CAST(0 AS NUMERIC(15,6))                                           AS UDF54,
    CAST(0 AS NUMERIC(15,6))                                           AS UDF55,
    CAST(0 AS NUMERIC(15,6))                                           AS UDF56
INTO #MOCTC
FROM LSSJ..MIR AS TMP 
LEFT OUTER JOIN MOCTA ON TMP.工单单别 = TA001 AND TMP.工单单号 = TA002
LEFT OUTER JOIN MOCTC ON TC001 = '5601' AND SUBSTRING(TC003,1,6) = FORMAT(GETDATE(), 'yyyyMM')
GROUP BY TMP.工单单别, TMP.工单单号,TA019,TA021,TA001,TA002,TA064
ORDER BY 工单单别, 工单单号 ASC;


----工单信息档
--SELECT
--'0001' AS COMPANY,
--'10105978' AS CREATOR,
--'90001' AS USR_GROUP,
--FORMAT(GETDATE(), 'yyyyMMddHHmmssfff') AS CREATE_DATE,
--'' AS MODIFIER,
--'' AS MODI_DATE,
--1 AS FLAG,
--TC001 AS TD001,
--TC002 AS TD002,
--TA001 AS TD003,
--TA002 AS TD004,
--'1' AS TD005,
--领退料数量 AS TD006,
--'1' AS TD007,
--'1' AS TD008,
--'' AS TD009,
--'' AS TD010,
--'' AS TD011,
--'' AS TD012,
--'' AS TD013,
--0 AS TD014,
--'' AS TD015,
--'' AS TD016,
--'' AS TD017,
--'' AS TD018,
--'' AS TD019,
--'' AS TD020,
--'' AS TD021,
--'' AS TD022,
--0 AS TD023,
--0 AS TD024,
--0 AS TD025,
--'' AS UDF01,
--'' AS UDF02,
--'' AS UDF03,
--'' AS UDF04,
--'' AS UDF05,
--'' AS UDF06,
--0 AS UDF51,
--0 AS UDF52,
--0 AS UDF53,
--0 AS UDF54,
--0 AS UDF55,
--0 AS UDF56
--INTO #MOCTD
--FROM LSSJ..MIR
--	INNER JOIN #MOCTC ON TC019 = 工单单别 AND TC020 = 工单单号 
--	INNER JOIN MOCTA ON TA001 = TC019 AND TA002 = TA020;



--将单身信息插入到临时表
SELECT
    CAST('0001' AS CHAR(10))                                   AS COMPANY,
    CAST('10105978' AS CHAR(10))                                AS CREATOR,
    CAST('90001' AS CHAR(10))                                   AS USR_GROUP,
    CAST(FORMAT(GETDATE(),'yyyyMMddHHmmssfff') AS CHAR(17))     AS CREATE_DATE,
    CAST('' AS CHAR(10))                                        AS MODIFIER,
    CAST('' AS CHAR(17))                                        AS MODI_DATE,
    CAST(1 AS NUMERIC(3,0))                                     AS FLAG,
    CAST(TC001 AS CHAR(4))                                      AS TE001,  -- 单别
    CAST(TC002 AS CHAR(11))                                     AS TE002,  -- 单号(11)
    CAST(RIGHT('0000' + CAST(ROW_NUMBER() OVER (
            PARTITION BY TC001, TC002 ORDER BY 工单单号
        ) AS VARCHAR(4)), 4) AS CHAR(4))                        AS TE003,
    CAST(材料品号 AS CHAR(20))                                  AS TE004,  -- 材料品号
    CAST(领退料数量 AS NUMERIC(15,6))                           AS TE005,  -- 数量
    CAST(TB007 AS CHAR(4))                                      AS TE006,  -- 单位
    CAST('' AS CHAR(4))                                         AS TE007,  -- 参考单位
    CAST(TB009 AS CHAR(10))                                     AS TE008,  -- 仓库
    CAST(TB006 AS CHAR(4))                                      AS TE009,  -- 工艺
    CAST(ISNULL(ME002,'') AS CHAR(20))                          AS TE010,  -- 批号
    CAST(TA001 AS CHAR(4))                                      AS TE011,  -- 来源单别
    CAST(TA002 AS CHAR(11))                                     AS TE012,  -- 来源单号
    CAST('' AS VARCHAR(60))                                     AS TE013,  -- 领料说明
    CAST('' AS VARCHAR(255))                                    AS TE014,  -- 备注
    CAST(TB014 AS CHAR(20))                                     AS TE015,  -- 上阶主件品号
    CAST(TB011 AS CHAR(1))                                      AS TE016,  -- 标志/类型(Y/N/…)
    CAST(TB012 AS VARCHAR(60))                                  AS TE017,  -- 自由说明1
    CAST(TB013 AS VARCHAR(60))                                  AS TE018,  -- 自由说明2
    CAST('N' AS CHAR(1))                                        AS TE019,  -- 是否冲销等
    CAST('0' AS CHAR(20))                                       AS TE020,  -- 项目编号
    CAST(领退料包装数量 AS NUMERIC(15,6))                       AS TE021,  -- 包装数量
    CAST(TB021 AS CHAR(4))                                      AS TE022,  -- 包装单位
    CAST(TA058 AS VARCHAR(80))                                  AS TE023,  -- 备注/说明
    CAST(ISNULL(ME023,0) AS NUMERIC(5,4))                       AS TE024,  -- 折算率
    CAST(MC015 AS CHAR(10))                                     AS TE025,  -- 库位
    CAST(MB004 AS CHAR(4))                                      AS TE026,  -- 库存单位
    CAST(MC007 AS NUMERIC(15,6))                                AS TE027,  -- 库存数量
    CAST('' AS CHAR(1))                                         AS TE028,
    CAST('' AS CHAR(8))                                         AS TE029,
    CAST('' AS VARCHAR(30))                                     AS TE030,
    CAST(0 AS NUMERIC(13,2))                                    AS TE031,
    CAST(0 AS NUMERIC(13,2))                                    AS TE032,
    CAST(0 AS NUMERIC(13,2))                                    AS TE033,
    CAST('' AS VARCHAR(255))                                    AS UDF01,
    CAST('' AS VARCHAR(255))                                    AS UDF02,
    CAST('' AS VARCHAR(255))                                    AS UDF03,
    CAST('' AS VARCHAR(255))                                    AS UDF04,
    CAST('' AS VARCHAR(255))                                    AS UDF05,
    CAST('' AS VARCHAR(255))                                    AS UDF06,
    CAST(0 AS NUMERIC(15,6))                                    AS UDF51,
    CAST(0 AS NUMERIC(15,6))                                    AS UDF52,
    CAST(0 AS NUMERIC(15,6))                                    AS UDF53,
    CAST(0 AS NUMERIC(15,6))                                    AS UDF54,
    CAST(0 AS NUMERIC(15,6))                                    AS UDF55,
    CAST(0 AS NUMERIC(15,6))                                    AS UDF56
INTO #MOCTE
FROM LSSJ..MIR
	LEFT OUTER JOIN #MOCTC ON TC019 = 工单单别 AND TC020 = 工单单号
	LEFT OUTER JOIN MOCTA ON TA001 = TC019 AND TA002 = TC020
	LEFT OUTER JOIN MOCTB ON TB001 = TC019 AND TB002 = TC020 AND TB003 = 材料品号
	LEFT OUTER JOIN INVMB ON MB001 = 材料品号
	LEFT OUTER JOIN INVMC ON MC001 = 材料品号 AND MC002 = TB009
	LEFT OUTER JOIN INVME ON ME001 = 材料品号


--从临时表复制到正式表。
INSERT INTO MOCTC SELECT * FROM #MOCTC
INSERT INTO MOCTE SELECT * FROM #MOCTE
