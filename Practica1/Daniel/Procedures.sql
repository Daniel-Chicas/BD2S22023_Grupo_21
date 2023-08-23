USE [BD2];
Go;

--------------------------------------------
-- PROCEDURE PARA EL REGISTRO DE USUARIOS --
--------------------------------------------
-- DROP PROCEDURE [practica1].[PR1];
CREATE PROCEDURE [practica1].[PR1](@FirstName NVARCHAR(MAX),@LastName NVARCHAR(MAX),@Email NVARCHAR(MAX),@DateOfBirth DATETIME2,@Password NVARCHAR(MAX),@Credits INT) AS
BEGIN
	DECLARE @idUser UNIQUEIDENTIFIER;
	DECLARE @idRol UNIQUEIDENTIFIER;
	DECLARE @tfa bit = 0; -- el estado de la verificación de dos pasos es desactivado por defecto.
	  

    IF NOT EXISTS (SELECT 1 FROM [practica1].[Usuarios] WHERE [Email] = @Email) BEGIN
		BEGIN TRY
			BEGIN TRANSACTION
				INSERT INTO [practica1].[Usuarios] ([Id], [Firstname], [Lastname], [Email], [DateOfBirth], [Password], [LastChanges], [EmailConfirmed]) -- Se crea el nuevo usuario
										  VALUES (NEWID(), @FirstName, @LastName, @Email, @DateOfBirth, @Password, GETDATE(), 1); -- EmailConfirmed establecido en 1
			
				SET @idUser = (SELECT [Id] FROM [practica1].[Usuarios] WHERE [Email] = @Email); -- Se obtiene el id del usuario creado recientemente
				SET @idRol = (SELECT [Id] FROM [practica1].[Roles] WHERE [RoleName] = 'Student'); -- se obtene el id del rol "Student"
			
				INSERT INTO [practica1].[UsuarioRole] ([RoleId], [UserId], [IsLatestVersion]) -- Se asgina el rol al usuario creado recientemente
				VALUES (@idRol, @idUser, 1);

				INSERT INTO [practica1].[ProfileStudent] ([UserId], [Credits]) -- Se crea el perfil del usuario creado recientemente
				VALUES (@idUser, @Credits);
			 
				INSERT INTO [practica1].[TFA] ([UserId], [Status], [LastUpdate]) -- Se asigna como estado inactivo la verificación de dos pasos para el usuario creado recientemente
				VALUES (@idUser, 0, GETDATE());
			
				INSERT INTO [practica1].[Notification] ([UserId], [Message], [Date]) -- Se crea la notificación para indicarle al usuario que si registro fue exitoso
				VALUES (@idUser, '¡Bienvenido "'+@FirstName + ' '+@LastName+'"!', GETDATE());

				INSERT INTO practica1.HistoryLog ([Date], [Description])
				VALUES (GETDATE(), 'Se ha registrado al usuario: '+@FirstName+' , correctamente.');

				COMMIT TRANSACTION; -- Confirmacion de la transaccion
			 
		END TRY
		BEGIN CATCH
            ROLLBACK TRANSACTION; -- Se revierte la transaccion
			
			CREATE TABLE ErrorLog (Error NVARCHAR(MAX), ErrorDate DATETIME);
			INSERT INTO [dbo].[ErrorLog]([Error], [ErrorDate])
			VALUES ('Ha ocurrido un error inesperado al ingresar al usuario: '+@FirstName, GETDATE());
			SELECT * FROM dbo.ErrorLog;
			DROP TABLE dbo.ErrorLog;

			INSERT INTO practica1.HistoryLog ([Date], [Description])
			VALUES (GETDATE(), 'Ha ocurrido un error inesperado al ingresar al usuario: '+@FirstName);
			 
		END CATCH
	END
	ELSE BEGIN 
		CREATE TABLE ErrorLog (Error NVARCHAR(MAX), ErrorDate DATETIME);
		INSERT INTO [dbo].[ErrorLog]([Error], [ErrorDate])
        VALUES ('El correo electrónico ya está en uso.', GETDATE());
		SELECT * FROM dbo.ErrorLog;
		DROP TABLE dbo.ErrorLog;

		INSERT INTO practica1.HistoryLog ([Date], [Description])
		VALUES (GETDATE(), 'El correo electrónico: '+@Email+' ya está en uso.'); 
	END; 

END;
Go;
 
