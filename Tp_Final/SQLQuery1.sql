/*
Ejercicio 1
Contexto: La empresa requiere realizar una actualización masiva en la lista 
de precios de sus productos debido a una nueva normativa impositiva.
Para garantizar la consistencia de los datos, la operación debe ser atómica (todo o nada).
*/

/*
Consigna: Escribir un script en Transact-SQL que cumpla con los siguientes requerimientos:
	Lógica de Negocio: Incrementar un 15% el precio (ListPrice) de todos los productos
	de la tabla Production.Product cuyo precio actual sea mayor a cero.

	Control de Transacciones: Si tras aplicar el incremento, el precio mínimo de los
	productos modificados no supera el promedio original de precios de la empresa,
	la operación debe considerarse riesgosa y revertirse por completo (ROLLBACK).
	De lo contrario, se debe confirmar (COMMIT).

	Manejo de Errores Dinámico: Envolver toda la lógica en un bloque TRY...CATCH. 
	Si ocurre un error inesperado en la base de datos (por ejemplo, un error aritmético 
	de división por cero simulado dinámicamente), se debe:

		Verificar mediante funciones o variables del sistema si existe una transacción
		activa para revertirla.

		Capturar las propiedades del error (ERROR_NUMBER(), ERROR_MESSAGE()).

		Relanzar un error personalizado utilizando THROW o RAISERROR informando la falla crítica.
*/

use AdventureWorks2008R2;
DECLARE @PromedioOriginal MONEY;
DECLARE @MinimoPostIncremento MONEY;
DECLARE @FilasModificadas INT;

BEGIN TRY

    -- Iniciamos la transacción controlada
    BEGIN TRANSACTION;

    -- Obtener el promedio original antes del cambio
    SELECT @PromedioOriginal = AVG(ListPrice)
    FROM Production.Product
    WHERE ListPrice > 0;

    PRINT 'Auditoria: Promedio original de precios: '
        + CAST(@PromedioOriginal AS VARCHAR);

    -- Aplicamos la lógica de negocio (incremento del 15%)
    UPDATE Production.Product
    SET ListPrice = ListPrice * 1.15
    WHERE ListPrice > 0;

    -- Capturamos las filas afectadas
    SET @FilasModificadas = @@ROWCOUNT;

    PRINT 'Auditoria: Productos afectados por el incremento: '
        + CAST(@FilasModificadas AS VARCHAR);

    -- Validación posterior
    SELECT @MinimoPostIncremento = MIN(ListPrice)
    FROM Production.Product
    WHERE ListPrice > 0;

    PRINT 'Auditoria: Precio mínimo detectado post-incremento: '
        + CAST(@MinimoPostIncremento AS VARCHAR);

    -- Regla de negocio
    IF @MinimoPostIncremento <= @PromedioOriginal
    BEGIN
        ROLLBACK TRANSACTION;

        PRINT 'X Operación revertida: el precio mínimo no supera el promedio original.';
    END
    ELSE
    BEGIN
        COMMIT TRANSACTION;

        PRINT '✓ Operación confirmada: precios actualizados correctamente.';
    END

END TRY

BEGIN CATCH

    PRINT 'Se detectó un error crítico en la ejecución';

    -- Si hay una transacción activa, se revierte
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;

        PRINT 'Transacción revertida automáticamente para preservar la integridad de AdventureWorks2008R2.';
    END;

    -- Auditoría del error
    PRINT '---------------------------------------------------------';
    PRINT 'Código de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Descripción: ' + ERROR_MESSAGE();
    PRINT 'Severidad: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    PRINT '---------------------------------------------------------';

    -- Error personalizado
    THROW 51000,
    'Error de Proceso: La actualización masiva falló debido a un problema técnico o aritmético interno. Operación cancelada.',
    1;

END CATCH;



/*
Ejercicio 2
Contexto: La cadena de complejos deportivos "SportNet" requiere el diseño desde cero de su infraestructura
de base de datos corporativa. Debido al alto volumen de transacciones de accesos diarios, se exige una 
arquitectura que distribuya físicamente la información para optimizar el rendimiento de los discos, 
organice los módulos por responsabilidades mediante capas lógicas y estandarice tipos de datos críticos.
*/
/*
Consigna: Desarrollar un script unificado en Transact-SQL que implemente las siguientes directivas 
de arquitectura física y lógica:

    * Infraestructura de Almacenamiento (Sistema de Archivos): Crear la base de datos SportNetDB 
    distribuyendo sus archivos en dos grupos diferenciados:

    * PRIMARY (Datos operativos y de configuración): Un archivo .MDF de 10 MB con crecimiento de 2 MB.

    * HISTORICO (Registro masivo de accesos/auditoría): Un grupo de archivos secundario con un archivo
    .NDF de 15 MB para balancear la carga de lectura/escritura de datos antiguos.

    * HISTORICO (Registro masivo de accesos/auditoría): Un grupo de archivos secundario con un archivo 
     .NDF de 15 MB para balancear la carga de lectura/escritura de datos antiguos.

Organización de Objetos (Esquemas): Estructurar la base de datos dividiéndola en dos áreas de negocio
bien delimitadas: Socios (para datos personales y membresías) y Facturacion (para cobros y aranceles).

Estandarización de Dominios (UDT): Crear tipos de datos definidos por el usuario para asegurar la
integridad semántica de la base de datos:

    * TipoDocumento (basado en VARCHAR(12), obligatorio).
    * CodigoPostal (basado en CHAR(8), opcional).

Construcción de Tablas Relacionales: Diseñar tres tablas interactuando con los esquemas y los UDT 
creados, definiendo correctamente sus claves primarias, externas y asignaciones de Filegroups:
    
    * Socios.FichaPersonal (Almacenada en el Filegroup PRIMARY).
    * Socios.RegistroAccesos (Almacenada explícitamente en el Filegroup HISTORICO).


*/

