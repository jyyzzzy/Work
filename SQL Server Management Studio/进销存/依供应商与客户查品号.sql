/******根据供应商与客户查询物料信息******/
--CREATE AT 2025/9/26 BY ZIYANG ZHANG
;WITH VendorComp AS (      -- 该供应商供货的元件
    SELECT DISTINCT PMB.MB001 AS COMP
    FROM PURMB AS PMB
    WHERE PMB.MB002 = '20500143'      -- 供应商
),
BOMUp AS (                 -- 自元件向上追溯父件
    SELECT v.COMP, m.MD001 AS P
    FROM VendorComp AS v
    LEFT JOIN BOMMD AS m ON m.MD003 = v.COMP
    UNION ALL
    SELECT u.COMP, m.MD001
    FROM BOMUp AS u
    JOIN BOMMD AS m ON m.MD003 = u.P
),
TopItem AS (               -- 顶阶主件：无更高父件，且编码首字母在 '1','A'
    SELECT u.COMP, u.P AS TOPITEM
    FROM BOMUp AS u
    WHERE u.P IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM BOMMD z WHERE z.MD003 = u.P)
      AND SUBSTRING(u.P,1,1) IN ('1','A')
    UNION ALL               -- 兼容“元件本身就是顶阶主件”
    SELECT v.COMP, v.COMP
    FROM VendorComp AS v
    WHERE SUBSTRING(v.COMP,1,1) IN ('1','A')
      AND NOT EXISTS (SELECT 1 FROM BOMMD z WHERE z.MD003 = v.COMP)
)
SELECT DISTINCT
    v.COMP        AS 元件编码,
    cmb.MB002     AS 元件品名,
    cmb.MB003     AS 元件规格,
    cmb.MB004     AS 元件单位,
    t.TOPITEM     AS 顶阶主件编码,
    tmb.MB002     AS 顶阶主件品名,
    tmb.MB003     AS 顶阶主件规格,
    tmb.MB004     AS 顶阶主件单位,
    mg.MG001      AS 客户编号,
    ma.MA003      AS 客户全称
FROM TopItem AS t
JOIN VendorComp AS v   ON v.COMP    = t.COMP                       -- 只取供应商 20500143 的元件
JOIN INVMB      AS cmb ON cmb.MB001 = v.COMP                       -- 元件信息
JOIN INVMB      AS tmb ON tmb.MB001 = t.TOPITEM                    -- 顶阶主件信息
JOIN COPMG      AS mg  ON mg.MG002  = t.TOPITEM AND mg.MG001='10900009' -- 客户 10900009
JOIN COPMA      AS ma  ON ma.MA001  = mg.MG001
ORDER BY v.COMP, t.TOPITEM
OPTION (MAXRECURSION 0);
