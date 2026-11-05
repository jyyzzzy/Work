select rtrim(MC001) ,MC002,LEFT(UDF01,4),UDF01 from  CMSMC where MC004 = '1'




SELECT  SYB,SUM(PRODUCTCOST) FROM (
SELECT C.TA003+'-'+C.TA004 AS TA003C,(C.TA026+C.TA027+C.TA028+C.TA029) AS PRODUCTCOST, M.TA020 AS TA36789, LEFT(MD011,4) SYB,MD002
FROM CSTTA AS  C 
LEFT JOIN MOCTA AS M ON M.TA001=C.TA003 AND M.TA002=C.TA004 LEFT JOIN INVMB AS INVMB ON MB001=C.TA001 LEFT JOIN CMSMF AS CMSMF ON MF001= 'RMB' 
LEFT JOIN CMSMD ON M.TA021=MD001

WHERE (C.TA002='202610' AND (C.TA023<>0 OR C.TA024<>0 OR C.TA031<>0 OR C.TA026<>0 OR C.TA027<>0 OR C.TA028<>0 OR C.TA029<>0)) 

) AS B GROUP BY SYB


SELECT  SYB,SUM(PRODUCTCOST) FROM (
SELECT C.TA003+'-'+C.TA004 AS TA003C,(C.TA025) AS PRODUCTCOST, M.TA020 AS TA36789, LEFT(MD011,4) SYB,MD002
FROM CSTTA AS  C 
LEFT JOIN MOCTA AS M ON M.TA001=C.TA003 AND M.TA002=C.TA004 LEFT JOIN INVMB AS INVMB ON MB001=C.TA001 LEFT JOIN CMSMF AS CMSMF ON MF001= 'RMB' 
LEFT JOIN CMSMD ON M.TA021=MD001

WHERE (C.TA002='202610' AND (C.TA023<>0 OR C.TA024<>0 OR C.TA031<>0 OR C.TA026<>0 OR C.TA027<>0 OR C.TA028<>0 OR C.TA029<>0)) 

) AS B GROUP BY SYB


SELECT SYB,SUM(PRODUCTCOST) FROM (
SELECT C.TA003+'-'+C.TA004 AS TA003C,(C.TA026+C.TA027+C.TA028+C.TA029) AS PRODUCTCOST, M.TA020 AS TA36789, LEFT(CMSMC.UDF01,4) SYB
FROM AHRD..CSTTA AS  C 
LEFT JOIN AHRD..MOCTA AS M ON M.TA001=C.TA003 AND M.TA002=C.TA004 LEFT JOIN AHRD..INVMB AS INVMB ON MB001=C.TA001 LEFT JOIN AHRD..CMSMF AS CMSMF ON MF001= 'RMB' 
LEFT JOIN AHRD..CMSMC ON M.TA020=MC001

WHERE (C.TA002='202610' AND (C.TA023<>0 OR C.TA024<>0 OR C.TA031<>0 OR C.TA026<>0 OR C.TA027<>0 OR C.TA028<>0 OR C.TA029<>0)) 

) AS B GROUP BY SYB


SELECT SYB,SUM(PRODUCTCOST) FROM (
SELECT C.TA003+'-'+C.TA004 AS TA003C,(C.TA026+C.TA027+C.TA028+C.TA029) AS PRODUCTCOST, M.TA020 AS TA36789, LEFT(CMSMC.UDF01,4) SYB
FROM ZJRD..CSTTA AS  C 
LEFT JOIN ZJRD..MOCTA AS M ON M.TA001=C.TA003 AND M.TA002=C.TA004 LEFT JOIN ZJRD..INVMB AS INVMB ON MB001=C.TA001 LEFT JOIN ZJRD..CMSMF AS CMSMF ON MF001= 'RMB' 
LEFT JOIN ZJRD..CMSMC on M.TA020=MC001

WHERE (C.TA002='202610' AND (C.TA023<>0 OR C.TA024<>0 OR C.TA031<>0 OR C.TA026<>0 OR C.TA027<>0 OR C.TA028<>0 OR C.TA029<>0)) 

) AS B GROUP BY SYB


