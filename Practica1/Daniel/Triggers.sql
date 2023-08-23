use [BD2];
Go

-- Diego

-- FUNCIÓN PARA VALIDAR QUE SEA DE TIPO NÚMERICO
CREATE FUNCTION VALIDATE_NUMBER(@Number VARCHAR(50))
RETURNS BIT
AS
BEGIN 
	-- Validaciones
    IF @Number IS NOT NULL AND ISNUMERIC(@Number) = 1
        RETURN 1;
    ELSE
        RETURN 0;
    RETURN 0;
END;

--FUNCIÓN PARA VALIDAR QUE SEA UNA CADENA DE TEXTO
CREATE FUNCTION VALIDATE_STRING(@Text VARCHAR(MAX))
RETURNS BIT
AS
BEGIN
	-- Validaciones
    IF @Text IS NOT NULL AND TRY_CAST(@Text AS VARCHAR(MAX)) IS NOT NULL AND ISNUMERIC(@Text) = 0
        RETURN 1;
    ELSE
        RETURN 0;
	RETURN 0;
END;

-- FUNCIÓN PARA BUSCAR CURSOS POR SU CÓDIGO
CREATE FUNCTION FIND_COURSE(@CodCourse INT)
RETURNS BIT
AS
BEGIN
	-- Buscar
	IF EXISTS (SELECT 1 FROM practica1.Course WHERE [CodCourse] = @CodCourse) AND @CodCourse IS NOT NULL
		RETURN 1;
	RETURN 0;
END;

-- PROCEDIMIENTO PARA REGISTRAR ERRORES EN HISTORYLOG
CREATE PROCEDURE SAVE_LOG
	@Description VARCHAR(MAX)
AS
BEGIN
	BEGIN TRY
		INSERT INTO practica1.HistoryLog([Date], [Description])VALUES(GETDATE(), @Description)
	END TRY
	BEGIN CATCH
		PRINT(ERROR_MESSAGE());
	END CATCH
END;

-- PROCEDIMIENTO PARA CREAR CURSOS
CREATE PROCEDURE PR5
	@CodCourse VARCHAR(50),
	@Name VARCHAR(MAX),
	@CreditsRequired VARCHAR(50)
AS
BEGIN
	BEGIN TRY
		-- validar el código del curso en formato númerico
		IF (dbo.VALIDATE_NUMBER(@CodCourse)) = 0
			BEGIN
				EXEC [dbo].[SAVE_LOG] 'El código del curso debe ser un número'
				RAISERROR ('El código del curso debe ser un número', 16, 1);
			END;

		-- validar el nombre del curso en tipo texto
		IF (SELECT dbo.VALIDATE_STRING(@Name)) = 0
			BEGIN
				EXEC [dbo].[SAVE_LOG] 'El nombre del curso debe ser de varchar' 
				RAISERROR ('El nombre del curso debe ser de varchar', 16, 1);
			END;

		-- validar los creditos del curso en formato númerico
		IF (SELECT dbo.VALIDATE_NUMBER(@CreditsRequired)) = 0
			BEGIN
				EXEC [dbo].[SAVE_LOG] 'Los créditos del curso debe de ser un número'
				RAISERROR ('Los créditos del curso debe de ser un número', 16, 1);
			END;

		-- validar que el curso no exista
		IF (SELECT dbo.FIND_COURSE(@CodCourse)) = 1
			BEGIN
				EXEC [dbo].[SAVE_LOG] 'El curso ya existe en la base de datos'
				RAISERROR ('El curso ya existe en la base de datos', 16, 1);
			END;

		-- insertar en la tabla
		INSERT INTO practica1.Course([CodCourse],[Name],[CreditsRequired]) VALUES(@CodCourse, @Name, @CreditsRequired)
		PRINT('Curso insertado en la base de datos');
	END TRY
	BEGIN CATCH
		PRINT(ERROR_MESSAGE());
	END CATCH
END;

-- Daniel

-------------------------------------------------------
--	TRIGGER PARA INSERT EN LA TABLA PRACTICA1.COURSE --
-------------------------------------------------------
-- DROP TRIGGER practica1.NuevoCurso;
CREATE TRIGGER NuevoCurso ON practica1.Course 
FOR INSERT AS
BEGIN
    DECLARE @mensaje VARCHAR(max); 
    DECLARE @codigo INTEGER;
    DECLARE @nombre VARCHAR(max);
	DECLARE @creditos INTEGER;

    SELECT @nombre = Name FROM inserted;
    SELECT @codigo = CodCourse FROM inserted;
	SELECT @creditos = CreditsRequired FROM inserted;
	 
	SET @mensaje = 'Nuevo curso agregado: '+@nombre+' (Código: '+ CONVERT(VARCHAR(10), @codigo) + ', Créditos: '+ CONVERT(VARCHAR(10), @creditos) + ').'
    INSERT INTO practica1.HistoryLog ([Date], [Description])
    VALUES (GETDATE(), @mensaje);
