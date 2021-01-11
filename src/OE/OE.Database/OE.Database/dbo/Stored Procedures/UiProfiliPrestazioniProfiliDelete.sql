


CREATE PROCEDURE [dbo].[UiProfiliPrestazioniProfiliDelete]

@IdPrestazione as uniqueidentifier,
@IdProfilo as uniqueidentifier

AS
BEGIN
SET NOCOUNT ON

delete from [dbo].PrestazioniProfili
    where IDFiglio = @IDPrestazione 
      and IDPadre = @IdProfilo

SET NOCOUNT OFF
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiProfiliPrestazioniProfiliDelete] TO [DataAccessUi]
    AS [dbo];

