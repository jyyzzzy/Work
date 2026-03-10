/******插入调拨单******/

SELECT * FROM LSSJ..TmpItemTransfer
DELETE FROM LSSJ..TmpItemTransfer
--="INSERT INTO LSSJ..TmpItemTransfer(ItemCode,FromWarehouse,ToWarehouse,TransferQty) VALUES('"&&"','"&&"','"&&"',"&&");"
INSERT INTO [dbo].[INVTB]
           ([COMPANY]
           ,[CREATOR]
           ,[USR_GROUP]
           ,[CREATE_DATE]
           ,[MODIFIER]
           ,[MODI_DATE]
           ,[FLAG]
           ,[TB001]
           ,[TB002]
           ,[TB003]
           ,[TB004]
           ,[TB005]
           ,[TB006]
           ,[TB007]
           ,[TB008]
           ,[TB009]
           ,[TB010]
           ,[TB011]
           ,[TB012]
           ,[TB013]
           ,[TB014]
           ,[TB015]
           ,[TB016]
           ,[TB017]
           ,[TB018]
           ,[TB019]
           ,[TB020]
           ,[TB021]
           ,[TB022]
           ,[TB023]
           ,[TB024]
           ,[TB025]
           ,[TB026]
           ,[TB027]
           ,[TB028]
           ,[TB029]
           ,[TB030]
           ,[TB031]
           ,[TB032]
           ,[TB033]
           ,[TB034]
           ,[TB035]
           ,[TB036]
           ,[TB037]
           ,[UDF01]
           ,[UDF02]
           ,[UDF03]
           ,[UDF04]
           ,[UDF05]
           ,[UDF06]
           ,[UDF51]
           ,[UDF52]
           ,[UDF53]
           ,[UDF54]
           ,[UDF55]
           ,[UDF56])
SELECT
      '0001' AS [COMPANY]                 -- char(10)
    , '10105978' AS [CREATOR]             -- char(10)
    , '90001' AS [USR_GROUP]             -- char(10)
    , FORMAT(GETDATE(), 'yyyyMMddHHmmssfff') AS [CREATE_DATE]  -- char(17)
    , '' AS [MODIFIER]                    -- char(10)
    , '' AS [MODI_DATE]                   -- char(17)
    , 1  AS [FLAG]                        -- numeric(3,0)
    , '1201' AS [TB001]                   -- char(4)
    , '20260326001' AS [TB002]            -- char(11)
    , RIGHT('0000' + CAST(
          ROW_NUMBER() OVER (
              ORDER BY IT.ItemCode, IT.FromWarehouse, IT.ToWarehouse
          ) AS varchar(4)
      ), 4) AS [TB003]                    -- char(4) 序号，从 0001 开始
    , IT.ItemCode AS [TB004]              -- char(20)
    , MB002 AS [TB005]                       -- varchar(60)
    , MB003 AS [TB006]                       -- varchar(60)
    , IT.TransferQty  AS [TB007]                       -- numeric(15,6)
    , MB004 AS [TB008]                       -- char(4)
    , IT.TransferQty  AS [TB009]          -- numeric(15,6)
    , MB057  AS [TB010]                       -- numeric(17,8)
    , CAST(IT.TransferQty*MB057 AS NUMERIC(15,2)) AS [TB011]                       -- numeric(15,2)
    , IT.FromWarehouse AS [TB012]         -- char(10)
    , IT.ToWarehouse AS [TB013]           -- char(10)
    , '********************' AS [TB014]                       -- char(20)
    , '' AS [TB015]                       -- char(8)
    , '' AS [TB016]                       -- char(8)
    , '' AS [TB017]                       -- varchar(255)
    , 'N' AS [TB018]                       -- char(1)
    , '20260326' AS [TB019]                       -- char(8)
    , MB072 AS [TB020]                       -- char(4)
    , '' AS [TB021]                       -- char(20)
    , 0  AS [TB022]                       -- numeric(15,6)
    , MB090 AS [TB023]                       -- char(4)
    , MC003 AS [TB024]                       -- char(20)
    , 0  AS [TB025]                       -- numeric(15,6)
    , 0  AS [TB026]                       -- numeric(15,6)
    , 0  AS [TB027]                       -- numeric(15,6)
    , '' AS [TB028]                       -- varchar(80)
    , '##########' AS [TB029]                       -- char(10)
    , '##########' AS [TB030]                       -- char(10)
    , '' AS [TB031]                       -- char(8)
    , '' AS [TB032]                       -- char(1)
    , '' AS [TB033]                       -- char(8)
    , '' AS [TB034]                       -- varchar(30)
    , 0  AS [TB035]                       -- numeric(13,2)
    , 0  AS [TB036]                       -- numeric(13,2)
    , 0  AS [TB037]                       -- numeric(13,2)
    , '' AS [UDF01]                       -- varchar(255)
    , '' AS [UDF02]                       -- varchar(255)
    , '' AS [UDF03]                       -- varchar(255)
    , '' AS [UDF04]                       -- varchar(255)
    , '' AS [UDF05]                       -- varchar(255)
    , '' AS [UDF06]                       -- varchar(255)
    , 0  AS [UDF51]                       -- numeric(15,6)
    , 0  AS [UDF52]                       -- numeric(15,6)
    , 0  AS [UDF53]                       -- numeric(15,6)
    , 0  AS [UDF54]                       -- numeric(15,6)
    , 0  AS [UDF55]                       -- numeric(15,6)
    , 0  AS [UDF56]                       -- numeric(15,6)
