USE [BD2];

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

-- FUNCIÓN QUE RETORNA LOS ALUMNOS ASIGNADOS A UN CURSO Func_course_usuarios 
CREATE FUNCTION Func_course_usuarios(@CodCourse VARCHAR(50))
RETURNS TABLE
AS
RETURN(
	SELECT practica1.Usuarios.Id, practica1.Usuarios.Firstname, practica1.Usuarios.Lastname, practica1.Usuarios.Email FROM practica1.Course
	INNER JOIN practica1.CourseAssignment ON practica1.Course.CodCourse = practica1.CourseAssignment.CourseCodCourse
	INNER JOIN practica1.Usuarios ON practica1.CourseAssignment.StudentId = practica1.Usuarios.Id
	INNER JOIN practica1.UsuarioRole ON practica1.Usuarios.Id = practica1.UsuarioRole.UserId
	INNER JOIN practica1.Roles ON practica1.UsuarioRole.RoleId = practica1.Roles.Id
	WHERE practica1.Course.CodCourse = @CodCourse
);


-- FUNCIÓN QUE RETORNA LOS TUTORES ASIGNADOS A UN CURSO Func_tutor_course
CREATE FUNCTION Func_tutor_course(@Id VARCHAR(50))
RETURNS TABLE
AS
RETURN(
	SELECT practica1.Course.CodCourse, practica1.Course.Name ,practica1.Course.CreditsRequired FROM 
);