USE master;
GO

--  1. CREACIÓN DE LA BASE DE DATOS

CREATE DATABASE SportNetDB
ON PRIMARY
(
    NAME = N'SportNet_Data',
    FILENAME = N'C:\DATA\SportNet.mdf',
    SIZE = 10MB,
    FILEGROWTH = 2MB
),
FILEGROUP HISTORICO
(
    NAME = N'SportNet_Historico_Data',
    FILENAME = N'C:\DATA\SportNet_Hist.ndf',
    SIZE = 15MB,
    FILEGROWTH = 5MB
)
LOG ON
(
    NAME = N'SportNet_Log',
    FILENAME = N'C:\DATA\SportNet_Log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB
);
GO


USE SportNetDB;
GO

 -- 2. CREACIÓN DE ESQUEMAS


CREATE SCHEMA Socios;
GO

CREATE SCHEMA Facturacion;
GO

SELECT name
FROM sys.schemas
WHERE name IN ('Socios','Facturacion');

--  3. TIPOS DE DATOS DEFINIDOS POR EL USUARIO

CREATE TYPE TipoDocumento
FROM VARCHAR(12) NOT NULL;
GO

CREATE TYPE CodigoPostal
FROM CHAR(8) NULL;
GO


 -- 4. TABLAS

-- Tabla principal de socios (PRIMARY)

CREATE TABLE Socios.FichaPersonal
(
    SocioID INT IDENTITY(1,1),
    Apellido VARCHAR(50) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Documento TipoDocumento,
    CP CodigoPostal,
    FechaAlta DATE DEFAULT GETDATE(),

    CONSTRAINT PK_FichaPersonal
        PRIMARY KEY (SocioID)
)
ON [PRIMARY];
GO

SELECT *
FROM sys.tables
WHERE name = 'FichaPersonal';

USE SportNetDB;
GO



-- Tabla histórica de accesos (HISTORICO)

CREATE TABLE Socios.RegistroAccesos
(
    AccesoID BIGINT IDENTITY(1,1),
    SocioID INT NOT NULL,
    FechaHora DATETIME DEFAULT GETDATE(),
    DispositivoID INT NOT NULL,

    CONSTRAINT PK_RegistroAccesos
        PRIMARY KEY (AccesoID),

    CONSTRAINT FK_RegistroAccesos_Socios
        FOREIGN KEY (SocioID)
        REFERENCES Socios.FichaPersonal(SocioID)
)
ON [HISTORICO];
GO

-- Tabla de facturación

CREATE TABLE Facturacion.Cobros
(
    CobroID INT IDENTITY(1,1),
    SocioID INT NOT NULL,
    FechaCobro DATE NOT NULL,
    Importe DECIMAL(10,2) NOT NULL,
    Concepto VARCHAR(100) NOT NULL,

    CONSTRAINT PK_Cobros
        PRIMARY KEY (CobroID),

    CONSTRAINT FK_Cobros_Socios
        FOREIGN KEY (SocioID)
        REFERENCES Socios.FichaPersonal(SocioID)
)
ON [PRIMARY];
GO


 -- 5. VERIFICACIONES


SELECT *
FROM sys.schemas
WHERE name IN ('Socios','Facturacion');
GO

SELECT *
FROM sys.types
WHERE is_user_defined = 1;
GO

SELECT name
FROM sys.tables;
GO


--Ejercicio 3
/*
Contexto: El departamento de desarrollo de software ha detectado serios problemas de redundancia,
anomalías de actualización y falta de integridad en el almacenamiento de las solicitudes de cotización.
Se presenta una estructura no normalizada (vistas de tabla única o "tabla plana") y se solicita su proceso
de normalización completo.
*/
--Consigna: Dada la siguiente estructura de datos plana:
/*
puesto_Solicitado = #Presupuesto + Fecha_Dia + Fecha_Caducidad + Razon_Social_Cliente + Codigo_Producto
                    + Descripcion_Producto + Precio_Unitario + Cantidad + Precio_x_Cantidad + Precio_Total


Aplicar el proceso de normalización paso a paso explicando las transformaciones para alcanzar la Primera (1FN)
, Segunda (2FN) y Tercera (3FN) Forma Normal. Omitir los atributos derivados o calculados en el modelo físico 
final para respetar las buenas prácticas de bases de datos relacionales.

*/
/*
1FN
Puesto_Solicitado = @#Presupuesto + Fecha del dia + Fecha Caducidad Presupuesto + Razón Social + #Precio Total.

Puesto_Solicitado = @#Presupuesto + @#Codigo Producto + Descripción Producto + #Precio Unitario + #Cantidad + #Precio x Cantidad


2FN
Presupuesto_Solicitado = @#Presupuesto + Fecha del dia + Fecha Caducidad Presupuesto + Razón Social + #Precio Total.

Presupuesto_Detalle = @#Presupuesto + @#Codigo Producto + #Cantidad + #Precio x Cantidad

Producto =  @#Codigo Producto + Descripción Producto + #Precio Unitario



3FN
Presupuesto_Solicitado = @#Presupuesto + Fecha del dia + Fecha Caducidad Presupuesto + Razón Social + #Precio Total.

Presupuesto_Detalle = @#Presupuesto + @#Codigo Producto + #Cantidad + #Precio x Cantidad

Producto =  @#Codigo Producto + Descripción Producto + #Precio Unitario



Atributos calculados  
#Precio x Cantidad =  #Precio Unitario * #Cantidad
#Precio Total = sum(#Precio Unitario * #Cantidad)


Estructura Normalizada
Presupuesto_Solicitado = @#Presupuesto + Fecha del dia + Fecha Caducidad Presupuesto + Razón Social.

Presupuesto_Detalle = @#Presupuesto + @#Codigo Producto + #Cantidad

Producto =  @#Codigo Producto + Descripción Producto + #Precio Unitario


*/

