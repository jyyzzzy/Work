SELECT [TA001] 工单单别
      ,[TA002] 工单单号
      ,[TA003] 开单日期
      ,TA015 预计产量
      ,TA016 已领套数
      ,TA017 已生产量,
      TA015 - TA017 未生产量
      ,[TA024] 源工单单别
      ,[TA025] 源工单编号,
      TB003 材料品号
      ,
      TB004 需领用量
      ,TB005 已领用量
      ,TB004-TB005 未领用量
      ,TB006 工艺
      ,TB012 材料品名
      ,
      TB013 材料规格
FROM MOCTA 
INNER JOIN MOCTB ON TB001 = TA001 AND TB002 = TA002
WHERE TA001 = '5111'
AND TA011 NOT IN ('Y','y')
AND TA013 = 'Y'
ORDER BY TA002