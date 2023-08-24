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
 

 ---------
--	F4 --
---------

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
GO;


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
GO;

CREATE FUNCTION F1(@CodCourse VARCHAR(50))
RETURNS TABLE
AS
RETURN(
	SELECT practica1.Usuarios.Id, practica1.Usuarios.Firstname, practica1.Usuarios.Lastname, practica1.Usuarios.Email FROM practica1.Course
	INNER JOIN practica1.CourseAssignment ON practica1.Course.CodCourse = practica1.CourseAssignment.CourseCodCourse
	INNER JOIN practica1.Usuarios ON practica1.CourseAssignment.StudentId = practica1.Usuarios.Id
	INNER JOIN practica1.UsuarioRole ON practica1.Usuarios.Id = practica1.UsuarioRole.UserId
	INNER JOIN practica1.Roles ON practica1.UsuarioRole.RoleId = practica1.Roles.Id
	WHERE practica1.Course.CodCourse = @CodCourse AND practica1.Roles.Id = 'F4E6D8FB-DF45-4C91-9794-38E043FD5ACD'
);

-- FUNCIÓN QUE RETORNA LOS TUTORES ASIGNADOS A UN CURSO Func_tutor_course
CREATE FUNCTION F2(@Id VARCHAR(50))
RETURNS TABLE
AS
RETURN(
	SELECT practica1.Course.CodCourse, practica1.Course.Name ,practica1.Course.CreditsRequired FROM practica1.TutorProfile
	INNER JOIN practica1.Usuarios ON TutorProfile.UserId = practica1.Usuarios.Id
	INNER JOIN practica1.UsuarioRole ON practica1.Usuarios.Id = practica1.UsuarioRole.UserId
	INNER JOIN practica1.Roles ON practica1.UsuarioRole.RoleId = practica1.Roles.Id
	INNER JOIN practica1.CourseTutor ON practica1.Usuarios.Id = practica1.CourseTutor.TutorId
	INNER JOIN practica1.Course ON practica1.CourseTutor.CourseCodCourse = practica1.Course.CodCourse
	WHERE practica1.TutorProfile.Id = @Id AND practica1.Roles.Id = '2CF8E1CF-3CD6-44F3-8F86-1386B7C17657'
);