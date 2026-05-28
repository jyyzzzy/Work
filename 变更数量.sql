SELECT 
     TC.TC004 AS 客户编号
    ,MA.MA002 AS 客户简称
    ,TC.TC005 AS 部门编号
    ,ME.ME002 AS 部门名称
    ,TD.TD001 AS 订单单别
    ,TD.TD002 AS 订单单号
    ,TD.TD003 AS 订单序号
    ,TF.TF109 AS 原订单数量
    ,TD.TD008 AS 订单数量
    ,TD.TD004 AS 产品品号
    ,MB.MB002 AS 产品品名
    ,MB.MB003 AS 产品规格
    ,MB.MB004 AS 产品单位
FROM COPTD AS TD
INNER JOIN COPTC AS TC
    ON TC.TC001 = TD.TD001
   AND TC.TC002 = TD.TD002
INNER JOIN COPMA AS MA
    ON MA.MA001 = TC.TC004
INNER JOIN CMSME AS ME
    ON ME.ME001 = TC.TC005
INNER JOIN INVMB AS MB
    ON MB.MB001 = TD.TD004
CROSS APPLY
(
    SELECT TOP (1)
         F.TF109
    FROM COPTF AS F
    WHERE F.TF001 = TD.TD001
      AND F.TF002 = TD.TD002
      AND F.TF004 = TD.TD003
      AND F.TF019 = 'Y'
    ORDER BY F.TF003 ASC
) AS TF
WHERE TC.TC027 = 'Y'
  AND TD.TD021 = 'Y'
  AND TF.TF109 <> TD.TD008
ORDER BY 
     TC.TC003
    ,TD.TD001
    ,TD.TD002
    ,TD.TD003;

/*========================================================
  1. 清理临时表
========================================================*/
IF OBJECT_ID('tempdb..#OrderDiff') IS NOT NULL DROP TABLE #OrderDiff;
IF OBJECT_ID('tempdb..#tbMC') IS NOT NULL DROP TABLE #tbMC;
IF OBJECT_ID('tempdb..#BCPXJ') IS NOT NULL DROP TABLE #BCPXJ;
IF OBJECT_ID('tempdb..#MaterialStatus') IS NOT NULL DROP TABLE #MaterialStatus;


/*========================================================
  2. 取订单数量差异明细 + 订单变更原因
========================================================*/
SELECT 
     TC.TC004 AS 客户编号
    ,MA.MA002 AS 客户简称
    ,TC.TC005 AS 部门编号
    ,ME.ME002 AS 部门名称
    ,TD.TD001 AS 订单单别
    ,TD.TD002 AS 订单单号
    ,TD.TD003 AS 订单序号
    ,ISNULL(TF.TF109, TD.TD008) AS 原订单数量
    ,TD.TD008 AS 订单数量
    ,TD.TD009 AS 已交数量
    ,TD.TD016 AS 结束码
    ,TR.变更原因 AS 变更原因
    ,TD.TD004 AS 产品品号
    ,MB.MB002 AS 产品品名
    ,MB.MB003 AS 产品规格
    ,MB.MB004 AS 产品单位
    ,TC.TC003 AS 订单日期
INTO #OrderDiff
FROM COPTD AS TD WITH(NOLOCK)
INNER JOIN COPTC AS TC WITH(NOLOCK)
    ON TC.TC001 = TD.TD001
   AND TC.TC002 = TD.TD002
INNER JOIN COPMA AS MA WITH(NOLOCK)
    ON MA.MA001 = TC.TC004
INNER JOIN CMSME AS ME WITH(NOLOCK)
    ON ME.ME001 = TC.TC005
INNER JOIN SDRD.dbo.INVMB AS MB WITH(NOLOCK)
    ON MB.MB001 = TD.TD004
INNER JOIN CMSMQ AS MQ ON MQ001 = TC001 
/* 取当前订单单身对应的第一笔变更前数量 */
OUTER APPLY
(
    SELECT TOP (1)
         F.TF109
    FROM COPTF AS F WITH(NOLOCK)
    WHERE F.TF001 = TD.TD001
      AND F.TF002 = TD.TD002
      AND F.TF004 = TD.TD003
      AND F.TF019 = 'Y'
    ORDER BY F.TF003 ASC
) AS TF

