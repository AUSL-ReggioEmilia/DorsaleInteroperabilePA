


CREATE PROCEDURE [dbo].[IstatAslSelect]
	  @Codice varchar(3)
	, @CodiceComune varchar(6)

AS
BEGIN
/*
	MODIFICA ETTORE 2015-05-24: cerco sempre il codice della regione, perchè nella tabella IstataAsl potrebbe mancare
*/
	SET NOCOUNT ON;

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT 
		Codice, CodiceComune, Nome, --,CodiceAslRegione 
		CASE WHEN CodiceAslRegione = '' THEN
			(SELECT TOP 1 CodiceRegione FROM [IstatComuni] Where Nazione = 0 AND Codice = @CodiceComune)
		ELSE 
			CodiceAslRegione
		END AS CodiceAslRegione 
	FROM 
		IstatAsl
	WHERE
			Codice = @Codice
		AND CodiceComune = @CodiceComune
	
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatAslSelect] TO [DataAccessUi]
    AS [dbo];