END;



-------------------------------------------------------
--	TRIGGER PARA UPDATE EN LA TABLA PRACTICA1.COURSE --
-------------------------------------------------------
-- DROP TRIGGER practica1.ActualizarCurso;
CREATE TRIGGER ActualizarCurso ON practica1.Course 
FOR UPDATE AS 
BEGIN
    DECLARE @mensaje VARCHAR(max); 
    DECLARE @codigo INTEGER;
    DECLARE @nombre VARCHAR(max);
	DECLARE @creditos INTEGER;

    SELECT @nombre = Name FROM inserted;
    SELECT @codigo = CodCourse FROM inserted;
	SELECT @creditos = CreditsRequired FROM inserted;
	 
	SET @mensaje = 'Se ha actualizado el curso: '+@nombre+' (Código: '+ CONVERT(VARCHAR(10), @codigo) + ', Créditos: '+ CONVERT(VARCHAR(10), @creditos) + ').'
    INSERT INTO practica1.HistoryLog ([Date], [Description])
    VALUES (GETDATE(), @mensaje);
END;

 
-------------------------------------------------------
--	TRIGGER PARA DELETE EN LA TABLA PRACTICA1.COURSE --
-------------------------------------------------------
-- DROP TRIGGER practica1.EliminarCurso;
CREATE TRIGGER EliminarCurso ON practica1.Course 
FOR DELETE AS 
BEGIN
    DECLARE @mensaje VARCHAR(max); 
    DECLARE @codigo INTEGER;
    DECLARE @nombre VARCHAR(max); 

    SELECT @nombre = Name FROM deleted;
    SELECT @codigo = CodCourse FROM deleted; 
	 
	SET @mensaje = 'Se ha eliminado el curso: '+@nombre+' (Código: '+ CONVERT(VARCHAR(10), @codigo) +').'
    INSERT INTO practica1.HistoryLog ([Date], [Description])
    VALUES (GETDATE(), @mensaje);
END;


-----------------------------------------------------------------
--	TRIGGER PARA INSERT EN LA TABLA PRACTICA1.CourseAssignment --
-----------------------------------------------------------------
-- DROP TRIGGER practica1.AgregarAsingacionCurso;
CREATE TRIGGER AgregarAsingacionCurso ON practica1.CourseAssignment  
FOR INSERT AS
BEGIN
  DECLARE @idEstudiante uniqueidentifier;
  DECLARE @codigoCurso INT;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @estudiante VARCHAR(max);

  SELECT @idEstudiante = StudentId, @codigoCurso = CourseCodCourse FROM inserted;
  
  SET @estudiante = (SELECT Firstname FROM practica1.Usuarios WHERE Id = @idEstudiante) + ' ' + (SELECT Lastname FROM practica1.Usuarios WHERE Id = @idEstudiante);
  SET @mensaje = 'El estudiante: "' + @estudiante + '", se ha asignado correctamente en el curso: "' + (SELECT Name FROM practica1.Course WHERE CodCourse = @codigoCurso)+'"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


-----------------------------------------------------------------
--	TRIGGER PARA UPDATE EN LA TABLA PRACTICA1.CourseAssignment --
-----------------------------------------------------------------
-- DROP TRIGGER practica1.ActualizarAsingacionCurso;
CREATE TRIGGER ActualizarAsingacionCurso ON practica1.CourseAssignment  
FOR UPDATE AS
BEGIN
  DECLARE @idEstudiante uniqueidentifier;
  DECLARE @codigoCurso INT;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @estudiante VARCHAR(max);

  SELECT @idEstudiante = StudentId, @codigoCurso = CourseCodCourse FROM inserted;
  
  SET @estudiante = (SELECT Firstname FROM practica1.Usuarios WHERE Id = @idEstudiante) + ' ' + (SELECT Lastname FROM practica1.Usuarios WHERE Id = @idEstudiante);
  SET @mensaje = 'El estudiante: "' + @estudiante + '", ha actualizado su asignación en el curso: "' + (SELECT Name FROM practica1.Course WHERE CodCourse = @codigoCurso)+'".';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;

