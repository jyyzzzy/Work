/*
三地代管料转月明细（六份 Excel 对应六组结果集）
SQL Server / 鼎捷易飞 ERP / 只读

日期：
  退货使用 PURTI.TI003；进货使用 PURTG.TG003；均为 YYYYMMDD 字符串日期。
  默认：2026-10-31 退货，2026-11-01 进货。可分别修改四个日期变量。
单别：
  广东 SDRD ：3504 退货，3403 进货。
  安徽 AHRD ：3574 退货，3474 进货。
  浙江 ZJRD ：3574 退货，3474 进货。

六份 Excel 的表头：退货 60 列 / 进货 80 列，顺序与源文件一致。
额外增加[账套]、[地区]，进货单增加[仓库编号]以便核查。
Excel 中重复的“件数”列重命名为“件数_单头/件数_单身”；其他表头保留原样。
注意：部分 Excel 显示/扩展字段无法仅从已提供的四张采购源表定义中
准确定位（如付款名称、生产企业、批准文号、制造商/认可型号等），
这些字段保留同名列，以 NULL 表示未映射；不伪造数据。
  [发票种类]、[税种]、[检验状态]按常见易飞编码转中文显示值。
  单价、日期、税率以 ERP 原始字段为准；金额合计为相应明细金额的算术和。
  数据查回后可与原 Excel 逐笔核对。
*/

SET NOCOUNT ON;

DECLARE @退货开始日期 CHAR(8) = '20261031';
DECLARE @退货结束日期 CHAR(8) = '20261031';
DECLARE @进货开始日期 CHAR(8) = '20261101';
DECLARE @进货结束日期 CHAR(8) = '20261101';

-- SDRD 广东 退货 3504 （60 个 Excel 字段）
SELECT
    'SDRD' AS [账套],
    N'广东' AS [地区],
    R.TI003 AS [退货日期],
    RTRIM(R.TI001) + '-' + RTRIM(R.TI002) AS [退货单号],
    R.TI004 AS [供应商编号],
    V.MA002 AS [简称],
    R.TI006 AS [币种],
    R.TI007 AS [汇率],
    CASE RTRIM(R.TI008) WHEN 'S' THEN N'可抵扣专用发票' WHEN 'B' THEN N'普通发票' WHEN 'T' THEN N'运输发票' WHEN 'N' THEN N'不可抵扣专用发票' WHEN 'A' THEN N'农产品收购凭证' WHEN 'G' THEN N'海关代征完税凭证' WHEN 'W' THEN N'废旧物资收购凭证' WHEN 'Z' THEN N'其他' ELSE R.TI008 END AS [发票种类],
    CASE RTRIM(R.TI009) WHEN '1' THEN N'应税内含' WHEN '2' THEN N'应税外加' WHEN '3' THEN N'零税率' WHEN '4' THEN N'免税' WHEN '9' THEN N'不计税' ELSE R.TI009 END AS [税种],
    R.TI011 AS [原币退货金额],
    R.TI015 AS [原币退货税额],
    R.TI022 AS [数量合计],
    R.TI021 AS [件数_单头],
    T.TJ004 AS [品号],
    T.TJ005 AS [品名],
    T.TJ006 AS [规格],
    T.TJ011 AS [仓库编号],
    W.MC002 AS [仓库名称],
    T.TJ009 AS [数量],
    T.TJ007 AS [单位],
    T.TJ023 AS [小单位],
    T.TJ008 AS [单价],
    R.TI028 AS [本币退货金额],
    T.TJ019 AS [备注],
    T.TJ021 AS [开票],
    R.TI014 AS [单据日期],
    R.TI029 AS [本币退货税额],
    T.TJ030 AS [原币税前金额],
    T.TJ031 AS [原币税额],
    T.TJ032 AS [本币税前金额],
    T.TJ033 AS [本币税额],
    R.TI030 AS [付 款 条 件],
    CAST(NULL AS NVARCHAR(255)) AS [付 款 名 称],
    R.TI031 AS [包装数量合计],
    T.TJ024 AS [包装数量],
    T.TJ034 AS [包装单位],
    T.TJ036 AS [已开票数量],
    T.TJ037 AS [存储位置],
    T.TJ038 AS [生产日期],
    T.TJ042 AS [有效日期],
    T.TJ043 AS [复检日期],
    CAST(NULL AS NVARCHAR(255)) AS [生产企业],
    CAST(NULL AS NVARCHAR(255)) AS [批准文号],
    T.TJ039 AS [件装],
    T.TJ040 AS [件数_单身],
    ISNULL(T.TJ030, 0) + ISNULL(T.TJ031, 0) AS [原币价税合计],
    ISNULL(T.TJ032, 0) + ISNULL(T.TJ033, 0) AS [本币价税合计],
    T.TJ012 AS [批号],
    T.TJ044 AS [批号说明],
    T.TJ046 AS [库位编号],
    R.TI039 AS [部门],
    D.ME002 AS [部门名称],
    T.TJ047 AS [计价单位],
    T.TJ049 AS [库存单位],
    T.TJ048 AS [计价数量],
    T.TJ022 AS [库存数量],
    R.TI018 AS [发票号码],
    R.TI023 AS [发票日期],
    R.TI027 AS [税率%],
    T.TJ056 AS [暂估],
    T.TJ003 AS [序号]
