/*
Trabajo Practico Captura de errores

1. Realizar una división por cero y atrapar el error utilizando variables de sistema (revertir la transacción).

2. Realizar una división por cero y atrapar el error sin utilizar variables de sistema (revertir la transacción).

3. Agregar al ejercicio anterior el envío de un mensaje de error utilizando RAISERROR.

4. Realizar una copia del punto 3 y enviar un mensaje de error utilizando THROW.*/


BEGIN TRANSACTION
    select 4/0
    if @@ERROR<>0 -- si existen errores
    BEGIN
        ROLLBACK TRANSACTION
        print 'No se puede dividir por cero'
        return;
    END
COMMIT TRANSACTION
GO
-- 2

begin try
        BEGIN TRANSACTION
        select 1/0
        COMMIT TRANSACTION
end TRY
begin catch
    rollback TRANSACTION
    THROW
end catch

-- 3
begin try 
    BEGIN TRANSACTION
        select 1/0
    COMMIT TRANSACTION
end try
begin catch
    ROLLBACK TRANSACTION
    RAISERROR (
        'Aqui el error personalizado', --Mensaje personalizado
        16,--Severidad
        1 --Estado
    );
end catch
-- 4

begin try
    BEGIN TRANSACTION
        select 1/0

    commit TRANSACTION
end try
begin catch
        ROLLBACK TRANSACTION;
        THROW 50000, 'Division por cero no permitida',1;
end catch