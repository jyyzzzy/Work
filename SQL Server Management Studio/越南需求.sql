use master;
WITH CTE_COPTH AS (
    SELECT 
        CT.UDF01 UDF1,
        RTRIM(CT.TH004) AS TH04,
        SUM( CT.TH008) TH08,
        SUM(CASE WHEN PT.TH030 = 'Y' THEN PT.TH015 ELSE 0 END) AS TH015_Y,
        SUM(CASE WHEN PT.TH030 = 'N' THEN PT.TH015 ELSE 0 END) AS TH215_N
        --,MAX(CASE WHEN PT.TH030 = 'N' THEN PT.TH014 END) AS TH214_N
    FROM SDRD..COPTH CT with(nolock)
    JOIN SDRD..COPTG CG with(nolock) ON CT.TH001 = CG.TG001 AND CT.TH002 = CG.TG002
    LEFT JOIN YNRD..PURTH PT with(nolock) ON CT.TH001 = PT.UDF01 
                             AND CT.TH002 = PT.UDF02 
                             AND CT.TH003 = PT.UDF03
    WHERE CG.TG001 = '23V4'
      AND CT.TH020 = 'Y'
      AND ISNULL(CT.UDF03, '') IN ('', '未结束')
    GROUP BY CT.UDF01, RTRIM(CT.TH004)
)
select    ycsj.*
    ,case when max(isnull(TG003,''))>max(isnull(PT.TH014,'')) then max(isnull(TG003,'')) else max(isnull(PT.TH014,'')) end RQ 
     from ( 

 SELECT TD001,TD002,TD003,rtrim(TD001)+'-'+rtrim(TD002)+'-'+rtrim(TD003) 采购单号,rtrim(TD004) 品号,TD005,TD006,TD008 采购数量,TD008-TD015 未交,case TD008-TD015 WHEN 0 THEN 'Y' ELSE 'N' END 结束,isnull(TH08,0)-isnull(TH015_Y,0) 来料数量,cast(isnull(TB004-TB005,0) as float) 顺德未交,ISNULL(TH215_N,0) 已到未入库数,isnull(TH08,0)-isnull(TH015_Y,0)-ISNULL(TH215_N,0)  在途量,TD008-TD015-(isnull(TH08,0)-isnull(TH015_Y,0))-cast(isnull(TB004-TB005,0) as float) 差异 , TD016 采购单状态
  
   FROM  YNRD..PURTD with(nolock) join YNRD..PURTC with(nolock) on TC001=TD001 and TC002=TD002 and TC004 = '20500009'--and  ltrim(TD001)+'-'+ltrim(TD002)+'-'+ltrim(TD003)='3371-20240912006-0020'

  LEFT JOIN CTE_COPTH as SH on ltrim(TD001) = LEFT(UDF1,4) AND ltrim(TD002)=SUBSTRING(UDF1,6, 11) AND +ltrim(TD003)=RIGHT(UDF1,4) --and TH04=TD004 
    
   left join SDRD..MOCTB MOCTB with(nolock) on TB018='Y' and TB001='5113' and TB004-TB005>0 and TD004=TB003 --and rtrim(TD001)+'-'+rtrim(TD002)+'-'+rtrim(TD003)=MOCTB.UDF01 
   
   AND  ltrim(TD001) = LEFT(MOCTB.UDF01,4) AND ltrim(TD002)=SUBSTRING(MOCTB.UDF01,6, 11) AND +ltrim(TD003)=RIGHT(MOCTB.UDF01,4) 

   where  TD018='Y' and ((TD008-TD015>0 and TD016='N') or ISNULL(TH04,'') <> ''  or  ISNULL(TB001,'') <>'')
   
   ) as ycsj 
  left join (SDRD..COPTH CT with(nolock) join SDRD..COPTG CG with(nolock) on CT.TH001=CG.TG001 and CT.TH002= CG.TG002 AND CG.TG001='23V4') on CT.UDF01=采购单号 left join YNRD..PURTH PT with(nolock) on ltrim(PT.TH011)=TD001 AND  ltrim(PT.TH012)=TD002 AND ltrim(PT.TH013)=TD003   
 group by  TD001,TD002,TD003,采购单号,品号,TD005,TD006,采购数量,未交,结束,来料数量,顺德未交,已到未入库数,在途量,差异,采购单状态 
    order by RQ 