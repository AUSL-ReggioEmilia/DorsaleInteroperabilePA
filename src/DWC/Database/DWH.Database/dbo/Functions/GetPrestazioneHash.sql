

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetPrestazioneHash] (@Id uniqueidentifier)  
RETURNS VARBINARY(MAX) AS  
BEGIN 
/*
Calcola hash del referto
*/
DECLARE @Hash AS VARBINARY(MAX) 

	IF NOT @ID IS NULL
	BEGIN
		--
		-- Prestazioni
		--
		SET @Hash = HashBytes('SHA1',(
			SELECT Prestazione.Id, Prestazione.DataInserimento, Prestazione.DataModifica,
				CONVERT(XML, (
						SELECT HashBytes('SHA1', 
							Attributo.Nome + '|' + CONVERT(VARCHAR(MAX), Attributo.Valore)) AS [Hash]
						FROM store.PrestazioniAttributi AS Attributo
						WHERE Attributo.IdPrestazioniBase = Prestazione.Id
							AND Attributo.DataPartizione = Prestazione.DataPartizione
							AND NOT Attributo.Valore IS NULL
						ORDER BY Attributo.Nome
						FOR XML AUTO, BINARY BASE64
						)) AS Attributi
			FROM store.PrestazioniBase AS Prestazione
			WHERE Prestazione.Id = @Id
			FOR XML AUTO, BINARY BASE64
				))
	END
	ELSE
	BEGIN
		SET @Hash = NULL
	END

	RETURN @Hash
END

