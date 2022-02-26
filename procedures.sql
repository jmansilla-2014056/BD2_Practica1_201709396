CREATE PROCEDURE TR1 @firname nvarchar(max),
                    @lastanme nvarchar(max),
                    @email nvarchar(max),
                    @pass nvarchar(max),
                    @credits int
    AS
    BEGIN
            DECLARE @identificador uniqueidentifier = NEWID()
             DECLARE @identificador2 uniqueidentifier = NEWID()
            DECLARE @valitor int = (SELECT COUNT(Email) FROM practica1.Usuarios WHERE Email = @email)
            IF @valitor = 0
                BEGIN
                    INSERT INTO practica1.Usuarios(id, firstname, lastname, email, dateofbirth, password, lastchanges, emailconfirmed)
                    VALUES (@identificador, @firname, @lastanme, @email, SYSDATETIME(), @pass, SYSDATETIME(), 0)

                    INSERT INTO practica1.ProfileStudent(UserId, Credits)
                    VALUES (@identificador, @credits)

                    INSERT INTO practica1.TFA(UserId, Status, LastUpdate)
                    VALUES(@identificador, 0, SYSDATETIME())

                END
    END


DELETE FROM practica1.Usuarios WHERE EmailConfirmed = 0;

EXEC TR1 'Jesusa', 'Mansillaa', 'chusanics@gmail.com', '123456',  22;
GO

SELECT *FROM practica1.ProfileStudent;
