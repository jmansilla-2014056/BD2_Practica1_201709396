
USE BD2;
GO

CREATE PROCEDURE TR1
    @firname nvarchar(max),
    @lastanme nvarchar(max),
    @email nvarchar(max),
    @pass nvarchar(max),
    @credits int
AS
BEGIN
    DECLARE @TransactionName VARCHAR(max) = NEWID()
    BEGIN TRANSACTION
    DECLARE @identificador uniqueidentifier = NEWID()
    DECLARE @valitor int = (SELECT COUNT(Email) FROM practica1.Usuarios WHERE Email = @email)
    DECLARE @rolstudend nvarchar(max) = (SELECT Id FROM practica1.Roles WHERE RoleName = 'Student')

    BEGIN TRY
        IF @valitor = 0
            BEGIN
                INSERT INTO practica1.Usuarios(id, firstname, lastname, email, dateofbirth, password, lastchanges, emailconfirmed)
                VALUES (@identificador, @firname, @lastanme, @email, SYSDATETIME(), @pass, SYSDATETIME(), 0)

                INSERT INTO practica1.UsuarioRole(RoleId, UserId, IsLatestVersion)
                VALUES (@rolstudend,@identificador,0)

                INSERT INTO practica1.ProfileStudent(UserId, Credits)
                VALUES (@identificador, @credits)

                INSERT INTO practica1.TFA(UserId, Status, LastUpdate)
                VALUES(@identificador, 0, SYSDATETIME())

                INSERT INTO practica1.Notification(UserId, Message, Date)
                VALUES (@identificador, 'Usuario Creado'+ @firname + ':' + @email, SYSDATETIME())

                INSERT INTO practica1.HistoryLog(Date, Description)
                VALUES (SYSDATETIME(),'Se ingreso el usuario correctamentamente ' + @firname + ':' + @email)
            END
        ELSE
            BEGIN
                INSERT INTO practica1.HistoryLog(Date, Description)
                VALUES (SYSDATETIME(),'Correo en uso, ocurrio un error al  ingresar usuario ' + @firname + ':' + @email)
            END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION -- rollback to MySavePoint
            INSERT INTO practica1.HistoryLog(Date, Description)
            VALUES (SYSDATETIME(),'Se hiso un rollback, ocurrio un error al  ingresar usuario ' + @firname + ':' + @email)
            RETURN
        END
    END CATCH
END;
GO;

CREATE PROCEDURE TR2
    @email nvarchar(max),
    @courseCod int
AS
BEGIN
    BEGIN TRANSACTION
    DECLARE @identificador nvarchar(max) = (SELECT Id FROM practica1.Usuarios WHERE Email = @email)
    DECLARE @valitor int = (SELECT COUNT(Email) FROM practica1.Usuarios WHERE Email = @email)
    DECLARE @emailConfirm int = (SELECT EmailConfirmed FROM practica1.Usuarios WHERE Email = @email)
    DECLARE @roltutor nvarchar(max) = (SELECT Id FROM practica1.Roles WHERE RoleName = 'Tutor')
    BEGIN TRY
        IF @valitor = 1 AND @emailConfirm = 1
            BEGIN

                INSERT INTO practica1.CourseTutor(TutorId, CourseCodCourse)
                VALUES (@identificador, @courseCod)

                INSERT INTO practica1.UsuarioRole(RoleId, UserId, IsLatestVersion)
                VALUES (@roltutor,@identificador,0)

                INSERT INTO practica1.TutorProfile(UserId, TutorCode)
                VALUES (@identificador, @email)

                INSERT INTO practica1.Notification(UserId, Message, Date)
                VALUES (@identificador, 'Tutor creado' + @email, SYSDATETIME())

                INSERT INTO practica1.HistoryLog(Date, Description)
                VALUES (SYSDATETIME(),'Se ingreso el tutor correctamentamente ' + @email)

            END
        ELSE
            BEGIN
                INSERT INTO practica1.HistoryLog(Date, Description)
                VALUES (SYSDATETIME(),'correo no encontrado o inactivo, ocurrio un error haciendo tutor ' + @email)
            END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION
                INSERT INTO practica1.HistoryLog(Date, Description)
                VALUES (SYSDATETIME(),'Se hiso un rollback, ocurrio un error al  ingresar tutor :'+ @email)
                RETURN
            END

    END CATCH
END;
GO;


CREATE PROCEDURE TR3
    @email nvarchar(max),
    @courseCod int
AS
BEGIN
    BEGIN TRANSACTION
    DECLARE @identificador nvarchar(max) = (SELECT TOP 1 Id FROM practica1.Usuarios WHERE Email = @email )
    DECLARE @valitor int = (SELECT COUNT(Email) FROM practica1.Usuarios WHERE Email = @email)
    DECLARE @emailConfirm int = (SELECT TOP 1  EmailConfirmed FROM practica1.Usuarios WHERE Email = @email)
    DECLARE @idtutor nvarchar(max) = (SELECT TOP 1  TutorId FROM practica1.CourseTutor WHERE CourseCodCourse = @courseCod)
    DECLARE @creditos int = (SELECT TOP 1  Credits FROM practica1.ProfileStudent WHERE UserId = @identificador)
    DECLARE @creditosCurso int = (SELECT TOP 1 CreditsRequired FROM  practica1.Course WHERE CodCourse = @courseCod)
    BEGIN TRY
        IF @valitor = 1 AND @emailConfirm = 1 AND (@creditos >= @creditosCurso)
            BEGIN

                INSERT INTO practica1.CourseAssignment(StudentId, CourseCodCourse)
                VALUES (@identificador , @courseCod)

                INSERT INTO practica1.Notification(UserId, Message, Date)
                VALUES (@identificador, 'Se completo la asignacion' + @email, SYSDATETIME())

                INSERT INTO practica1.Notification(UserId, Message, Date)
                VALUES (@idtutor, 'SE completo la asignacion' + @email, SYSDATETIME())

                INSERT INTO practica1.HistoryLog(Date, Description)
                VALUES (SYSDATETIME(),'Se ingreso la asignacion existosamente ' + @email)

            END
        ELSE
            BEGIN
                INSERT INTO practica1.HistoryLog(Date, Description)
                VALUES (SYSDATETIME(),'creditos insuficientes, correo no encontrado o inactivo, ocurrio un error haciendo asignacion ' + @email)
            END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION
                INSERT INTO practica1.HistoryLog(Date, Description)
                VALUES (SYSDATETIME(),'Se hiso un rollback, ocurrio un error al  ingresar asignacion :'+ @email)
                RETURN
            END
    END CATCH
END;
GO;

