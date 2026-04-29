use AdventureWorks2008R2
declare @ventaTotal decimal(20,2)


select @ventaTotal = sum(ss.LineTotal)
from	Sales.SalesOrderHeader sh
join	sales.SalesOrderDetail ss
on		sh.SalesOrderID = ss.SalesOrderID
where	YEAR(sh.OrderDate) = 2006


print @ventaTotal

declare @Promedio decimal(20,1)

select @Promedio = AVG(listPrice)
from	Production.Product 

select  ProductID, ListPrice
from	Production.Product
where	ListPrice < @Promedio

print @promedio
