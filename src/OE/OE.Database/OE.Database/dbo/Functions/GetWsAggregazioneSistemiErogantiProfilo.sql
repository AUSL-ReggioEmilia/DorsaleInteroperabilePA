
CREATE FUNCTION [dbo].[GetWsAggregazioneSistemiErogantiProfilo] (
	@IDProfilo uniqueidentifier
)
RETURNS VARCHAR(MAX)
AS
BEGIN
--2014-10-17 Sandro - Rimosso cursore

	DECLARE @separator VARCHAR(1) = ';'
	DECLARE @returnValue VARCHAR(MAX) = ''

	SELECT 	@returnValue = @returnValue + (SistemiDescrizioni.CodiceAzienda + '@' + 
											SistemiDescrizioni.Codice) +
											@separator 
	FROM 
		(
		SELECT DISTINCT S.CodiceAzienda, S.Codice
		FROM [dbo].[GetProfiloGerarchia2](@IDProfilo) PP
			INNER JOIN Sistemi S ON S.ID = PP.IdSistemaErogante
			INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda
		WHERE PP.Attivo = 1
		) AS SistemiDescrizioni
	
	--Trim ultimo separatore
	SET @returnValue = SUBSTRING(@returnValue, 1, 
										CASE WHEN LEN(@returnValue) <= LEN(@separator) THEN 0
											ELSE LEN(@returnValue)-LEN(@separator) END
								)
	-- Lo schema del WS richiede NOT NULL
	RETURN ISNULL(@returnValue, '')
END