-----------------------------------------------------------------
--	TRIGGER PARA DELETE EN LA TABLA PRACTICA1.CourseAssignment --
-----------------------------------------------------------------
-- DROP TRIGGER practica1.EliminarAsingacionCurso;
CREATE TRIGGER EliminarAsingacionCurso ON practica1.CourseAssignment  
FOR DELETE AS
BEGIN
  DECLARE @idEstudiante uniqueidentifier;
  DECLARE @codigoCurso INT;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @estudiante VARCHAR(max);

  SELECT @idEstudiante = StudentId, @codigoCurso = CourseCodCourse FROM deleted;
  
  SET @estudiante = (SELECT Firstname FROM practica1.Usuarios WHERE Id = @idEstudiante) + ' ' + (SELECT Lastname FROM practica1.Usuarios WHERE Id = @idEstudiante);
  SET @mensaje = 'El estudiante: "' + @estudiante + '", se ha desasignado del curso: "' + (SELECT Name FROM practica1.Course WHERE CodCourse = @codigoCurso)+'".';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


------------------------------------------------------------
--	TRIGGER PARA INSERT EN LA TABLA PRACTICA1.CourseTutor --
------------------------------------------------------------
-- DROP TRIGGER practica1.AgregarAsingacionTutor;
CREATE TRIGGER AgregarAsingacionTutor ON practica1.CourseTutor  
FOR INSERT AS
BEGIN
  DECLARE @idProfesor uniqueidentifier;
  DECLARE @codigoCurso INT;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @profesor VARCHAR(max);

  SELECT @idProfesor = TutorId, @codigoCurso = CourseCodCourse FROM inserted;
  
  SET @profesor = (SELECT Firstname FROM practica1.Usuarios WHERE Id = @idProfesor) + ' ' + (SELECT Lastname FROM practica1.Usuarios WHERE Id = @idProfesor);
  SET @mensaje = 'El tutor: "' + @profesor + '", se ha asignado al curso: "' + (SELECT Name FROM practica1.Course WHERE CodCourse = @codigoCurso)+'"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


------------------------------------------------------------
--	TRIGGER PARA UPDATE EN LA TABLA PRACTICA1.CourseTutor --
------------------------------------------------------------
-- DROP TRIGGER practica1.ActualizarAsingacionTutor;
CREATE TRIGGER ActualizarAsingacionTutor ON practica1.CourseTutor  
FOR UPDATE AS
BEGIN
  DECLARE @idProfesor uniqueidentifier;
  DECLARE @codigoCurso INT;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @profesor VARCHAR(max);

  SELECT @idProfesor = TutorId, @codigoCurso = CourseCodCourse FROM inserted;
  
  SET @profesor = (SELECT Firstname FROM practica1.Usuarios WHERE Id = @idProfesor) + ' ' + (SELECT Lastname FROM practica1.Usuarios WHERE Id = @idProfesor);
  SET @mensaje = 'Se ha actualizado la asignación del tutor: "' + @profesor + '", al curso: "' + (SELECT Name FROM practica1.Course WHERE CodCourse = @codigoCurso)+'"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


------------------------------------------------------------
--	TRIGGER PARA DELETE EN LA TABLA PRACTICA1.CourseTutor --
------------------------------------------------------------
-- DROP TRIGGER practica1.EliminarAsingacionTutor;
CREATE TRIGGER EliminarAsingacionTutor ON practica1.CourseTutor  
FOR DELETE AS
BEGIN
  DECLARE @idProfesor uniqueidentifier;
  DECLARE @codigoCurso INT;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @profesor VARCHAR(max);

  SELECT @idProfesor = TutorId, @codigoCurso = CourseCodCourse FROM deleted;

  
  SET @profesor = (SELECT Firstname FROM practica1.Usuarios WHERE Id = @idProfesor) + ' ' + (SELECT Lastname FROM practica1.Usuarios WHERE Id = @idProfesor);
  SET @mensaje = 'Se ha eliminado la asignación del tutor: "' + @profesor + '", al curso: "' + (SELECT Name FROM practica1.Course WHERE CodCourse = @codigoCurso)+'"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