--Ejercicio 4

/*
Contexto: El departamento de auditoría detectó que las búsquedas y reportes sobre la tabla de socios 
están sufriendo serios problemas de rendimiento debido a la falta de una estrategia de indexación sólida.
Además, se han reportado ingresos de números de documentos duplicados. Se solicita rediseñar la estructura 
de índices de la tabla para garantizar la máxima velocidad de consulta y asegurar la integridad de los datos.

*/

/*
Consigna: Escribir un script unificado en Transact-SQL que simule y resuelva el ciclo de vida de optimización 
de la tabla Socios.FichaPersonal cumpliendo las siguientes directivas:

    * Punto de Partida Ineficiente: Crear la estructura base sin asignación automática de índices y cargar 
      registros que fuercen la existencia de apellidos duplicados.

    * Conflicto de Unicidad: Intentar aplicar un índice agrupado único sobre una columna con datos duplicados 
      para analizar el comportamiento del motor.

    * Estrategia de Indexación Mixta: * Implementar un índice agrupado no único para optimizar búsquedas por 
      rangos alfabéticos de apellidos
            
            * Configurar la clave primaria de forma "No Agrupada" para evitar conflictos estructurales inmediatos.

    * Garantía de Integridad: Crear un índice único no agrupado para el documento de identidad y verificar el
      bloqueo ante intentos de duplicación.

    * Reingeniería Estructural (Refactorización): Demostrar la capacidad de reestructurar la tabla eliminando
      el índice anterior y regenerando la Clave Primaria para que sea, finalmente, el índice agrupado principal
      de la tabla.

*/

PRINT '>>> 1. Creando tabla de optimización de socios...';

-- Eliminamos la tabla si ya existía del punto 2 para hacer la simulación limpia
IF OBJECT_ID('Socios.FichaPersonal') IS NOT NULL 
    DROP TABLE Facturacion.Cobros;
GO

IF OBJECT_ID('Socios.FichaPersonal') IS NOT NULL 
    DROP TABLE Socios.FichaPersonal;
GO

CREATE TABLE Socios.FichaPersonal
(
    SocioID CHAR(5) NOT NULL,
    Documento CHAR(8) NOT NULL,
    Apellido VARCHAR(30) NOT NULL,
    Nombre VARCHAR(30) NOT NULL,
    ArancelMensual DECIMAL(10,2) NULL
);
GO
select * from Socios.FichaPersonal;
-- Inserción de registros de prueba (con apellidos duplicados adrede)
INSERT INTO Socios.FichaPersonal (SocioID, Documento, Apellido, Nombre, ArancelMensual)
VALUES  
('S0001', '40123456', 'Pérez', 'Juan', 8500.00),
('S0002', '41123457', 'Pérez', 'María', 7250.00),
('S0003', '42123458', 'Gómez', 'Lucas', 9000.00),
('S0004', '43123459', 'Rodríguez', 'Ana', 6500.00),
('S0005', '44123460', 'Fernández', 'Luis', 4000.00),
('S0006', '45123461', 'López', 'Laura', 9750.00);
GO

--conflico de unicidad
create unique clustered index i_apellido_unico
on Socios.FichaPersonal(Apellido);
go
-- no se puede crear indices UNIQUE con valores repetidos

--Estrategia de Indexación Mixta
create clustered index I_apellido_grupado
on Socios.FichaPersonal(Apellido)
go

SELECT *
FROM Socios.FichaPersonal
WHERE Apellido BETWEEN 'G' AND 'P';

-- pk no agrupada para SocioID

ALTER TABLE Socios.FichaPersonal
ADD CONSTRAINT PK_FichaPersonal
PRIMARY KEY NONCLUSTERED (SocioID);
GO


--Garantía de Integridad
create unique nonclustered index I_Documento
on Socios.FichaPersonal(Documento);
go

INSERT INTO Socios.FichaPersonal
VALUES
(6,'Lopez','Mario','30111222');
GO

-- no nos deja insertar un documento ya existente

--Reingeniería Estructural

DROP INDEX I_apellido_grupado
ON Socios.FichaPersonal;
GO

