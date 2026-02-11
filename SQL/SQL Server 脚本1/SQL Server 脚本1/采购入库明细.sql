SELECT '顺德' AS 类别,
TG005C '供应商编号',MA002C '供应商简称',TH014C '验收/退货日',TH004C '品号',TH005C '品名',TH006C '规格',TH001C '验收/退货单号',
TH016C '计价/退货数量',
TH018C '单价',TH047C '本币税前金额',TH048C '本币税额',TH047C+TH048C '本币金额',TH008C '单位',
MC002C '交货仓库',TH031C '开票码',TG007C '币种',TG008C '汇率',
TH011C '采购单号',MV002 '采购人员'
,TH054C '已开票数量',
TH045C '原币税前金额',TH046C '原币税额',TH045C+TH046C '原币金额',TH026C '暂不付款'
,CASE WHEN TGOODS=1 THEN '验收' WHEN TGOODS=2 THEN '退货' END '异动别',TG006C '供应商单号'--,TG016
FROM SDRD..Pur_Sup_Detail WHERE TH014C>='20250101' AND  TH014C<='20250831'AND LEFT(TH004C,1) NOT IN ('1','A','2')
--AND TH001C NOT LIKE '3403%' AND TH001C NOT LIKE '3405%'  
--AND TH001C NOT LIKE '3474%' 
--AND TH001C NOT LIKE '3474%' AND TH001C NOT LIKE '3405%' 
-- AND TG016 NOT LIKE '%采购月末%'    
AND  (TG016 NOT in( '代管料转月月末退货单','月末批量开退货单') AND TG016 NOT in( '代管料转月月初入库单','采购月末退货月初进仓'))
 union all
SELECT '浙江' AS 类别,
TG005C '供应商编号',MA002C '供应商简称',TH014C '验收/退货日',TH004C '品号',TH005C '品名',TH006C '规格',TH001C '验收/退货单号',
TH016C '计价/退货数量',
TH018C '单价',TH047C '本币税前金额',TH048C '本币税额',TH047C+TH048C '本币金额',TH008C '单位',
MC002C '交货仓库',TH031C '开票码',TG007C '币种',TG008C '汇率',
TH011C '采购单号',MV002 '采购人员'
,TH054C '已开票数量',
TH045C '原币税前金额',TH046C '原币税额',TH045C+TH046C '原币金额',TH026C '暂不付款'
,CASE WHEN TGOODS=1 THEN '验收' WHEN TGOODS=2 THEN '退货' END '异动别',TG006C '供应商单号'--,TG016
FROM ZJRD..Pur_Sup_Detail WHERE TH014C>='20250101' AND  TH014C<='20250831'AND LEFT(TH004C,1) NOT IN ('1','A','2')
--AND TH001C NOT LIKE '3403%' AND TH001C NOT LIKE '3405%'  
--AND TH001C NOT LIKE '3474%' 
--AND TH001C NOT LIKE '3474%' AND TH001C NOT LIKE '3405%' 
-- AND TG016 NOT LIKE '%采购月末%'      
AND  (TG016 NOT in( '代管料转月月末退货单','月末批量开退货单') AND TG016 NOT in( '代管料转月月初入库单','采购月末退货月初进仓'))

  union all
SELECT '安徽' AS 类别,
TG005C '供应商编号',MA002C '供应商简称',TH014C '验收/退货日',TH004C '品号',TH005C '品名',TH006C '规格',TH001C '验收/退货单号',
TH016C '计价/退货数量',
TH018C '单价',TH047C '本币税前金额',TH048C '本币税额',TH047C+TH048C '本币金额',TH008C '单位',
MC002C '交货仓库',TH031C '开票码',TG007C '币种',TG008C '汇率',
TH011C '采购单号',MV002 '采购人员'
,TH054C '已开票数量',
TH045C '原币税前金额',TH046C '原币税额',TH045C+TH046C '原币金额',TH026C '暂不付款'
,CASE WHEN TGOODS=1 THEN '验收' WHEN TGOODS=2 THEN '退货' END '异动别',TG006C '供应商单号'--,TG016
FROM AHRD..Pur_Sup_Detail WHERE TH014C>='20250101' AND  TH014C<='20250831'AND LEFT(TH004C,1) NOT IN ('1','A','2')
--AND TH001C NOT LIKE '3403%' AND TH001C NOT LIKE '3405%'  
--AND TH001C NOT LIKE '3474%' 
--AND TH001C NOT LIKE '3474%' AND TH001C NOT LIKE '3405%' 
-- AND TG016 NOT LIKE '%采购月末%'      
AND  (TG016 NOT in( '代管料转月月末退货单','月末批量开退货单') AND TG016 NOT in( '代管料转月月初入库单','采购月末退货月初进仓'))