FROM SDRD.dbo.PURTI R WITH(NOLOCK)
INNER JOIN SDRD.dbo.PURTJ T WITH(NOLOCK)
    ON T.TJ001 = R.TI001 AND T.TJ002 = R.TI002
LEFT JOIN SDRD.dbo.PURMA V WITH(NOLOCK)
    ON V.MA001 = R.TI004
LEFT JOIN SDRD.dbo.CMSMC W WITH(NOLOCK)
    ON W.MC001 = T.TJ011
LEFT JOIN SDRD.dbo.CMSME D WITH(NOLOCK)
    ON D.ME001 = R.TI039
WHERE R.TI001 = '3504'
  AND R.TI003 BETWEEN @退货开始日期 AND @退货结束日期
ORDER BY R.TI003, R.TI002, T.TJ003;

-- SDRD 广东 进货 3403 （80 个 Excel 字段）
SELECT
    'SDRD' AS [账套],
    N'广东' AS [地区],
    RTRIM(G.TG001) + '-' + RTRIM(G.TG002) AS [进货单号],
    COALESCE(NULLIF(RTRIM(H.TH014), ''), G.TG003) AS [验收日期],
    G.TG005 AS [供应商编号],
    V.MA002 AS [供应商简称],
    G.TG006 AS [供应商单号],
    CASE RTRIM(G.TG009) WHEN 'S' THEN N'可抵扣专用发票' WHEN 'B' THEN N'普通发票' WHEN 'T' THEN N'运输发票' WHEN 'N' THEN N'不可抵扣专用发票' WHEN 'A' THEN N'农产品收购凭证' WHEN 'G' THEN N'海关代征完税凭证' WHEN 'W' THEN N'废旧物资收购凭证' WHEN 'Z' THEN N'其他' ELSE G.TG009 END AS [发票种类],
    CASE RTRIM(G.TG010) WHEN '1' THEN N'应税内含' WHEN '2' THEN N'应税外加' WHEN '3' THEN N'零税率' WHEN '4' THEN N'免税' WHEN '9' THEN N'不计税' ELSE G.TG010 END AS [税种],
    G.TG025 AS [件数_单头],
    G.TG007 AS [币种],
    G.TG008 AS [汇率],
    G.TG013 AS [审核],
    H.TH004 AS [品    号],
    H.TH005 AS [品    名],
    H.TH006 AS [规    格],
    G.TG014 AS [单据日期],
    W.MC002 AS [仓库],
    H.TH007 AS [进货数量],
    H.TH015 AS [验收数量],
    H.TH016 AS [计价数量],
    H.TH017 AS [验退数量],
    H.TH008 AS [单位],
    H.TH035 AS [小单位],
    H.TH027 AS [超期],
    CASE RTRIM(H.TH028) WHEN '0' THEN N'免检' WHEN '1' THEN N'待验' WHEN '2' THEN N'合格' WHEN '3' THEN N'不良' WHEN '4' THEN N'特采' ELSE H.TH028 END AS [检验状态],
    H.TH029 AS [验退],
    H.TH018 AS [原币单位进价],
    H.TH019 AS [原币进货金额],
    H.TH020 AS [原币扣款金额],
    ISNULL(H.TH019, 0) - ISNULL(H.TH020, 0) AS [合计金额],
    H.TH024 AS [本币进货费用],
    H.TH025 AS [扣款说明],
    CASE WHEN RTRIM(ISNULL(H.TH011, '')) <> '' THEN RTRIM(H.TH011) + '-' + RTRIM(H.TH012) ELSE '' END AS [采购单号],
    H.TH033 AS [备注],
    H.TH031 AS [开票],
    CAST(NULL AS NVARCHAR(255)) AS [急料],
    H.TH045 AS [原币税前金额],
    H.TH046 AS [原币税额],
    H.TH047 AS [本币税前金额],
    H.TH048 AS [本币税额],
    G.TG033 AS [付款条件],
    CAST(NULL AS NVARCHAR(255)) AS [付款名称],
    CAST(NULL AS NVARCHAR(255)) AS [制造商],
    CAST(NULL AS NVARCHAR(255)) AS [简称],
    CAST(NULL AS NVARCHAR(255)) AS [认可型号],
    H.TH052 AS [本币冲自筹额],
    CAST(NULL AS NVARCHAR(255)) AS [请购单号],
    G.TG011 AS [发票号码],
    H.TH049 AS [进货包装数量],
    H.TH050 AS [验收包装数量],
    H.TH051 AS [验退包装数量],
    H.TH053 AS [包装单位],
    H.TH054 AS [已开票数量],
    H.TH056 AS [存储位置],
    H.TH057 AS [生产日期],
    H.TH058 AS [件装],
    H.TH059 AS [件数_单身],
    CAST(NULL AS NVARCHAR(255)) AS [批准文号],
    CAST(NULL AS NVARCHAR(255)) AS [生产企业],
    ISNULL(H.TH045, 0) + ISNULL(H.TH046, 0) AS [原币价税合计],
    ISNULL(H.TH047, 0) + ISNULL(H.TH048, 0) AS [本币价税合计],
    H.TH010 AS [批号],
    H.TH067 AS [批号说明],
    H.TH070 AS [报废码],
    H.TH068 AS [破坏数量],
    H.TH069 AS [破坏包装数量],
    H.TH061 AS [报废数量],
    H.TH062 AS [报废包装数量],
    H.TH064 AS [计价单位],
    H.TH065 AS [库存单位],
    H.TH034 AS [库存数量],
    H.TH072 AS [库位编号],
    G.TG049 AS [部门],
    D.ME002 AS [部门名称],
    G.TG046 AS [看板张数],
    H.TH073 AS [交货时段编号],
    CAST(NULL AS NVARCHAR(255)) AS [交货时段],
    G.TG027 AS [发票日期],
    G.TG030 AS [税率%],
    H.TH080 AS [暂估],
    H.TH003 AS [序号],
    H.TH009 AS [仓库编号]
