USE [BD2];
Go;

-------------------------------------------------------------------
-- FUNCION PARA OBTENER EL TOTAL DE NOTIFICACIONES DE UN USUARIO --
-------------------------------------------------------------------
-- DROP FUNCTION [dbo].[F3]; 
-- se usa así:  SELECT * FROM [dbo].[F3]('0055FF66-4B63-4D9B-B020-7D60A56C23BE');
CREATE FUNCTION F3(@idUsuario UNIQUEIDENTIFIER) RETURNS TABLE
AS RETURN (
	SELECT n.Message, n.Date FROM practica1.Notification n WHERE n.UserId = @idUsuario
)
Go;
 

  