ALTER TABLE Socios.FichaPersonal
DROP CONSTRAINT PK_FichaPersonal;
GO

ALTER TABLE Socios.FichaPersonal
ADD CONSTRAINT PK_FichaPersonal
PRIMARY KEY CLUSTERED (SocioID);
GO

EXEC sp_helpindex 'Socios.FichaPersonal';



--Ejercicio 5

/*
Contexto: El volumen de transacciones de preventas y detalles de órdenes en AdventureWorks ha crecido 
exponencialmente, ralentizando los índices y aumentando los tiempos de mantenimiento de backups.
Como Ingeniero de Datos / DBA, se le solicita diseñar e implementar una arquitectura de tabla particionada
para la auditoría de ventas trimestrales del año 2011(Sales.SalesOrderDetail), distribuyendo la carga en 
almacenamiento físico diferenciado para optimizar el rendimiento de entrada/salida (I/O).

*/

/*
Consigna: Desarrollar un script en Transact-SQL que ejecute paso a paso las siguientes 
fases de ingeniería de almacenamiento:
        
        * Infraestructura Física: Crear 4 Filegroups independientes con un archivo secundario (.ndf) cada
          uno en el directorio de datos.

        * Lógica de Particionado: Definir una función de partición basada en rangos temporales para segmentar 
          los trimestres de un año fiscal y mapearlos mediante un esquema de partición a los Filegroups creados.

        * Migración Masiva: Construir una réplica de la tabla de órdenes de venta particionada, poblarla con 
          la información histórica real de AdventureWorks y testear inserciones en los límites de los rangos.

        * Metadatos y Auditoría: Consultar las vistas del sistema para auditar la distribución de registros por
          partición exacta, documentando detalladamente las diferencias operativas de las funciones de partición.

        * Rollback Estructural: Proveer la secuencia de desmantelamiento seguro y ordenado de los objetos creados
          para limpieza del entorno.
*/

use AdventureWorks;

CREATE PARTITION FUNCTION pf_OrderDate (datetime)
AS RANGE RIGHT
FOR VALUES ('01/04/2011', '01/07/2011','01/10/2011')

alter database AdventureWorks
add filegroup FG_T1;
go

alter database AdventureWorks
add filegroup FG_T2;
go

alter database AdventureWorks
add filegroup FG_T3;
go

alter database AdventureWorks
add filegroup FG_T4;
go

BACKUP LOG AdventureWorks TO DISK = 'NUL';

ALTER DATABASE AdventureWorks 
ADD FILE 
( NAME = data1,
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AWd1.ndf',
  SIZE = 1MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 1MB)
TO FILEGROUP FG_T1
GO

SELECT name, type_desc
FROM sys.filegroups;

ALTER DATABASE AdventureWorks 
ADD FILE 
( NAME = data2,
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AWd2.ndf',
  SIZE = 1MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 1MB)
TO FILEGROUP FG_T2
GO

ALTER DATABASE AdventureWorks 
ADD FILE 
( NAME = data3,
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AWd3.ndf',
  SIZE = 1MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 1MB)
TO FILEGROUP FG_T3
GO

ALTER DATABASE AdventureWorks 
ADD FILE 
( NAME = data4,
  FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AWd4.ndf',
  SIZE = 1MB,
  MAXSIZE = 100MB,
  FILEGROWTH = 1MB)
TO FILEGROUP FG_T4
GO


CREATE PARTITION SCHEME ps_OrderDate
AS PARTITION pf_OrderDate 
TO (FG_T1, FG_T2, FG_T3, FG_T4)
GO


CREATE TABLE dbo.PartitionedTransactions
(
	TransactionID int IDENTITY(1,1) NOT NULL,
	ProductID int NOT NULL,
	TransactionDate datetime NOT NULL DEFAULT (getdate()),
	TransactionType nchar(1) NOT NULL
)
ON ps_OrderDate(TransactionDate)
GO

INSERT INTO dbo.PartitionedTransactions
SELECT	ProductID, TransactionDate, TransactionType
FROM Production.TransactionHistory
GO

INSERT INTO dbo.PartitionedTransactions
VALUES
(1, '01/01/2011', 'S')
GO




SELECT * FROM sys.Partitions
WHERE [object_id] = OBJECT_ID('dbo.PartitionedTransactions')


SELECT TransactionID, TransactionDate, $Partition.pf_OrderDate(TransactionDate) PartitionNo
FROM dbo.PartitionedTransactions


SELECT MIN(TransactionDate) FirstTran, $Partition.pf_OrderDate(TransactionDate) PartitionNo
FROM dbo.PartitionedTransactions
GROUP BY $Partition.pf_OrderDate(TransactionDate)
ORDER BY PartitionNo



DROP TABLE dbo.PartitionedTransactions
DROP PARTITION SCHEME ps_OrderDate
DROP PARTITION FUNCTION pf_OrderDate
ALTER DATABASE AdventureWorks REMOVE FILE data1
ALTER DATABASE AdventureWorks REMOVE FILE data2
ALTER DATABASE AdventureWorks REMOVE FILE data3
ALTER DATABASE AdventureWorks REMOVE FILE data4
ALTER DATABASE AdventureWorks REMOVE FILEGROUP FG_T1
ALTER DATABASE AdventureWorks REMOVE FILEGROUP FG_T2
ALTER DATABASE AdventureWorks REMOVE FILEGROUP FG_T3
ALTER DATABASE AdventureWorks REMOVE FILEGROUP FG_T4




