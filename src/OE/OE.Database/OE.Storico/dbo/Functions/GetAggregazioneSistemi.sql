

CREATE FUNCTION [dbo].[GetAggregazioneSistemi]
(
	@idOrdiniTestate VARCHAR(100), 
	@separator VARCHAR(10)
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @returnValue VARCHAR(MAX);
	SET @returnValue = '';

	SELECT 	@returnValue = @returnValue + ((SistemiDescrizioni.CodiceAzienda + '-' + 
											ISNULL( SistemiDescrizioni.Codice, SistemiDescrizioni.Descrizione))) +
											@separator 
	FROM 
		(
		SELECT DISTINCT Sistemi.Codice, Sistemi.CodiceAzienda, Sistemi.Descrizione
		FROM dbo.GetGerarchiaPrestazioniOrdineByIdTestata(@idOrdiniTestate) GP
			INNER JOIN dbo.Prestazioni	ON GP.IDFiglio = Prestazioni.ID
			INNER JOIN dbo.Sistemi ON Sistemi.ID = Prestazioni.IdSistemaErogante
									  
		WHERE Sistemi.ID <> '00000000-0000-0000-0000-000000000000' 
		) AS SistemiDescrizioni
	
	--Trim ultimo separatore
	SET @returnValue = SUBSTRING(@returnValue, 1, CASE WHEN LEN(@returnValue) <= LEN(@separator) THEN 0
											ELSE LEN(@returnValue)-LEN(@separator) END)
	
	RETURN NULLIF(@returnValue, '')
END