SELECT SYB,SUM(PRODUCTCOST)/3500 FROM (
SELECT C.TA003+'-'+C.TA004 AS TA003C,(C.TA026+C.TA027+C.TA028+C.TA029) AS PRODUCTCOST, M.TA020 AS TA36789, LEFT(CMSMC.UDF01,4) SYB
FROM YNRD..CSTTA AS  C 
LEFT JOIN YNRD..MOCTA AS M ON M.TA001=C.TA003 AND M.TA002=C.TA004 LEFT JOIN YNRD..INVMB AS INVMB ON MB001=C.TA001 LEFT JOIN YNRD..CMSMF AS CMSMF ON MF001= 'RMB' 
LEFT JOIN YNRD..CMSMC ON M.TA020=MC001

WHERE (C.TA002='202610' AND (C.TA023<>0 OR C.TA024<>0 OR C.TA031<>0 OR C.TA026<>0 OR C.TA027<>0 OR C.TA028<>0 OR C.TA029<>0)) 

) AS B GROUP BY SYB






SELECT LEFT(MD011, CHARINDEX('-', MD011 + '-') - 1) 事业部,M.TA001 工单单别,M.TA002 工单单号,M.TA006 产品品号,M.TA034 产品品名,M.TA035 产品规格,(C.TA026+C.TA027+C.TA028+C.TA029) AS 在产金额,
M.TA015 预计产量,M.TA017 已生产量,M.TA021 工作中心,CMSMD.MD002 工作中心名称,M.TA026 订单单别,M.TA027 订单单号--,M.TA010 预计完工,M.TA014 实际完工,M.TA011 状态码
FROM CSTTA AS  C 
LEFT JOIN MOCTA AS M ON M.TA001=C.TA003 AND M.TA002=C.TA004 LEFT JOIN INVMB AS INVMB ON MB001=C.TA001 LEFT JOIN CMSMF AS CMSMF ON MF001= 'RMB' 
LEFT JOIN CMSMD ON M.TA021=MD001
WHERE (C.TA002='202610' AND (C.TA023<>0 OR C.TA024<>0 OR C.TA031<>0 OR C.TA026<>0 OR C.TA027<>0 OR C.TA028<>0 OR C.TA029<>0)) 
union all

SELECT '浙江瑞德' 事业部,M.TA001 工单单别,M.TA002 工单单号,M.TA006 产品品号,M.TA034 产品品名,M.TA035 产品规格,(C.TA026+C.TA027+C.TA028+C.TA029) AS 在产金额,
M.TA015 预计产量,M.TA017 已生产量,M.TA021 工作中心,CMSMD.MD002 工作中心名称,M.TA026 订单单别,M.TA027 订单单号--,M.TA010 预计完工,M.TA014 实际完工,M.TA011 状态码
FROM ZJRD..CSTTA AS  C 
LEFT JOIN ZJRD..MOCTA AS M ON M.TA001=C.TA003 AND M.TA002=C.TA004 LEFT JOIN ZJRD..INVMB AS INVMB ON MB001=C.TA001 LEFT JOIN ZJRD..CMSMF AS CMSMF ON MF001= 'RMB' 
LEFT JOIN ZJRD..CMSMD ON M.TA021=MD001
WHERE (C.TA002='202610' AND (C.TA023<>0 OR C.TA024<>0 OR C.TA031<>0 OR C.TA026<>0 OR C.TA027<>0 OR C.TA028<>0 OR C.TA029<>0)) 

union all

