

CREATE PROC [dbo].[PazientiUIAnonimizzazioniListaByIdSacOriginale]

(
	@IdSacOriginale uniqueidentifier
)
AS
BEGIN
SET NOCOUNT OFF
	SELECT 
		IdAnonimo,
		IdSacAnonimo,
		IdSacOriginale,
		DataInserimento,
		Utente,
		Note
	FROM  
		PazientiAnonimizzazioni
	WHERE 
		IdSacOriginale = @IdSacOriginale
	ORDER BY 
		DataInserimento DESC
		
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUIAnonimizzazioniListaByIdSacOriginale] TO [DataAccessUi]
    AS [dbo];

