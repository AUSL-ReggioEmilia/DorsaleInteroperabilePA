


CREATE PROCEDURE [dbo].[UiPrestazioniGruppiPrestazioniDelete]

@IDPrestazione as uniqueidentifier,
@IDGruppo as uniqueidentifier

AS
BEGIN
SET NOCOUNT ON

delete from [dbo].PrestazioniGruppiPrestazioni
    where IDPrestazione = @IDPrestazione 
      and IDGruppoPrestazioni = @IDGruppo

SET NOCOUNT OFF
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniGruppiPrestazioniDelete] TO [DataAccessUi]
    AS [dbo];

