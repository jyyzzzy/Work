--SELECT MOCTA.TA021 AS LS001,CMSMD.MD002 AS LS002,MOCTA.TA001+'-'+MOCTA.TA002   工单号,MOCTA.TA003 AS LS005,
--MOCTA.TA014 AS LS006,MOCTA.TA006 AS LS007,MOCTA.TA034 AS LS008,MOCTA.TA035 AS LS009,

--MOCTA.TA015 AS 预计产量,MOCTA.TA017 AS 已生产量,


--MOCTB.TB003 AS LS012,INVMB.MB002 AS LS013,INVMB.MB003 AS LS014,CASE WHEN SUBSTRING(INVMB.MB001,1,1)< '3' THEN INVMB.MB057 ELSE INVMB.UDF54 END AS 单位成本


--,CASE MOCTA.TA015 WHEN 0 THEN 0 ELSE MOCTB.TB004*MOCTA.TA017/MOCTA.TA015 END AS 需领数量,

--CASE MOCTA.TA015 WHEN 0 THEN MOCTB.TB004 ELSE MOCTB.TB004/MOCTA.TA015 END AS 单位用量,TB005 实际领用

--FROM SDRD..MOCTA INNER JOIN SDRD..MOCTB ON  MOCTA.TA001 = MOCTB.TB001 AND MOCTA.TA002 = MOCTB.TB002

--INNER JOIN SDRD..CMSMD ON MOCTA.TA021 = CMSMD.MD001
--INNER JOIN SDRD..INVMB ON MOCTB.TB003 = INVMB.MB001
--WHERE  TA014 like '202501%'  AND  ((MOCTA.TA011 = 'Y')  OR  (MOCTA.TA011 = 'y')) -- AND left(MOCTB.TB003,1) IN('3','6')




--SELECT MOCTA.TA021 AS LS001,CMSMD.MD002 AS LS002,MOCTA.TA001+'-'+MOCTA.TA002   工单号,MOCTA.TA003 AS LS005,
--MOCTA.TA014 AS LS006,MOCTA.TA006 AS LS007,MOCTA.TA034 AS LS008,MOCTA.TA035 AS LS009,

--MOCTA.TA015 AS 预计产量,MOCTA.TA017 AS 已生产量 
--FROM SDRD..MOCTA  
--INNER JOIN SDRD..CMSMD ON MOCTA.TA021 = CMSMD.MD001 
--WHERE TA001='5102' AND  TA014 like '202501%'  AND  ((MOCTA.TA011 = 'Y')  OR  (MOCTA.TA011 = 'y')) -- AND left(MOCTB.TB003,1) IN('3','6')




--SELECT MOCTA.TA001,MOCTA.TA002,TB006

--FROM SDRD..MOCTA INNER JOIN SDRD..MOCTB ON  MOCTA.TA001 = MOCTB.TB001 AND MOCTA.TA002 = MOCTB.TB002

--INNER JOIN SDRD..CMSMD ON MOCTA.TA021 = CMSMD.MD001
--INNER JOIN SDRD..INVMB ON MOCTB.TB003 = INVMB.MB001
--WHERE TA001='5102' AND  TA014 like '202501%' AND ((MOCTA.TA011 = 'Y')  OR  (MOCTA.TA011 = 'y')) -- AND left(MOCTB.TB003,1) IN('3','6')
--and TB006 in('P031','P032','P034')


--union all

