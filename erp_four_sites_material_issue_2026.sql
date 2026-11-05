-- 集团四地贴片磁珠、电感领用量（2026全年）
-- 实际领用量 = 54领料 - 56退料；仅已审核记录
-- 数据源：SDRD、ZJRD、AHRD、YNRD
SET NOCOUNT ON;

SELECT CASE WHEN MAX(CASE WHEN T.品名 LIKE N'%贴片磁珠%' THEN 1 ELSE 0 END) = 1
            THEN N'贴片磁珠' ELSE N'电感' END AS 物料类别,
       T.品号 AS 材料品号,
       MAX(T.品名) AS 材料品名,
       MAX(T.规格) AS 材料规格,
       MAX(T.单位) AS 单位,
       SUM(CASE WHEN T.地区 = N'顺德' THEN T.净领用量 ELSE 0 END) AS 顺德领用量,
       SUM(CASE WHEN T.地区 = N'浙江' THEN T.净领用量 ELSE 0 END) AS 浙江领用量,
       SUM(CASE WHEN T.地区 = N'安徽' THEN T.净领用量 ELSE 0 END) AS 安徽领用量,
       SUM(CASE WHEN T.地区 = N'越南' THEN T.净领用量 ELSE 0 END) AS 越南领用量,
       SUM(T.净领用量) AS 集团总领用量
FROM
(
    SELECT N'顺德' AS 地区,
           E.TE004 AS 品号,
           MAX(M.MB002) AS 品名,
           MAX(M.MB003) AS 规格,
           MAX(M.MB004) AS 单位,
           SUM(CASE WHEN E.TE001 LIKE '54%' THEN ISNULL(E.TE005, 0)
                    ELSE -ISNULL(E.TE005, 0) END) AS 净领用量
    FROM SDRD.dbo.MOCTC C WITH(NOLOCK)
    INNER JOIN SDRD.dbo.MOCTE E WITH(NOLOCK)
        ON C.TC001 = E.TE001 AND C.TC002 = E.TE002
    INNER JOIN SDRD.dbo.INVMB M WITH(NOLOCK)
        ON M.MB001 = E.TE004
    WHERE C.TC003 BETWEEN '20260101' AND '20261231'
      AND E.TE019 = 'Y'
      AND (E.TE001 LIKE '54%' OR E.TE001 LIKE '56%')
      AND (M.MB002 LIKE N'%贴片磁珠%' OR M.MB002 LIKE N'%电感%')
    GROUP BY E.TE004

    UNION ALL

    SELECT N'浙江' AS 地区,
           E.TE004 AS 品号,
           MAX(M.MB002) AS 品名,
           MAX(M.MB003) AS 规格,
           MAX(M.MB004) AS 单位,
           SUM(CASE WHEN E.TE001 LIKE '54%' THEN ISNULL(E.TE005, 0)
                    ELSE -ISNULL(E.TE005, 0) END) AS 净领用量
    FROM ZJRD.dbo.MOCTC C WITH(NOLOCK)
    INNER JOIN ZJRD.dbo.MOCTE E WITH(NOLOCK)
        ON C.TC001 = E.TE001 AND C.TC002 = E.TE002
    INNER JOIN ZJRD.dbo.INVMB M WITH(NOLOCK)
        ON M.MB001 = E.TE004
    WHERE C.TC003 BETWEEN '20260101' AND '20261231'
      AND E.TE019 = 'Y'
      AND (E.TE001 LIKE '54%' OR E.TE001 LIKE '56%')
      AND (M.MB002 LIKE N'%贴片磁珠%' OR M.MB002 LIKE N'%电感%')
    GROUP BY E.TE004

    UNION ALL

    SELECT N'安徽' AS 地区,
           E.TE004 AS 品号,
           MAX(M.MB002) AS 品名,
           MAX(M.MB003) AS 规格,
           MAX(M.MB004) AS 单位,
           SUM(CASE WHEN E.TE001 LIKE '54%' THEN ISNULL(E.TE005, 0)
                    ELSE -ISNULL(E.TE005, 0) END) AS 净领用量
    FROM AHRD.dbo.MOCTC C WITH(NOLOCK)
    INNER JOIN AHRD.dbo.MOCTE E WITH(NOLOCK)
        ON C.TC001 = E.TE001 AND C.TC002 = E.TE002
    INNER JOIN AHRD.dbo.INVMB M WITH(NOLOCK)
        ON M.MB001 = E.TE004
    WHERE C.TC003 BETWEEN '20260101' AND '20261231'
      AND E.TE019 = 'Y'
      AND (E.TE001 LIKE '54%' OR E.TE001 LIKE '56%')
      AND (M.MB002 LIKE N'%贴片磁珠%' OR M.MB002 LIKE N'%电感%')
    GROUP BY E.TE004

    UNION ALL

    SELECT N'越南' AS 地区,
           E.TE004 AS 品号,
           MAX(M.MB002) AS 品名,
           MAX(M.MB003) AS 规格,
           MAX(M.MB004) AS 单位,
           SUM(CASE WHEN E.TE001 LIKE '54%' THEN ISNULL(E.TE005, 0)
                    ELSE -ISNULL(E.TE005, 0) END) AS 净领用量
    FROM YNRD.dbo.MOCTC C WITH(NOLOCK)
    INNER JOIN YNRD.dbo.MOCTE E WITH(NOLOCK)
        ON C.TC001 = E.TE001 AND C.TC002 = E.TE002
    INNER JOIN YNRD.dbo.INVMB M WITH(NOLOCK)
        ON M.MB001 = E.TE004
    WHERE C.TC003 BETWEEN '20260101' AND '20261231'
      AND E.TE019 = 'Y'
      AND (E.TE001 LIKE '54%' OR E.TE001 LIKE '56%')
      AND (M.MB002 LIKE N'%贴片磁珠%' OR M.MB002 LIKE N'%电感%')
    GROUP BY E.TE004
) T
GROUP BY T.品号
ORDER BY 物料类别, T.品号;
