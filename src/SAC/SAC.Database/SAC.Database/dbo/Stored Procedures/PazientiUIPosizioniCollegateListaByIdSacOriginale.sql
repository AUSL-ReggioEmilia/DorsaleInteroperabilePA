

-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2018-02-22
-- Description:	Restituisce la lista della posizioni collegate alla'anagrafica SAC con guid uguale a @IdSacOriginale
-- =============================================
CREATE PROC [dbo].[PazientiUIPosizioniCollegateListaByIdSacOriginale]

(
	@IdSacOriginale uniqueidentifier
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
		IdSacOriginale = @IdSacOriginale
	ORDER BY 
		DataInserimento DESC
		
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUIPosizioniCollegateListaByIdSacOriginale] TO [DataAccessUi]
    AS [dbo];

