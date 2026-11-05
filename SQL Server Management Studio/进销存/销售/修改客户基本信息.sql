/******修改客户基本信息******/--Modify customer basic info
--CREATE AT 20251129 BY ZIYANG ZHANG
SELECT * FROM COPMA
CREATE TABLE LSSJ..CustomerBasic (
    custNo        CHAR(10),   -- 客户编号-- Customer Number (CUST_NO)
    custShortName CHAR(20),   -- 客户简称 Customer Short Name (CUST_SHORT_NAME)
    custFullName  CHAR(72),   -- 客户全称 Customer Full Name (CUST_FULL_NAME)
    salesRepNo        CHAR(10),   -- 业务人员编号 Sales Representative Number (SALES_REP_NO)
    salesRepName      CHAR(10)    -- 业务人员名称 Sales Representative Name (SALES_REP_NAME)
);

ALTER TABLE LSSJ..CustomerBasic
ADD
    deptNo   CHAR(10) NULL,  -- 部门编号 Department Number (DEPT_NO)
    deptName CHAR(10) NULL;  -- 部门名称 Department Name (DEPT_NAME)

DELETE FROM LSSJ..CustomerBasic
SELECT * FROM LSSJ..CustomerBasic 

WHERE salesRepNo IS NULL
ORDER BY custNo
--="INSERT INTO LSSJ..CustomerBasic(custNo,custShortName,salesRepName) VALUES('"&&"','"&&"','"&&"');"
--="INSERT INTO LSSJ..CustomerBasic(custNo,salesRepNo,deptNo) VALUES('"&&"','"&&"','"&&"');"
--="INSERT INTO LSSJ..CustomerBasic(custNo,salesRepNo) VALUES('"&&"','"&&"');"
--="INSERT INTO LSSJ..CustomerBasic(custNo,deptNo) VALUES('"&&"','"&&"');"
--UPDATE CB
--SET CB.custNo = MA001
--FROM LSSJ..CustomerBasic AS CB
--INNER JOIN COPMA ON MA002 = CB.custShortName

--UPDATE CB
--SET CB.salesRepNo = MV001
----SELECT MJ002
--FROM LSSJ..CustomerBasic AS CB
--INNER JOIN CMSMV ON MV002 = CB.salesRepName
--INNER JOIN CMSMK ON MK002 = MV001
--INNER JOIN CMSMJ ON MK001 = MJ001 AND MJ002 = '3'

--UPDATE CB
--SET CB.salesRepNo = ''
--FROM LSSJ..CustomerBasic AS CB
--WHERE CB.salesRepNo IS NULL


DELETE FROM LSSJ..CustomerBasic

UPDATE COPMA 
SET 
--SELECT
--MA001,
--MA015 = CB.deptNo,
MA016 = CB.salesRepNo,
MA085 = CB.salesRepNo
FROM COPMA 
INNER JOIN LSSJ..CustomerBasic AS CB ON CB.custNo = MA001
WHERE --MA015 <> CB.deptNo OR 
MA016 <> CB.salesRepNo OR 
MA085 <> CB.salesRepNo