---------------------------------------
-- PROCEDURE PARA EL CAMBIO DE ROLES --
---------------------------------------
-- DROP PROCEDURE [practica1].[PR2];
CREATE PROCEDURE [practica1].[PR2](@Email NVARCHAR(MAX), @CodCourse INT) AS
BEGIN
	BEGIN TRANSACTION
		DECLARE @userId UNIQUEIDENTIFIER;
		DECLARE @idRol UNIQUEIDENTIFIER;
		DECLARE @nombreUser NVARCHAR(MAX);
		DECLARE @nombreCurso NVARCHAR(MAX);
		DECLARE @encontrado BIT = 0;

		SELECT @userId = users.Id, @encontrado = 1 FROM practica1.Usuarios users WHERE users.Email = @Email;
		
		IF @encontrado = 0 BEGIN
			CREATE TABLE ErrorLog (Error NVARCHAR(MAX), ErrorDate DATETIME);
			INSERT INTO [dbo].[ErrorLog]([Error], [ErrorDate])
			VALUES ('No se ha encontrado a ningún usuario con el correo: '+@Email, GETDATE());
			 
			INSERT INTO practica1.HistoryLog ([Date], [Description])
			VALUES (GETDATE(), 'No se ha encontrado a ningún usuario con el correo: '+@Email);
			SELECT * FROM dbo.ErrorLog;
			DROP TABLE dbo.ErrorLog;  
			ROLLBACK;
		END
		ELSE BEGIN
			SET @nombreUser = (SELECT users.Firstname FROM practica1.Usuarios users where users.Email = @Email);

			SET @encontrado = 0
			SELECT @encontrado = 1 from practica1.Course curso where curso.CodCourse = @CodCourse;
			
			IF @encontrado = 1 BEGIN
				SET @nombreCurso = (SELECT curso.Name from practica1.Course curso where curso.CodCourse = @CodCourse);

				SET @encontrado = 0;
				SELECT @encontrado = 1 FROM practica1.TutorProfile tp WHERE tp.UserId = @userId;

				IF @encontrado = 0 BEGIN
					
					SET @idRol = (SELECT [Id] FROM [practica1].[Roles] WHERE [RoleName] = 'Tutor');
			
					INSERT INTO practica1.UsuarioRole (RoleId, UserId, IsLatestVersion) 
					VALUES (@idRol, @userId, 1);
			
					INSERT INTO practica1.TutorProfile (UserId, TutorCode) 
					VALUES(@userId, convert(nvarchar(max), NEWID()));

					
					INSERT INTO practica1.CourseTutor (TutorId, CourseCodCourse) 
					VALUES (@userId, @CodCourse);
			
					INSERT INTO practica1.Notification (UserId, Message, [Date])
					VALUES (@userId, 'Se ha registrado como tutor del curso: '+@nombreCurso, CAST(GETDATE() as Date));
		 
					INSERT INTO practica1.HistoryLog ([Date], [Description])
					VALUES (GETDATE(), 'Se ha asignado al usuario: '+@nombreUser+', como tutor del curso: '+@nombreCurso);

					COMMIT TRANSACTION;

				END
				ELSE BEGIN
				
					CREATE TABLE ErrorLog (Error NVARCHAR(MAX), ErrorDate DATETIME);
					INSERT INTO [dbo].[ErrorLog]([Error], [ErrorDate])
					VALUES ('El usuario: '+@nombreUser+', ya tiene rol de tutor.', GETDATE());
			 
					INSERT INTO practica1.HistoryLog ([Date], [Description])
					VALUES (GETDATE(), 'El usuario: '+@nombreUser+', ya tiene rol de tutor.');
					ROLLBACK;
					SELECT * FROM dbo.ErrorLog;
					DROP TABLE dbo.ErrorLog;  
				END

			END
			ELSE BEGIN
				CREATE TABLE ErrorLog (Error NVARCHAR(MAX), ErrorDate DATETIME);
				INSERT INTO [dbo].[ErrorLog]([Error], [ErrorDate])
				VALUES ('No se encontró el curso con el código: '+convert(nvarchar(max), @CodCourse), GETDATE());
			 
				INSERT INTO practica1.HistoryLog ([Date], [Description])
				VALUES (GETDATE(), 'No se encontró el curso con el código: '+convert(nvarchar(max), @CodCourse));
				ROLLBACK;
				SELECT * FROM dbo.ErrorLog;
				DROP TABLE dbo.ErrorLog;  
			END

	END
END;
GO;
