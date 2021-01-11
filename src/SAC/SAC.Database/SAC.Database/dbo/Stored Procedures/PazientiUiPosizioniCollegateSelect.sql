
-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2018-02-22
-- Description:	Utilizzata per ottenere a quale Paziente è associata la "posizione collegata"
-- =============================================
CREATE PROC [dbo].[PazientiUiPosizioniCollegateSelect]
(
	@IdPosizioneCollegata varchar(16) --Id/Codice della posizione collegata
)
AS
BEGIN
SET NOCOUNT OFF
	SELECT 
		IdPosizioneCollegata,
		IdSacPosizioneCollegata,
		IdSacOriginale,
		DataInserimento,
		Utente,
		Note
	FROM  
		PazientiPosizioniCollegate
	WHERE 
		IdPosizioneCollegata = @IdPosizioneCollegata
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiPosizioniCollegateSelect] TO [DataAccessUi]
    AS [dbo];

