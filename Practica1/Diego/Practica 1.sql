-- FUNCI�N PARA VALIDAR QUE SEA DE TIPO N�MERICO
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

--FUNCI�N PARA VALIDAR QUE SEA UNA CADENA DE TEXTO
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

-- FUNCI�N PARA BUSCAR CURSOS POR SU C�DIGO
CREATE FUNCTION FIND_COURSE(@CodCourse INT)
RETURNS BIT
AS
BEGIN
	-- Buscar
	IF EXISTS (SELECT 1 FROM [BD2].[practica1].[Course] WHERE [CodCourse] = @CodCourse) AND @CodCourse IS NOT NULL
		RETURN 1;
	RETURN 0;
END;

-- PROCEDIMIENTO PARA CREAR CURSOS
CREATE PROCEDURE PR5
	@CodCourse VARCHAR(MAX),
	@Name VARCHAR(MAX),
	@CreditsRequired VARCHAR(MAX)
AS
BEGIN
	BEGIN TRY
		-- validar el c�digo del curso en formato n�merico
		IF [dbo].[VALIDATE_NUMBER](@CodCourse) = 0
			RAISERROR ('El c�digo del curso debe ser un n�mero', 16, 1);

		-- validar el nombre del curso en tipo texto
		IF [dbo].[VALIDATE_STRING](@Name) = 0
			RAISERROR ('El nombre del curso debe ser de varchar', 16, 1);

		-- validar los creditos del curso en formato n�merico
		IF [dbo].[VALIDATE_NUMBER](@CreditsRequired) = 0
			RAISERROR ('Los cr�ditos del curso debe de ser un n�mero', 16, 1);

		-- validar que el curso no exista
		IF [dbo].[FIND_COURSE](@CodCourse) = 1
			RAISERROR ('El curso ya existe en la base de datos', 16, 1);

		-- insertar en la tabla
		INSERT INTO [BD2].[practica1].[Course]([CodCourse],[Name],[CreditsRequired])VALUES(@CodCourse, @Name, @CreditsRequired)
		PRINT('Curso insertado en la base de datos');
	END TRY
	BEGIN CATCH
		PRINT(ERROR_MESSAGE());
	END CATCH
END;

-- FUNCI�N QUE RETORNA LOS ALUMNOS ASIGNADOS A UN CURSO Func_course_usuarios 
-- FUNCI�N QUE RETORNA LOS TUTORES ASIGNADOS A UN CURSO Func_tutor_course