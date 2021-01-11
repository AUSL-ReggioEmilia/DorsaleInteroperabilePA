
CREATE PROCEDURE [ws2].[PazienteByRiferimenti]
(
	@Anagrafica VARCHAR (16), @IdAnagrafica VARCHAR (64)
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2PazienteByRiferimenti

	Ritorna le informazioni relative al paziente passato
	Eseguito in passi separati la ricerca del paziente e del consenso: L'esecuzione inline  delle function causa timeout 
	Restituzione della data di decesso									  
*/
	SET NOCOUNT ON

	-------------------------------------------------------------------------------------------------------------------------
	--  Ricerco in PazientiRiferimenti il Paziente per Anagrafica+Codice
	-------------------------------------------------------------------------------------------------------------------------
	DECLARE @IdPaziente	UNIQUEIDENTIFIER = NULL
	DECLARE @Consenso TINYINT = NULL
	SELECT @IdPaziente = dbo.GetPazientiIdByRiferimento(@Anagrafica, @IdAnagrafica)
	IF NOT @IdPaziente IS NULL
		SELECT @Consenso = dbo.GetPazientiConsenso(@IdPaziente)  
	
	SELECT	Id,
			AziendaErogante, 
			SistemaErogante, 
			RepartoErogante, 
			CodiceSanitario,
			Nome, Cognome,
			DataNascita,
			LuogoNascita,
			CodiceFiscale,
			Sesso,
			@Consenso as Consenso, 
			DatiAnamnestici,
			dbo.GetPazientiDataDecesso(Pazienti.Id)  AS DataDecesso
	FROM	
		Pazienti
	WHERE	
		Id = @IdPaziente

	RETURN @@ERROR

END
