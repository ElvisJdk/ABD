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
--1. mostrar los empleados que tienen mas de 90 horas de vacaciones 
select	*
from	HumanResources.Employee
where	VacationHours > 90

--2. mostrar el nombre, precio y precio con iva de los productos fabricados

select  Name, ListPrice precio,ListPrice * 1.21
from	Production.Product		

--3. mostrar los diferentes titulos de trabajo que existen
select	JobTitle 'titulos de trabajo'
from	HumanResources.Employee

--4. mostrar todos los posibles colores de productos 
select  Color
from	Production.Product

--5. mostrar todos los tipos de pesonas que existen 
select  PersonType
from	Person.Person
where	PersonType is not null

--6. mostrar el nombre concatenado con el apellido de las personas cuyo apellido sea johnson

select	FirstName + +''+ LastName as 'nombre y apellido' 
from	Person.Person
where	LastName = 'johnson'

--7. mostrar todos los productos cuyo precio sea inferior a 150$ de color rojo o cuyo precio sea mayor a 500$ de color negro


select  ListPrice
from	Production.Product
where	ListPrice < 150 and Color = 'red' or ListPrice > 500 and Color = 'black'


/*
8. mostrar el codigo, fecha de ingreso y horas de vacaciones de los empleados ingresaron a partir del año 2000 
*/
select	LoginID codigo, HireDate 'fecha de ingreso', VacationHours
from	HumanResources.Employee
where	year(HireDate) >= 2000

/*
9. mostrar el nombre,nmero de producto, precio de lista y el precio de lista incrementado en un 10% de los productos cuya fecha de fin de venta sea anerior al dia de hoy
*/

select	Name, ProductID, ListPrice, ListPrice * 0.1 'precio incrementado'
from	Production.Product
where	SellEndDate < GETDATE()


/*
between & in

10. mostrar todos los porductos cuyo precio de lista este entre 200 y 300 
11. mostrar todos los empleados que nacieron entre 1970 y 1985 
12. mostrar los codigos de venta y producto,cantidad de venta y precio unitario de los articulos 750,753 y 770 
13. mostrar todos los porductos cuyo color sea verde, blanco y azul 
14. mostrar el la fecha,nuero de version y subtotal de las ventas efectuadas en los años 2005 y 2006 

like

15. mostrar el nombre, precio y color de los accesorios para asientos de las bicicletas cuyo precio sea  mayor a 100 pesos
16. mostrar las bicicletas de montaña que  cuestan entre $1000 y $1200 	
17. mostrar los nombre de los productos que tengan cualquier combinacion de ‘mountain bike’ 
18. mostrar las personas que su nombre empiece con la letra y 
11. mostrar todos los empleados que nacieron entre 1970 y 1985 
19. mostrar las personas que la segunda letra de su apellido es una s 
20. mostrar el nombre concatenado con el apellido de las personas cuyo apellido tengan terminacion española (ez)
21. mostrar los nombres de los productos que su nombre termine en un numero 
22. mostrar las personas cuyo  nombre tenga una c o c como primer caracter, cualquier otro como segundo caracter, ni d ni d ni f ni g como tercer caracter, cualquiera entre j y r o entre s y w como cuarto caracter y el resto sin restricciones 

*/


--10. mostrar todos los porductos cuyo precio de lista este entre 200 y 300 
select	ListPrice
from	Production.Product
where	ListPrice between 200 and 300


--11. mostrar todos los empleados que nacieron entre 1970 y 1985 
select *
from	HumanResources.Employee
where	BirthDate between '01-01-1970' and '01-01-1985'

--12. mostrar los codigos de venta y producto,cantidad de venta y precio unitario de los articulos 750,753 y 770 
select  SalesOrderID,ProductID,OrderQty,UnitPrice
from	Sales.SalesOrderDetail
where	ProductID in (750,753,770)


--14. mostrar el la fecha,nuero de version y subtotal de las ventas efectuadas en los años 2005 y 2006 