FROM LSSJ..TmpItemTransfer AS IT
LEFT OUTER JOIN INVMB ON MB001 = IT.ItemCode
LEFT OUTER JOIN INVMC ON MC001 = IT.ItemCode AND MC002 = IT.FromWarehouse
;

GO
--SELECT * FROM INVTB WHERE TB001 = '1201' AND TB002 = '20260326001'



INSERT INTO [dbo].[INVTA]
           ([COMPANY]
           ,[CREATOR]
           ,[USR_GROUP]
           ,[CREATE_DATE]
           ,[MODIFIER]
           ,[MODI_DATE]
           ,[FLAG]
           ,[TA001]
           ,[TA002]
           ,[TA003]
           ,[TA004]
           ,[TA005]
           ,[TA006]
           ,[TA007]
           ,[TA008]
           ,[TA009]
           ,[TA010]
           ,[TA011]
           ,[TA012]
           ,[TA013]
           ,[TA014]
           ,[TA015]
           ,[TA016]
           ,[TA017]
           ,[TA018]
           ,[TA019]
           ,[TA020]
           ,[TA021]
           ,[TA022]
           ,[TA023]
           ,[TA024]
           ,[TA025]
           ,[TA026]
           ,[TA027]
           ,[TA028]
           ,[TA029]
           ,[TA030]
           ,[TA031]
           ,[UDF01]
           ,[UDF02]
           ,[UDF03]
           ,[UDF04]
           ,[UDF05]
           ,[UDF06]
           ,[UDF51]
           ,[UDF52]
           ,[UDF53]
           ,[UDF54]
           ,[UDF55]
           ,[UDF56])
SELECT
      '0001'                       AS [COMPANY]      -- char(10)
    , '10105978'                       AS [CREATOR]      -- char(10)
    , '90001'                     AS [USR_GROUP]    -- char(10)
    , FORMAT(GETDATE(),'yyyyMMddHHmmssfff') AS [CREATE_DATE]  -- char(17)
    , ''                              AS [MODIFIER]     -- char(10)
    , ''                              AS [MODI_DATE]    -- char(17)
    , 1                               AS [FLAG]         -- numeric(3,0)
    , B.TB001                         AS [TA001]        -- char(4)  调拨单别
    , B.TB002                         AS [TA002]        -- char(11) 调拨单号
    , '20260326'  AS [TA003]        -- char(8)  单据日期
    , '120800'                              AS [TA004]        -- char(6)
    , ''                              AS [TA005]        -- varchar(255)
    , 'N'                              AS [TA006]        -- char(1)
    , 0                               AS [TA007]        -- numeric(1,0)
    , '000101'                              AS [TA008]        -- char(6)
    , '12'                              AS [TA009]        -- char(2)
    , 0                               AS [TA010]        -- numeric(5,0)
    , B.TB007                               AS [TA011]        -- numeric(15,6)
    , B.TB011                               AS [TA012]        -- numeric(15,2)
    , 'N'                              AS [TA013]        -- char(1)
    , '20260326'                              AS [TA014]        -- char(8)
    , ''                              AS [TA015]        -- char(10)
    , TB022                               AS [TA016]        -- numeric(15,6)
    , 'N'                              AS [TA017]        -- char(1)
    , ''                              AS [TA018]        -- char(15)
    , ''                              AS [TA019]        -- varchar(255)
    , ''                              AS [TA020]        -- varchar(255)
    , 0                               AS [TA021]        -- numeric(1,0)
    , ''                              AS [TA022]        -- char(12)
    , ''                              AS [TA023]        -- char(10)
    , ''                              AS [TA024]        -- char(12)
    , '1'                              AS [TA025]        -- char(1)
    , ''                              AS [TA026]        -- char(1)
    , ''                              AS [TA027]        -- char(8)
    , ''                              AS [TA028]        -- varchar(30)
    , 0                               AS [TA029]        -- numeric(13,2)
    , 0                               AS [TA030]        -- numeric(13,2)
    , 0                               AS [TA031]        -- numeric(13,2)
    , ''                              AS [UDF01]        -- varchar(255)
    , ''                              AS [UDF02]        -- varchar(255)
    , ''                              AS [UDF03]        -- varchar(255)
    , ''                              AS [UDF04]        -- varchar(255)
    , ''                              AS [UDF05]        -- varchar(255)
    , ''                              AS [UDF06]        -- varchar(255)
    , 0                               AS [UDF51]        -- numeric(15,6)
    , 0                               AS [UDF52]        -- numeric(15,6)
    , 0                               AS [UDF53]        -- numeric(15,6)
    , 0                               AS [UDF54]        -- numeric(15,6)
    , 0                               AS [UDF55]        -- numeric(15,6)
    , 0                               AS [UDF56]        -- numeric(15,6)
FROM (
    -- 一张单据头对应多行明细时，用 DISTINCT/分组保证每个单号只插一条头
    SELECT COMPANY, CREATOR, USR_GROUP, TB001, TB002,SUM(TB007) AS TB007,SUM(TB011) AS TB011,SUM(TB022) AS TB022
    FROM   dbo.INVTB
    WHERE TB001 = '1201' AND TB002 = '20260326001'
    GROUP BY COMPANY, CREATOR, USR_GROUP, TB001, TB002
) AS B;