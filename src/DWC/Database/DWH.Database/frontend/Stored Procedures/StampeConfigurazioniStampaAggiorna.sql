
CREATE PROCEDURE [frontend].[StampeConfigurazioniStampaAggiorna]
(
	@AccountName VARCHAR(64)
	, @ClientName VARCHAR(64)
	, @TipoConfigurazione INT
	, @ServerDiStampa varchar(64)
	, @Stampante varchar(64)
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsStampeConfigurazioniStampaAggiorna
		Nessuna modifica
*/
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT * FROM StampeConfigurazioniStampa WHERE AccountName = @AccountName AND ClientName = @ClientName)
	BEGIN
		INSERT INTO StampeConfigurazioniStampa
			   (AccountName
			   ,ClientName
			   ,TipoConfigurazione
			   ,ServerDiStampa
			   ,Stampante)
		 VALUES
			   (@AccountName
			   ,@ClientName
			   ,@TipoConfigurazione
			   ,@ServerDiStampa
			   ,@Stampante)
	END
	ELSE
	BEGIN
		UPDATE StampeConfigurazioniStampa
			   SET TipoConfigurazione = @TipoConfigurazione
			   , ServerDiStampa = @ServerDiStampa
			   , Stampante = @Stampante
			   , DataModificaConfigurazione = GETDATE()
		WHERE
			   (AccountName = @AccountName)
			   AND (ClientName = @ClientName)
	END

END

