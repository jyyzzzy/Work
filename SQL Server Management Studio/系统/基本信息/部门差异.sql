SELECT [departmentcode]
      ,[departmentname]
      ,[subcompanyname],
      ME001,ME002
  FROM [192.168.8.24].[ecology].[dbo].[OA_COMPLETEDEP_Vcode]
  INNER JOIN CMSME ON ME001 = departmentcode COLLATE Chinese_PRC_BIN
  WHERE [subcompanyname] = '浙江瑞德'
  ORDER BY ME001

  SELECT [departmentcode]
      ,[departmentname]
      ,[subcompanyname]
  FROM [192.168.8.24].[ecology].[dbo].[OA_COMPLETEDEP_Vcode]
  WHERE [departmentcode] = '150213'