-------------------------------------------------------------
--	TRIGGER PARA INSERT EN LA TABLA PRACTICA1.Notification --
-------------------------------------------------------------
-- DROP TRIGGER practica1.AgregarNotificacion;
CREATE TRIGGER AgregarNotificacion ON practica1.Notification  
FOR INSERT AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombre VARCHAR(max);

  SELECT @idUser = UserId FROM inserted;

  SET @nombre = (SELECT Firstname FROM practica1.Usuarios WHERE Id = @idUser) + ' ' + (SELECT Lastname FROM practica1.Usuarios WHERE Id = @idUser);
  SET @mensaje = 'El usuario: "' + @nombre + '" tiene una notificación pendiente';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


-------------------------------------------------------------
--	TRIGGER PARA UPDATE EN LA TABLA PRACTICA1.Notification --
-------------------------------------------------------------
-- DROP TRIGGER practica1.ActualizarNotificacion;
CREATE TRIGGER ActualizarNotificacion ON practica1.Notification  
FOR UPDATE AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombre VARCHAR(max);

  SELECT @idUser = UserId FROM inserted;

  SET @nombre = (SELECT Firstname FROM practica1.Usuarios WHERE Id = @idUser) + ' ' + (SELECT Lastname FROM practica1.Usuarios WHERE Id = @idUser);
  SET @mensaje = 'Se ha actualizado una notificación del usuario: "' + @nombre + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


-------------------------------------------------------------
--	TRIGGER PARA DELETE EN LA TABLA PRACTICA1.Notification --
-------------------------------------------------------------
-- DROP TRIGGER practica1.EliminarNotificacion;
CREATE TRIGGER EliminarNotificacion ON practica1.Notification  
FOR DELETE AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombre VARCHAR(max);

  SELECT @idUser = UserId FROM deleted;

  SET @nombre = (SELECT Firstname FROM practica1.Usuarios WHERE Id = @idUser) + ' ' + (SELECT Lastname FROM practica1.Usuarios WHERE Id = @idUser);
  SET @mensaje = 'Se ha eliminado una notificación del usuario: "' + @nombre + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


---------------------------------------------------------------
--	TRIGGER PARA INSERT EN LA TABLA PRACTICA1.ProfileStudent --
---------------------------------------------------------------
-- DROP TRIGGER practica1.AgregarPerfilEstudiante;
CREATE TRIGGER AgregarPerfilEstudiante ON practica1.ProfileStudent  
FOR INSERT AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombre VARCHAR(max);

  SELECT @idUser = UserId FROM inserted;
  SELECT @nombre = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  
  SET @mensaje = 'Se ha creado el perfil del estudiante: "' + @nombre + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


---------------------------------------------------------------
--	TRIGGER PARA UPDATE EN LA TABLA PRACTICA1.ProfileStudent --
---------------------------------------------------------------
-- DROP TRIGGER practica1.ActualizarPerfilEstudiante;
CREATE TRIGGER ActualizarPerfilEstudiante ON practica1.ProfileStudent  
FOR UPDATE AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombre VARCHAR(max);

  SELECT @idUser = UserId FROM inserted;
  SELECT @nombre = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  
  SET @mensaje = 'Se ha actualizado el perfil del estudiante: "' + @nombre + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


---------------------------------------------------------------
--	TRIGGER PARA DELETE EN LA TABLA PRACTICA1.ProfileStudent --
---------------------------------------------------------------
-- DROP TRIGGER practica1.EliminarPerfilEstudiante;
CREATE TRIGGER EliminarPerfilEstudiante ON practica1.ProfileStudent  
FOR DELETE AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombre VARCHAR(max);

  SELECT @idUser = UserId FROM deleted;
  SELECT @nombre = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  
  SET @mensaje = 'Se ha eliminado el perfil del estudiante: "' + @nombre + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;

------------------------------------------------------
--	TRIGGER PARA INSERT EN LA TABLA PRACTICA1.Roles --
------------------------------------------------------
-- DROP TRIGGER practica1.AgregarRol;
CREATE TRIGGER AgregarRol ON practica1.Roles  
FOR INSERT AS
BEGIN
  DECLARE @mensaje VARCHAR(max);
  DECLARE @rol VARCHAR(max);
  
  SELECT @rol = RoleName FROM inserted;
  SET @mensaje = 'Se ha creado el rol: "' + @rol + '"';

  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


------------------------------------------------------
--	TRIGGER PARA UPDATE EN LA TABLA PRACTICA1.Roles --
------------------------------------------------------
-- DROP TRIGGER practica1.ActualizarRol;
CREATE TRIGGER ActualizarRol ON practica1.Roles  
FOR UPDATE AS
BEGIN
  DECLARE @mensaje VARCHAR(max);
  DECLARE @rol VARCHAR(max);
  
  SELECT @rol = RoleName FROM inserted;
  SET @mensaje = 'Se ha actualizado el rol: "' + @rol + '"';

  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


