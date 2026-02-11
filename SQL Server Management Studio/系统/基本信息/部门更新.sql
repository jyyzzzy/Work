DELETE FROM LSSJ..zjcgrk
="INSERT INTO LSSJ..zjcgrk(cgdh, 供应商) VALUES('"&&"','"&&"')"

UPDATE COPTI
SET TI005 = 供应商
SELECT *
FROM COPTI 
INNER JOIN LSSJ..zjcgrk ON TI001 + '-'+ TI002 = LEFT(cgdh,16)