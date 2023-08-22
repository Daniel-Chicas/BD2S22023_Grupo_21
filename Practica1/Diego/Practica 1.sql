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
		-- validar el código del curso en formato númerico
		IF [dbo].[VALIDATE_NUMBER](@CodCourse) = 0
			RAISERROR ('El código del curso debe ser un número', 16, 1);

		-- validar el nombre del curso en tipo texto
		IF [dbo].[VALIDATE_STRING](@Name) = 0
			RAISERROR ('El nombre del curso debe ser de varchar', 16, 1);

		-- validar los creditos del curso en formato númerico
		IF [dbo].[VALIDATE_NUMBER](@CreditsRequired) = 0
			RAISERROR ('Los créditos del curso debe de ser un número', 16, 1);

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

-- FUNCIÓN QUE RETORNA LOS ALUMNOS ASIGNADOS A UN CURSO Func_course_usuarios 
-- FUNCIÓN QUE RETORNA LOS TUTORES ASIGNADOS A UN CURSO Func_tutor_course