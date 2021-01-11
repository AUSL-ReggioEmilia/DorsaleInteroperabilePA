
CREATE FUNCTION [dbo].[GetAllegatoHash]
 (@Id uniqueidentifier)  
RETURNS VARBINARY(MAX) AS  
BEGIN 
/*
 Calcola hash dell'ALLEGATO

 MODIFICA SANDRO 2015-08-19: Usa le VIEW store
*/
DECLARE @Hash AS VARBINARY(MAX) = NULL

	IF NOT @ID IS NULL
		--
		-- Converte in XML i vari dati, poi SHA1
		--
		SET @Hash = HashBytes('SHA1',(
			SELECT Allegato.ID, Allegato.DataInserimento, Allegato.DataModifica,
					CONVERT(XML, (
						SELECT HashBytes('SHA1', 
							Attributo.Nome + '|' + CONVERT(VARCHAR(MAX), Attributo.Valore)) AS [Hash]
						FROM store.AllegatiAttributi AS Attributo
						WHERE Attributo.IdAllegatiBase = Allegato.Id
							AND Attributo.DataPartizione = Allegato.DataPartizione
							AND NOT Attributo.Valore IS NULL
						ORDER BY  Attributo.Nome
						FOR XML AUTO, BINARY BASE64
						)) AS Attributi
			FROM store.AllegatiBase AS Allegato
			WHERE Allegato.Id = @ID
			FOR XML AUTO, BINARY BASE64
				))

	RETURN @Hash
END
