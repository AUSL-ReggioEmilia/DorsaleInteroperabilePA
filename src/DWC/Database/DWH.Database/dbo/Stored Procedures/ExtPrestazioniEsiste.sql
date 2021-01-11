/* 
Controllo se la prestazione esiste gia' ritorna ID interno

MODIFICATO SANDRO 2015-11-02: review Usa PrestazioniBaseper onorare i LOCK
*/
CREATE PROCEDURE [dbo].[ExtPrestazioniEsiste]
	@IdEsternoReferto as varchar(64),
	@IdEsterno as varchar(64)
AS
BEGIN
	SET NOCOUNT ON

	SELECT Id
	FROM [store].PrestazioniBase
	WHERE ID = dbo.GetPrestazioniId(@IdEsternoReferto, @IdEsterno)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtPrestazioniEsiste] TO [ExecuteExt]
    AS [dbo];