FROM SDRD.dbo.PURTG G WITH(NOLOCK)
INNER JOIN SDRD.dbo.PURTH H WITH(NOLOCK)
    ON H.TH001 = G.TG001 AND H.TH002 = G.TG002
LEFT JOIN SDRD.dbo.PURMA V WITH(NOLOCK)
    ON V.MA001 = G.TG005
LEFT JOIN SDRD.dbo.CMSMC W WITH(NOLOCK)
    ON W.MC001 = H.TH009
LEFT JOIN SDRD.dbo.CMSME D WITH(NOLOCK)
    ON D.ME001 = G.TG049
WHERE G.TG001 = '3403'
  AND G.TG003 BETWEEN @进货开始日期 AND @进货结束日期
ORDER BY G.TG003, G.TG002, H.TH003;

-- AHRD 安徽 退货 3574 （60 个 Excel 字段）
SELECT
    'AHRD' AS [账套],
    N'安徽' AS [地区],
    R.TI003 AS [退货日期],
    RTRIM(R.TI001) + '-' + RTRIM(R.TI002) AS [退货单号],
    R.TI004 AS [供应商编号],
    V.MA002 AS [简称],
    R.TI006 AS [币种],
    R.TI007 AS [汇率],
    CASE RTRIM(R.TI008) WHEN 'S' THEN N'可抵扣专用发票' WHEN 'B' THEN N'普通发票' WHEN 'T' THEN N'运输发票' WHEN 'N' THEN N'不可抵扣专用发票' WHEN 'A' THEN N'农产品收购凭证' WHEN 'G' THEN N'海关代征完税凭证' WHEN 'W' THEN N'废旧物资收购凭证' WHEN 'Z' THEN N'其他' ELSE R.TI008 END AS [发票种类],
    CASE RTRIM(R.TI009) WHEN '1' THEN N'应税内含' WHEN '2' THEN N'应税外加' WHEN '3' THEN N'零税率' WHEN '4' THEN N'免税' WHEN '9' THEN N'不计税' ELSE R.TI009 END AS [税种],
    R.TI011 AS [原币退货金额],
    R.TI015 AS [原币退货税额],
    R.TI022 AS [数量合计],
    R.TI021 AS [件数_单头],
    T.TJ004 AS [品号],
    T.TJ005 AS [品名],
    T.TJ006 AS [规格],
    T.TJ011 AS [仓库编号],
    W.MC002 AS [仓库名称],
    T.TJ009 AS [数量],
    T.TJ007 AS [单位],
    T.TJ023 AS [小单位],
    T.TJ008 AS [单价],
    R.TI028 AS [本币退货金额],
    T.TJ019 AS [备注],
    T.TJ021 AS [开票],
    R.TI014 AS [单据日期],
    R.TI029 AS [本币退货税额],
    T.TJ030 AS [原币税前金额],
    T.TJ031 AS [原币税额],
    T.TJ032 AS [本币税前金额],
    T.TJ033 AS [本币税额],
    R.TI030 AS [付 款 条 件],
    CAST(NULL AS NVARCHAR(255)) AS [付 款 名 称],
    R.TI031 AS [包装数量合计],
    T.TJ024 AS [包装数量],
    T.TJ034 AS [包装单位],
    T.TJ036 AS [已开票数量],
    T.TJ037 AS [存储位置],
    T.TJ038 AS [生产日期],
    T.TJ042 AS [有效日期],
    T.TJ043 AS [复检日期],
    CAST(NULL AS NVARCHAR(255)) AS [生产企业],
    CAST(NULL AS NVARCHAR(255)) AS [批准文号],
    T.TJ039 AS [件装],
    T.TJ040 AS [件数_单身],
    ISNULL(T.TJ030, 0) + ISNULL(T.TJ031, 0) AS [原币价税合计],
    ISNULL(T.TJ032, 0) + ISNULL(T.TJ033, 0) AS [本币价税合计],
    T.TJ012 AS [批号],
    T.TJ044 AS [批号说明],
    T.TJ046 AS [库位编号],
    R.TI039 AS [部门],
    D.ME002 AS [部门名称],
    T.TJ047 AS [计价单位],
    T.TJ049 AS [库存单位],
    T.TJ048 AS [计价数量],
    T.TJ022 AS [库存数量],
    R.TI018 AS [发票号码],
    R.TI023 AS [发票日期],
    R.TI027 AS [税率%],
    T.TJ056 AS [暂估],
    T.TJ003 AS [序号]
