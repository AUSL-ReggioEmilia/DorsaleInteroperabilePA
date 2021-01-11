
CREATE FUNCTION [dbo].[GetWsAggregazioneSistemiErogantiDescrizione]
(
	@idOrdineTestata uniqueidentifier
)
RETURNS VARCHAR(MAX)
AS
BEGIN
--2014-10-27 Sandro: Restituisce l'aggregazione delle descrizioni dei sistemi eroganti

	DECLARE @separator VARCHAR(1) = ';'
	DECLARE @returnValue VARCHAR(MAX) = ''

	SELECT 	@returnValue = @returnValue + CASE WHEN NOT Sistemi.Descrizione IS NULL THEN 
													(Sistemi.CodiceAzienda + ' - ' + Sistemi.Descrizione) +
														@separator
											ELSE (Sistemi.CodiceAzienda + ' - ' + Sistemi.Codice) +
													@separator
											END
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
