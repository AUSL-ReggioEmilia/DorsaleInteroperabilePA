
CREATE PROC [dbo].[PazientiUiAnonimizzazioniSelect]
(
	@IdAnonimo varchar(16)
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
		IdAnonimo = @IdAnonimo
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiAnonimizzazioniSelect] TO [DataAccessUi]
    AS [dbo];

