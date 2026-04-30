/*

1. Obtener el total de ventas del año 2006 y guardarlo en una variable llamada @TotalVentas, luego imprimir el resultado.

Tablas: Sales.SalesOrderDetail
Campos: LineTotal
*/
use AdventureWorks2008R2

declare @ventaTotal decimal(20,2)


select @ventaTotal = sum(ss.LineTotal)
from	Sales.SalesOrderHeader sh
join	sales.SalesOrderDetail ss
on		sh.SalesOrderID = ss.SalesOrderID
where	YEAR(sh.OrderDate) = 2006


print @ventaTotal

/*
2. Obtener el promedio de precios y guardarlo en una variable llamada @Promedio luego
hacer un reporte de todos los productos cuyo precio de venta sea menor al Promedio.

Tablas: Production.Product
Campos: ListPrice, ProductID
*/
declare @Promedio decimal(20,1)

select @Promedio = AVG(listPrice)
from	Production.Product 

select  ProductID, ListPrice
from	Production.Product
where	ListPrice < @Promedio

print @promedio

/*

3. Utilizando la variable @Promedio incrementar en un 10% el valor de los productos sean inferior al promedio.

Tablas: Production.Product
Campos: ListPrice
*/
declare @promedio decimal (20,1)
select  @promedio = avg(ListPrice)
from	Production.Product
update Production.Product
set	ListPrice = ListPrice * 1.10
where ListPrice < @promedio

print @promedio
select  ListPrice 
from	Production.Product
where	ListPrice is not null
order by  ListPrice desc

/*
4. Crear un variable de tipo tabla con las categorías y subcategoría de productos y
reportar el resultado.

Tablas: Production.ProductSubcategory, Production.ProductCategory
Campos: Name
*/

declare @tables table (subcategoria varchar(50), categoria varchar(50))
insert into @tables
select	distinct ps.Name, pp.Name
from	Production.Product pp
join	Production.ProductSubcategory ps
on		pp.ProductSubcategoryID = ps.ProductCategoryID

select *
from @tables

/*
5. Analizar el promedio de la lista de precios de productos, si su valor es menor a 500 imprimir el mensaje el PROMEDIO BAJO de lo contrario imprimir el mensaje PROMEDIO ALTO.

Tablas: Production.Product
Campos: ListPrice
*/

if (select avg(ListPrice) from Production.Product) <500
	print 'PROMEDIO BAJO'
else
	print 'PROMEDIO ALTO'