/*
生产入库数据：2025-10-01 至 2026-09-30（含）
账套：SDRD、ZJRD、AHRD、YNRD
生产部门：从各账套 CMSMD.MD011 截取第一个 - 之前的事业部名称
BOM：使用 SDRD 当前标准 BOM；第一阶全部保留，仅 4 开头虚拟件横向展开第二阶
虚拟件右侧仅追加：子材料品号、品名、规格、单位、默认选择 MD013、单位用量
数量：按账套、产品、事业部、客户汇总 MOCTG.TG011
注意：每个 BOM 明细行均重复显示同一产品的入库总数量；不能直接整列求和。
注意：NOLOCK 可能读取未提交的数据。本脚本未按历史日期回溯 BOM 版本。
*/

SET NOCOUNT ON;
DECLARE @StartDate CHAR(8) = '20251001';
DECLARE @EndDate   CHAR(8) = '20260930';

SELECT
    R.账套,
    R.产品品号,
    R.产品品名,
    R.产品规格,
    R.生产部门,
    R.客户编码,
    R.客户简称,
    R.入库总数量,

    B.MD003 AS 材料品号,
    M.MB002 AS 材料品名,
    M.MB003 AS 材料规格,
    M.MB004 AS 材料单位,
    B.MD009 AS 工艺编码,
    W.MW002 AS 工艺名称,
    B.MD019 AS 插件位置,
    IIF(B.MD007 > 0, CAST(B.MD006 / B.MD007 AS DECIMAL(28,10)), 0) AS 单位用量,

    -- 以下仅虚拟件（第一阶材料品号以 4 开头）有值
    V.MD003 AS 虚拟件子材料品号,
    VM.MB002 AS 虚拟件子材料品名,
    VM.MB003 AS 虚拟件子材料规格,
    VM.MB004 AS 虚拟件子材料单位,
    V.MD013 AS 虚拟件默认选择,
    IIF(V.MD007 > 0, CAST(V.MD006 / V.MD007 AS DECIMAL(28,10)), 0) AS 虚拟件单位用量
