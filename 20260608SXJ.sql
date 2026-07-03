SELECT 
    CONCAT(COPTG.TG001, '-', COPTG.TG002) AS 销货单号,
    COPTG.TG004 AS 客户编号,
--     COPTG.TG005 AS 部门编号,
    CASE WHEN CMSME.ME002 = '科技中心项目四组' THEN '瑞德物联' ELSE CMSME.ME002 END AS 部门名称,
    COPTG.TG006 AS 业务员,
    CMSMV.MV002 AS 业务员姓名,
    COPMA.MA002 AS 客户简称,
    COPTH.TH004 AS 品号,
    COPTH.TH005 AS 品名,
    COPTH.TH006 AS 规格,
    COPTG.TG003 AS 日期,
--     COPTH.TH007 AS 仓库,
    COPTH.TH009 AS 单位,
    COPTH.TH012 AS 原币单价,--原币单价
    COPTG.TG046 AS 本币总税额,--本币总税额
    COPTH.TH026 AS 开票码,
    COPTH.TH013 AS 原币税后金额,
    COPTH.TH008 AS 销货数量,
    COPTG.TG011 as 币种,
    COPTG.TG012 AS 汇率,
    COPTH.TH036 AS 原币税额,
    COPTG.TG045 AS 本币税前总金额,
    COPTG.TG020 AS 备注,
--     CMSMV.MV004 as 部门,
    CMSME.ME002 AS 部门,
    COPTG.TG013 原币销货税前总金额,
    COPTG.TG025 原币销货总税额,
    COPTG.TG013 + COPTG.TG025 AS 原币销货税后总金额,
    COPTG.TG045 AS 本币税前总金额,
    COPTG.TG046 AS 本币总税额,
    COPTG.TG045 + COPTG.TG046 AS 本币税后总金额,
    COPTH.TH013 原币税后金额,
    COPTH.TH035 原币税前金额,
    COPTH.TH036 原币税额,
    COPTH.TH037 本币税前金额,
    COPTH.TH038 本币税额,
    COPTH.TH037 + COPTH.TH038 AS 本币税后金额,
    HR.[workcode] AS 总监编号,
    HR.[lastname] AS 总监姓名,
    SUPHD.[departmentcode] AS 编号,
    SUPHD.[departmentname] AS 区域
--税种 1: 应税内含 2: 应税外加 3: 零税率 4: 免税 9: 不计税
FROM COPTG
INNER JOIN COPTH ON COPTG.TG001 = COPTH.TH001 AND COPTG.TG002 = COPTH.TH002
INNER JOIN COPMA ON COPTG.TG004 = COPMA.MA001
INNER JOIN CMSME ON CMSME.ME001 = COPTG.TG005
INNER JOIN CMSMV ON CMSMV.MV001 = COPTG.TG006
--部门
LEFT OUTER JOIN [192.168.8.24].[ecology].[dbo].[HrmDepartment] AS HD ON COPTG.TG005 = HD.[departmentcode] COLLATE Chinese_PRC_BIN
--上级部门
LEFT OUTER JOIN [192.168.8.24].[ecology].[dbo].[HrmDepartment] AS SUPHD ON HD.[supdepid] = SUPHD.[id]
--部门自定义
LEFT OUTER JOIN [192.168.8.24].[ecology].[dbo].[HrmDepartmentDefined] AS HDD ON HD.[id] = HDD.[deptid]
--人力资源
LEFT OUTER JOIN [192.168.8.24].[ecology].[dbo].[HrmResource] AS HR
    ON TRY_CAST(
           TRIM(CAST(HDD.[zzjgbmfzr] AS VARCHAR(50)))
       AS INT) = HR.[id]
WHERE COPTG.TG003 BETWEEN '20260601' AND '20260607'
  AND COPTG.TG023 = 'Y'  -- 已审核
  --AND ISNULL(COPTG.TG005,'') <> ''--部门编号
  AND RIGHT(COPTG.TG001, 1) <> '5'--单别
  AND LEFT(COPMA.MA002,5) <> '安徽瑞德-'
  AND LEFT(COPMA.MA002,5) <> '浙江瑞德-'
  AND LEFT(COPMA.MA002,5) <> '瑞德智能-'
  AND COPTH.TH020 = 'Y'--审核码
ORDER BY COPTG.TG003, COPTG.TG001, COPTG.TG002, COPTH.TH003;