FROM AHRD.dbo.PURTI R WITH(NOLOCK)
INNER JOIN AHRD.dbo.PURTJ T WITH(NOLOCK)
    ON T.TJ001 = R.TI001 AND T.TJ002 = R.TI002
LEFT JOIN AHRD.dbo.PURMA V WITH(NOLOCK)
    ON V.MA001 = R.TI004
LEFT JOIN AHRD.dbo.CMSMC W WITH(NOLOCK)
    ON W.MC001 = T.TJ011
LEFT JOIN AHRD.dbo.CMSME D WITH(NOLOCK)
    ON D.ME001 = R.TI039
WHERE R.TI001 = '3574'
  AND R.TI003 BETWEEN @退货开始日期 AND @退货结束日期
ORDER BY R.TI003, R.TI002, T.TJ003;

-- AHRD 安徽 进货 3474 （80 个 Excel 字段）
SELECT
    'AHRD' AS [账套],
    N'安徽' AS [地区],
    RTRIM(G.TG001) + '-' + RTRIM(G.TG002) AS [进货单号],
    COALESCE(NULLIF(RTRIM(H.TH014), ''), G.TG003) AS [验收日期],
    G.TG005 AS [供应商编号],
    V.MA002 AS [供应商简称],
    G.TG006 AS [供应商单号],
    CASE RTRIM(G.TG009) WHEN 'S' THEN N'可抵扣专用发票' WHEN 'B' THEN N'普通发票' WHEN 'T' THEN N'运输发票' WHEN 'N' THEN N'不可抵扣专用发票' WHEN 'A' THEN N'农产品收购凭证' WHEN 'G' THEN N'海关代征完税凭证' WHEN 'W' THEN N'废旧物资收购凭证' WHEN 'Z' THEN N'其他' ELSE G.TG009 END AS [发票种类],
    CASE RTRIM(G.TG010) WHEN '1' THEN N'应税内含' WHEN '2' THEN N'应税外加' WHEN '3' THEN N'零税率' WHEN '4' THEN N'免税' WHEN '9' THEN N'不计税' ELSE G.TG010 END AS [税种],
    G.TG025 AS [件数_单头],
    G.TG007 AS [币种],
    G.TG008 AS [汇率],
    G.TG013 AS [审核],
    H.TH004 AS [品    号],
    H.TH005 AS [品    名],
    H.TH006 AS [规    格],
    G.TG014 AS [单据日期],
    W.MC002 AS [仓库],
    H.TH007 AS [进货数量],
    H.TH015 AS [验收数量],
    H.TH016 AS [计价数量],
    H.TH017 AS [验退数量],
    H.TH008 AS [单位],
    H.TH035 AS [小单位],
    H.TH027 AS [超期],
    CASE RTRIM(H.TH028) WHEN '0' THEN N'免检' WHEN '1' THEN N'待验' WHEN '2' THEN N'合格' WHEN '3' THEN N'不良' WHEN '4' THEN N'特采' ELSE H.TH028 END AS [检验状态],
    H.TH029 AS [验退],
    H.TH018 AS [原币单位进价],
    H.TH019 AS [原币进货金额],
    H.TH020 AS [原币扣款金额],
    ISNULL(H.TH019, 0) - ISNULL(H.TH020, 0) AS [合计金额],
    H.TH024 AS [本币进货费用],
    H.TH025 AS [扣款说明],
    CASE WHEN RTRIM(ISNULL(H.TH011, '')) <> '' THEN RTRIM(H.TH011) + '-' + RTRIM(H.TH012) ELSE '' END AS [采购单号],
    H.TH033 AS [备注],
    H.TH031 AS [开票],
    CAST(NULL AS NVARCHAR(255)) AS [急料],
    H.TH045 AS [原币税前金额],
    H.TH046 AS [原币税额],
    H.TH047 AS [本币税前金额],
    H.TH048 AS [本币税额],
    G.TG033 AS [付款条件],
    CAST(NULL AS NVARCHAR(255)) AS [付款名称],
    CAST(NULL AS NVARCHAR(255)) AS [制造商],
    CAST(NULL AS NVARCHAR(255)) AS [简称],
    CAST(NULL AS NVARCHAR(255)) AS [认可型号],
    H.TH052 AS [本币冲自筹额],
    CAST(NULL AS NVARCHAR(255)) AS [请购单号],
    G.TG011 AS [发票号码],
    H.TH049 AS [进货包装数量],
    H.TH050 AS [验收包装数量],
    H.TH051 AS [验退包装数量],
    H.TH053 AS [包装单位],
    H.TH054 AS [已开票数量],
    H.TH056 AS [存储位置],
    H.TH057 AS [生产日期],
    H.TH058 AS [件装],
    H.TH059 AS [件数_单身],
    CAST(NULL AS NVARCHAR(255)) AS [批准文号],
    CAST(NULL AS NVARCHAR(255)) AS [生产企业],
    ISNULL(H.TH045, 0) + ISNULL(H.TH046, 0) AS [原币价税合计],
    ISNULL(H.TH047, 0) + ISNULL(H.TH048, 0) AS [本币价税合计],
    H.TH010 AS [批号],
    H.TH067 AS [批号说明],
    H.TH070 AS [报废码],
    H.TH068 AS [破坏数量],
    H.TH069 AS [破坏包装数量],
    H.TH061 AS [报废数量],
    H.TH062 AS [报废包装数量],
    H.TH064 AS [计价单位],
    H.TH065 AS [库存单位],
    H.TH034 AS [库存数量],
    H.TH072 AS [库位编号],
    G.TG049 AS [部门],
    D.ME002 AS [部门名称],
    G.TG046 AS [看板张数],
    H.TH073 AS [交货时段编号],
    CAST(NULL AS NVARCHAR(255)) AS [交货时段],
    G.TG027 AS [发票日期],
    G.TG030 AS [税率%],
    H.TH080 AS [暂估],
    H.TH003 AS [序号],
    H.TH009 AS [仓库编号]
