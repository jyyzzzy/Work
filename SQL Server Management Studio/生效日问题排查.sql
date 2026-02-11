SELECT
    t.MB001 品号, 
    t.MB002 供应商, 
    t.MB003 币种,
    t.MB004 单位,
    t.MB014 AS 生效日,
    t.MB015 AS 失效日,
    t.NextMB014 AS 下个生效日
FROM (
    SELECT
        p.MB001, p.MB002, p.MB003, p.MB004,
        p.MB014, p.MB015,
        LEAD(p.MB014) OVER (
            PARTITION BY p.MB001, p.MB002, p.MB003, p.MB004
            ORDER BY p.MB014, p.MB015
        ) AS NextMB014
    FROM PURMB p
) AS t
WHERE
    t.NextMB014 IS NOT NULL
    AND ISNULL(NULLIF(t.MB015, ''), '99991231') > t.NextMB014
    AND t.MB015 >= '20251225'
ORDER BY
    --t.MB001, t.MB002, t.MB003, t.MB004,
    t.MB014, t.MB015;
