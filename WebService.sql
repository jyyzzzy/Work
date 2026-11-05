SELECT *FROM RDSJK..SysDataStructHead WHERE SystemName='DataSyncService'  AND StructName='UpdateCOP_KPM'
--UPDATE  RDSJK..SysDataStructHead SET Approve='N' WHERE SystemName='DataSyncService'  AND StructName='INVTA'
SELECT *FROM RDSJK..SysDataStructDetail WHERE SystemName='DataSyncService'  AND StructName='UpdateCOP_KPM'


SELECT *FROM RDSJK..SysDataStructHead WHERE SystemName='DataSyncService'  AND StructName='COPTA'
--UPDATE  RDSJK..SysDataStructHead SET Approve='Y' WHERE SystemName='DataSyncService'  AND StructName='COPTA'
SELECT *FROM RDSJK..SysDataStructDetail WHERE SystemName='DataSyncService'  AND StructName='COPTA'


/*========================================================
  COPTA + COPTB 增加 YNRD、RDZNCS
========================================================*/

----------------------------------------------------------
-- COPTA 单头
----------------------------------------------------------

-- Add / Sel 可用账套
UPDATE RDSJK..SysDataStructHead
SET CompanyEnum = 'RDCS|RDtest|AHRDBAK|AHRD|ZJRD|SDRD|YNRD|RDZNCS'
WHERE SystemName = 'DataSyncService'
  AND StructName = 'COPTA';

-- COPTA 账套对应 COMPANY
UPDATE RDSJK..SysDataStructHead
SET CompID = 'SDRD,0001|ZJRD,0006|AHRD,0011|RDCS,RDCS|AHRDBAK,0016|ZJRDBAK,0015|YNRD,YNRD|RDZNCS,RDZNCS'
WHERE SystemName = 'DataSyncService'
  AND StructName = 'COPTA';

-- COPTA COMPANY 字段映射
UPDATE RDSJK..SysDataStructDetail
SET Arg = 'SDRD,0001|ZJRD,0006|AHRD,0011|RDCS,RDCS|AHRDBAK,0016|YNRD,YNRD|RDZNCS,RDZNCS'
WHERE SystemName = 'DataSyncService'
  AND StructName = 'COPTA'
  AND Type = 'Add'
  AND FieldName = 'COMPANY';


----------------------------------------------------------
-- COPTB 单身
----------------------------------------------------------

-- Add / Sel 可用账套
UPDATE RDSJK..SysDataStructHead
SET CompanyEnum = 'RDCS|RDtest|AHRDBAK|AHRD|ZJRD|SDRD|YNRD|RDZNCS'
WHERE SystemName = 'DataSyncService'
  AND StructName = 'COPTB';

-- COPTB COMPANY 字段映射
UPDATE RDSJK..SysDataStructDetail
SET Arg = 'SDRD,0001|ZJRD,0006|AHRD,0011|RDCS,RDCS|AHRDBAK,0016|YNRD,YNRD|RDZNCS,RDZNCS'
WHERE SystemName = 'DataSyncService'
  AND StructName = 'COPTB'
  AND Type = 'Add'
  AND FieldName = 'COMPANY';


----------------------------------------------------------
-- 检查结果
----------------------------------------------------------

SELECT
    SystemName,
    Type,
    StructName,
    CompanyEnum,
    CompID
FROM RDSJK..SysDataStructHead
WHERE SystemName = 'DataSyncService'
  AND StructName IN ('COPTA', 'COPTB');

SELECT
    SystemName,
    Type,
    StructName,
    FieldName,
    MothodName,
    Arg
FROM RDSJK..SysDataStructDetail
WHERE SystemName = 'DataSyncService'
  AND StructName IN ('COPTA', 'COPTB')
  AND FieldName = 'COMPANY';