
CREATE PROCEDURE [dbo].[IstatNazioniWsByNome]
(
	  @Nome varchar(64)
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
		, CASE 
			WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
			END AS Obsoleto
		, DataFineValidita AS ObsoletoData		
	FROM 
		IstatNazioni
	WHERE
		(Nome LIKE @Nome OR @Nome IS NULL)
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
    ON OBJECT::[dbo].[IstatNazioniWsByNome] TO [DataAccessWs]
    AS [dbo];

