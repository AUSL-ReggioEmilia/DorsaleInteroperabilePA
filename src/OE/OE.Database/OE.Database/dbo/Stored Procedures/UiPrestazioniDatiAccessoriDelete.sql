


create PROCEDURE [dbo].[UiPrestazioniDatiAccessoriDelete]

@IDPrestazione as uniqueidentifier,
@CodiceDatoAccesorio as varchar (64)

AS
BEGIN
SET NOCOUNT ON

delete from [dbo].DatiAccessoriPrestazioni
    where IDPrestazione = @IDPrestazione 
      and CodiceDatoAccessorio = @CodiceDatoAccesorio

SET NOCOUNT OFF
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniDatiAccessoriDelete] TO [DataAccessUi]
    AS [dbo];

