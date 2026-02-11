/******查询出货成品******/
/*最近两年内接过订单或出过货的成品，
导出数据需要包含的信息有：
品号、品名、规格、单位、客户编号、客户名称、销售部、事业部、最近接单/销售日期，
关联物料最长采购参考周期*/
SELECT DISTINCT 品号,品名,规格,单位,客户编号,客户简称,部门编号,部门名称,分部名称,日期,INVMB.UDF52
FROM(
SELECT TH004 AS 品号,
	TH005 AS 品名,
	TH006 AS 规格,
	TH009 AS 单位,
	TG004 AS 客户编号,
	MA002 AS 客户简称,
	TG005 AS 部门编号,
	ME002 AS 部门名称,
	LEFT(CMSMC.UDF01,CHARINDEX('-',CMSMC.UDF01 + '-') - 1) AS 分部名称,
	(
		;WITH TREE AS (
			SELECT MD003 AS CHILD
			FROM BOMMD 
			WHERE MD001 = TH004

			UNION ALL

			SELECT MD003 AS CHILD
			FROM TREE
			INNER JOIN BOMMD
				ON MD001 = TREE.CHILD
		) SELECT DISTINCT MAX(INVMB.UDF52) AS 日期 FROM TREE
		INNER JOIN INVMB ON MB001 = CHILD
	) AS 日期
FROM COPTH
	INNER JOIN COPTG ON TG001 = TH001 AND TG002 = TH002
	INNER JOIN COPMA ON MA001 = TG004
	INNER JOIN CMSME ON ME001 = TG005
	INNER JOIN CMSMC ON MC001 = TH007
	INNER JOIN 
WHERE TG003 >= '20240101'
GROUP BY TH004,
	TH005,
	TH006,
	TH009,
	TG004,
	MA002,
	TG005,
	ME002,
	LEFT(CMSMC.UDF01,CHARINDEX('-',CMSMC.UDF01 + '-') - 1)

UNION

SELECT TD004 AS 品号,
	TD005 AS 品名,
	TD006 AS 规格,
	TD010 AS 单位,
	TC004 AS 客户编号,
	MA002 AS 客户简称,
	TC005 AS 部门编号,
	ME002 AS 部门名称,
	LEFT(CMSMC.UDF01,CHARINDEX('-',CMSMC.UDF01 + '-') - 1) AS 分部名称,
	(
		;WITH TREE AS (
			SELECT MD003 AS CHILD
			FROM BOMMD 
			WHERE MD001 = TH004

			UNION ALL

			SELECT MD003 AS CHILD
			FROM TREE
			INNER JOIN BOMMD
				ON MD001 = TREE.CHILD
		) SELECT DISTINCT MAX(INVMB.UDF52) AS 日期 FROM TREE
		INNER JOIN INVMB ON MB001 = CHILD
	) AS 日期
FROM COPTD
	INNER JOIN COPTC ON TC001 = TD001 AND TC002 = TD002
	INNER JOIN COPMA ON MA001 = TC004
	INNER JOIN CMSME ON ME001 = TC005
	INNER JOIN CMSMC ON MC001 = TD007
WHERE TC003 >= '20240101'
GROUP BY TD004,
	TD005,
	TD006,
	TD010,
	TC004,
	MA002,
	TC005,
	ME002,
	LEFT(CMSMC.UDF01,CHARINDEX('-',CMSMC.UDF01 + '-') - 1)
) AS ODINF
--INNER JOIN INVMB ON MB001 = ODINF.品号
SELECT * FROM CMSMC ORDER BY CREATE_DATE DESC
SELECT * FROM COPTH WHERE ISNULL(TH014,'') = ''


;WITH Base AS (
    -- 进货/出货头表（按你实际含义）
    SELECT DISTINCT
        品号     = TH004,
        品名     = TH005,
        规格     = TH006,
        单位     = TH009,
        客户编号 = TG004,
        客户简称 = MA002,
        部门编号 = TG005,
        部门名称 = ME002,
        分部名称 = LEFT(CMSMC.UDF01, CHARINDEX('-', CMSMC.UDF01 + '-') - 1)
    FROM COPTH
    INNER JOIN COPTG  ON TG001 = TH001 AND TG002 = TH002
    INNER JOIN COPMA  ON MA001 = TG004
    INNER JOIN CMSME  ON ME001 = TG005
    INNER JOIN CMSMC  ON MC001 = TH007
    WHERE TG003 >= '20240101'

    UNION

    -- 明细表
    SELECT DISTINCT
        品号     = TD004,
        品名     = TD005,
        规格     = TD006,
        单位     = TD010,
        客户编号 = TC004,
        客户简称 = MA002,
        部门编号 = TC005,
        部门名称 = ME002,
        分部名称 = LEFT(CMSMC.UDF01, CHARINDEX('-', CMSMC.UDF01 + '-') - 1)
    FROM COPTD
    INNER JOIN COPTC  ON TC001 = TD001 AND TC002 = TD002
    INNER JOIN COPMA  ON MA001 = TC004
    INNER JOIN CMSME  ON ME001 = TC005
    INNER JOIN CMSMC  ON MC001 = TD007
    WHERE TC003 >= '20240101'
),
Roots AS (
    SELECT DISTINCT 品号
    FROM Base
),
Tree AS (
    -- 第 1 层：根品号 -> 子件
    SELECT
        Root  = R.品号,
        Child = B.MD003
    FROM Roots R
    INNER JOIN BOMMD B
        ON B.MD001 = R.品号

    UNION ALL

    -- 递归层：上一层子件作为下一层母件
    SELECT
        T.Root,
        B.MD003
    FROM Tree T
    INNER JOIN BOMMD B
        ON B.MD001 = T.Child
),
ChildMax AS (
    -- 每个根品号，取所有子件(含多层)的 INVMB.UDF52 最大值
    SELECT
        Root,
        日期 = MAX(I.UDF52)
    FROM Tree T
    INNER JOIN INVMB I
        ON I.MB001 = T.Child
    GROUP BY Root
)
SELECT DISTINCT
    B.品号, B.品名, B.规格, B.单位,
    B.客户编号, B.客户简称,
    B.部门编号, B.部门名称,
    B.分部名称,
    ISNULL(CM.日期,I0.UDF52) AS 最大采购参考周期
