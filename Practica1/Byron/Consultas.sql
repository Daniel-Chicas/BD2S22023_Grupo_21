USE BD2
GO

 
CREATE PROCEDURE PR3
  @Email VARCHAR(max),
  @CodCourse INT
AS
BEGIN
	DECLARE @IdStudent uniqueidentifier;
	DECLARE @CreditsStudent INT;
	DECLARE @RequiredCredits INT;

	SET @IdStudent = (SELECT Id FROM practica1.Usuarios WHERE Email = @Email);
	SET @CreditsStudent = (SELECT Credits FROM practica1.ProfileStudent WHERE UserId = @IdStudent);
	SET @RequiredCredits = (SELECT CreditsRequired FROM practica1.Course WHERE CodCourse = @CodCourse);

	IF @CreditsStudent >= @RequiredCredits
		BEGIN
			INSERT INTO practica1.CourseAssignment (StudentId, CourseCodCourse) VALUES (@IdStudent, @CodCourse);
			INSERT INTO practica1.Notification (UserId, Message, [Date]) 
			VALUES (
				@IdStudent,
				'Se ha inscrito en el curso ' + (SELECT Name FROM practica1.Course WHERE CodCourse = @CodCourse), GETDATE()
			);
			INSERT INTO practica1.HistoryLog ([Date], [Description])
				VALUES (GETDATE(), 'El estudiante con el id ' + @IdStudent + 'Se ha inscrito en el curso ' + 
				(SELECT Name FROM practica1.Course WHERE CodCourse = @CodCourse)
			);
		END
	ELSE
		BEGIN
		INSERT INTO practica1.HistoryLog ([Date], [Description])
				VALUES (GETDATE(), 'No se ha podido inscribir en el curso ' + (SELECT Name FROM practica1.Course WHERE CodCourse = @CodCourse) + 
				' porque no tiene los créditos necesarios'
			);
		INSERT INTO practica1.Notification (UserId, Message, [Date]) 
		VALUES (
			@IdStudent, 
			'No se ha podido inscribir en el curso ' + (SELECT Name FROM practica1.Course WHERE CodCourse = @CodCourse) + ' porque no tiene los créditos necesarios', 
			GETDATE()
		);
		RAISERROR('El estudiante no tiene los créditos necesarios para inscribirse en el curso', 16, 1);
    END
END
GO

 CREATE PROCEDURE [PR4]
    @RoleName NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM [practica1].[Roles] WHERE [RoleName] = @RoleName)
    BEGIN
        
        INSERT INTO [practica1].[Roles] ([Id], [RoleName])
        VALUES (NEWID(), @RoleName);

        PRINT 'Rol creado exitosamente: ' + @RoleName;
    END
    ELSE
    BEGIN
        PRINT 'El rol ya existe: ' + @RoleName;
    END
END;

GO

CREATE FUNCTION F4()
RETURNS TABLE
AS
RETURN
(
    SELECT
        [Id] AS LogId,
        [Date] AS LogDate,
        [Description] AS LogDescription
    FROM
        [practica1].[HistoryLog]
);
GO


CREATE FUNCTION F5(@Id uniqueidentifier)
RETURNS TABLE
AS
RETURN(
	SELECT 
		u.Firstname ,
		u.Lastname ,
		u.Email ,
		u.DateOfBirth ,
		PS.Credits ,
		R.RoleName 
	FROM [practica1].[Usuarios] U
	inner join [practica1].[ProfileStudent] PS ON PS.UserId = U.Id 
	inner join [practica1].[UsuarioRole] UR ON UR.UserId = U.Id 
	inner join [practica1].[Roles] R ON UR.RoleId = R.Id 
	WHERE u.Id = @Id
);