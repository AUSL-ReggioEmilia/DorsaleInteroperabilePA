



CREATE PROCEDURE [dbo].[UiGruppiPrestazioniDelete]

@ID as uniqueidentifier

AS
BEGIN
SET NOCOUNT ON

delete from PrestazioniGruppiPrestazioni where IDGruppoPrestazioni = @ID

delete from GruppiPrestazioni where ID = @ID

SET NOCOUNT OFF
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiGruppiPrestazioniDelete] TO [DataAccessUi]
    AS [dbo];

