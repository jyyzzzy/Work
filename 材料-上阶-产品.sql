SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#CL') IS NOT NULL DROP TABLE #CL;
IF OBJECT_ID('tempdb..#DIRECT') IS NOT NULL DROP TABLE #DIRECT;
IF OBJECT_ID('tempdb..#CUR') IS NOT NULL DROP TABLE #CUR;
IF OBJECT_ID('tempdb..#NEXT') IS NOT NULL DROP TABLE #NEXT;
IF OBJECT_ID('tempdb..#RESULT') IS NOT NULL DROP TABLE #RESULT;


/*==============================================================
  1. 起始材料
==============================================================*/
SELECT DISTINCT
       CAST(RTRIM(ITEMNO) AS CHAR(20)) AS 材料品号
INTO #CL
FROM LSSJ..ITEMTMP
WHERE ITEMNO IS NOT NULL
  AND LEN(RTRIM(ITEMNO)) = 12;

CREATE UNIQUE CLUSTERED INDEX IX_CL
ON #CL(材料品号);


/*==============================================================
  2. 材料真正的直接上阶

  这里只认：

      BOMMD.MD003 = 材料
      BOMMD.MD001 = 直接上阶

  不判断 MD001 是 2、4 或其他。
==============================================================*/
CREATE TABLE #DIRECT
(
    材料品号         CHAR(20) NOT NULL,
    材料上阶品号     CHAR(20) NOT NULL,
    上阶BOM序号      CHAR(4) NOT NULL,
    材料对上阶用量   DECIMAL(38,12) NOT NULL,
    插件位置         VARCHAR(4000) NULL,
    工艺编号         CHAR(4) NULL
);


INSERT INTO #DIRECT
(
    材料品号,
    材料上阶品号,
    上阶BOM序号,
    材料对上阶用量,
    插件位置,
    工艺编号
)
SELECT
    CL.材料品号,
    MD.MD001,
    MD.MD002,

    CAST(MD.MD006 AS DECIMAL(38,12))
    /
    CAST(MD.MD007 AS DECIMAL(38,12)),

    MD.MD019,
    MD.MD009

FROM #CL CL

JOIN SDRD.dbo.BOMMD MD
  ON MD.MD003 = CL.材料品号

WHERE MD.MD007 > 0;


/* 这里绝对不要加：
   MD001 LIKE '4%' AND MD013='Y'
*/


CREATE INDEX IX_DIRECT_PARENT
ON #DIRECT(材料上阶品号);

CREATE INDEX IX_DIRECT_MATERIAL
ON #DIRECT(材料品号);


/*==============================================================
  3. 当前展开层
==============================================================*/
CREATE TABLE #CUR
(
    材料品号       CHAR(20) NOT NULL,
    材料上阶品号   CHAR(20) NOT NULL,
    上阶BOM序号    CHAR(4) NOT NULL,

    当前品号       CHAR(20) NOT NULL,

    累计用量       DECIMAL(38,12) NOT NULL,
    层级           INT NOT NULL
);


CREATE TABLE #NEXT
(
    材料品号       CHAR(20) NOT NULL,
    材料上阶品号   CHAR(20) NOT NULL,
    上阶BOM序号    CHAR(4) NOT NULL,

    当前品号       CHAR(20) NOT NULL,

    累计用量       DECIMAL(38,12) NOT NULL,
    层级           INT NOT NULL
);


CREATE TABLE #RESULT
(
    材料品号       CHAR(20) NOT NULL,
    材料上阶品号   CHAR(20) NOT NULL,
    上阶BOM序号    CHAR(4) NOT NULL,

    产品品号       CHAR(20) NOT NULL,

    累计用量       DECIMAL(38,12) NOT NULL,
    层级           INT NOT NULL
);


/*==============================================================
  4. 从材料直接上阶开始往上找

  如果：

  100...
    ↓
  210...
    ↓
  400...
    ↓
  300...

  初始状态就是：

  材料       = 300...
  材料上阶   = 400...
  当前品号   = 400...
==============================================================*/
INSERT INTO #CUR
(
    材料品号,
    材料上阶品号,
    上阶BOM序号,
    当前品号,
    累计用量,
    层级
)
SELECT
    材料品号,
    材料上阶品号,
    上阶BOM序号,

    材料上阶品号,

    材料对上阶用量,

    1
FROM #DIRECT;


CREATE INDEX IX_CUR_CURRENT
ON #CUR(当前品号);


