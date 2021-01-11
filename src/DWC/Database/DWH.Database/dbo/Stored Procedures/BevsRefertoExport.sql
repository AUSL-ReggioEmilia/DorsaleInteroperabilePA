
-- =============================================
-- Author:		ETTORE
-- Create date: 2018-01-17
-- Description:	Restituisce XML che rappresenta il referto
-- =============================================
CREATE PROCEDURE [dbo].[BevsRefertoExport]
(
	@IdReferto UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	/*
		XML come ELEMENT
	*/
	DECLARE @XmlReferto xml

	IF NOT @IdReferto IS NULL
	BEGIN
	
		--
		-- Prestazioni testate
		--
		DECLARE @XmlPrestazioniBase XML
		SET @XmlPrestazioniBase = (
			SELECT 
				PrestazioneBase.Id
				, PrestazioneBase.IdRefertiBase
				, PrestazioneBase.IdEsterno
				, PrestazioneBase.DataInserimento
				, PrestazioneBase.DataModifica
				, PrestazioneBase.DataErogazione
				, PrestazioneBase.PrestazioneCodice
				, PrestazioneBase.PrestazioneDescrizione
				, PrestazioneBase.SoundexPrestazione
				, PrestazioneBase.SezioneCodice
				, PrestazioneBase.SezioneDescrizione
				, PrestazioneBase.SoundexSezione
				, PrestazioneBase.DataPartizione
			FROM store.PrestazioniBase AS PrestazioneBase
			WHERE PrestazioneBase.IdRefertiBase = @IdReferto
			ORDER BY  PrestazioneBase.IdEsterno
			FOR XML AUTO, ELEMENTS
			)

		--
		-- Tutti gli attributi elle prestazioni
		--
		DECLARE @XmlPrestazioniAttributi AS XML 
		SET @XmlPrestazioniAttributi = (
						SELECT PrestazioneAttributi.IdPrestazioniBase, PrestazioneAttributi.Nome, PrestazioneAttributi.Valore, PrestazioneAttributi.DataPartizione
						FROM 
							store.PrestazioniBase AS Prestazione
							INNER JOIN store.PrestazioniAttributi AS PrestazioneAttributi
								ON Prestazione.Id = PrestazioneAttributi.IdPrestazioniBase
						WHERE 
							Prestazione.IdRefertiBase = @IdReferto
							AND PrestazioneAttributi.DataPartizione = Prestazione.DataPartizione
						ORDER BY PrestazioneAttributi.IdPrestazioniBase, PrestazioneAttributi.Nome
						FOR XML AUTO, ELEMENTS
						)
	
		--
		-- Allegati base
		--
		DECLARE @XmlAllegatiBase XML
		SET @XmlAllegatiBase = (
			SELECT [Id]
				  ,[IdRefertiBase]
				  ,[IdEsterno]
				  ,[DataInserimento]
				  ,[DataModifica]
				  ,[DataFile]
				  ,[MimeType]
				  ,[MimeData]
				  ,[DataPartizione]
				  ,[MimeDataCompresso]
				  ,[MimeStatoCompressione]
				  ,[MimeDataOriginale]
			  FROM [store].[AllegatiBase] AS AllegatoBase
			WHERE AllegatoBase.IdRefertiBase = @IdReferto
			ORDER BY  AllegatoBase.IdEsterno
			FOR XML AUTO, ELEMENTS, BINARY BASE64
			)
			
		--
		-- Tutti gli attributi degli allegati
		--
		DECLARE @XmlAllegatiAttributi AS XML 
		SET @XmlAllegatiAttributi = (
						SELECT AllegatoAttributi.IdAllegatiBase, AllegatoAttributi.Nome, AllegatoAttributi.Valore, AllegatoAttributi.DataPartizione
						FROM 
							store.AllegatiBase AS Allegato
							INNER JOIN store.AllegatiAttributi AS AllegatoAttributi
								ON Allegato.Id = AllegatoAttributi.IdAllegatiBase
						WHERE 
							Allegato.IdRefertiBase = @IdReferto
							AND AllegatoAttributi.DataPartizione = Allegato.DataPartizione
						ORDER BY AllegatoAttributi.IdAllegatiBase, AllegatoAttributi.Nome
						FOR XML AUTO, ELEMENTS
						)
	
		DECLARE @XmlAttributiReferto xml
		SET @XmlAttributiReferto = (			
							SELECT Attributo.IdRefertiBase, Attributo.Nome, Attributo.Valore, Attributo.DataPartizione
							FROM store.RefertiAttributi AS Attributo INNER JOIN store.RefertiBase AS Referto
									ON Attributo.IdRefertiBase = Referto.Id
									AND (Attributo.DataPartizione = Referto.DataPartizione)
							WHERE Referto.ID = @IdReferto
							ORDER BY Attributo.IdRefertiBase, Attributo.Nome
							FOR XML AUTO, ELEMENTS
						)


		--
		-- La testata del referto + tutte le varie parti calcolate sopra
		--
		SELECT @XmlReferto = (
			SELECT 
				--I dati di testata della tabella store.RefertiBase
				Referto.Id
				, Referto.DataPartizione
				, Referto.IdEsterno
				, Referto.IdPaziente
				, Referto.DataInserimento
				, Referto.DataModifica
				, Referto.AziendaErogante
				, Referto.SistemaErogante
				, Referto.RepartoErogante
				, Referto.DataReferto
				, Referto.NumeroReferto
				, Referto.NumeroNosologico
				, Referto.Cancellato
				, Referto.NumeroPrenotazione
				, Referto.DataModificaEsterno
				, Referto.StatoRichiestaCodice
				, Referto.RepartoRichiedenteCodice
				, Referto.RepartoRichiedenteDescr
				, Referto.IdOrderEntry
				, Referto.DataEvento
				, Referto.Firmato
				--Gli attributi del referto
				, @XmlAttributiReferto as Attributi
				--Le prestazioni e gli attributi delle prestazioni
				, @XmlPrestazioniBase AS PrestazioniBase
				, @XmlPrestazioniAttributi AS PrestazioniAttributi
				--Gli allegati e gli attributi degli allegati
				, @XmlAllegatiBase AS AllegatiBase
				, @XmlAllegatiAttributi AS AllegatiAttributi
			FROM store.RefertiBase AS Referto
			WHERE Referto.Id = @IdReferto
			FOR XML AUTO, ELEMENTS
			)


	END
	--
	--
	--
	SELECT @XmlReferto AS XmlReferto

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertoExport] TO [ExecuteFrontEnd]
    AS [dbo];

