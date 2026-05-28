declare @QZRQ varchar(8)
set @QZRQ = CONVERT(varchar(100), GETDATE() -10, 112) 
SELECT @QZRQ
--if object_id(N'tempdb..#PUR1', N'U') is not null begin --删除临时表
--    --DROP Table #PUR1                

--end
--SELECT distinct purth003 TH03,
--    purth004 TH02 
--    into #PUR1  
--    FROM  RWDZ..INVTB 
--        join RWDZ..purth on UDF01=purth001+'-'+purth002 
--    WHERE TB018='Y' 
--        and ISNULL(UDF01,'')<>'' 
--        AND TB001='1112' 
--        AND CREATE_DATE>=@QZRQ+'000000000'
--insert into #PUR1 
SELECT distinct TB.CREATE_DATE,TD001+'-'+TD002 ,
    TD003  
    from RWDZ..PURTD td 
        join RWDZ..PURTC on TC001=TD001 AND TC002=TD002 
        join [scm_lnk].myerp_scm_rw.dbo.pu_pps_beliverylist  
            on  (TC009 collate Chinese_PRC_BIN = sbillno ) 
                AND TD003 collate Chinese_PRC_BIN = right('0000'+cast(orderlistno as varchar),4) 
        join  (
            select *
            from RWDZ..INVTB 
            where ISNULL(UDF01,'')<>'' 
                AND TB001='1112' 
                AND CREATE_DATE>=@QZRQ+'000000000'
                                --20130501145714397
        )  TB on TB.UDF01 collate Chinese_PRC_BIN =msgno+'-'+right('0000'+cast(autoid as varchar),4)  
        ORDER BY TD001+'-'+TD002
