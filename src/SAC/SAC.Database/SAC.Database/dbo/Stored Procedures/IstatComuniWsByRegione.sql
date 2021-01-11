
CREATE PROCEDURE [dbo].[IstatComuniWsByRegione]
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
		  IstatComuni.Codice
		, IstatComuni.Nome
		, IstatComuni.CodiceProvincia
		, CASE 
			WHEN GETDATE() BETWEEN ISNULL(IstatComuni.DataInizioValidita, '1800-01-01') AND ISNULL(IstatComuni.DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
			END AS Obsoleto
		, IstatComuni.DataFineValidita AS ObsoletoData		

	FROM 
		IstatComuni

		INNER JOIN IstatProvince ON IstatComuni.CodiceProvincia = IstatProvince.Codice

		INNER JOIN IstatRegioni ON IstatProvince.CodiceRegione = IstatRegioni.Codice
	
	WHERE
			(IstatRegioni.Nome LIKE @Nome OR @Nome IS NULL)
		AND (IstatComuni.Nazione = 0)
		--AND (IstatComuni.Obsoleto = @Obsoleti OR @Obsoleti IS NULL)
		AND 
		(
			(@Obsoleti IS NULL) OR 
			 (CASE 
				WHEN GETDATE() BETWEEN ISNULL(IstatComuni.DataInizioValidita, '1800-01-01') AND ISNULL(IstatComuni.DataFineValidita, GETDATE()) THEN
					CAST(0 AS BIT) 
				ELSE CAST(1 AS BIT) 
				END = @Obsoleti) 
		)
		AND (IstatComuni.Nome NOT LIKE '%{Codice Sconosciuto}%')
	
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatComuniWsByRegione] TO [DataAccessWs]
    AS [dbo];

