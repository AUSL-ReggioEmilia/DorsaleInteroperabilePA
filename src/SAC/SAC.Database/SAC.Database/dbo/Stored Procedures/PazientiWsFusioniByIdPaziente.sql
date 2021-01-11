

CREATE PROCEDURE [dbo].[PazientiWsFusioniByIdPaziente]
(
	@Identity varchar(64),
	@IdPaziente uniqueidentifier
)
AS
BEGIN
/*
	Modifica Ettore 2014-05-15: modificato il nome della vista PazientiFusioniOutputResult in PazientiFusioniSpResult
*/

	SET NOCOUNT ON;

	-- Controllo accesso
	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsFusioniByIdPaziente', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiWsFusioniByIdPaziente!', 16, 1)
		RETURN
	END


	SELECT
		  IdPaziente
		, IdPazienteFuso
		, ProgressivoFusione
		, Abilitato
		, DataInserimento
		
	FROM
		dbo.PazientiFusioniSpResult
		
	WHERE     
		IdPaziente = @IdPaziente OR IdPazienteFuso = @IdPaziente
		
	ORDER BY
		Abilitato DESC, ProgressivoFusione
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsFusioniByIdPaziente] TO [DataAccessWs]
    AS [dbo];

