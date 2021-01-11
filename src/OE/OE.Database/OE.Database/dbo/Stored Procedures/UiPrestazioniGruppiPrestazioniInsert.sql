


CREATE PROCEDURE [dbo].[UiPrestazioniGruppiPrestazioniInsert]

@IDPrestazione as uniqueidentifier,
@IDGruppo as uniqueidentifier

AS
BEGIN
SET NOCOUNT ON

declare @newId as uniqueidentifier = NEWID()

INSERT INTO [dbo].PrestazioniGruppiPrestazioni
           ([ID]
           ,IDPrestazione
           ,IDGruppoPrestazioni)
     VALUES
           (@newId
           ,@IDPrestazione
           ,@IDGruppo)


select * from PrestazioniGruppiPrestazioni where ID = @newId


SET NOCOUNT OFF
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniGruppiPrestazioniInsert] TO [DataAccessUi]
    AS [dbo];

