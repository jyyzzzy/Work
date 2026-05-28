-------------------------------- 越南每月生产领料数据(Star)---------------------------------------
use YNRD
declare @yf varchar(6)
declare @dt date
set @yf='202604'
set @dt=convert(date,@yf+'01',0);

with ProductOrder as (
        select distinct OrderID,OrderNo from (
                select left(LA024,4) OrderID,right(Rtrim(LA024),11) OrderNo,1 Type from INVLA where left(LA004,6)=@yf and left(LA006,2) in ('58')
                        union all
                select TA001,TA002,2 from MOCTA where Upper(TA011)='Y' and left(TA014,6)=@yf
        ) MOCTA 
)
, ProductQty_ as (
        select left(LA024,4) OrderID, right(Rtrim(LA024),11) OrderNo, sum(LA005*LA011) Qty
        from INVLA 
        where left(LA006,2) in ('58') 
        and left(LA004,6)<@yf
        and exists (select * from ProductOrder where OrderID=left(LA024,4) and OrderNo=right(Rtrim(LA024),11) )
        group by left(LA024,4) , right(Rtrim(LA024),11) 
)
, ProductQty as (
        select left(LA024,4) OrderID, right(Rtrim(LA024),11) OrderNo, sum(LA005*LA011) Qty
        from INVLA 
        where left(LA006,2) in ('58') 
        and left(LA004,6)=@yf
        and exists (select * from ProductOrder where OrderID=left(LA024,4) and OrderNo=right(Rtrim(LA024),11) )
        group by left(LA024,4) , right(Rtrim(LA024),11) 
)
, MaterialPick as (
        select TE011 OrderID, TE012 OrderNo, TE004 MaterialCode, sum(LA005*LA011) Qty
        from INVLA 
        join MOCTE on LA006=TE001 and LA007=TE002 and LA008=TE003
        where 1=1
        and left(LA004,6)<=@yf
        and exists (select * from ProductOrder where OrderID=TE011 and OrderNo=TE012 )
        group by TE011,TE012,TE004
)
, BomQty as (
        select Rtrim(MD001) ProductCode, Rtrim(MD003) MaterialCode, sum(MD006/MD007)Qty
        from BOMMD 
        where exists (select * from ProductOrder join MOCTA on TA001=OrderID and TA002=OrderNo and MD001=TA006)
        and MD006>0
        and MD011<>'4'
        group by MD001,MD003
)

select TA001+'-'+TA002 [工单单别-单号]--WorkOrder
,Rtrim(TA006)  产品品号--ProductCode
,Rtrim(P.MB002) 产品品名--ProductName
,Rtrim(P.MB003) 产品规格--ProductModel
,convert(date,TA010,0) 实际开工--StartDate
,convert(date,TA014,0) 实际完工--EndDate
,@yf 入库年月--ProductYF
,TA015 预计产量--PlannedProdQty --预计产量
,convert(float,TA017,0) 已生产量--ProductQty --已生产量
,convert(float,ISNULL(PQ2.Qty,0),0) 入库数量--ProductQtyYF
,case TA011 when '3' then '生产中' when 'y' then '指定完结' when 'Y' then '自动完结' else TA011 end 工单状态--WorkOrderStatus
,Rtrim(TB003) 材料品号--MaterialCode
,Rtrim(M.MB002) 材料品名--MaterialName
,Rtrim(M.MB003) 材料规格--MaterialModel
,MOCTB.TB004 AS 需领用量--RequestedQuantity --需领用量
,convert(float, (case when upper(TA011)='Y' and left(TA014,6)=@yf then TB005-(TB004/TA015)*isnull(PQ1.Qty,0.000000) else (TB004/TA015)*isnull(PQ2.Qty,0.000000) end)  ,0) 已领用量--Qty
from MOCTA 
join (select TB001,TB002,TB003,sum(TB004) TB004,sum(TB005)TB005 from MOCTB group by TB001,TB002,TB003) MOCTB on TA001=TB001 and TA002=TB002
join INVMB P on P.MB001=TA006
join INVMB M on M.MB001=TB003
left join ProductQty_ PQ1 on TA001=PQ1.OrderID and TA002=PQ1.OrderNo
left join ProductQty PQ2 on TA001=PQ2.OrderID and TA002=PQ2.OrderNo
left join MaterialPick MP on TA001=MP.OrderID and TA002=MP.OrderNo and TB003=MP.MaterialCode 
where exists (select * from ProductOrder where TA001=OrderID and TA002=OrderNo)
and TA015>0
and TB005>0
--and left(TB003,1) not in ('A','1','2')
order by TA001,TA002;
-------------------------------- 越南每月生产领料数据(End)---------------------------------------