SELECT * 
FROM #PUR1

    --select *from  #PUR1   where   TH03  LIKE '%20191214024%'
    --UPDATE  D SET 
    --SELECT TD.*,
    --TD015=TB007, TD016= CASE WHEN TB007>=D.TD008 THEN 'Y' ELSE 'N' END 
    --FROM (          
    --        select purth003 ,purth004 ,(TB007) TB007,TB001,TB002,TB003,TB004,UDF01 from (
    --        SELECT purth003,purth004 ,(TB007) ,TB001,TB002,TB003,TB004,INVTB.UDF01  FROM  RWDZ..INVTB join RWDZ..purth on UDF01=purth001+'-'+purth002 WHERE TB018='Y' and  ISNULL(UDF01,'')<>'' AND TB001='1112' and (select count(*)from  #PUR1 where TH03= purth003 AND TH02=purth004 )>0 
    --        union  all
    --        SELECT  TD001+'-'+TD002 ,TD003,(TB007),TB001,TB002,TB003,TB004,TB.UDF01  from RWDZ..PURTD td join RWDZ..PURTC on TC001=TD001 AND TC002=TD002 join [scm_lnk].myerp_scm_rw.dbo.pu_pps_beliverylist  on  (TC009 collate Chinese_PRC_BIN = sbillno ) AND TD003 collate Chinese_PRC_BIN = right('0000'+cast(orderlistno as varchar),4) join  (select *from RWDZ..INVTB where TB018='Y' and ISNULL(UDF01,'')<>'' AND TB001='1112')  TB on TB.UDF01 collate Chinese_PRC_BIN =msgno+'-'+right('0000'+cast(autoid as varchar),4)  and (select count(*)from  #PUR1 where TH03= TD001+'-'+TD002 AND TH02=TD003 )>0 
    --        ) as inv-- group by purth003 ,purth004 
    --        ) AS TD  JOIN RWDZ..PURTD D ON purth003= TD001+'-'+TD002 AND purth004=TD003  where  purth003='3301-20191214024' 
UPDATE D
SET --SELECT 
    TD015 = TB007,
    TD016 = CASE
        WHEN TB007 >= D.TD008 THEN 'Y'
        ELSE 'N'
    END
FROM (
    select purth003,
        purth004,
        sum(TB007) TB007
    from (
        SELECT purth003,
            purth004,
            (TB007)
        FROM RWDZ..INVTB
            join RWDZ..purth on UDF01 = purth001 + '-' + purth002
        WHERE TB018 = 'Y'
            and ISNULL(UDF01, '') <> ''
            AND TB001 = '1112'
            and (
                select count(*)
                from #PUR1 where TH03= purth003 AND TH02=purth004 
            )>0 
        union all
        SELECT TD001 + '-' + TD002,
            TD003,
            (TB007)
        from RWDZ..PURTD td
            join RWDZ..PURTC on TC001 = TD001
                AND TC002 = TD002
            join [scm_lnk].myerp_scm_rw.dbo.pu_pps_beliverylist on (TC009 collate Chinese_PRC_BIN = sbillno)
                AND TD003 collate Chinese_PRC_BIN = right('0000' + cast(orderlistno as varchar), 4)
            join (
                select *
                from RWDZ..INVTB
                where TB018 = 'Y'
                    and ISNULL(UDF01, '') <> ''
                    AND TB001 = '1112'
            ) TB on TB.UDF01 collate Chinese_PRC_BIN = msgno + '-' + right('0000' + cast(autoid as varchar), 4)
            and (
                select count(*)
                from #PUR1 where TH03= TD001+'-'+TD002 AND TH02=TD003 
            )>0 
        ) as inv
    group by purth003,
        purth004
) AS TD
JOIN RWDZ..PURTD D ON purth003 = TD001 + '-' + TD002
AND purth004 = TD003 --where  purth003='3301-20191214024' D.TD016='N'
                UPDATE RWDZ..PURTD
                SET TD016 = 'y'
                WHERE (
                        SELECT COunt(*)
                        from RWDZ..PURTF
                        WHERE TF014 = 'Y'
                            and TF001 = TD001
                            AND TF002 = TD002
                            AND TF104 = TD003
                    ) > 0
                    AND TD016 = 'N'
                update scm
                set kcoutqty = TB007,
                    returnqty = 0,
                    quaqty = TB007,
                    qty = TB007
                from [scm_lnk].myerp_scm_rw.dbo.pu_pps_beliverylist scm
                    join (
                        select *
                        from RWDZ..INVTB
                        where ISNULL(UDF01, '') <> ''
                            AND TB001 = '1112'
                            AND CREATE_DATE >= @QZRQ + '000000000'
                    ) as inv on UDF01 collate Chinese_PRC_BIN = msgno + '-' + right('0000' + cast(autoid as varchar), 4)
                where TB018 = 'Y'
                update scm
                set kcoutqty = 0,
                    returnqty = 0,
                    quaqty = 0
                from [scm_lnk].myerp_scm_rw.dbo.pu_pps_beliverylist scm
                    join (
                        select *
                        from RWDZ..INVTB
                        where ISNULL(UDF01, '') <> ''
                            AND TB001 = '1112'
                            AND CREATE_DATE >= @QZRQ + '000000000'
                    ) inv on UDF01 collate Chinese_PRC_BIN = msgno + '-' + right('0000' + cast(autoid as varchar), 4)
                where TB018 = 'N'
                update scm
                set istates = '9'
                FROM [scm_lnk].myerp_scm_rw.dbo.pu_pps_belivery scm
                where (
                        select count(*)
                        from (
                                select *
                                from RWDZ..INVTB
                                where ISNULL(UDF01, '') <> ''
                                    AND TB001 = '1112'
                                    AND CREATE_DATE >= @QZRQ + '000000000'
                            ) inv
                        where UDF01 collate Chinese_PRC_BIN like msgno + '-%'
                            and TB018 = 'Y'
                    ) > 0 -- 完结送货单
                update scm
                set qty = TH015
                from [scm_lnk].myerp_scm_rw.dbo.pu_pps_beliverylist scm
                    join (
                        select *
                        from RWDZ..PURTH
                        where isnull(UDF01, '') <> ''
                            AND TH030 = 'Y'
                            AND CREATE_DATE >= @QZRQ + '000000000'
                    ) AS PUR on UDF01 collate Chinese_PRC_BIN = msgno + '-' + right('0000' + cast(autoid as varchar), 4)
                update scm
                set kcoutqty = TH015,
                    returnqty = TH017,
                    quaqty = TH015,
                    qty = TH015
                from [scm_lnk].myerp_scm_rw.dbo.pu_pps_beliverylist scm
                    join (
                        select *
                        from RWDZ..PURTH
                        where isnull(UDF01, '') <> ''
                            AND TH030 = 'Y'
                            AND CREATE_DATE >= @QZRQ + '000000000'
                    ) AS PUR on UDF01 collate Chinese_PRC_BIN = msgno + '-' + right('0000' + cast(autoid as varchar), 4)
                update scm
                set istates =case
                        when TH030 = 'Y' then '9'
                        else '2'
                    end
                FROM [scm_lnk].myerp_scm_rw.dbo.pu_pps_belivery scm
                    JOIN (
                        select *
                        from RWDZ..PURTH
                        where isnull(UDF01, '') <> ''
                            AND TH030 = 'Y'
                            AND CREATE_DATE >= @QZRQ + '000000000'
                    ) AS PUR ON UDF01 collate Chinese_PRC_BIN like msgno + '-%' -- 完结送货单