/*==============================================================
  5. 逐层反向上展
==============================================================*/
DECLARE @Level INT = 1;
DECLARE @Rows INT;
DECLARE @MaxLevel INT = 20;


WHILE @Level <= @MaxLevel
BEGIN

    /* 当前品号已经是产品 */
    INSERT INTO #RESULT
    (
        材料品号,
        材料上阶品号,
        上阶BOM序号,
        产品品号,
        累计用量,
        层级
    )
    SELECT
        材料品号,
        材料上阶品号,
        上阶BOM序号,
        当前品号,
        累计用量,
        层级
    FROM #CUR
    WHERE LEFT(当前品号, 1) IN ('1', 'A');


    TRUNCATE TABLE #NEXT;


    /*----------------------------------------------------------
      当前品号作为 BOM 子件，继续查它被哪些父件使用

      MD003 = 当前品号
      MD001 = 下一层父件
    ----------------------------------------------------------*/
    INSERT INTO #NEXT
    (
        材料品号,
        材料上阶品号,
        上阶BOM序号,
        当前品号,
        累计用量,
        层级
    )
    SELECT
        CUR.材料品号,

        /* 永远保持第一跳，不修改 */
        CUR.材料上阶品号,
        CUR.上阶BOM序号,

        /* 向上移动 */
        MD.MD001,

        SUM
        (
            CUR.累计用量
            *
            (
                CAST(MD.MD006 AS DECIMAL(38,12))
                /
                CAST(MD.MD007 AS DECIMAL(38,12))
            )
        ),

        CUR.层级 + 1

    FROM #CUR CUR

    JOIN SDRD.dbo.BOMMD MD
      ON MD.MD003 = CUR.当前品号

    WHERE LEFT(CUR.当前品号, 1) NOT IN ('1', 'A')
      AND MD.MD007 > 0

    GROUP BY
        CUR.材料品号,
        CUR.材料上阶品号,
        CUR.上阶BOM序号,
        MD.MD001,
        CUR.层级;


    SET @Rows = @@ROWCOUNT;

    IF @Rows = 0
        BREAK;


    TRUNCATE TABLE #CUR;


    INSERT INTO #CUR
    (
        材料品号,
        材料上阶品号,
        上阶BOM序号,
        当前品号,
        累计用量,
        层级
    )
    SELECT
        材料品号,
        材料上阶品号,
        上阶BOM序号,
        当前品号,
        累计用量,
        层级
    FROM #NEXT;


    SET @Level = @Level + 1;

END;


/*==============================================================
  6. 最终输出
==============================================================*/
SELECT
    RTRIM(R.产品品号) AS 产品品号,
    P.MB002 AS 产品名称,
    P.MB003 AS 产品规格,
    P.MB109 AS 产品关闭,

    /* 材料真正直接上阶 */
    RTRIM(R.材料上阶品号) AS 上阶品号,
    SJ.MB002 AS 上阶名称,
    SJ.MB003 AS 上阶规格,
    SJ.MB109 AS 上阶关闭,

    RTRIM(R.材料品号) AS 材料品号,
    CL.MB002 AS 材料品名,
    CL.MB003 AS 材料规格,
    CL.MB109 AS 材料关闭,

    CAST
    (
        SUM(R.累计用量)
        AS DECIMAL(38,8)
    ) AS 物料用量,

    CAST(CL.MB433 AS DECIMAL(18,6)) AS 拼板数,

    D.插件位置,

    MW.MW002 AS 工艺,

    MIN(R.层级) AS BOM层级

FROM #RESULT R

JOIN SDRD.dbo.INVMB P
  ON P.MB001 = R.产品品号

JOIN SDRD.dbo.INVMB SJ
  ON SJ.MB001 = R.材料上阶品号

JOIN SDRD.dbo.INVMB CL
  ON CL.MB001 = R.材料品号

JOIN #DIRECT D
  ON D.材料品号     = R.材料品号
 AND D.材料上阶品号 = R.材料上阶品号
 AND D.上阶BOM序号  = R.上阶BOM序号

LEFT JOIN SDRD.dbo.CMSMW MW
  ON MW.MW001 = D.工艺编号

GROUP BY
    R.产品品号,
    P.MB002,
    P.MB003,
    P.MB109,

    R.材料上阶品号,
    SJ.MB002,
    SJ.MB003,
    SJ.MB109,

    R.材料品号,
    CL.MB002,
    CL.MB003,
    CL.MB109,
    CL.MB433,

    D.插件位置,
    MW.MW002

ORDER BY
    R.材料品号,
    R.材料上阶品号,
    R.产品品号;