--6 Ejercicio 6


/*
Contexto: La Fintech "CryptoAr" está expandiendo su infraestructura y requiere configurar la seguridad
de acceso global para su nueva instancia de producción de SQL Server. La  política corporativa exige 
auditorías estrictas de acceso, separación de funciones según el principio de "privilegio mínimo" y la 
habilitación segura de logins de aplicaciones.


Consigna: Escribir un script unificado en Transact-SQL que implemente la configuración de seguridad 
perimetral del servidor bajo los siguientes requerimientos:

*/

/*
    Auditoría de Instancia: Verificar programáticamente el modo de seguridad de la instancia. Si no admite
    logins internos, dejar documentado el procedimiento de cambio a modo mixto y el requerimiento operativo
    de infraestructura.

    Aprovisionamiento con Políticas: Crear tres logins de servidor para el nuevo personal del Centro de
    Operaciones de Red (NOC) y del Equipo de Seguridad (SecOps):

        * SecAuditor_Gomez

        * NocMonitor_Lopez

        * DbaJunior_Paz


Todos deben cumplir obligatoriamente con las políticas de expiración y complejidad del sistema operativo.
        
        * Gestión de Ciclo de Vida: Simular una ventana de mantenimiento donde se bloqueen accesos sospechosos,
          se reestablezcan credenciales comprometidas y se reasigne el contexto de base de datos por defecto
          a un entorno seguro corporativo.

        * Separación de Funciones (Server Roles): Asignar roles fijos de servidor específicos según el perfil
          técnico:

                   * El auditor debe poder revisar logs y configuraciones globales (securityadmin).

                   * El monitor del NOC debe analizar la salud, recursos y procesos del motor (processadmin).

                   * El DBA Junior debe administrar el espacio en disco y archivos lógicos (diskadmin).

        
        *Validación Dinámica: Consultar las vistas de catálogo del sistema para verificar estados y mapeos
        de roles vigentes.
*/
use master;
go
/*
1) abrir sql server management studio
2) click derecho sobre la instancia del usuario
3) properties
4) security
5) seleccionar sql server and windows authentication mode
*/

SELECT
    SERVERPROPERTY('ServerName') AS Servidor,
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
        WHEN 1 THEN 'Solo Windows Authentication'
        WHEN 0 THEN 'Modo Mixto (Windows + SQL Server)'
    END AS ModoSeguridad;
GO

create login SecAuditor_Gomez
with password = 'Gomez123!',
check_policy = on,
check_expiration = on;
go

create login NocMonitor_Lopez
with password = 'Lopez123!',
check_policy = on,
check_expiration = on;
go

create login DbaJunior_Paz
with password = 'Paz123!',
check_policy = on,
check_expiration = on;
go


-- gestion de ciclo de vida

--simulacion de bloqueo temporal

alter login DbaJunior_Paz disable;
go

-- similacion de reactivacion

alter login DbaJunior_Paz enable;
go

--cambiar contraseña

alter login DbaJunior_Paz
with password = 'DbaJunior_Paz123!';
go

--asignamos una base de datos al login

alter login DbaJunior_Paz
with default_database = master;
go


alter login NocMonitor_Lopez
with default_database = master;
go

alter login SecAuditor_Gomez
with default_database = master;
go


--separacion de funciones

alter server role securityadmin
add member SecAuditor_Gomez;
go

alter server role processadmin
add member NocMonitor_Lopez;
go

alter server role diskadmin
add member DbaJunior_Paz;
go


--validacion de login

SELECT
    name,
    type_desc,
    is_disabled,
    default_database_name
FROM sys.server_principals
WHERE name IN
(
    'SecAuditor_Gomez',
    'NocMonitor_Lopez',
    'DbaJunior_Paz'
);
GO

--validadion de roles

SELECT
    sp.name AS LoginName,
    sr.name AS ServerRole
FROM sys.server_role_members rm
INNER JOIN sys.server_principals sr
    ON rm.role_principal_id = sr.principal_id
INNER JOIN sys.server_principals sp
    ON rm.member_principal_id = sp.principal_id
WHERE sp.name IN
(
    'SecAuditor_Gomez',
    'NocMonitor_Lopez',
    'DbaJunior_Paz'
)
ORDER BY sp.name;
GO

--Ejercicio 7

/*
Contexto: La plataforma de streaming "StreamPlay" necesita configurar la seguridad interna de su 
base de datos de producción. El área de ciberseguridad exige aplicar de forma estricta el principio de
"privilegio mínimo", resguardar datos sensibles de los clientes (como los métodos de pago) y dar acceso
controlado al equipo de soporte, creadores de contenido y auditores de sistemas.

*/