select	OrderDate, AccountNumber 'numero de version', SubTotal
from	Sales.SalesOrderHeader
where	year(OrderDate) between 2005 and 2006



--15. mostrar el nombre, precio y color de los accesorios para asientos de las bicicletas cuyo precio sea  mayor a 100 pesos

select	Name nombre
from	Production.Product
where	ListPrice > 100 and Name like '%seat%'





--PROCEDIMIENTOS ALMACENADOS

--82: Crear un procedimiento almacenado que dada una determinada inicial ,devuelva codigo, nombre,apellido y direccion de correo de los empleados cuyo nombre coincida con la inicial ingresada

 CREATE PROCEDURE InformarEmpleadosPorInicial(@inicial char(1))
 AS 
    BEGIN
        SELECT		BusinessEntityID as Codigo, 
                    FirstName +' '+ LastName as Empleado, 
                    EmailAddress as 'Correo Electronico'
        FROM		HumanResources.vEmployee
        WHERE		FirstName LIKE @inicial + '%'
        ORDER BY	FirstName
    END

GO
EXECUTE InformarEmpleadosPorInicial @inicial='a'
EXECUTE InformarEmpleadosPorInicial @inicial='j'
EXECUTE InformarEmpleadosPorInicial @inicial='m'


--83: Crear un procedimiento almacenado que devuelva los productos que lleven de fabricado la cantidad de dias que le 
pasemos como parametro

create Procedure TiempoDeFabricacion(@dias int = 1)
AS
    BEGIN
        SELECT	    Name, ProductNumber, DaysToManufacture
        FROM		Production.Product
        WHERE		DaysToManufacture = @dias
    END
GO

EXECUTE TiempoDeFabricacion @dias=2
EXECUTE TiempoDeFabricacion @dias=4
EXECUTE TiempoDeFabricacion @dias=5 
EXECUTE TiempoDeFabricacion


84: Crear un procedimiento almacenado que permita actualizar y ver los precios de un determinado 
producto que reciba como parametro

CREATE PROCEDURE ActualizarPrecios
(@cantidad as float,@codigo as int)
AS
    BEGIN
        UPDATE Production.Product
        SET ListPrice = ListPrice*@cantidad
        WHERE ProductID=@codigo

        SELECT Name,ListPrice
        FROM Production.Product
        WHERE ProductID=@codigo
    END

GO
EXECUTE ActualizarPrecios 1.1, 886




























SELECT listPrice from production.Product
WHERE ProductID=886 -- Antes: 366,762  Despues: 403,4382


--85: Armar un procedimineto almacenado que devuelva los proveedores que proporcionan el producto especificado por parametro

CREATE PROCEDURE Proveedores(@producto varchar(30)='%')
AS
    
    SELECT      v.Name proveedor,
                p.Name producto 
    
    FROM        Purchasing.Vendor AS v 
    INNER JOIN  Purchasing.ProductVendor AS pv
    ON          v.BusinessEntityID = pv.BusinessEntityID 
    INNER JOIN  Production.Product AS p 
    ON          pv.ProductID = p.ProductID 
    WHERE       p.Name LIKE @producto
    ORDER BY    v.Name 
GO    

EXECUTE Proveedores 'r%'
EXECUTE Proveedores 'reflector'
EXECUTE Proveedores 


--86: Crear un procedimiento almacenado que devuelva nombre,apellido y sector del empleado que le 
pasemos como argumento.no es necesario pasar el nombre y apellido exactos al procedimiento.
 
CREATE PROCEDURE empleados
    @apellido nvarchar(50)='%', 
    @nombre nvarchar(50)='%' 
AS 
    SELECT FirstName, LastName,Department
    FROM HumanResources.vEmployeeDepartmentHistory
    WHERE FirstName LIKE @nombre AND LastName LIKE @apellido
GO

