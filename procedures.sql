CREATE PROCEDURE TR1
    @firname nvarchar(max),
    @lastanme nvarchar(max),
    @email nvarchar(max),
    @pass nvarchar(max),
    @credits int
AS
BEGIN
    DECLARE @TransactionName VARCHAR(max) = NEWID()
    BEGIN TRANSACTION;
    SAVE TRANSACTION @TransactionName;
    DECLARE @identificador uniqueidentifier = NEWID()
    DECLARE @valitor int = (SELECT COUNT(Email) FROM practica1.Usuarios WHERE Email = @email)

    BEGIN TRY
        IF @valitor = 0
            BEGIN
                INSERT INTO practica1.Usuarios(id, firstname, lastname, email, dateofbirth, password, lastchanges, emailconfirmed)
                VALUES (@identificador, @firname, @lastanme, @email, SYSDATETIME(), @pass, SYSDATETIME(), 0)

                INSERT INTO practica1.UsuarioRole(RoleId, UserId, IsLatestVersion)
                VALUES ('F4E6D8FB-DF45-4C91-9794-38E043FD5ACD',@identificador,0)

                INSERT INTO practica1.ProfileStudent(UserId, Credits)
                VALUES (@identificador, @credits)

                INSERT INTO practica1.TFA(UserId, Status, LastUpdate)
                VALUES(@identificador, 0, SYSDATETIME())

                INSERT INTO practica1.Notification(UserId, Message, Date)
                VALUES (@identificador, 'Usuario Creado', SYSDATETIME())

            END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION @TransactionName; -- rollback to MySavePoint
        END
    END CATCH
END;


DROP PROCEDURE TR1;

DELETE FROM practica1.Usuarios WHERE EmailConfirmed = 0;

EXEC TR1 'Jesusa', 'Mansillaa', 'chusanics@gmail.com', '123456',  22;
GO

SELECT *FROM practica1.ProfileStudent;
SELECT *FROM practica1.Roles;