FROM AHRD.dbo.PURTG G WITH(NOLOCK)
INNER JOIN AHRD.dbo.PURTH H WITH(NOLOCK)
    ON H.TH001 = G.TG001 AND H.TH002 = G.TG002
LEFT JOIN AHRD.dbo.PURMA V WITH(NOLOCK)
    ON V.MA001 = G.TG005
LEFT JOIN AHRD.dbo.CMSMC W WITH(NOLOCK)
    ON W.MC001 = H.TH009
LEFT JOIN AHRD.dbo.CMSME D WITH(NOLOCK)
    ON D.ME001 = G.TG049
WHERE G.TG001 = '3474'
  AND G.TG003 BETWEEN @进货开始日期 AND @进货结束日期
ORDER BY G.TG003, G.TG002, H.TH003;

-- ZJRD 浙江 退货 3574 （60 个 Excel 字段）
SELECT
    'ZJRD' AS [账套],
    N'浙江' AS [地区],
    R.TI003 AS [退货日期],
    RTRIM(R.TI001) + '-' + RTRIM(R.TI002) AS [退货单号],
    R.TI004 AS [供应商编号],
    V.MA002 AS [简称],
    R.TI006 AS [币种],
    R.TI007 AS [汇率],
    CASE RTRIM(R.TI008) WHEN 'S' THEN N'可抵扣专用发票' WHEN 'B' THEN N'普通发票' WHEN 'T' THEN N'运输发票' WHEN 'N' THEN N'不可抵扣专用发票' WHEN 'A' THEN N'农产品收购凭证' WHEN 'G' THEN N'海关代征完税凭证' WHEN 'W' THEN N'废旧物资收购凭证' WHEN 'Z' THEN N'其他' ELSE R.TI008 END AS [发票种类],
    CASE RTRIM(R.TI009) WHEN '1' THEN N'应税内含' WHEN '2' THEN N'应税外加' WHEN '3' THEN N'零税率' WHEN '4' THEN N'免税' WHEN '9' THEN N'不计税' ELSE R.TI009 END AS [税种],
    R.TI011 AS [原币退货金额],
    R.TI015 AS [原币退货税额],
    R.TI022 AS [数量合计],
    R.TI021 AS [件数_单头],
    T.TJ004 AS [品号],
    T.TJ005 AS [品名],
    T.TJ006 AS [规格],
    T.TJ011 AS [仓库编号],
    W.MC002 AS [仓库名称],
    T.TJ009 AS [数量],
    T.TJ007 AS [单位],
    T.TJ023 AS [小单位],
    T.TJ008 AS [单价],
    R.TI028 AS [本币退货金额],
    T.TJ019 AS [备注],
    T.TJ021 AS [开票],
    R.TI014 AS [单据日期],
    R.TI029 AS [本币退货税额],
    T.TJ030 AS [原币税前金额],
    T.TJ031 AS [原币税额],
    T.TJ032 AS [本币税前金额],
    T.TJ033 AS [本币税额],
    R.TI030 AS [付 款 条 件],
    CAST(NULL AS NVARCHAR(255)) AS [付 款 名 称],
    R.TI031 AS [包装数量合计],
    T.TJ024 AS [包装数量],
    T.TJ034 AS [包装单位],
    T.TJ036 AS [已开票数量],
    T.TJ037 AS [存储位置],
    T.TJ038 AS [生产日期],
    T.TJ042 AS [有效日期],
    T.TJ043 AS [复检日期],
    CAST(NULL AS NVARCHAR(255)) AS [生产企业],
    CAST(NULL AS NVARCHAR(255)) AS [批准文号],
    T.TJ039 AS [件装],
    T.TJ040 AS [件数_单身],
    ISNULL(T.TJ030, 0) + ISNULL(T.TJ031, 0) AS [原币价税合计],
    ISNULL(T.TJ032, 0) + ISNULL(T.TJ033, 0) AS [本币价税合计],
    T.TJ012 AS [批号],
    T.TJ044 AS [批号说明],
    T.TJ046 AS [库位编号],
    R.TI039 AS [部门],
    D.ME002 AS [部门名称],
    T.TJ047 AS [计价单位],
    T.TJ049 AS [库存单位],
    T.TJ048 AS [计价数量],
    T.TJ022 AS [库存数量],
    R.TI018 AS [发票号码],
    R.TI023 AS [发票日期],
    R.TI027 AS [税率%],
    T.TJ056 AS [暂估],
    T.TJ003 AS [序号]