------------------------------------------------------
--	TRIGGER PARA DELETE EN LA TABLA PRACTICA1.Roles --
------------------------------------------------------
-- DROP TRIGGER practica1.EliminarRol;
CREATE TRIGGER EliminarRol ON practica1.Roles  
FOR DELETE AS
BEGIN
  DECLARE @mensaje VARCHAR(max);
  DECLARE @rol VARCHAR(max);
  
  SELECT @rol = RoleName FROM deleted;
  SET @mensaje = 'Se ha eliminado el rol: "' + @rol + '"';

  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;



----------------------------------------------------
--	TRIGGER PARA INSERT EN LA TABLA PRACTICA1.TFA --
----------------------------------------------------
-- DROP TRIGGER practica1.AgregarTFA;
CREATE TRIGGER AgregarTFA ON practica1.TFA  
FOR INSERT AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @estudiante VARCHAR(max);
  

  SELECT @idUser = UserId FROM inserted;
  SELECT @estudiante = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  SET @mensaje = 'Se ha creado el TFA para el estudiante: "' + @estudiante + '"';

  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


----------------------------------------------------
--	TRIGGER PARA UPDATE EN LA TABLA PRACTICA1.TFA --
----------------------------------------------------
-- DROP TRIGGER practica1.ActualizarTFA;
CREATE TRIGGER ActualizarTFA ON practica1.TFA  
FOR UPDATE AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @estudiante VARCHAR(max);
  

  SELECT @idUser = UserId FROM inserted;
  SELECT @estudiante = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  SET @mensaje = 'Se ha actualizado el TFA para el estudiante: "' + @estudiante + '"';

  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


----------------------------------------------------
--	TRIGGER PARA DELETE EN LA TABLA PRACTICA1.TFA --
----------------------------------------------------
-- DROP TRIGGER practica1.EliminarTFA;
CREATE TRIGGER EliminarTFA ON practica1.TFA  
FOR DELETE AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @estudiante VARCHAR(max);
  

  SELECT @idUser = UserId FROM deleted;
  SELECT @estudiante = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  SET @mensaje = 'Se ha eliminado el TFA para el estudiante: "' + @estudiante + '"';

  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


-------------------------------------------------------------
--	TRIGGER PARA INSERT EN LA TABLA PRACTICA1.TutorProfile --
-------------------------------------------------------------
-- DROP TRIGGER practica1.AgregarPerfilEstudiante;
CREATE TRIGGER AgregarPerfilTutor ON practica1.TutorProfile  
FOR INSERT AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombre VARCHAR(max);
  
  SELECT @idUser = UserId FROM inserted;
  SELECT @nombre = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  SET @mensaje = 'Se ha creado el perfil para el tutor: "' + @nombre + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);

END;


-------------------------------------------------------------
--	TRIGGER PARA UPDATE EN LA TABLA PRACTICA1.TutorProfile --
-------------------------------------------------------------
-- DROP TRIGGER practica1.ActualizarPerfilTutor;
CREATE TRIGGER ActualizarPerfilTutor ON practica1.TutorProfile  
FOR UPDATE AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombre VARCHAR(max);
  
  SELECT @idUser = UserId FROM inserted;
  SELECT @nombre = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  SET @mensaje = 'Se ha actualizado el perfil para el tutor: "' + @nombre + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


-------------------------------------------------------------
--	TRIGGER PARA DELETE EN LA TABLA PRACTICA1.TutorProfile --
-------------------------------------------------------------
-- DROP TRIGGER practica1.EliminarPerfilTutor;
CREATE TRIGGER EliminarPerfilTutor ON practica1.TutorProfile  
FOR DELETE AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombre VARCHAR(max);
  
  SELECT @idUser = UserId FROM deleted;
  SELECT @nombre = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  SET @mensaje = 'Se ha eliminado el perfil para el tutor: "' + @nombre + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


