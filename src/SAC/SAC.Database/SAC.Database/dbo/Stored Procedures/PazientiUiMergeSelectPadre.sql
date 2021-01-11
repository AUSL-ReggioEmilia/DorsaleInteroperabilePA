
CREATE PROCEDURE [dbo].[PazientiUiMergeSelectPadre]
(
	@IdPaziente AS uniqueidentifier
)
AS
BEGIN
/*
	MODIFICA ETTORE 2014-03-07: Restituizione del campo codice fiscale 
*/
	DECLARE @IdPazientePadre AS uniqueidentifier

	SET NOCOUNT ON;

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT 
		@IdPazientePadre = IdPaziente 
	FROM 
		PazientiFusioni 
	WHERE 
		IdPazienteFuso = @IdPaziente 
		AND Abilitato = 1


	IF @IdPazientePadre IS NULL
		SET @IdPazientePadre = @IdPaziente


	SELECT 
		Id AS IdPaziente, 
		Id AS IdPazienteFuso, 
		1 AS Abilitato,
		Provenienza,
		IdProvenienza,
		Cognome, 
		Nome, 
		DataNascita,
		CodiceFiscale
	FROM 
		Pazienti
	WHERE 
		Id = @IdPazientePadre

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiMergeSelectPadre] TO [DataAccessUi]
    AS [dbo];

