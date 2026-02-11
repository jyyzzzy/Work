SELECT 
	MB001 品号,
	MB002 品名,
	MB003 规格,
	MB004 单位,
	MB005 会计分类,
	MB006 仓管分类,
	MB007 商品分类,
	MB008 生管分类
FROM INVMB 
WHERE 
--NOT EXISTS(
--	SELECT 1 FROM INVMA WHERE MA002 = MB005
--)
--OR NOT EXISTS(
--	SELECT 1 FROM INVMA WHERE MA002 = MB006
--)
--OR 
NOT EXISTS(
	SELECT 1 FROM INVMA WHERE MA002 = MB007
)
--OR NOT EXISTS(
--	SELECT 1 FROM INVMA WHERE MA002 = MB008
--)

UPDATE INVMB
SET MB005 = I.ItemCategoryCode_Accounting,
MB006 = I.ItemCategoryCode_Warehouse,
MB007 = I.ItemCategoryCode_Product,
MB008 = I.ItemCategoryCode_ProductionControl
FROM INVMB 
INNER JOIN LSSJ..ItemMaster AS I ON I.ItemCode = MB001
WHERE MB005 <> I.ItemCategoryCode_Accounting
OR MB006 <> I.ItemCategoryCode_Warehouse
OR MB007 <> I.ItemCategoryCode_Product
OR MB008 <> I.ItemCategoryCode_ProductionControl


CREATE TABLE LSSJ..ItemMaster
(
    ItemCode CHAR(20)     COLLATE Chinese_PRC_BIN NOT NULL,
    ItemName VARCHAR(60)  COLLATE Chinese_PRC_BIN NULL,
    ItemSpecification VARCHAR(60)  COLLATE Chinese_PRC_BIN NULL,
    UnitOfMeasure CHAR(4)      COLLATE Chinese_PRC_BIN NULL,
    ItemCategoryCode_Accounting CHAR(6)      COLLATE Chinese_PRC_BIN NULL,
    ItemCategoryCode_Warehouse CHAR(6)      COLLATE Chinese_PRC_BIN NULL,
    ItemCategoryCode_Product CHAR(6)      COLLATE Chinese_PRC_BIN NULL,
    ItemCategoryCode_ProductionControl CHAR(6)      COLLATE Chinese_PRC_BIN NULL
);
--="INSERT INTO LSSJ..ItemMaster(ItemCode,ItemCategoryCode_Accounting,ItemCategoryCode_Warehouse,ItemCategoryCode_Product,ItemCategoryCode_ProductionControl) VALUES('"&&"','"&&"','"&&"','"&&"','"&&"')"