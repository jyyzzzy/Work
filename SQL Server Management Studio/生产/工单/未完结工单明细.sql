SELECT RTRIM([TA001]) 工单单别
      ,RTRIM([TA002]) 工单单号
      ,RTRIM([TA003]) 开单日期
      ,TA015 预计产量
      ,TA016 已领套数
      ,TA017 已生产量,
      TA015 - TA017 未生产量
      ,RTRIM([TA024]) 源工单单别
      ,RTRIM([TA025]) 源工单编号,
      RTRIM(TB003) 材料品号
      ,
      TB004 需领用量
      ,TB005 已领用量
      ,TB004-TB005 未领用量
      ,RTRIM(TB006) 工艺
      ,RTRIM(TB012) 材料品名
      ,
      RTRIM(TB013) 材料规格
FROM MOCTA 
INNER JOIN MOCTB ON TB001 = TA001 AND TB002 = TA002
WHERE TA001 = '5112'
AND TA011 NOT IN ('Y','y')
AND TA013 = 'Y'
ORDER BY TA002