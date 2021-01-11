/*
Controllo se l'allegato esiste gia' ritorna ID interno

MODIFICATO SANDRO 2015-08-19: Usa VIEW store
MODIFICATO SANDRO 2015-11-02: Rilegge AllegatiBase per onorare i LOCK
*/
CREATE PROCEDURE [dbo].[ExtAllegatiEsiste]
	@IdEsternoReferto as varchar(64),
	@IdEsterno as varchar(64)
AS
BEGIN

	SET NOCOUNT ON

	SELECT ID
	FROM store.AllegatiBase
	WHERE Id = dbo.GetAllegatiId(@IdEsternoReferto, @IdEsterno)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtAllegatiEsiste] TO [ExecuteExt]
    AS [dbo];