/* 按订单单头汇总所有变更原因，并剔除重复原因 */
OUTER APPLY
(
    SELECT
        STUFF(
        (
            SELECT 
                '|' + X.TE006
            FROM
            (
                SELECT
                     LTRIM(RTRIM(E.TE006)) AS TE006
                    ,MIN(E.TE003) AS SortNo
                FROM COPTE AS E WITH(NOLOCK)
                WHERE E.TE001 = TD.TD001
                  AND E.TE002 = TD.TD002
                  AND ISNULL(LTRIM(RTRIM(E.TE006)), '') <> ''
                GROUP BY LTRIM(RTRIM(E.TE006))
            ) AS X
            ORDER BY X.SortNo
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 1, '') AS 变更原因
) AS TR

WHERE TC.TC027 = 'Y'
  AND TD.TD021 = 'Y'
  AND (
    (
        TD.TD016 IN ('Y','y')
        AND ISNULL(TF.TF109, TD.TD008) > TD.TD009
    )
    OR (
        TD.TD016 = 'N'
        AND ISNULL(TF.TF109, TD.TD008) > TD.TD008
    )
  )
  AND MQ002 = '客户订单'
  --AND TC.TC003<'20220101'
  --AND TC.TC003 BETWEEN '20260101' AND '20261231';


/*========================================================
  3. 提取需要展开 BOM 的产品
========================================================*/
SELECT DISTINCT
    RTRIM(产品品号) AS 产品品号
INTO #tbMC
FROM #OrderDiff
WHERE LEN(ISNULL(RTRIM(产品品号), '')) = 12;

CREATE UNIQUE CLUSTERED INDEX IX_tbMC_产品品号 
ON #tbMC(产品品号);


/*========================================================
  4. 建立 BOM 展开结果表
========================================================*/
CREATE TABLE #BCPXJ
(
     产品品号   NVARCHAR(30)      NULL
    ,材料品号   NVARCHAR(30)      NULL
    ,材料品名   NVARCHAR(255)     NULL
    ,材料规格   NVARCHAR(255)     NULL
    ,单位用量   DECIMAL(38,10)    NULL
);


/*========================================================
  5. 循环调用 Fn_GetBOMIDs_YL 展开 BOM
========================================================*/
DECLARE @产品品号 NVARCHAR(30);

WHILE EXISTS (SELECT 1 FROM #tbMC)
BEGIN
    SELECT TOP (1) 
        @产品品号 = 产品品号
    FROM #tbMC
    ORDER BY 产品品号;

    INSERT INTO #BCPXJ
    (
         产品品号
        ,材料品号
        ,材料品名
        ,材料规格
        ,单位用量
    )
    SELECT 
         @产品品号 AS 产品品号
        ,F.MD03 AS 材料品号
        ,B.MB002 AS 材料品名
        ,B.MB003 AS 材料规格
        ,CASE 
            WHEN ((F.MD01 LIKE '4%' AND F.MD13 = 'Y') OR F.MD01 NOT LIKE '4%')
                THEN CONVERT(DECIMAL(38,10), F.MD06) / NULLIF(CONVERT(DECIMAL(38,10), F.MD07), 0)
            ELSE 0
         END AS 单位用量
    FROM SDRD.dbo.Fn_GetBOMIDs_YL(@产品品号) AS F
    INNER JOIN SDRD.dbo.INVMB AS B WITH(NOLOCK)
        ON B.MB001 = F.MD03
    WHERE F.MD07 > 0;

    PRINT @产品品号;

    DELETE FROM #tbMC
    WHERE 产品品号 = @产品品号;
END;

CREATE INDEX IX_BCPXJ_产品品号 
ON #BCPXJ(产品品号);

CREATE INDEX IX_BCPXJ_材料品号 
ON #BCPXJ(材料品号);


/*========================================================
  6. 汇总材料库存、分配、在途
========================================================*/
SELECT
     M.材料品号
    ,ISNULL(KC.库存, 0) AS 库存
    ,ISNULL(FP.分配, 0) AS 分配
    ,ISNULL(ZT.在途, 0) AS 在途
INTO #MaterialStatus
FROM
(
    SELECT DISTINCT 材料品号
    FROM #BCPXJ
    WHERE ISNULL(RTRIM(材料品号), '') <> ''
) AS M
LEFT JOIN
(
    SELECT 
         MC.MC001 AS 材料品号
        ,SUM(MC.MC007) AS 库存
    FROM INVMC AS MC WITH(NOLOCK)
    INNER JOIN CMSMC AS WH WITH(NOLOCK)
        ON MC.MC002 = WH.MC001
    INNER JOIN
    (
        SELECT DISTINCT 材料品号
        FROM #BCPXJ
    ) AS BM
        ON BM.材料品号 = MC.MC001
    --WHERE WH.MC005 = 'Y'
    GROUP BY MC.MC001
) AS KC
    ON KC.材料品号 = M.材料品号
LEFT JOIN
(
    SELECT 
         TB.TB003 AS 材料品号
        ,SUM(CASE 
                WHEN TB.TB004 - TB.TB005 <= 0 THEN 0 
                ELSE TB.TB004 - TB.TB005 
             END) AS 分配
    FROM MOCTB AS TB WITH(NOLOCK)
    INNER JOIN MOCTA AS TA WITH(NOLOCK)
        ON TA.TA001 = TB.TB001
       AND TA.TA002 = TB.TB002
    INNER JOIN
    (
        SELECT DISTINCT 材料品号
        FROM #BCPXJ
    ) AS BM
        ON BM.材料品号 = TB.TB003
    WHERE TA.TA013 = 'Y'
      AND TA.TA011 IN ('1', '2', '3')
    GROUP BY TB.TB003
) AS FP
    ON FP.材料品号 = M.材料品号
LEFT JOIN
(
    SELECT 
         TD.TD004 AS 材料品号
        ,SUM(TD.TD008 - TD.TD015) AS 在途
    FROM PURTD AS TD WITH(NOLOCK)
    INNER JOIN
    (
        SELECT DISTINCT 材料品号
        FROM #BCPXJ
    ) AS BM
        ON BM.材料品号 = TD.TD004
    WHERE TD.TD016 = 'N'
      AND TD.TD018 = 'Y'
    GROUP BY TD.TD004
) AS ZT
    ON ZT.材料品号 = M.材料品号;

CREATE UNIQUE CLUSTERED INDEX IX_MaterialStatus_材料品号
ON #MaterialStatus(材料品号);


/*========================================================
  7. 最终输出：订单差异 + 变更原因 + BOM实际用量 + 材料库存状态
========================================================*/
SELECT 
     O.客户编号
    ,O.客户简称
    ,O.部门编号
    ,O.部门名称
    ,O.订单单别
    ,O.订单单号
    ,O.订单序号
    ,O.订单日期
    ,O.变更原因

    ,O.原订单数量
    ,O.订单数量
    ,O.已交数量
    ,O.结束码
    --,O.原订单数量 - O.已交数量 AS 原订单未交差异
    --,O.原订单数量 - O.订单数量 AS 订单数量差异

    ,O.产品品号
    ,O.产品品名
    ,O.产品规格
    ,O.产品单位

    ,B.材料品号
    ,B.材料品名
    ,B.材料规格
    ,B.单位用量

    --,CONVERT(DECIMAL(38,6), O.订单数量 * ISNULL(B.单位用量, 0)) AS 实际用量

    ,ISNULL(S.在途, 0) AS 在途
    ,ISNULL(S.库存, 0) AS 库存
    ,ISNULL(S.分配, 0) AS 分配
FROM #OrderDiff AS O
LEFT JOIN #BCPXJ AS B
    ON RTRIM(O.产品品号) = RTRIM(B.产品品号)
LEFT JOIN #MaterialStatus AS S
    ON S.材料品号 = B.材料品号
WHERE LEFT(B.材料品号, 1) IN ('3', '5', '6', '7')
ORDER BY 
     O.订单日期
    ,O.订单单别
    ,O.订单单号
    ,O.订单序号
    ,B.材料品号;

    --=SUMIFS(Sheet3!I:I,Sheet3!C:C,TRIM(P2))