--select *from  (
--SELECT MOCTA.TA001,MOCTA.TA002,TB006

--FROM SDRD..MOCTA INNER JOIN SDRD..MOCTB ON  MOCTA.TA001 = MOCTB.TB001 AND MOCTA.TA002 = MOCTB.TB002

--INNER JOIN SDRD..CMSMD ON MOCTA.TA021 = CMSMD.MD001
--INNER JOIN SDRD..INVMB ON MOCTB.TB003 = INVMB.MB001
--WHERE TA001='5102' AND  TA014 like '202501%' AND ((MOCTA.TA011 = 'Y')  OR  (MOCTA.TA011 = 'y')) -- AND left(MOCTB.TB003,1) IN('3','6')
--and TB006 in('P036','P033','P030') 


--union all

--SELECT MOCTA.TA001,MOCTA.TA002,TB006

--FROM SDRD..MOCTA INNER JOIN SDRD..MOCTB ON  MOCTA.TA001 = MOCTB.TB001 AND MOCTA.TA002 = MOCTB.TB002

--INNER JOIN SDRD..CMSMD ON MOCTA.TA021 = CMSMD.MD001
--INNER JOIN SDRD..INVMB ON MOCTB.TB003 = INVMB.MB001
--WHERE TA001='5102' AND  TA014 like '202501%' AND ((MOCTA.TA011 = 'Y')  OR  (MOCTA.TA011 = 'y')) -- AND left(MOCTB.TB003,1) IN('3','6')
--and TB006 in('P040','P043','P046') 
--) as a

    


use SDRD
SELECT MOCTA.TA021 AS 工作中心编号,CMSMD.MD002 AS 工作中心名称,MOCTA.TA001+'-'+MOCTA.TA002   工单号,MOCTA.TA003 AS 开单日期,
MOCTA.TA014 AS 实际完工,MOCTA.TA006 AS 产品品号,MOCTA.TA034 AS 产品品名,MOCTA.TA035 AS 产品规格,

MOCTA.TA015 AS 预计产量,MOCTA.TA017 AS 已生产量,case when TA011='Y' then 'Y:已完工' when TA011='y' then 'y:指定结束' end  工单状态 ,left(CMSMC.UDF01,4) 事业部
 ,case when isnull(gy.MF001,'')='' then '' else '是' end  双面锡膏
  ,case when isnull(AI.MF001,'')='' then '' else '是' end  AI工艺  
  ,case when isnull(RI.MF001,'')='' then '' else '是' end  RI工艺
  ,case when isnull(SMT.MF001,'')='' then '' else '是' end  SMT工艺
FROM MOCTA  
INNER JOIN CMSMD ON MOCTA.TA021 = CMSMD.MD001 
inner join CMSMC on MC001=TA020

left join (  select *from (
select distinct MF001 from  BOMMF where   MF004  in('P031','P032','P034')---SMT-双面
union all
select MF001 from (
--select distinct MF001 from  BOMMF where   MF004  in('P036','P033','P030')
--union all
--select distinct MF001 from  BOMMF where   MF004  in('P040','P043','P046')
select distinct MF001,MW002 from  BOMMF join CMSMW on MF004=MW001 where   MW002  like'%SMT%'
) A group by MF001 having(COUNT(*))>1 )gy) gy on  gy.MF001=TA006
left join ( select distinct MF001 from  BOMMF where   MF004  in('P010')
) AI on  AI.MF001=TA006
left join ( select distinct MF001 from  BOMMF where   MF004  in('P022','P020')
) RI on  RI.MF001=TA006
left join ( select distinct MF001 from  BOMMF join CMSMW on MF004=MW001 where   MW002  like'%SMT%') SMT on  SMT.MF001=TA006
WHERE TA001='5102' AND  TA014 >= '20260626' AND  TA014 <= '20260702'   AND  ((MOCTA.TA011 = 'Y')  OR  (MOCTA.TA011 = 'y')) -- AND left(MOCTB.TB003,1) IN('3','6')


union all
SELECT MOCTA.TA021 AS LS001,CMSMD.MD002 AS LS002,MOCTA.TA001+'-'+MOCTA.TA002   工单号,MOCTA.TA003 AS LS005,
MOCTA.TA014 AS LS006,MOCTA.TA006 AS LS007,MOCTA.TA034 AS LS008,MOCTA.TA035 AS LS009,

MOCTA.TA015 AS 预计产量,MOCTA.TA017 AS 已生产量 ,case when TA011='Y' then 'Y:已完工' when TA011='y' then 'y:指定结束' end  工单状态 ,left(CMSMC.UDF01,4)
 ,case when isnull(gy.MF001,'')='' then '' else '是' end  双面锡膏
  ,case when isnull(AI.MF001,'')='' then '' else '是' end  AI工艺  
  ,case when isnull(RI.MF001,'')='' then '' else '是' end  RI工艺
  ,case when isnull(SMT.MF001,'')='' then '' else '是' end  SMT工艺
