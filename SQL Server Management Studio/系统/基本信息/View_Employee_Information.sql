select lastname,HrmJobTitles.jobtitlename,部门名称,* 
from [192.168.8.24].[ecology].[dbo].HrmResource 
left join [192.168.8.24].[ecology].[dbo].HrmJobTitles on jobtitle=HrmJobTitles.id
left join [192.168.8.24].[ecology].[dbo].OA_COMPLETEDEP on departmentid= 部门ID
where status<>'5'