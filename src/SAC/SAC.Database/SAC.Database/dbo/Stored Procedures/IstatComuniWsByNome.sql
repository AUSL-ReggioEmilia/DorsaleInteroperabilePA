
CREATE PROCEDURE [dbo].[IstatComuniWsByNome]
(
	  @Nome varchar(128)
	, @Obsoleti bit
)
AS
BEGIN
/*
	Modifica Ettore 2014-05-20: tolto i campi Obsoleto e ObsoletoData (li restituisco usando i nuovi campi)
*/
	SET NOCOUNT ON;
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	IF RIGHT(@Nome, 1) = '*'
	BEGIN
		SET @Nome = SUBSTRING(@Nome, 1, LEN(@Nome)-1) + '%'
	END

	SELECT 
		Codice
		, Nome
		, CodiceProvincia
		, CASE 
			WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
			END AS Obsoleto
		, DataFineValidita AS ObsoletoData		
	FROM 
		IstatComuni
	WHERE
		(Nome LIKE @Nome OR @Nome IS NULL)
		AND (Nazione = 0)
		--AND (Obsoleto = @Obsoleti OR @Obsoleti IS NULL)
		AND 
		(
			(@Obsoleti IS NULL) OR 
			 (CASE 
				WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
					CAST(0 AS BIT) 
				ELSE CAST(1 AS BIT) 
				END = @Obsoleti) 
		)
		AND (Nome NOT LIKE '%{Codice Sconosciuto}%')
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatComuniWsByNome] TO [DataAccessWs]
    AS [dbo];