FROM ZJRD..MOCTA  
INNER JOIN ZJRD..CMSMD ON MOCTA.TA021 = CMSMD.MD001 
inner join ZJRD..CMSMC on MC001=TA020

left join (  select *from (
select distinct MF001 from  BOMMF where   MF004  in('P031','P032','P034')---SMT-双面
union all
select MF001 from (

select distinct MF001,MW002 from  BOMMF join CMSMW on MF004=MW001 where   MW002  like'%SMT%'
) A group by MF001 having(COUNT(*))>1 )gy) gy on  gy.MF001=TA006
left join ( select distinct MF001 from  BOMMF where   MF004  in('P010')
) AI on  AI.MF001=TA006
left join ( select distinct MF001 from  BOMMF where   MF004  in('P022','P020')
) RI on  RI.MF001=TA006
left join ( select distinct MF001 from  BOMMF join CMSMW on MF004=MW001 where   MW002  like'%SMT%') SMT on  SMT.MF001=TA006
WHERE TA001='5102' AND  TA014 >= '20260626' AND  TA014 <= '20260702'  AND  ((MOCTA.TA011 = 'Y')  OR  (MOCTA.TA011 = 'y')) -- AND left(MOCTB.TB003,1) IN('3','6')


union all
SELECT MOCTA.TA021 AS LS001,CMSMD.MD002 AS LS002,MOCTA.TA001+'-'+MOCTA.TA002   工单号,MOCTA.TA003 AS LS005,
MOCTA.TA014 AS LS006,MOCTA.TA006 AS LS007,MOCTA.TA034 AS LS008,MOCTA.TA035 AS LS009,

MOCTA.TA015 AS 预计产量,MOCTA.TA017 AS 已生产量 ,case when TA011='Y' then 'Y:已完工' when TA011='y' then 'y:指定结束' end  工单状态 
,IIF(SUBSTRING(MD011,0 ,CHARINDEX('-',MD011 , 0)) = '',left(CMSMC.UDF01,4),SUBSTRING(MD011,0 ,CHARINDEX('-',MD011 , 0)) )
 ,case when isnull(gy.MF001,'')='' then '' else '是' end  双面锡膏
  ,case when isnull(AI.MF001,'')='' then '' else '是' end  AI工艺  
  ,case when isnull(RI.MF001,'')='' then '' else '是' end  RI工艺 
  ,case when isnull(SMT.MF001,'')='' then '' else '是' end  SMT工艺
FROM AHRD..MOCTA  
INNER JOIN AHRD..CMSMD ON MOCTA.TA021 = CMSMD.MD001 
inner join AHRD..CMSMC on MC001=TA020

left join (  select *from (
select distinct MF001 from  BOMMF where   MF004  in('P031','P032','P034')---SMT-双面
union all
select MF001 from (

select distinct MF001,MW002 from  BOMMF join CMSMW on MF004=MW001 where   MW002  like'%SMT%'
) A group by MF001 having(COUNT(*))>1 )gy) gy on  gy.MF001=TA006
left join ( select distinct MF001 from  BOMMF where   MF004  in('P010')
) AI on  AI.MF001=TA006
left join ( select distinct MF001 from  BOMMF where   MF004  in('P022','P020')
) RI on  RI.MF001=TA006
left join ( select distinct MF001 from  BOMMF join CMSMW on MF004=MW001 where   MW002  like'%SMT%') SMT on  SMT.MF001=TA006

WHERE TA001='5102' AND   TA014 >= '20260626' AND  TA014 <= '20260702'  AND  ((MOCTA.TA011 = 'Y')  OR  (MOCTA.TA011 = 'y')) -- AND left(MOCTB.TB003,1) IN('3','6')
ORDER BY MOCTA.TA014,MOCTA.TA003,MOCTA.TA001+'-'+MOCTA.TA002




--select MF001 from (

--select distinct MF001,MW002 from  BOMMF join CMSMW on MF004=MW001 where   MW002  like'%SMT%' and MF001='214701730AX0'

--) A group by MF001 having(COUNT(*))>1 