/*
Consigna: Desarrollar un script unificado en Transact-SQL que implemente la infraestructura de seguridad
lógica en la base de datos StreamPlayDB resolviendo los siguientes requerimientos prácticos:

    * Modelado Base: Crear la base de datos y tres estructuras clave: Suscripciones (datos de usuarios y cobros)
    , Catalogo (películas y series) y Visualizaciones (historial de reproducción).

    * Aprovisionamiento Perimetral: Crear cinco logins a nivel de servidor y sus correspondientes usuarios
      mapeados exclusivamente dentro de la base de datos del negocio.

    * Roles de Base de Datos: Asignar los roles fijos db_datareader y db_datawriter según corresponda para
      dar acceso de lectura global o control operativo de datos.

    * Seguridad Granular (GRANT): Configurar permisos específicos tabla por tabla para perfiles gerenciales, 
      limitando la capacidad de eliminación destructiva de registros.

    * Restricción de Privilegios (DENY): Implementar bloqueos perimetrales absolutos mediante DENY.
      Se debe proteger el catálogo de modificaciones accidentales y ocultar columnas con datos financieros
      sensibles a nivel de celda.

    * Seguridad Avanzada y Roles Personalizados: Crear un rol de auditoría a la medida que herede permisos
      de lectura y obtenga privilegios de inspección de código fuente (VIEW DEFINITION).

    * Normalización de Permisos (REVOKE): Demostrar la remoción de privilegios explícitos para devolver
      una entidad a su estado heredado neutral.
*/




create database StreamPlayDB;
use StreamPlayDB;