EXECUTE empleados  'eric%' 
EXECUTE empleados



--FUNCIONES ESCALARES

--87: Armar una funcion que devuelva los productos que estan por encima del promedio de precios general

CREATE FUNCTION promedio()
RETURNS MONEY
AS
BEGIN
        DECLARE @promedio MONEY
        SELECT @promedio=AVG(ListPrice) FROM Production.Product
        RETURN @promedio
END


--uso de la funcion
SELECT  * 
FROM    Production.Product 
WHERE   ListPrice >dbo.promedio()

SELECT AVG(ListPrice) FROM Production.Product --438.6662


--88: Armar una función que dado un código de producto devuelva el total de ventas para dicho producto.Luego, mediante una consulta, traer codigo, nombre y total de ventas ordenados por esta ultima columna

CREATE FUNCTION VentasProductos(@codigoProducto int) 
RETURNS int
AS
 BEGIN
   DECLARE @total int
   SELECT @total = SUM(OrderQty)
   FROM Sales.SalesOrderDetail WHERE ProductID = @codigoProducto
   IF (@total IS NULL)
      SET @total = 0
   RETURN @total
 END
 
--uso de la funcion
SELECT      ProductID "codigo producto",
            Name nombre,
            dbo.VentasProductos(ProductID) AS "total de ventas"
FROM        Production.Product
ORDER BY    3 DESC


--  89.armar una función que dado un año , devuelva nombre y  apellido de los empleados 
-- que ingresaron ese año 

create function añoIngresoEmpleados (@año int)
returns table
as 
	return
	(select FirstName, LastName, hireDate
	 from Person.Person p
	 inner join  HumanResources.Employee e
	 on e.BusinessEntityID = p.BusinessEntityID
	 where year (HireDate)=@año
	)

	-- uso de la funcion
select * from dbo.añoIngresoEmpleados(2004)
select * from dbo.añoIngresoEmpleados(2000)


/*
90.armar una función que dado el codigo de negocio cliente de la fabrica, devuelva el codigo, nombre y las ventas del año hasta la fecha para cada producto vendido en el negocio ordenadas por esta ultima columna
*/

CREATE FUNCTION VentasNegocio (@codNegocio int)
RETURNS TABLE
AS
RETURN 
(	
	SELECT  p.ProductID, p.Name, sum(sd.LineTotal) as 'total'
	FROM	Production.Product AS p
	JOIN	Sales.SalesOrderDetail as sd
	on		sd.ProductID = p.ProductID
	join	sales.SalesOrderHeader as sh
	on		sh.SalesOrderID = sd.SalesOrderDetailID
	join	sales.Customer as sc
	on		sh.CustomerID = sc.CustomerID
	where	sc.StoreID = @codNegocio
	group by p.ProductID, p.Name

)

--uso de la funcion
select   *
from	 dbo.VentasNegocio(1340)
order by 3 desc;


/*
	
91. crear una  función llmada "ofertas" que reciba un parámetro correspondiente a un precio y nos retorne una tabla con código,nombre, color y precio de todos los productos cuyo precio sea inferior al parámetro ingresado

*/

create function ofertas(@minimo decimal(6,2))
returns @oferta table
(codigo int,
 nombre varchar(40),
 color varchar(30),
 precio decimal(6,2)
 )
 as
	begin
		insert @oferta
		select ProductID,Name,Color,ListPrice
		from	Production.Product
		where	ListPrice <@minimo
		return
	end


-- uso de la funcion

select *
from	dbo.ofertas(1)


/*
	92. mostrar la cantidad de horas que transcurrieron desde el comienzo del año
*/

select DATEDIFF(DAY,'10-22-1999', GETDATE())


/*
93. mostrar la cantidad de dias transcurridos entre la primer y la ultima venta 

*/

select DATEDIFF(day,(select min(OrderDate) from Sales.SalesOrderHeader),
					(select max(OrderDate) from Sales.salesOrderheader))