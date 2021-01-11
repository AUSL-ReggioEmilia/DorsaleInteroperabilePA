

-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2018-02-22
-- Description:	Utilizzata per ottenere i dati principali della "posizione collegata"
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUIPosizioniCollegateSelectByIdSacPosizioneCollegata]
(
	@IdSacPosizioneCollegata uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT OFF
	SELECT 
		PC.IdPosizioneCollegata
		, PC.IdSacPosizioneCollegata --questo è l'Id dell'anagrafica SAC associata al codice IdPosizioneCollegata
		, PC.IdSacOriginale --questo è l'id dell'anagrafica reale 
		, PC.DataInserimento
		, PC.Utente
		, PC.Note
		-- DATI DELLA POSIZIONE ANAGRAFICA COLLEGATA
		, P.Nome As PosizioneCollegataNome
		, P.Cognome As PosizioneCollegataCognome
		, P.Sesso As PosizioneCollegataSesso
		, P.DataNascita As PosizioneCollegataDataNascita
		--, '000000' AS PosizioneCollegataComuneNascitaDescrizione
		, CASE WHEN P.ComuneNascitaCodice = '000000' THEN
			'000000'
		ELSE
			(SELECT TOP 1 CAST(ISNULL(Nome, '') AS varchar(128)) FROM IstatComuni WHERE Codice = P.ComuneNascitaCodice ) 
		END AS PosizioneCollegataComuneNascitaDescrizione
		, P.CodiceFiscale AS PosizioneCollegataCodiceFiscale
	FROM  
		PazientiPosizioniCollegate AS PC
		INNER JOIN PazientiUiBaseResult AS P
			ON P.Id = PC.IdSacPosizioneCollegata
	WHERE 
		IdSacPosizioneCollegata = @IdSacPosizioneCollegata
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUIPosizioniCollegateSelectByIdSacPosizioneCollegata] TO [DataAccessUi]
    AS [dbo];