CREATE TABLE Suscripciones(
    IdSuscripcion INT IDENTITY(1,1) PRIMARY KEY,
    Usuario VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    MetodoPago VARCHAR(50) NOT NULL,
    Tarjeta VARCHAR(30) NOT NULL,
    FechaAlta DATE NOT NULL,
    ImporteMensual DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE Catalogo(
    IdContenido INT IDENTITY(1,1) PRIMARY KEY,
    Titulo VARCHAR(150) NOT NULL,
    TipoContenido VARCHAR(30),
    Genero VARCHAR(50),
    AnioEstreno INT
);
GO

CREATE TABLE Visualizaciones(
    IdVisualizacion INT IDENTITY(1,1) PRIMARY KEY,
    IdSuscripcion INT,
    IdContenido INT,
    FechaVisualizacion DATETIME DEFAULT GETDATE(),
    DuracionMinutos INT,
    
    FOREIGN KEY(IdSuscripcion)
        REFERENCES Suscripciones(IdSuscripcion),

    FOREIGN KEY(IdContenido)
        REFERENCES Catalogo(IdContenido)
);
GO

--Aprovisionamiento Perimetral: 

create login auditoriaSP
with password = 'auditoria123!',
check_policy = on;

create login gerenteSP
with password = 'gerente123!',
check_policy = on;

create login lectorSP
with password = 'lector123!',
check_policy = on;

create login creadorSP
with password = 'creadorSP',
check_policy = on;

create login operadorSP
with password = 'rrhh123!',
check_policy = on;

drop login creadorSP;

create user U_auditoriaSP for login auditoriaSP;
create user U_gerenteSP for login gerenteSP;
create user U_lectorSP for login lectorSP;
create user U_creadorSP for login creadorSP;
create user U_operador for login operadorSP;


alter role db_datareader 
add member U_lectorSP;
go

alter role db_datareader
add member U_operador;
go

alter role db_datawriter 
add member U_creadorSP;
go
-- seguridad granular, el gerente puede hacer (update,insert,select)
grant select on Suscripciones
to U_gerenteSP;

grant select on Visualizaciones
to U_gerenteSP;

grant select on Catalogo
to U_gerenteSP;


 grant insert, update on Suscripciones
 to U_gerenteSP;

 grant insert, update on Catalogo
 to U_gerenteSP;

 grant insert, update on Visualizaciones
 to U_gerenteSP;

 -- el gerente no puede eliminar 


 deny delete on Visualizaciones
 to U_gerenteSP; 

 deny delete on Catalogo
 to U_gerenteSP;

 deny delete on Suscripciones
 to U_gerenteSP; 


 -- Restricción de Privilegios 
 --denegar la eliminacion para el role db_datawriter(U_creadorSP)

 grant select on Catalogo
 to U_creadorSP;

 deny insert on Catalogo
 to U_creadorSP;

 deny update on Catalogo
 to U_creadorSP
 
 deny delete on Catalogo
 to U_creadorSP;

 -- U_operador y U_auditoriaSP no pueden ver el importe mensual de la tabla suscripsioness

 deny select on Suscripciones(ImporteMensual) to U_operador;
 deny select on Suscripciones(ImporteMensual) to U_auditoriaSP;



 create role auditoriaview;

 alter role auditoriaview
 add member U_auditoriaSP;  
 go

 grant select to auditoriaview;

 grant VIEW DEFINITION
 to auditoriaview;


 -- Normalización de Permisos 
 -- dar permisos y quitarselos

 grant insert on Catalogo
 to U_auditoriaSP;

 revoke insert on Catalogo
 from U_auditoriaSp;




 --Ejercicio 8

 /*
 Contexto: Para optimizar el espacio de almacenamiento de la plataforma "SportNet", el equipo de desarrollo
 solicitó que los registros de la tabla de accesos que tengan más de 30 días de antigüedad se eliminen
 de forma automática. De esta manera, se evita que la base de datos crezca indefinidamente con datos obsoletos.


 Consigna: Escribir un script unificado en Transact-SQL utilizando el subsistema de msdb que configure un 
 Job automatizado en el SQL Server Agent bajo las siguientes especificaciones:

        * Configuración Global: Crear un Job llamado Limpieza_Automatica_Accesos_SportNet.
        
        * Definición del Paso (Job Step): Configurar un paso de ejecución de tipo T-SQL que aplique un 
          comando estándar de eliminación (DELETE) sobre la tabla Socios.RegistroAccesos de la base de datos
          SportNetDB. El comando debe borrar las filas cuya fecha sea menor a la actual. Establecer una 
          política de 2 reintentos ante fallas.

        * Planificación Horaria (Schedule): Programar la tarea para que se ejecute de forma recurrente 
          todos los domingos a las 03:00 AM.

        * Asignación de Destino: Enlazar el Job para que corra de manera local en la instancia del 
          servidor actual.



 */

 use msdb;
 -- creo JOB en msdb
EXEC dbo.sp_add_job
    @job_name = N'Limpieza_Automatica_Accesos_SportNet', 
    @enabled = 1,
    @description = N'Elimina registros de accesos con mas de 30 dias de antiguedad' ;
GO

EXEC sp_add_jobstep
    @job_name = 'Limpieza_Automatica_Accesos_SportNet',
    @step_name = 'Eliminar_Accesos_Antiguos',
    @subsystem = 'TSQL',
    @database_name = 'SportNetDB',
    @command = '
        DELETE FROM Socios.RegistroAccesos
        WHERE FechaAcceso < DATEADD(DAY,-30,GETDATE());
    ',
    @retry_attempts = 2,
    @retry_interval = 5;
GO
--⦁	Planificación Horaria (Schedule

EXEC sp_add_schedule
    @schedule_name = 'Domingos_03AM',
    @enabled = 1,
    @freq_type = 8,               
    @freq_interval = 1,           
    @freq_recurrence_factor = 1,  
    @active_start_time = 030000;
GO

-- asocio el schedule al job

EXEC sp_attach_schedule
    @job_name = 'Limpieza_Automatica_Accesos_SportNet',
    @schedule_name = 'Domingos_03AM';
GO

-- asigno el job al servidor local


EXEC sp_add_jobserver
    @job_name = 'Limpieza_Automatica_Accesos_SportNet',
    @server_name = '(LOCAL)';
GO



--Ejercicio 9

/*
Contexto: La cadena "CoffeeHouse" opera con un sistema de puntos de venta centralizado. Debido a la 
criticidad de las transacciones comerciales, el área de sistemas exige implementar una política de 
respaldo bajo el modelo de recuperación completa (FULL). Como Administrador de Bases de Datos (DBA),
debe simular el flujo diario de operaciones, ejecutar la secuencia de copias de seguridad programadas 
y, ante un escenario simulado de pérdida total de datos, liderar el protocolo de restauración de 
emergencia sin perder una sola venta.

Consigna: Desarrollar un script unificado en Transact-SQL que implemente las siguientes fases de contingencia:
        * Infraestructura Base: Crear la base de datos CoffeeHouseDB junto con las tablas relacionales 
          de clientes y órdenes de compra con una carga de datos inicial (Simulación: Estado de ventas 
          a las 08:00 AM).

        * Línea Base General (Backup Full): Configurar el modelo de recuperación en modo completo y generar 
          el respaldo total de la estructura (Simulación: 09:00 AM).

        * Punto de Control Acumulativo (Backup Diferencial): Insertar actividad comercial y generar un
          respaldo diferencial para empaquetar los cambios de la mañana (Simulación: 11:00 AM).

        * Resguardos Transaccionales (Backups de Log): Intercalar nuevas ventas con la ejecución secuencial
          de dos copias del Log de transacciones para registrar la actividad de la tarde (Simulación: 12:00 PM y 02:00 PM).

        * Protocolo de Recuperación: Simular un colapso crítico del sistema y reconstruir la base de
          datos de forma ordenada utilizando las cláusulas NORECOVERY y RECOVERY en el orden cronológico 
          correcto.

        * Validación de Integridad: Comprobar mediante consultas de combinación que la base de datos
          fue recuperada en su totalidad.

*/






use CoffeeHouseDB;

create database CoffeeHouseDB;
go
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    Localidad VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY IDENTITY(1,1),
    ClienteID INT FOREIGN KEY REFERENCES Clientes(ClienteID),
    Producto VARCHAR(100) NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    FechaPedido DATETIME DEFAULT GETDATE()
);
GO

INSERT INTO Clientes (Nombre, Localidad) VALUES 
('Erica Ramos', 'Palermo'),
('Jorge Galván', 'Almagro'),
('Estudio Multimedial', 'Caballito');

INSERT INTO Pedidos (ClienteID, Producto, Monto) VALUES 
(1, 'Notebook Samsung Book3', 1200000.00),
(2, 'Monitor Samsung Odyssey G4', 450000.00);
GO



SELECT name, recovery_model_desc
FROM sys.databases
WHERE name = 'CoffeeHouseDB'; -- modo full

ALTER DATABASE [CoffeeHouseDB] SET RECOVERY FULL;
GO

BACKUP DATABASE [CoffeeHouseDB]
TO DISK = 'c:\backups\CoffeeHouseDB.bak'
WITH FORMAT, MEDIANAME = 'CoffeeHouseDB_media', NAME = 'Full CoffeeHouseDB Backup';
GO



--⦁	Punto de Control Acumulativo 
INSERT INTO Clientes (Nombre, Localidad) VALUES 
('prueba', '123');

BACKUP DATABASE CoffeeHouseDB
TO DISK = 'C:\Backups\CoffeeHouseDB_DIFF.bak'
WITH DIFFERENTIAL,
NAME = 'Backup Diferencial 11AM';
GO


-- insercion de registros y log backup
INSERT INTO Clientes (Nombre, Localidad) VALUES 
('pruebaLog', '123');


BACKUP LOG CoffeeHouseDB
TO DISK = 'C:\Backups\CoffeeHouseDB_LOG1.trn'
WITH INIT,
NAME = 'Log Backup 12PM';
GO

-- insercion de registros y log backup

INSERT INTO Ordenes(IdCliente, Total)
VALUES
(1, 22.00);
GO

BACKUP LOG CoffeeHouseDB
TO DISK = 'C:\Backups\CoffeeHouseDB_LOG1.trn'
WITH INIT,
NAME = 'Log Backup 12PM';
GO

/* 1. Restaurar FULL */

RESTORE DATABASE CoffeeHouseDB
FROM DISK = 'C:\Backups\CoffeeHouseDB_FULL.bak'
WITH NORECOVERY;
GO

/* 2. Restaurar DIFERENCIAL */

RESTORE DATABASE CoffeeHouseDB
FROM DISK = 'C:\Backups\CoffeeHouseDB_DIFF.bak'
WITH NORECOVERY;
GO

/* 3. Restaurar LOG 1 */

RESTORE LOG CoffeeHouseDB
FROM DISK = 'C:\Backups\CoffeeHouseDB_LOG1.trn'
WITH NORECOVERY;
GO

/* 4. Restaurar LOG 2 */

RESTORE LOG CoffeeHouseDB
FROM DISK = 'C:\Backups\CoffeeHouseDB_LOG2.trn'
WITH RECOVERY;
GO

--Ejercicio 10
/*

Ejercicio 10
Responde el siguiente cuestionario de múltiple choice sobre Alta Disponibilidad.
1.  Si la prioridad absoluta de una empresa es poder utilizar el servidor secundario 
    de respaldo para generar reportes pesados de forma aislada, ¿cuál es la solución 
    tecnológica recomendada por defecto en la actualidad?
   marco con ** la correcta

    ⦁	A) Clustering (FCI), porque el nodo pasivo permite lecturas transparentes.
    ⦁	B) Mirroring (Reflejo), ya que mantiene la base de datos en estado de recuperación legible.
    **	C) Always On AG, debido a que permite configurar copias legibles (Secondaries Read-Only) para reportes.
    ⦁	D) Replicación, ya que es la opción que ofrece el failover automático más veloz del mercado.

2. Al analizar la infraestructura de almacenamiento de la tecnología Clustering (FCI), ¿cuál es el principal
        riesgo técnico asociado a su diseño?

      
    ⦁	A) Que duplica el uso de discos independientes por cada servidor, encareciendo los costos.
    **	B) El uso de almacenamiento compartido (SAN/NAS), que introduce un riesgo de punto único de falla.
    ⦁	C) Que obliga a que la base de datos permanezca en un estado inaccesible llamado RECOVERING.
    ⦁	D) Que no requiere la configuración de un clúster de Windows (WSFC), perdiendo soporte del sistema operativo.



3. Un administrador de sistemas propone utilizar "Mirroring" (Reflejo) para proteger una base de datos 
    individual en un proyecto nuevo. Según el estado actual de la tecnología (2026), ¿cuál es la postura
    orrecta ante esta sugerencia?

    ⦁	A) Debe aceptarse, ya que es el estándar actual de la industria para bases de datos individuales.
   **	B) Debe rechazarse, porque es una tecnología depreciada sin soporte activo por parte de Microsoft.
    ⦁	C) Debe aceptarse, porque ofrece un failover automático a nivel de grupo de bases de datos.
    ⦁	D) Debe rechazarse, únicamente porque requiere obligatoriamente la instalación de un clúster de Windows (WSFC).


4. ¿Cuál es la diferencia conceptual clave en el "Nivel de Protección" entre Clustering (FCI) y Always On 
    AG ante una falla de hardware?


    ⦁	A) FCI protege objetos individuales (tablas/vistas) y Always On protege servidores físicos completos.
    ⦁	B) FCI ofrece failover manual y Always On es la única que permite failover automático.
    ⦁	C) FCI protege bases de datos individuales aisladas y Always On requiere discos compartidos SAN/NAS 
    	D) FCI protege la instancia completa de SQL Server, mientras que Always On protege un grupo de bases de datos elegidas.

5. ¿Qué requisito del sistema operativo Windows comparten obligatoriamente las tecnologías "Clustering 
    (FCI)" y "Always On AG" para poder operar?


    ⦁	A) Ninguno, ambas tecnologías funcionan de forma nativa sin requerimientos especiales de Windows.
    ⦁	B) Ambas dependen estrictamente de un servidor de testigos externo (Witness).
    **	C) Ambas dependen de la configuración de un Windows Server Failover Cluster (WSFC).
    ⦁	D) Ambas requieren que los discos de almacenamiento de los servidores estén físicamente duplicados.

*/