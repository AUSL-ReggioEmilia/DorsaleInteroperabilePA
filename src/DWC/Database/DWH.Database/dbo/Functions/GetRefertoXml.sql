




CREATE FUNCTION [dbo].[GetRefertoXml] (@Id uniqueidentifier)  
RETURNS XML AS  
BEGIN 
/*
 Ritorna un segmento XML di tutto il referto, prestazioni e allegato complesi

MODIFICA SANDRO 2015-08-19: Usa le VIEW store
							Invece di AllegatiBase usa Allegati che gestisce MineDataCompresso
							Prestazioni e Referti usate per ottimizare accesso agli attributi
MODIFICA ETTORE 2020-05-18: Non vengono restituiti gli attributi persistenti del referto (inizialno con $@)
							Restituisco '$@NumeroVersione' traslando il nome -> 'Dwh@NumeroVersione' 

*/
DECLARE @XmlReferto xml
DECLARE @XmlPrestazioni xml
DECLARE @XmlAllegati xml

	IF NOT @ID IS NULL
	BEGIN
		--
		-- Prestazioni
		--
		SET @XmlPrestazioni = (
			SELECT Prestazione.Id, Prestazione.DataInserimento, Prestazione.DataModifica,
				Prestazione.DataErogazione,
				Prestazione.PrestazioneCodice, Prestazione.PrestazioneDescrizione, 
				Prestazione.SezioneCodice, Prestazione.SezioneDescrizione,
				CONVERT(XML ,( 
						SELECT Attributo.Nome, Attributo.Valore
						FROM store.PrestazioniAttributi AS Attributo
						WHERE Attributo.IdPrestazioniBase = Prestazione.Id
							AND Attributo.DataPartizione = Prestazione.DataPartizione
						ORDER BY Attributo.Nome
						FOR XML AUTO, ELEMENTS
						)) AS Attributi
			FROM store.Prestazioni AS Prestazione
			WHERE Prestazione.IdRefertiBase = @ID
			ORDER BY  Prestazione.PrestazioneCodice
			FOR XML AUTO, ELEMENTS
				)
		--
		-- Allegati
		--
		SET @XmlAllegati = (
			SELECT Allegati.ID, Allegati.DataInserimento, Allegati.DataModifica
					, Allegati.DataFile, Allegati.MimeType, Allegati.MimeData
					, CONVERT(XML, (
						SELECT Attributo.Nome, Attributo.Valore
						FROM store.AllegatiAttributi AS Attributo
						WHERE Attributo.IdAllegatiBase = Allegati.Id
							AND Attributo.DataPartizione = Allegati.DataPartizione
						ORDER BY  Attributo.Nome
						FOR XML AUTO, ELEMENTS
						)) AS Attributi
			FROM store.Allegati AS Allegati
			WHERE Allegati.IdRefertiBase = @ID
			ORDER BY  Allegati.DataModifica
			FOR XML AUTO, ELEMENTS, BINARY BASE64
				)
		--
		-- Referto
		--	
		SET @XmlReferto = (
			SELECT Referto.Id, Referto.DataInserimento, Referto.DataModifica,
				Referto.AziendaErogante, Referto.SistemaErogante, Referto.RepartoErogante, 
				Referto.DataReferto, Referto.NumeroReferto, 
				Referto.NumeroPrenotazione, Referto.NumeroNosologico,
				@XmlPrestazioni AS Prestazioni,
				@XmlAllegati AS Allegati,
				CONVERT(XML, (
							SELECT 
								CASE WHEN Attributo.Nome = '$@NumeroVersione' THEN 'Dwh@NumeroVersione'
								ELSE Attributo.Nome  END AS Nome
								, Attributo.Valore
							FROM store.RefertiAttributi AS Attributo
							WHERE Attributo.IdRefertiBase = Referto.Id
								AND Attributo.DataPartizione = Referto.DataPartizione
								-- MODIFICA ETTORE 2020-05-18: Non vengono restituiti gli attributi persistenti del referto
								-- Restituisco '$@NumeroVersione' traslando il nome -> 'Dwh@NumeroVersione' 
								AND ( 
										(NOT Nome like ('$@%'))
										OR 
										Nome = '$@NumeroVersione'
									)
							ORDER BY  Attributo.Nome
							FOR XML AUTO, ELEMENTS
				)) AS Attributi
			FROM store.Referti AS Referto
			WHERE Referto.Id = @ID
			FOR XML AUTO, ELEMENTS
				)
	END

	RETURN @XmlReferto
END