------------------------------------------------------------
--	TRIGGER PARA INSERT EN LA TABLA PRACTICA1.UsuarioRole --
------------------------------------------------------------
-- DROP TRIGGER practica1.AgregarRolUsuario;
CREATE TRIGGER AgregarRolUsuario ON practica1.UsuarioRole  
FOR INSERT AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @idRol uniqueidentifier;

  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombreEstudiante VARCHAR(max);
  DECLARE @rol VARCHAR(max);
   
  SELECT @idUser = UserId FROM inserted;
  SELECT @idRol = RoleId FROM inserted;

  SELECT @nombreEstudiante = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  SELECT @rol = RoleName FROM practica1.Roles WHERE Id = @idRol;
  
  SET @mensaje = 'Se ha asignado el rol: "' + @rol + '", al estudiante: "' + @nombreEstudiante + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


------------------------------------------------------------
--	TRIGGER PARA UPDATE EN LA TABLA PRACTICA1.UsuarioRole --
------------------------------------------------------------
-- DROP TRIGGER practica1.ActualizarRolUsuario;
CREATE TRIGGER ActualizarRolUsuario ON practica1.UsuarioRole  
FOR UPDATE AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @idRol uniqueidentifier;

  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombreEstudiante VARCHAR(max);
  DECLARE @rol VARCHAR(max);
   
  SELECT @idUser = UserId FROM inserted;
  SELECT @idRol = RoleId FROM inserted;

  SELECT @nombreEstudiante = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  SELECT @rol = RoleName FROM practica1.Roles WHERE Id = @idRol;
  
  SET @mensaje = 'Se ha actualizado el rol: "' + @rol + '", para el estudiante: "' + @nombreEstudiante + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


------------------------------------------------------------
--	TRIGGER PARA DELETE EN LA TABLA PRACTICA1.UsuarioRole --
------------------------------------------------------------
-- DROP TRIGGER practica1.EliminarRolUsuario;
CREATE TRIGGER EliminarRolUsuario ON practica1.UsuarioRole  
FOR DELETE AS
BEGIN
  DECLARE @idUser uniqueidentifier;
  DECLARE @idRol uniqueidentifier;

  DECLARE @mensaje VARCHAR(max);
  DECLARE @nombreEstudiante VARCHAR(max);
  DECLARE @rol VARCHAR(max);
   
  SELECT @idUser = UserId FROM deleted;
  SELECT @idRol = RoleId FROM deleted;

  SELECT @nombreEstudiante = Firstname + ' ' + Lastname FROM practica1.Usuarios WHERE Id = @idUser;
  SELECT @rol = RoleName FROM practica1.Roles WHERE Id = @idRol;
  
  SET @mensaje = 'Se ha eliminado el rol: "' + @rol + '", para el estudiante: "' + @nombreEstudiante + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


---------------------------------------------------------
--	TRIGGER PARA INSERT EN LA TABLA PRACTICA1.Usuarios --
---------------------------------------------------------
-- DROP TRIGGER practica1.AgregarUsuario;
CREATE TRIGGER AgregarUsuario ON practica1.Usuarios  
FOR INSERT AS
BEGIN
  DECLARE @mensaje VARCHAR(max);
  DECLARE @estudiante VARCHAR(max);

  SELECT @estudiante = Firstname + ' ' + Lastname FROM inserted;
  SET @mensaje = 'Se ha creado el usuario: "' + @estudiante + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


---------------------------------------------------------
--	TRIGGER PARA UPDATE EN LA TABLA PRACTICA1.Usuarios --
---------------------------------------------------------
-- DROP TRIGGER practica1.ActualizarUsuario;
CREATE TRIGGER ActualizarUsuario ON practica1.Usuarios  
FOR UPDATE AS
BEGIN
  DECLARE @mensaje VARCHAR(max);
  DECLARE @estudiante VARCHAR(max);

  SELECT @estudiante = Firstname + ' ' + Lastname FROM inserted;
  SET @mensaje = 'Se ha actualizado la información del usuario: "' + @estudiante + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;


---------------------------------------------------------
--	TRIGGER PARA DELETE EN LA TABLA PRACTICA1.Usuarios --
---------------------------------------------------------
-- DROP TRIGGER practica1.EliminarUsuarios;
CREATE TRIGGER EliminarUsuarios ON practica1.Usuarios  
FOR DELETE AS
BEGIN
  DECLARE @mensaje VARCHAR(max);
  DECLARE @estudiante VARCHAR(max);

  SELECT @estudiante = Firstname + ' ' + Lastname FROM deleted;
  SET @mensaje = 'Se ha eliminado el usuario: "' + @estudiante + '"';
  
  INSERT INTO practica1.HistoryLog ([Date], [Description])
  VALUES (GETDATE(), @mensaje);
END;

