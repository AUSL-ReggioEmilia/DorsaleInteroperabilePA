
CREATE FUNCTION [dbo].[GetRefertoHash] (@Id uniqueidentifier)  
RETURNS VARBINARY(MAX) AS  
BEGIN 
/*
 Calcola hash del referto. Viene eseguito in piccoli step per evita una errore di stringa troncata

MODIFICATO SANDRO 2015-08-19: Usa la VIEW store, che hanno già xml attributi
*/
DECLARE @Hash AS VARBINARY(MAX) 

	IF NOT @ID IS NULL
	BEGIN
		--
		-- Prestazioni
		--
		DECLARE @Prestazioni VARCHAR(MAX) 
		DECLARE @HashPrestazioni VARBINARY(MAX) 

		SET @Prestazioni = 
			(
			SELECT dbo.GetPrestazioneHash(Prestazione.Id) AS [Hash]
			FROM store.PrestazioniBase AS Prestazione
			WHERE Prestazione.IdRefertiBase = @ID
			ORDER BY Prestazione.DataModifica
			FOR XML AUTO, BINARY BASE64
			)
				
		SET @HashPrestazioni = HashBytes('SHA1', @Prestazioni)

		--
		-- Allegati
		--
		DECLARE @Allegati VARCHAR(MAX) 
		DECLARE @HashAllegati VARBINARY(MAX) 

		SET @Allegati = 
			(
			SELECT dbo.GetAllegatoHash(Allegato.Id) AS [Hash]
			FROM store.AllegatiBase AS Allegato
			WHERE Allegato.IdRefertiBase = @ID
			ORDER BY  Allegato.DataModifica
			FOR XML AUTO, BINARY BASE64
			)

		SET @HashAllegati = HashBytes('SHA1', @Allegati)
		--
		-- Referto
		--	
		DECLARE @Referto VARCHAR(MAX) 

	    SET @Referto = 
			(
			SELECT Referto.Id, Referto.DataInserimento, Referto.DataModifica,
				@HashPrestazioni AS Prestazioni,
				@HashAllegati AS Allegati,
				CONVERT(XML, (
							SELECT HashBytes('SHA1', 
								Attributo.Nome + '|' + CONVERT(VARCHAR(MAX), Attributo.Valore)) AS [Hash]
							FROM store.RefertiAttributi AS Attributo
							WHERE Attributo.IdRefertiBase = Referto.Id
								AND Attributo.DataPartizione = Referto.DataPartizione
								AND NOT Attributo.Nome LIKE 'Sole-%' 
								AND NOT Attributo.Valore IS NULL
							ORDER BY  Attributo.Nome
							FOR XML AUTO, BINARY BASE64
				)) AS Attributi
			FROM store.RefertiBase AS Referto
			WHERE Referto.Id = @ID
			FOR XML AUTO, BINARY BASE64
				)
				
		SET @Hash = HashBytes('SHA1', @Referto)
	END
	ELSE
	BEGIN
		SET @Hash = NULL
	END

	RETURN @Hash
END
