
CREATE PROCEDURE [frontend].[StampeConfigurazioniStampaDettaglio]
(
	@AccountName VARCHAR(64)
	,@ClientName VARCHAR(64)
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsStampeConfigurazioniStampaDettaglio
		Nessuna modifica
*/
	SET NOCOUNT ON

	SELECT 
		  Id
		  ,DataInserimento
		  ,DataModificaConfigurazione
		  ,AccountName
		  ,ClientName
		  ,TipoConfigurazione
		  ,ServerDiStampa
		  ,Stampante
		  ,DataTestStampante
		  ,ErroreTestStampante
	FROM 
		StampeConfigurazioniStampa
	WHERE
		  (AccountName = @AccountName)
		  AND (ClientName = @ClientName)

END

