
CREATE PROCEDURE [dbo].[PazientiUiComboNazioni]
AS
BEGIN
/*
	Modifica Ettore 2014-05-20: tolto i campi Obsoleto e ObsoletoData (li restituisco usando i nuovi campi)
*/
	SET NOCOUNT ON;
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	SELECT 
		  Codice
		, CASE
			WHEN NOT (GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE())) AND (DataFineValidita IS NULL) THEN
				Nome + ' (Obsoleto)'
			WHEN NOT (GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE())) AND NOT (DataFineValidita IS NULL) THEN 
				Nome + ' (Fino al ' + CONVERT(VARCHAR(10) , DataFineValidita, 103 ) + ')'
			ELSE Nome
		END AS Nome
	FROM 
		IstatNazioni
	UNION
	SELECT 
		null as Codice
		, '- seleziona la nazione -' as Nome
	ORDER BY Nome
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiComboNazioni] TO [DataAccessUi]
    AS [dbo];

