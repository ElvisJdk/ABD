/*
	
select - where

1. mostrar los empleados que tienen mas de 90 horas de vacaciones 
2. mostrar el nombre, precio y precio con iva de los productos fabricados
3. mostrar los diferentes titulos de trabajo que existen
4. mostrar todos los posibles colores de productos 
5. mostrar todos los tipos de pesonas que existen 
6. mostrar el nombre concatenado con el apellido de las personas cuyo apellido sea johnson
7. mostrar todos los productos cuyo precio sea inferior a 150$ de color rojo o cuyo precio sea mayor a 500$ de color negro
8. mostrar el codigo, fecha de ingreso y horas de vacaciones de los empleados ingresaron a partir del año 2000 
9. mostrar el nombre,nmero de producto, precio de lista y el precio de lista incrementado en un 10% de los productos cuya fecha de fin de venta sea anerior al dia de hoy

*/
use AdventureWorks2008R2
--1. mostrar los empleados que tienen mas de 90 horas de vacaciones 
select *
from	HumanResources.Employee
where	VacationHours > 90

--2. mostrar el nombre, precio y precio con iva de los productos fabricados

select	p.ListPrice * 1.21 precio, Name nombre
from	Production.Product p

--3. mostrar los diferentes titulos de trabajo que existen

select		JobTitle trabajo
from		HumanResources.Employee
order by	 JobTitle


-- 4. mostrar todos los posibles colores de productos 

select		Color colores
from		Production.Product
where		Color is not null
order by	Color


--5. mostrar todos los tipos de pesonas que existen 

select		Person.PersonType personas
from		Person.Person
order by	person.PersonType

--6. mostrar el nombre concatenado con el apellido de las personas cuyo apellido sea johnson

select		pp.FirstName + ' ' + pp.LastName 'Nombre y apellido'
from		Person.Person pp
where		pp.LastName = 'johnson'

--7. mostrar todos los productos cuyo precio sea inferior a 150$ de color rojo o cuyo precio sea mayor a 500$ de color negro

select		pp.*
from		Production.Product pp
where		pp.ListPrice < 150 and pp.Color = 'red' or pp.ListPrice > 500 and pp.Color = 'black'

--8. mostrar el codigo, fecha de ingreso y horas de vacaciones de los empleados ingresaron a partir del año 2000 
select		he.LoginID codigo, he.HireDate 'fecha de ingreso', VacationHours 'horas de vacaciones'
from		HumanResources.Employee he
where		he.HireDate >= '2000-01-01'

--9. mostrar el nombre,nmero de producto, precio de lista y el precio de lista incrementado en un 10% de los productos cuya
--fecha de fin de venta sea anerior al dia de hoy

select		Name nombre,ProductID 'numero de producto', ListPrice precio, ListPrice * 1.10 'precio incrementeado' 
from		Production.Product 
where		SellEndDate < GETDATE()


/*
between & in

10. mostrar todos los porductos cuyo precio de lista este entre 200 y 300 
11. mostrar todos los empleados que nacieron entre 1970 y 1985 
12. mostrar los codigos de venta y producto,cantidad de venta y precio unitario de los articulos 750,753 y 770 
13. mostrar todos los porductos cuyo color sea verde, blanco y azul 
14. mostrar el la fecha,nuero de version y subtotal de las ventas efectuadas en los años 2005 y 2006 

*/

--10. mostrar todos los porductos cuyo precio de lista este entre 200 y 300 

select	Name producto, ListPrice precio
from	Production.Product
where	ListPrice between 200 and 300

--11. mostrar todos los empleados que nacieron entre 1970 y 1985 

select	*
from	HumanResources.Employee
where	BirthDate between '1970-01-01' and '1985-01-01'

--12. mostrar los codigos de venta y producto,cantidad de venta y precio unitario de los articulos 750,753 y 770 

select		SalesOrderDetailID 'codigo de venta' , UnitPrice 'precio unitario', LineTotal 'venta total',OrderQty cantidad 
from		Sales.SalesOrderDetail
where		ProductID in (750,753,770)

--13. mostrar todos los porductos cuyo color sea verde, blanco y azul 

select		Color
from		Production.Product
where		Color in ('white','blue','green')

--14. mostrar el la fecha,numero de version y subtotal de las ventas efectuadas en los años 2005 y 2006 

select		OrderDate fecha,RevisionNumber 'numero de version', SubTotal
from		Sales.SalesOrderHeader
where		OrderDate between '2005-01-01' and '2006-01-01'


/*
like

15. mostrar el nombre, precio y color de los accesorios para asientos de las bicicletas cuyo precio sea  mayor a 100 pesos
16. mostrar las bicicletas de montaña que  cuestan entre $1000 y $1200 
17. mostrar los nombre de los productos que tengan cualquier combinacion de ‘mountain bike’ 
18. mostrar las personas que su nombre empiece con la letra y 
19. mostrar las personas que la segunda letra de su apellido es una s 
20. mostrar el nombre concatenado con el apellido de las personas cuyo apellido tengan terminacion española (ez)
21. mostrar los nombres de los productos que su nombre termine en un numero 
22. mostrar las personas cuyo  nombre tenga una c o c como primer caracter, cualquier otro como segundo caracter, ni d ni d ni f ni g como tercer caracter, cualquiera entre j y r o entre s y w como cuarto caracter y el resto sin restricciones 


*/

--15. mostrar el nombre, precio y color de los accesorios para asientos de las bicicletas cuyo precio sea  mayor a 100 pesos

select  Name nombre, ListPrice precio, Color
from	Production.Product
where	ListPrice > 100 and Name like '%bike%'

