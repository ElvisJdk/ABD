--Esquemas

CREATE DATABASE Test
go
use Test

CREATE SCHEMA Ventas

SELECT * FROM SYS.SCHEMAS

CREATE TABLE Ventas.Prueba(codigo int,nombre varchar(30))

DROP SCHEMA Ventas

DROP DATABASE Test

--Creacion de base de datos. Filegroups

/*El siguiente ejemplo crea la base de datos TestDB en la unidad D: con un
espacio inicial de 20 megabytes y crecimiento automático.
*/

CREATE DATABASE TestDB
ON PRIMARY 
	(NAME = N'TestDB_Data',
	FILENAME = N'C:\DATA\TestDB.MDF',
	SIZE = 3 MB,
	FILEGROWTH = 1 MB
	)
LOG ON 
	(NAME = N'TestDB_Log',
	FILENAME = N'C:\DATA\TestDB_Log.LDF',
	SIZE = 1 MB,
	FILEGROWTH = 1 MB
	)

drop database TestDB

/*El siguiente ejemplo crea la base de datos FACTURACION en la unidad C:
con un espacio de 20 megabytes y un archivo de registro de transacciones (LOG)
de 5Mb en el drive E. Todas las tablas que se creen en el filegroup HISTORICO 
se guardarán en el archivo FACTURACION2 en la unidad C.
*/

CREATE DATABASE [INVENTARIO]
ON PRIMARY
	(
	NAME = N'inventario_Data1',
	FILENAME = N'C:\DATA\inventario1.MDF',
	SIZE = 10 MB
	),
FILEGROUP [HISTORICO]
	(
	NAME = N'inventario_Data2',
	FILENAME = N'C:\DATA\inventario2.NDF',
	SIZE = 10 MB
	)
LOG ON
	(
	NAME = N'inventario_Log',
	FILENAME = N'C:\DATA\inventario_Log.LDF',
	SIZE = 5 MB
	)


	drop database INVENTARIO	

	SELECT * FROM SYS.databases
	where name = 'INVENTARIO'
	


	/*
EJERCICIO 3: Creación y uso de esquemas
	Dentro de la base de datos GestionPersonal (creada en el Ejercicio 1):

  a) Cree los esquemas: Rrhh, Contabilidad y Logistica.
  b) Consulte la vista SYS.SCHEMAS para verificar que los tres esquemas
     fueron creados correctamente.
  c) Cree la siguiente tabla dentro del esquema Rrhh:

       Empleados (
           EmpleadoID   int          PRIMARY KEY,
           Apellido     varchar(40)  NOT NULL,
           Nombre       varchar(30)  NOT NULL,
           Cargo        varchar(30)  NULL,
           FechaIngreso  date         NULL
       )

  d) Cree la siguiente tabla dentro del esquema Contabilidad:

       CuentasContables (
           CuentaID     int          PRIMARY KEY,
           Descripcion  varchar(60)  NOT NULL,
           Saldo        decimal(18,2) NULL
       )

  e) Intente eliminar el esquema Rrhh con DROP SCHEMA y observe
     qué ocurre. Justifique el resultado con un comentario en el script.

	*/
	go
	create schema Rrhh
	go
	create schema Contabilidad
	go
	create schema Logistica
	go
	select * from sys.schemas

	CREATE TABLE Rrhh.empleados( EmpleadoID   int          PRIMARY KEY,
           Apellido     varchar(40)  NOT NULL,
           Nombre       varchar(30)  NOT NULL,
           Cargo        varchar(30)  NULL,
           FechaIngreso  date         NULL
)
	
	CREATE TABLE Contabilidad.CuentasContables(           
		   CuentaID     int          PRIMARY KEY,
           Descripcion  varchar(60)  NOT NULL,
           Saldo        decimal(18,2) NULL
       )
	   /*
	   no se puede eliminar por que hay una tabla dentro del schema
	   */
	   drop schema Rrhh

	   /*
	   EJERCICIO 4: Tipos de datos definidos por el usuario
Dentro de la base de datos GestionPersonal:

  a) Cree los siguientes tipos de datos definidos por el usuario (UDT):

       - DNI      basado en char(8),    NOT NULL
       - Telefono basado en varchar(20), NULL
       - Email    basado en varchar(80), NULL

  b) Consulte la vista SYS.TYPES para verificar que los tipos
     fueron registrados


c) Cree la tabla Rrhh.Contactos utilizando los tipos definidos:

       Contactos (
           ContactoID  int        PRIMARY KEY,
           EmpleadoID  int        NOT NULL,  -- FK hacia Rrhh.Empleados
           Dni         DNI,
           Celular     Telefono,
           CorreoElec  Email
       )

     Incluya la FOREIGN KEY hacia Rrhh.Empleados(EmpleadoID).

	   */


	   create type DNI
	   from char(8) not null
	   create type TELEFONO
	   from char(20) null
	   create type EMAIL
	   from char(80) null
	   select * from sys.types
	   
	   create table Rrhh.Contactos(
           ContactoID  int        PRIMARY KEY,
           EmpleadoID  int        NOT NULL,  -- FK hacia Rrhh.Empleados
           Dni         DNI,
           Celular     TELEFONO,
           CorreoElec  EMAIL,
		   foreign key(EmpleadoID) references Rrhh.empleados(EMPLEADOID)
       )

	   

CREATE DATABASE Clinica
ON PRIMARY 
	(NAME = N'Clinica_Data',
	FILENAME = N'C:\DATA\Clinica.MDF',
	SIZE = 8 MB,
	FILEGROWTH = 1 MB
	)
LOG ON 
	(NAME = N'TestDB_Log',
	FILENAME = N'C:\DATA\TestDB_Log.LDF',
	SIZE = 3 MB,
	FILEGROWTH = 1 MB
	)
use Clinica
go
create schema Pacientes
go 
create schema Medicos
go
create type MatriculaMedica
from varchar(10) not null
create type ObraSocial
from varchar(50) null

create table Medicos.Profesionales(
           MedicoID    int               PRIMARY KEY,
           Apellido    varchar(40)       NOT NULL,
           Nombre      varchar(30)       NOT NULL,
           Matricula   MatriculaMedica,
           Especialidad varchar(40)      NULL
)
create table Pacientes.Personas(           PacienteID  int               PRIMARY KEY,
           Apellido    varchar(40)       NOT NULL,
           Nombre      varchar(30)       NOT NULL,
           FechaNac    date              NULL,
           Cobertura   ObraSocial
)

create table Pacientes.Turnos(TurnoID     int               PRIMARY KEY,
           PacienteID  int               NOT NULL,
           MedicoID    int               NOT NULL,
           FechaTurno  datetime          NOT NULL,
           Observaciones varchar(200)    NULL,
           FOREIGN KEY (PacienteID) REFERENCES Pacientes.Personas(PacienteID),
           FOREIGN KEY (MedicoID)   REFERENCES Medicos.Profesionales(MedicoID)
)

select * from sys.schemas
select * from sys.tables

	
drop type MatriculaMedica
drop type ObraSocial
/*
no se pueden eliminar los tipos de datos creados por que estan dentros de las tablas
*/