SELECT LEFT(MD011, CHARINDEX('-', MD011 + '-') - 1) 事业部,M.TA001 工单单别,M.TA002 工单单号,M.TA006 产品品号,M.TA034 产品品名,M.TA035 产品规格,(C.TA026+C.TA027+C.TA028+C.TA029) AS 在产金额,
M.TA015 预计产量,M.TA017 已生产量,M.TA021 工作中心,CMSMD.MD002 工作中心名称,M.TA026 订单单别,M.TA027 订单单号--,M.TA010 预计完工,M.TA014 实际完工,M.TA011 状态码
FROM AHRD..CSTTA AS  C 
LEFT JOIN AHRD..MOCTA AS M ON M.TA001=C.TA003 AND M.TA002=C.TA004 LEFT JOIN AHRD..INVMB AS INVMB ON MB001=C.TA001 LEFT JOIN AHRD..CMSMF AS CMSMF ON MF001= 'RMB' 
LEFT JOIN AHRD..CMSMD ON M.TA021=MD001
WHERE (C.TA002='202610' AND (C.TA023<>0 OR C.TA024<>0 OR C.TA031<>0 OR C.TA026<>0 OR C.TA027<>0 OR C.TA028<>0 OR C.TA029<>0)) 

union all

SELECT '越南瑞德' 事业部,M.TA001 工单单别,M.TA002 工单单号,M.TA006 产品品号,M.TA034 产品品名,M.TA035 产品规格,(C.TA026+C.TA027+C.TA028+C.TA029)/3500  AS 在产金额,
M.TA015 预计产量,M.TA017 已生产量,M.TA021 工作中心,CMSMD.MD002 工作中心名称,M.TA026 订单单别,M.TA027 订单单号--,M.TA010 预计完工,M.TA014 实际完工,M.TA011 状态码
FROM YNRD..CSTTA AS  C 
LEFT JOIN YNRD..MOCTA AS M ON M.TA001=C.TA003 AND M.TA002=C.TA004 LEFT JOIN YNRD..INVMB AS INVMB ON MB001=C.TA001 LEFT JOIN YNRD..CMSMF AS CMSMF ON MF001= 'RMB' 
LEFT JOIN YNRD..CMSMD ON M.TA021=MD001
WHERE (C.TA002='202610' AND (C.TA023<>0 OR C.TA024<>0 OR C.TA031<>0 OR C.TA026<>0 OR C.TA027<>0 OR C.TA028<>0 OR C.TA029<>0)) 


select CHARINDEX('-', '事业一部良品-' )

SELECT  LEFT('事业一部-良品', CHARINDEX('-', '事业一部-良品'+'-' )) AS 前面部分


SELECT *FROM  LSSJ..[LSKCB-YB]


select LA001,MB002,MB003,MB004,LA009,MC002,LA011, CASE LA011 WHEN 0 THEN 0 ELSE LA013/LA011 END ,LA013,'顺德瑞德',left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1),良品=right((CMSMC.UDF01),len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)),物料类别= case left(LA001,1) when '2' then'2半成品' when '1' then '1成品' when 'A'then '1成品' else '3原材料' end,'' from(
select RTRIM(LA001) LA001,RTRIM(LA009) LA009, SUM(CASE LA005 WHEN '1' THEN LA011 ELSE 0-LA011 END) LA011, SUM(CASE LA005 WHEN '1' THEN LA013 ELSE 0-LA013 END) LA013 FROM  SDRD..INVLA WHERE LA004 <= '20190531' GROUP BY  LA001,LA009 HAVING(SUM(CASE LA005 WHEN '1' THEN LA011 ELSE 0-LA011 END))>0 OR SUM(CASE LA005 WHEN '1' THEN LA013 ELSE 0-LA013 END)>0
) as KCMX  JOIN INVMB ON LA001=MB001 JOIN  SDRD..CMSMC on rtrim(LA009)=rtrim(MC001) where MC004 = '1' 



update  LSSJ..[LSKCB-YB] set 工厂='顺德瑞德' where isnull(工厂,'')=''

