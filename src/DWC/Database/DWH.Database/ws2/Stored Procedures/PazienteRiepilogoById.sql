

CREATE PROCEDURE [ws2].[PazienteRiepilogoById]
(
	@IdPazienti  uniqueidentifier
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2PazienteRiepilogoById
		Ritorna le informazioni relative al paziente passato
		
	MODIFICA ETTORE 2015-07-24: traslazione dell’IdPaziente passato come parametro nell’IdPaziente Attivo
*/
	SET NOCOUNT ON
	--			
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPazienti = dbo.GetPazienteAttivoByIdSac(@IdPazienti)

	SELECT	
		Id --questo è sempre l'IdPazienteAttivo
		, Cognome	
		, Nome
		, DataNascita
		, CodiceFiscale
		, Sesso
		, CodiceSanitario			
		, LuogoNascita			
		, dbo.GetPazientiConsenso(Id) AS Consenso --0=NEGATO,1=ACCORDATO,2=NON FORMNITO.
		, dbo.GetPazientiDataConsenso(Id) AS DataConsenso
		, dbo.GetPazientiDataDecesso(Id) AS DataDecesso			
	FROM	
		Pazienti
	WHERE   
		Id = @IdPazienti

	RETURN @@ERROR

END

