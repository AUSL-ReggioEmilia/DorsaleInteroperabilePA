


CREATE PROCEDURE [dbo].[UiPrestazioniDatiAccessoriInsert]

@IDPrestazione as uniqueidentifier,
@CodiceDatoAccesorio as varchar (64)

AS
BEGIN
SET NOCOUNT ON

declare @newId as uniqueidentifier = NEWID()

INSERT INTO [dbo].DatiAccessoriPrestazioni
           ([ID]
           ,IDPrestazione
           ,CodiceDatoAccessorio)
     VALUES
           (@newId
           ,@IDPrestazione
           ,@CodiceDatoAccesorio)


select * from DatiAccessoriPrestazioni where ID = @newId


SET NOCOUNT OFF
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniDatiAccessoriInsert] TO [DataAccessUi]
    AS [dbo];