FROM ZJRD.dbo.PURTI R WITH(NOLOCK)
INNER JOIN ZJRD.dbo.PURTJ T WITH(NOLOCK)
    ON T.TJ001 = R.TI001 AND T.TJ002 = R.TI002
LEFT JOIN ZJRD.dbo.PURMA V WITH(NOLOCK)
    ON V.MA001 = R.TI004
LEFT JOIN ZJRD.dbo.CMSMC W WITH(NOLOCK)
    ON W.MC001 = T.TJ011
LEFT JOIN ZJRD.dbo.CMSME D WITH(NOLOCK)
    ON D.ME001 = R.TI039
WHERE R.TI001 = '3574'
  AND R.TI003 BETWEEN @退货开始日期 AND @退货结束日期
ORDER BY R.TI003, R.TI002, T.TJ003;

-- ZJRD 浙江 进货 3474 （80 个 Excel 字段）
SELECT
    'ZJRD' AS [账套],
    N'浙江' AS [地区],
    RTRIM(G.TG001) + '-' + RTRIM(G.TG002) AS [进货单号],
    COALESCE(NULLIF(RTRIM(H.TH014), ''), G.TG003) AS [验收日期],
    G.TG005 AS [供应商编号],
    V.MA002 AS [供应商简称],
    G.TG006 AS [供应商单号],
    CASE RTRIM(G.TG009) WHEN 'S' THEN N'可抵扣专用发票' WHEN 'B' THEN N'普通发票' WHEN 'T' THEN N'运输发票' WHEN 'N' THEN N'不可抵扣专用发票' WHEN 'A' THEN N'农产品收购凭证' WHEN 'G' THEN N'海关代征完税凭证' WHEN 'W' THEN N'废旧物资收购凭证' WHEN 'Z' THEN N'其他' ELSE G.TG009 END AS [发票种类],
    CASE RTRIM(G.TG010) WHEN '1' THEN N'应税内含' WHEN '2' THEN N'应税外加' WHEN '3' THEN N'零税率' WHEN '4' THEN N'免税' WHEN '9' THEN N'不计税' ELSE G.TG010 END AS [税种],
    G.TG025 AS [件数_单头],
    G.TG007 AS [币种],
    G.TG008 AS [汇率],
    G.TG013 AS [审核],
    H.TH004 AS [品    号],
    H.TH005 AS [品    名],
    H.TH006 AS [规    格],
    G.TG014 AS [单据日期],
    W.MC002 AS [仓库],
    H.TH007 AS [进货数量],
    H.TH015 AS [验收数量],
    H.TH016 AS [计价数量],
    H.TH017 AS [验退数量],
    H.TH008 AS [单位],
    H.TH035 AS [小单位],
    H.TH027 AS [超期],
    CASE RTRIM(H.TH028) WHEN '0' THEN N'免检' WHEN '1' THEN N'待验' WHEN '2' THEN N'合格' WHEN '3' THEN N'不良' WHEN '4' THEN N'特采' ELSE H.TH028 END AS [检验状态],
    H.TH029 AS [验退],
    H.TH018 AS [原币单位进价],
    H.TH019 AS [原币进货金额],
    H.TH020 AS [原币扣款金额],
    ISNULL(H.TH019, 0) - ISNULL(H.TH020, 0) AS [合计金额],
    H.TH024 AS [本币进货费用],
    H.TH025 AS [扣款说明],
    CASE WHEN RTRIM(ISNULL(H.TH011, '')) <> '' THEN RTRIM(H.TH011) + '-' + RTRIM(H.TH012) ELSE '' END AS [采购单号],
    H.TH033 AS [备注],
    H.TH031 AS [开票],
    CAST(NULL AS NVARCHAR(255)) AS [急料],
    H.TH045 AS [原币税前金额],
    H.TH046 AS [原币税额],
    H.TH047 AS [本币税前金额],
    H.TH048 AS [本币税额],
    G.TG033 AS [付款条件],
    CAST(NULL AS NVARCHAR(255)) AS [付款名称],
    CAST(NULL AS NVARCHAR(255)) AS [制造商],
    CAST(NULL AS NVARCHAR(255)) AS [简称],
    CAST(NULL AS NVARCHAR(255)) AS [认可型号],
    H.TH052 AS [本币冲自筹额],
    CAST(NULL AS NVARCHAR(255)) AS [请购单号],
    G.TG011 AS [发票号码],
    H.TH049 AS [进货包装数量],
    H.TH050 AS [验收包装数量],
    H.TH051 AS [验退包装数量],
    H.TH053 AS [包装单位],
    H.TH054 AS [已开票数量],
    H.TH056 AS [存储位置],
    H.TH057 AS [生产日期],
    H.TH058 AS [件装],
    H.TH059 AS [件数_单身],
    CAST(NULL AS NVARCHAR(255)) AS [批准文号],
    CAST(NULL AS NVARCHAR(255)) AS [生产企业],
    ISNULL(H.TH045, 0) + ISNULL(H.TH046, 0) AS [原币价税合计],
    ISNULL(H.TH047, 0) + ISNULL(H.TH048, 0) AS [本币价税合计],
    H.TH010 AS [批号],
    H.TH067 AS [批号说明],
    H.TH070 AS [报废码],
    H.TH068 AS [破坏数量],
    H.TH069 AS [破坏包装数量],
    H.TH061 AS [报废数量],
    H.TH062 AS [报废包装数量],
    H.TH064 AS [计价单位],
    H.TH065 AS [库存单位],
    H.TH034 AS [库存数量],
    H.TH072 AS [库位编号],
    G.TG049 AS [部门],
    D.ME002 AS [部门名称],
    G.TG046 AS [看板张数],
    H.TH073 AS [交货时段编号],
    CAST(NULL AS NVARCHAR(255)) AS [交货时段],
    G.TG027 AS [发票日期],
    G.TG030 AS [税率%],
    H.TH080 AS [暂估],
    H.TH003 AS [序号],
    H.TH009 AS [仓库编号]
FROM ZJRD.dbo.PURTG G WITH(NOLOCK)
INNER JOIN ZJRD.dbo.PURTH H WITH(NOLOCK)
    ON H.TH001 = G.TG001 AND H.TH002 = G.TG002
LEFT JOIN ZJRD.dbo.PURMA V WITH(NOLOCK)
    ON V.MA001 = G.TG005
LEFT JOIN ZJRD.dbo.CMSMC W WITH(NOLOCK)
    ON W.MC001 = H.TH009
LEFT JOIN ZJRD.dbo.CMSME D WITH(NOLOCK)
    ON D.ME001 = G.TG049
WHERE G.TG001 = '3474'
  AND G.TG003 BETWEEN @进货开始日期 AND @进货结束日期
ORDER BY G.TG003, G.TG002, H.TH003;

