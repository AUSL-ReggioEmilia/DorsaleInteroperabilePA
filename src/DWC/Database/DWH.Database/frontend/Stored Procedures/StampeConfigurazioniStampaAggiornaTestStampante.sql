
CREATE PROCEDURE [frontend].[StampeConfigurazioniStampaAggiornaTestStampante]
(
	@AccountName VARCHAR(64)
	, @ClientName VARCHAR(64)
	, @TipoConfigurazione INT
	, @ServerDiStampa varchar(64)
	, @Stampante varchar(64)
	, @ErroreTestStampante varchar(2048)
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsStampeConfigurazioniStampaAggiornaTestStampante
		Nessuna modifica

		Se l'utente esegue un test su una configurazione [@Tipo, @ServerDiStampa, @Stampante]
		NON salvata NON si aggiorna nulla
*/
	SET NOCOUNT ON
	
	UPDATE StampeConfigurazioniStampa
		SET DataTestStampante = GETDATE()
		, ErroreTestStampante = @ErroreTestStampante
		
	WHERE
		(AccountName = @AccountName)
		AND (ClientName = @ClientName)
		AND (TipoConfigurazione = @TipoConfigurazione)
		AND (ServerDiStampa = @ServerDiStampa)
		AND (Stampante = @Stampante)

END

