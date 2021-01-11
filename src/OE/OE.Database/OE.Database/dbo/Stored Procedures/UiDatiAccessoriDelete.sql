


CREATE PROCEDURE [dbo].[UiDatiAccessoriDelete]

 @Codice as varchar(64) = NULL

AS
BEGIN
SET NOCOUNT ON

delete FROM [dbo].DatiAccessoriSistemi WHERE CodiceDatoAccessorio = @Codice
delete FROM [dbo].DatiAccessoriPrestazioni WHERE CodiceDatoAccessorio = @Codice
delete FROM [dbo].[DatiAccessori] WHERE Codice = @Codice



SET NOCOUNT OFF
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAccessoriDelete] TO [DataAccessUi]
    AS [dbo];

