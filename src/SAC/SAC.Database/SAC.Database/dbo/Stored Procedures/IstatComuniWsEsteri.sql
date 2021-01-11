
CREATE PROCEDURE [dbo].[IstatComuniWsEsteri]
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
		, Nome
		, CASE 
			WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
			END AS Obsoleto
		, DataFineValidita AS ObsoletoData		  
	FROM 
		IstatComuni

	WHERE
			(IstatComuni.Nazione = 1)
		AND (IstatComuni.Nome NOT LIKE '%{Codice Sconosciuto}%')
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatComuniWsEsteri] TO [DataAccessWs]
    AS [dbo];