FROM Base B
LEFT JOIN ChildMax CM
    ON CM.Root = B.品号
LEFT JOIN INVMB I0
    ON I0.MB001 = B.品号
WHERE LEFT(B.品号,1) IN ('1','A')
OPTION (MAXRECURSION 0);

USE YNRD


;WITH ODINF AS (
    SELECT
        TH004 AS 品号,
        TH005 AS 品名,
        TH006 AS 规格,
        TH009 AS 单位,
        TG004 AS 客户编号,
        MA002 AS 客户简称,
        TG005 AS 部门编号,
        ME002 AS 部门名称,
        LEFT(CMSMC.UDF01, CHARINDEX('-', CMSMC.UDF01 + '-') - 1) AS 分部名称,
        MAX(TG003) AS 最新订单日期
    FROM COPTH
    INNER JOIN COPTG  ON TG001 = TH001 AND TG002 = TH002
    INNER JOIN COPMA  ON MA001 = TG004
    INNER JOIN CMSME  ON ME001 = TG005
    INNER JOIN CMSMC  ON MC001 = TH007
    WHERE TG003 >= '20240101'
      AND LEFT(TH004, 1) IN ('1','A')
    GROUP BY
        TH004, TH005, TH006, TH009,
        TG004, MA002,
        TG005, ME002,
        LEFT(CMSMC.UDF01, CHARINDEX('-', CMSMC.UDF01 + '-') - 1)

    UNION ALL

    SELECT
        TD004 AS 品号,
        TD005 AS 品名,
        TD006 AS 规格,
        TD010 AS 单位,
        TC004 AS 客户编号,
        MA002 AS 客户简称,
        TC005 AS 部门编号,
        ME002 AS 部门名称,
        LEFT(CMSMC.UDF01, CHARINDEX('-', CMSMC.UDF01 + '-') - 1) AS 分部名称,
        MAX(TC003) AS 最新订单日期
    FROM COPTD
    INNER JOIN COPTC  ON TC001 = TD001 AND TC002 = TD002
    INNER JOIN COPMA  ON MA001 = TC004
    INNER JOIN CMSME  ON ME001 = TC005
    INNER JOIN CMSMC  ON MC001 = TD007
    WHERE TC003 >= '20240101'
      AND LEFT(TD004, 1) IN ('1','A')
    GROUP BY
        TD004, TD005, TD006, TD010,
        TC004, MA002,
        TC005, ME002,
        LEFT(CMSMC.UDF01, CHARINDEX('-', CMSMC.UDF01 + '-') - 1)
),
BOMTREE AS (
    SELECT
        O.品号 AS Root,
        B.MD003 AS Child
        ,IIF(LEFT(B.MD003,1) IN ('3','5','6','7') AND (LEFT(B.MD001,1) <> '4' OR B.MD013 = 'N'),'Y','N') AS FLAG
    FROM (SELECT DISTINCT 品号 FROM ODINF) O
    INNER JOIN BOMMD B
        ON B.MD001 = O.品号

    UNION ALL

    SELECT
        T.Root,
        B.MD003
        ,IIF(LEFT(B.MD003,1) IN ('3','5','6','7') AND (LEFT(B.MD001,1) <> '4' OR B.MD013 = 'N'),'Y','N') AS FLAG
    FROM BOMTREE T
    INNER JOIN BOMMD B
        ON B.MD001 = T.Child
),
Cycle AS (
    SELECT
        品号 = Root,
        最大参考周期材料品号 = MB001,
        最大采购参考周期 = UDF52
    FROM (
        SELECT
            T.Root,
            MB.MB001,
            MB.UDF52,
            ROW_NUMBER() OVER (
                PARTITION BY T.Root
                ORDER BY MB.UDF52 DESC, MB.MB001
            ) AS rn
        FROM BOMTREE T
        INNER JOIN INVMB MB
            ON MB.MB001 = T.Child
        WHERE T.FLAG = 'Y'
    ) X
    WHERE rn = 1
)
SELECT
    O.品号, O.品名, O.规格, O.单位,
    O.客户编号, O.客户简称,
    O.部门编号, O.部门名称,
    O.分部名称,
    MAX(O.最新订单日期) AS 最新订单日期,
    C.最大参考周期材料品号,
    MAX(C.最大采购参考周期) AS 最大采购参考周期
FROM ODINF O
LEFT JOIN Cycle C
    ON C.品号 = O.品号
GROUP BY
    O.品号, O.品名, O.规格, O.单位,
    O.客户编号, O.客户简称,
    O.部门编号, O.部门名称,
    O.分部名称,C.最大参考周期材料品号
OPTION (MAXRECURSION 0);


USE YNRD