update  LSSJ..[LSKCB-YB] set 工厂='安徽瑞德' where isnull(工厂,'')=''
update  LSSJ..[LSKCB-YB] set 工厂='浙江瑞德' where isnull(工厂,'')=''

SELECT SUM(库存金额 )FROM  LSSJ..[LSKCB-YB]

SELECT *FROM     CMSMC 

select Charindex('-','事业一部-良品')
update LSSJ..[LSKCB-YB] set 月份='2月22日' WHERE  ISNULL(月份,'')=''

SELECT *FROM  LSSJ..[LSKCB-YB] JOIN SDRD..CMSMC on rtrim(仓库编号)=rtrim(MC001) where MC004 = '1' and 工厂='顺德瑞德'

UPDATE LSSJ..[LSKCB-YB] SET 经营单位= left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1),良品=right((CMSMC.UDF01),len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)),物料类别= case left(品号,1) when '2' then'2半成品' when '1' then '1成品' when 'A'then '1成品' else '3原材料' end FROM  LSSJ..[LSKCB-YB] JOIN SDRD..CMSMC on rtrim(仓库编号)=rtrim(MC001) where MC004 = '1' and 工厂='顺德瑞德'  


UPDATE LSSJ..[LSKCB-YB] SET 经营单位= left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1),良品=right((CMSMC.UDF01),len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)),物料类别= case left(品号,1) when '2' then'2半成品' when '1' then '1成品' when 'A'then '1成品' else '3原材料' end FROM  LSSJ..[LSKCB-YB] JOIN AHRD..CMSMC on rtrim(仓库编号)=rtrim(MC001) where MC004 = '1' and 工厂='安徽瑞德'

UPDATE LSSJ..[LSKCB-YB] SET 经营单位= left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1),良品=right((CMSMC.UDF01),len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)),物料类别= case left(品号,1) when '2' then'2半成品' when '1' then '1成品' when 'A'then '1成品' else '3原材料' end FROM  LSSJ..[LSKCB-YB] JOIN ZJRD..CMSMC on rtrim(仓库编号)=rtrim(MC001) where MC004 = '1' and 工厂='浙江瑞德'


SELECT *FROM  LSSJ..[LSKCB-YB] where 良品='不良品'

SELECT *FROM  LSSJ..[LSKCB-YB] where 经营单位 like '%事业一部%' 

DELETE FROM  LSSJ..[LSKCB-YB]

select cast(''+'顺德瑞德' as varchar(10)),left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1),良品=right((CMSMC.UDF01),len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)),*from SDRD..CMSMC  


select left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1),良品=right((CMSMC.UDF01),len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)),rtrim(MC001),MC002 from SDRD..CMSMC  