--16. mostrar las bicicletas de montaña que  cuestan entre $1000 y $1200 

select	Name,ListPrice precio
from	Production.Product
where	ListPrice between 1000 and 1200 and Name like '%mountain%'


--17. mostrar los nombre de los productos que tengan cualquier combinacion de ‘mountain bike’ 
select	Name
from	Production.Product
where	 Name like '%mountain%'

--18. mostrar las personas que su nombre empiece con la letra y 
 
 select FirstName nombre
 from	Person.Person
 where	FirstName like 'l%'


 --19. mostrar las personas que la segunda letra de su apellido es una s 

 select		*
 from		Person.Person
 where		LastName like '_%s%'

 --20. mostrar el nombre concatenado con el apellido de las personas cuyo apellido tengan terminacion española (ez)

 select		FirstName  + ' ' + LastName 'nombre y apellido'
 from		Person.Person
 where		LastName like '%_ez%'

 --21. mostrar los nombres de los productos que su nombre termine en un numero 

 select		name nombre
 from		Production.Product
 WHERE		name LIKE '%[0-9]'

 -/*
 22. mostrar las personas cuyo  nombre tenga una c o c como primer caracter, cualquier otro como segundo caracter
 , ni d ni d ni f ni g como tercer caracter, cualquiera entre j y r o entre s y w como cuarto caracter y el resto 
 sin restricciones 
*/


/*
23. mostrar las personas ordernadas primero por su apellido y luego por su nombre
24. mostrar cinco productos mas caros y su nombre ordenado en forma alfabetica

*/

--23. mostrar las personas ordernadas primero por su apellido y luego por su nombre
select  LastName apellido, FirstName nombre
from	Person.Person
order by	LastName, FirstName

--24. mostrar cinco productos mas caros y su nombre ordenado en forma alfabetica
select TOP 5 Name, ListPrice
from  Production.Product
order by Name

/*
funciones de agrupacion

25. mostrar la fecha mas reciente de venta 
26. mostrar el precio mas barato de todas las bicicletas 
27. mostrar la fecha de nacimiento del empleado mas joven 

*/

--25. mostrar la fecha mas reciente de venta 

select	MAX(OrderDate) 'venta reciente'
from	Sales.SalesOrderHeader

--26. mostrar el precio mas barato de todas las bicicletas 

select	MIN(ListPrice) 'precio minimo'
from	Production.Product
where	ListPrice is not null and Name like '%Bike%'

--27. mostrar la fecha de nacimiento del empleado mas joven 
 
select  max(BirthDate) 'mas joven'
from	HumanResources.Employee

/*

null

28. mostrar los representantes de ventas (vendedores) que no tienen definido el numero de territorio
29. mostrar el peso promedio de todos los articulos. si el peso no estuviese definido, reemplazar por cero

*/

--28. mostrar los representantes de ventas (vendedores) que no tienen definido el numero de territorio

select	*
from	sales.SalesPerson
where	TerritoryID is null

--29. mostrar el peso promedio de todos los articulos. si el peso no estuviese definido, reemplazar por cero

select	AVG(isnull (Weight,0)) promedio
from	Production.Product

/*
group by

30. mostrar el codigo de subcategoria y el precio del producto mas barato de cada una 
de ellas 
31. mostrar los productos y la cantidad total vendida de cada uno de ellos
32. mostrar los productos y la cantidad total vendida de cada uno de ellos, ordenarlos por mayor cantidad de ventas
33. mostrar todas las facturas realizadas y el total facturado de cada una de ellas ordenado por numero de factura.
*/
 
 --30. mostrar el codigo de subcategoria y el precio del producto mas barato de cada una de ellas

 select		ProductSubcategoryID 'codigo de subcategoria', MIN(ListPrice) 'producto mas barato'
 from		Production.Product
 group by	ProductSubcategoryID

 --31. mostrar los productos y la cantidad total vendida de cada uno de ellos

select		ProductID as Producto,
			SUM(OrderQty) as 'Total de Ventas'
from		Sales.SalesOrderDetail
group by	ProductID


--32. mostrar los productos y la cantidad total vendida de cada uno de ellos, ordenarlos por mayor cantidad 
--de ventas

select		ProductID as Producto,
			SUM(OrderQty) as 'Total de Ventas'
from		Sales.SalesOrderDetail
group by	ProductID
order by	1

--33. mostrar todas las facturas realizadas y el total facturado de cada una de ellas ordenado
--por numero de factura.
select SalesOrderID factura, sum(LineTotal) 'subtotal'
from  Sales.SalesOrderDetail
group by SalesOrderID
order by SalesOrderID



/*
having

34. mostrar todas las facturas realizadas y el total facturado de cada una de ellas ordenado por nro de factura  pero solo de aquellas ordenes superen un total de $10.000 
35. mostrar la cantidad de facturas que vendieron mas de 20 unidades 
36. mostrar las subcategorias de los productos que tienen dos o mas productos que cuestan menos de $150 
37. mostrar todos los codigos de categorias existentes junto con la cantidad de productos y el precio de lista promedio por cada uno de aquellos productos que cuestan mas de $70 y el precio promedio es mayor a $300 
*/

--34. mostrar todas las facturas realizadas y el total facturado de cada una de ellas ordenado por nro de factura  
--pero solo de aquellas ordenes superen un total de $10.000 
select SalesOrderID factura, sum(LineTotal) 'subtotal'
from  Sales.SalesOrderDetail
group by SalesOrderID
having sum(LineTotal) > 10000
order by SalesOrderID