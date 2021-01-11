
CREATE FUNCTION [dbo].[GetWsAggregazioneSistemiEroganti]
(
	@idOrdineTestata uniqueidentifier
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @separator VARCHAR(1) = ';'
	DECLARE @returnValue VARCHAR(MAX) = ''

	SELECT @returnValue = @returnValue + (Sistemi.CodiceAzienda + '@' + Sistemi.Codice) +
											@separator
	FROM 
		(
		SELECT DISTINCT Sistemi.Codice, Sistemi.CodiceAzienda, Sistemi.Descrizione
		FROM dbo.GetGerarchiaPrestazioniOrdineByIdTestata(@idOrdineTestata) GP
			INNER JOIN dbo.Prestazioni	ON GP.IDFiglio = Prestazioni.ID
			INNER JOIN dbo.Sistemi ON Sistemi.ID = Prestazioni.IdSistemaErogante
									  
		WHERE Sistemi.ID <> '00000000-0000-0000-0000-000000000000' 
		) AS Sistemi
	
	--Trim ultimo separatore
	SET @returnValue = SUBSTRING(@returnValue, 1, 
										CASE WHEN LEN(@returnValue) <= LEN(@separator) THEN 0
											ELSE LEN(@returnValue) - LEN(@separator) END
								)
	-- Lo schema del WS richiede NOT NULL
	RETURN ISNULL(@returnValue, '')
END