INSERT INTO LSSJ..[LSKCB-YB]
select LA001,MB002,MB003,MB004,LA009,MC002,LA011, CASE LA011 WHEN 0 THEN 0 ELSE LA013/LA011 END ,LA013,'顺德瑞德',left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1),良品=right((CMSMC.UDF01),len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)),物料类别= cast(case left(LA001,1) when '2' then'2半成品' when '1' then '1成品' when 'A'then '1成品' else '3原材料' end as varchar(8)),'' from(

select MB001 LA001,MC002 LA009,INVNUMA LA011,INVMONEY LA013 from  SDRD..V_KCMX  


--SELECT * FROM SDRD..V_KCMX  
--/**剔除代管料*/
--UNION ALL
--select 品号,'052',case when -sum(入库数量) >sum(库存) then -sum(库存) else sum(入库数量) end,case when -sum(入库数量) >sum(库存) then -sum(库存) else sum(入库数量) end*MAX(DJ) from(
--SELECT rtrim(TB004)  品号,-SUM(TB007) 入库数量,0 库存,MAX(MB057) DJ FROM SDRD..INVTA INNER JOIN SDRD..INVTB ON TA001 = TB001 AND TA002 = TB002
--INNER JOIN SDRD..INVMB ON MB001 = TB004 WHERE ((TA003 >='20190501' AND TA003 <= '20190531') ) AND TA001 = '1112' AND TB018 = 'Y' --AND TB004='300010053300 ' 
--GROUP BY TB004 HAVING  SUM(TB007)<>0 
--union all 
--select rtrim(MC001) 品号,0,SUM(MC007) 库存, 0 DJ  from SDRD..INVMC INV WHERE MC007>0 AND (select count(*) from SDRD..CMSMC where CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%' and CMSMC.MC001=INV.MC002)>0  and (
--select count(*) from ( SELECT rtrim(TB004)  TB004,-SUM(TB007) TB007 FROM SDRD..INVTA INNER JOIN SDRD..INVTB ON TA001 = TB001 AND TA002 = TB002
--INNER JOIN SDRD..INVMB ON MB001 = TB004 WHERE ((TA003 >='20190501' AND TA003 <= '20190531') ) AND TA001 = '1112' AND TB018 = 'Y' 
-- GROUP BY TB004 HAVING  SUM(TB007)<>0 ) as b   where TB004=MC001 --AND TB004='300010053300'
--) >0 GROUP BY  MC001 
--) dgl 
-- group by 品号

/**剔除代管料*/
) as KCMX  LEFT  JOIN SDRD..INVMB ON LA001=MB001 LEFT JOIN  SDRD..CMSMC on rtrim(LA009)=rtrim(MC001) where MC004 = '1' 

--sp_helptext V_KCMX 


delete from  LSSJ..[LSKCB-YB]

INSERT INTO LSSJ..[LSKCB-YB]

select  ltrim(LA001),MB002,MB003,MB004,LA009,MC002,LA011, CASE LA011 WHEN 0 THEN 0 ELSE LA013/LA011 END ,LA013,'浙江瑞德',

LEFT(UDF01,4)-- CASE WHEN ISNUMERIC( CHARINDEX('-',UDF01))=1 THEN CHARINDEX('-',UDF01) ELSE 1 END-1 ) 
,良品=right((UDF01),len(UDF01)-Charindex('-',UDF01)),物料类别= case left(LA001,1) when '2' then'2半成品' when '1' then '1成品' when 'A'then '1成品' else '3原材料' end,'' 

FROM(
	SELECT LA001,MB002,MB003,MB004,LA009,MC002,LA011  ,LA013,CMSMC.UDF01
	FROM(
	select MB001 LA001,MC002 LA009,INVNUMA LA011,INVMONEY LA013 from  ZJRD..V_KCMX  
	) as KCMX  JOIN ZJRD..INVMB ON LA001=MB001 JOIN  ZJRD..CMSMC on rtrim(LA009)=rtrim(MC001) where MC004 = '1'
) KC

INSERT INTO LSSJ..[LSKCB-YB]
select  ltrim(LA001),MB002,MB003,MB004,LA009,MC002,LA011, CASE LA011 WHEN 0 THEN 0 ELSE LA013/LA011 END ,LA013,'安徽瑞德',left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1),良品=right((CMSMC.UDF01),len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)),物料类别= case left(LA001,1) when '2' then'2半成品' when '1' then '1成品' when 'A'then '1成品' else '3原材料' end,'' from(
select MB001 LA001,MC002 LA009,INVNUMA LA011,INVMONEY LA013 from  AHRD..V_KCMX  
) as KCMX  JOIN AHRD..INVMB ON LA001=MB001 JOIN  AHRD..CMSMC on rtrim(LA009)=rtrim(MC001) where MC004 = '1' 