FROM
(
    SELECT
        X.账套,
        X.产品品号,
        MAX(X.产品品名) AS 产品品名,
        MAX(X.产品规格) AS 产品规格,
        X.生产部门,
        X.客户编码,
        MAX(X.客户简称) AS 客户简称,
        SUM(X.入库数量) AS 入库总数量
    FROM
    (
        SELECT
            'SDRD' AS 账套,
            G.TG004 AS 产品品号,
            G.TG005 AS 产品品名,
            G.TG006 AS 产品规格,
            LEFT(W.MD011, CHARINDEX('-', W.MD011 + '-') - 1) AS 生产部门,
            C.TC004 AS 客户编码,
            MA.MA002 AS 客户简称,
            ISNULL(G.TG011, 0) AS 入库数量
        FROM SDRD..MOCTF F WITH(NOLOCK)
        INNER JOIN SDRD..MOCTG G WITH(NOLOCK)
            ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
        LEFT JOIN SDRD..MOCTA A WITH(NOLOCK)
            ON G.TG014 = A.TA001 AND G.TG015 = A.TA002
        LEFT JOIN SDRD..COPTC C WITH(NOLOCK)
            ON A.TA026 = C.TC001 AND A.TA027 = C.TC002
        LEFT JOIN SDRD..COPMA MA WITH(NOLOCK)
            ON C.TC004 = MA.MA001
        LEFT JOIN SDRD..CMSMD W WITH(NOLOCK)
            ON F.TF011 = W.MD001
        WHERE F.TF003 >= @StartDate AND F.TF003 <= @EndDate
          AND F.TF006 = 'Y' AND G.TG022 = 'Y'
          AND LEFT(G.TG004, 1) = '2'

        UNION ALL

        SELECT
            'ZJRD', G.TG004, G.TG005, G.TG006,
            '浙江瑞德',
            C.TC004, MA.MA002, ISNULL(G.TG011, 0)
        FROM ZJRD..MOCTF F WITH(NOLOCK)
        INNER JOIN ZJRD..MOCTG G WITH(NOLOCK)
            ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
        LEFT JOIN ZJRD..MOCTA A WITH(NOLOCK)
            ON G.TG014 = A.TA001 AND G.TG015 = A.TA002
        LEFT JOIN ZJRD..COPTC C WITH(NOLOCK)
            ON A.TA026 = C.TC001 AND A.TA027 = C.TC002
        LEFT JOIN ZJRD..COPMA MA WITH(NOLOCK)
            ON C.TC004 = MA.MA001
        LEFT JOIN ZJRD..CMSMD W WITH(NOLOCK)
            ON F.TF011 = W.MD001
        WHERE F.TF003 >= @StartDate AND F.TF003 <= @EndDate
          AND F.TF006 = 'Y' AND G.TG022 = 'Y'
          AND LEFT(G.TG004, 1) = '2'

        UNION ALL

        SELECT
            'AHRD', G.TG004, G.TG005, G.TG006,
            LEFT(W.MD011, CHARINDEX('-', W.MD011 + '-') - 1),
            C.TC004, MA.MA002, ISNULL(G.TG011, 0)
        FROM AHRD..MOCTF F WITH(NOLOCK)
        INNER JOIN AHRD..MOCTG G WITH(NOLOCK)
            ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
        LEFT JOIN AHRD..MOCTA A WITH(NOLOCK)
            ON G.TG014 = A.TA001 AND G.TG015 = A.TA002
        LEFT JOIN AHRD..COPTC C WITH(NOLOCK)
            ON A.TA026 = C.TC001 AND A.TA027 = C.TC002
        LEFT JOIN AHRD..COPMA MA WITH(NOLOCK)
            ON C.TC004 = MA.MA001
        LEFT JOIN AHRD..CMSMD W WITH(NOLOCK)
            ON F.TF011 = W.MD001
        WHERE F.TF003 >= @StartDate AND F.TF003 <= @EndDate
          AND F.TF006 = 'Y' AND G.TG022 = 'Y'
          AND LEFT(G.TG004, 1) = '2'

        UNION ALL

        SELECT
            'YNRD', G.TG004, G.TG005, G.TG006,
            '越南瑞德',
            C.TC004, MA.MA002, ISNULL(G.TG011, 0)
        FROM YNRD..MOCTF F WITH(NOLOCK)
        INNER JOIN YNRD..MOCTG G WITH(NOLOCK)
            ON F.TF001 = G.TG001 AND F.TF002 = G.TG002
        LEFT JOIN YNRD..MOCTA A WITH(NOLOCK)
            ON G.TG014 = A.TA001 AND G.TG015 = A.TA002
        LEFT JOIN YNRD..COPTC C WITH(NOLOCK)
            ON A.TA026 = C.TC001 AND A.TA027 = C.TC002
        LEFT JOIN YNRD..COPMA MA WITH(NOLOCK)
            ON C.TC004 = MA.MA001
        LEFT JOIN YNRD..CMSMD W WITH(NOLOCK)
            ON F.TF011 = W.MD001
        WHERE F.TF003 >= @StartDate AND F.TF003 <= @EndDate
          AND F.TF006 = 'Y' AND G.TG022 = 'Y'
          AND LEFT(G.TG004, 1) = '2'
    ) X
    GROUP BY X.账套, X.产品品号, X.生产部门, X.客户编码
) R
LEFT JOIN SDRD..BOMMD B WITH(NOLOCK)
    ON R.产品品号 = B.MD001
LEFT JOIN SDRD..INVMB M WITH(NOLOCK)
    ON B.MD003 = M.MB001
LEFT JOIN SDRD..CMSMW W WITH(NOLOCK)
    ON B.MD009 = W.MW001
LEFT JOIN SDRD..BOMMD V WITH(NOLOCK)
    ON LEFT(B.MD003, 1) = '4'
   AND B.MD003 = V.MD001
LEFT JOIN SDRD..INVMB VM WITH(NOLOCK)
    ON V.MD003 = VM.MB001
ORDER BY
    R.账套, R.产品品号, R.生产部门, R.客户编码,
    B.MD003, V.MD003;