INSERT INTO LSSJ..[LSKCB-YB]
select ltrim(LA001),MB002,MB003,MB004,LA009,MC002,LA011, CASE LA011 WHEN 0 THEN 0 ELSE LA013/LA011 END/3500 ,LA013/3500 ,'越南瑞德',left((CMSMC.UDF01),Charindex('-',CMSMC.UDF01)-1),良品=right((CMSMC.UDF01),len(CMSMC.UDF01)-Charindex('-',CMSMC.UDF01)),物料类别= case left(LA001,1) when '2' then'2半成品' when '1' then '1成品' when 'A'then '1成品' else '3原材料' end,'' from(
select MB001 LA001,MC002 LA009,INVNUMA LA011,INVMONEY LA013 from  YNRD..V_KCMX  
) as KCMX  JOIN YNRD..INVMB ON LA001=MB001 JOIN  YNRD..CMSMC on rtrim(LA009)=rtrim(MC001) where MC004 = '1' 

SELECT   rtrim(品号), 品名, 规格, 单位, 仓库编号, 仓库名称, 库存数量, 单价, 库存金额, 工厂, 经营单位, 良品, 物料类别, 月份
FROM      LSSJ.dbo.[LSKCB-YB]

--select *from  LSSJ..[LSKCB-YB]


select 经营单位,月份,case 物料类别 when '1成品' then sum(库存金额) else 0 end [1成品],case 物料类别 when '2半成品' then sum(库存金额) else 0 end [2半成品] ,case 物料类别 when '3原材料' then sum(库存金额) else 0 end [3原材料]  from   LSSJ..[LSKCB-YB] 
 --where (select count(*) from  [dbo].[v_Material_SMT] where Type='SMT' AND  MaterialID=品号)>0 and 良品='良品'
where  仓库名称 not like '%代管%' 
--WHERE 品号 like '5%'
group by 经营单位,月份,物料类别




SELECT sum(库存金额)  FROM  LSSJ..[LSKCB-YB] where 仓库名称 not like '%代管%' and 工厂='顺德瑞德' and   (select count(*) from  [dbo].[v_Material_SMT] where Type='SMT' AND  MaterialID=品号)>0 and 良品='良品'

SELECT sum(库存金额)  FROM  LSSJ..[LSKCB-YB] where 仓库名称 not like '%代管%' and 经营单位 like '%事业一部%' 

SELECT   rtrim(品号) 品号, 品名, 规格, 单位, 仓库编号, 仓库名称, 库存数量, 单价, 库存金额, 工厂, 经营单位, rtrim(良品) 良品, 物料类别, 月份 FROM LSSJ.dbo.[LSKCB-YB] where 仓库名称 not like '%代管%' 

and  经营单位 like '%事业一部%' 

SELECT 仓库名称 FROM  LSSJ..[LSKCB-YB] where 经营单位 like '%事业一部%'  and  仓库名称 not like '%代管%' group by 仓库名称


SELECT   SUM(库存金额) FROM LSSJ.dbo.[LSKCB-YB] where 仓库名称 not like '%代管%' 




select yb.*from   LSSJ..[LSKCB-YB] yb
 join SDRD.dbo.CMSMC on 仓库编号=CMSMC.MC001 where CMSMC.MC004='1' and CMSMC.MC018='Y' and CMSMC.UDF01 like '%-良品' AND CMSMC.MC002 not like '%车间仓%'AND CMSMC.MC002 not like '%外协仓%'AND CMSMC.MC002 not like '%非ROHS%'AND CMSMC.MC002 not like '%辅料%'
 --and (select count(*) from  [dbo].[v_Material_SMT] where Type='SMT' AND  MaterialID=品号)>0
  and 良品='良品' and 
(select count(*)from EscrowMaterialDetail d where 月份='201904' and d.品号=yb.品号)=0 and left(品号,1) in( '3' ,'5') 

select *from  [dbo].[v_Material_SMT] 


select Type,count(*) from  [dbo].[v_Material_SMT]  group by Type
select *from [dbo].[v_EscrowMaterial]
select *from  EscrowMaterialDetail