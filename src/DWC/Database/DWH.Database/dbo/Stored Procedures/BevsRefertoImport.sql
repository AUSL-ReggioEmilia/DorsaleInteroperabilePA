
-- =============================================
-- Author:		ETTORE
-- Create date: 2018-01-17
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- Modify date: 2020-12-18 - ETTORE - Rimozione della, parte di aggancio paziente (DWH-Tool import dei referti - uso della SP SAC dbo.PazientiOutputCercaAggancioPaziente item 1434)
-- Description:	Importazione referto
-- =============================================
CREATE PROCEDURE [dbo].[BevsRefertoImport]
(
	@XmlReferto AS XML
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IdReferto	UNIQUEIDENTIFIER
	DECLARE @IdEsternoReferto VARCHAR(64)
	DECLARE @IdPazienteSacAssociato UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
	--
	DECLARE @NomeAnagrafica varchar(64)
	DECLARE @CodiceAnagrafica varchar(64)
	DECLARE @IdEsternoPaziente VARCHAR(64)
	DECLARE @PazienteNome AS VARCHAR(64)
	DECLARE @PazienteCognome AS VARCHAR(64)
	DECLARE @PazienteCodiceFiscale AS VARCHAR(16)
	DECLARE @PazienteCodiceSanitario AS VARCHAR(16)
	DECLARE @PazienteDataNascita AS DATETIME
	DECLARE @PazienteSesso AS VARCHAR(1)
	--
	DECLARE @AziendaErogante VARCHAR(16)
	--
	-- Leggo alcuni valori
	--
	SELECT @IdReferto = @XmlReferto.value('(/Referto/Id)[1]', 'uniqueidentifier') 
	SELECT @IdEsternoReferto = @XmlReferto.value('(/Referto/IdEsterno)[1]', 'varchar(64)') 
	
	SELECT @NomeAnagrafica = @XmlReferto.value('(//Referto/Attributi/Attributo[Nome=''NomeAnagraficaCentrale'']/Valore)[1]', 'varchar(64)')
	SELECT @CodiceAnagrafica = @XmlReferto.value('(//Referto/Attributi/Attributo[Nome=''CodiceAnagraficaCentrale'']/Valore)[1]', 'varchar(64)') 
	SELECT @IdEsternoPaziente = @XmlReferto.value('(//Referto/Attributi/Attributo[Nome=''IdEsternoPaziente'']/Valore)[1]', 'varchar(64)') 
	SELECT @PazienteNome = @XmlReferto.value('(//Referto/Attributi/Attributo[Nome=''Nome'']/Valore)[1]', 'varchar(64)') 
	SELECT @PazienteCognome = @XmlReferto.value('(//Referto/Attributi/Attributo[Nome=''Cognome'']/Valore)[1]', 'varchar(64)') 
	SELECT @PazienteCodiceFiscale = @XmlReferto.value('(//Referto/Attributi/Attributo[Nome=''CodiceFiscale'']/Valore)[1]', 'varchar(16)') 
	SELECT @PazienteCodiceSanitario = @XmlReferto.value('(//Referto/Attributi/Attributo[Nome=''CodiceSanitario'']/Valore)[1]', 'varchar(16)') 
	SELECT @PazienteDataNascita = @XmlReferto.value('(//Referto/Attributi/Attributo[Nome=''DataNascita'']/Valore)[1]', 'datetime') 
	SELECT @PazienteSesso = @XmlReferto.value('(//Referto/Attributi/Attributo[Nome=''Sesso'']/Valore)[1]', 'varchar(1)') 

	--
	-- Inizio transazione per l'inserimento del referto
	--
	BEGIN TRANSACTION
	BEGIN TRY
		--*********************************************************************
		-- CANCELLAZIONE DEL REFERTO SE ESISTE
		--*********************************************************************
		DECLARE @IdRefertoDaCancellare UNIQUEIDENTIFIER
		SELECT @IdRefertoDaCancellare = Id 
		FROM store.RefertiBase WHERE IdEsterno = @IdEsternoReferto

		IF NOT @IdRefertoDaCancellare IS NULL 
		BEGIN 
			DELETE FROM store.AllegatiAttributi 
			WHERE IdAllegatiBase IN (
					SELECT Id FROM store.AllegatiBase (nolock) WHERE IdRefertiBase = @IdRefertoDaCancellare
					)
			
			DELETE FROM store.AllegatiBase 
			WHERE IdRefertiBase = @IdRefertoDaCancellare

			DELETE FROM store.PrestazioniAttributi WHERE 
			IdPrestazioniBase IN (
				SELECT Id FROM store.PrestazioniBase (nolock) WHERE IdRefertiBase = @IdRefertoDaCancellare
			)

			DELETE FROM store.PrestazioniBase 
			WHERE IdRefertiBase = @IdRefertoDaCancellare

			DELETE FROM store.RefertiAttributi
			WHERE  IdRefertiBase = @IdRefertoDaCancellare

			DELETE FROM store.RefertiBaseRiferimenti
			WHERE IdRefertiBase = @IdRefertoDaCancellare
		
			DELETE FROM store.RefertiBase
			WHERE Id = @IdRefertoDaCancellare

		END 

		--*********************************************************************
		-- INSERIMENTO REFERTO
		--*********************************************************************
		----------------------------------------------------------------
		-- Inserimento testata del referto
		----------------------------------------------------------------
		INSERT INTO [store].[RefertiBase]([Id],[DataPartizione],[IdEsterno],[IdPaziente],[DataInserimento]
		           ,[DataModifica],[AziendaErogante],[SistemaErogante],[RepartoErogante],[DataReferto]
		           ,[NumeroReferto],[NumeroNosologico],[Cancellato],[NumeroPrenotazione],[DataModificaEsterno]
		           ,[StatoRichiestaCodice],[RepartoRichiedenteCodice],[RepartoRichiedenteDescr],[IdOrderEntry],[DataEvento],[Firmato])
		SELECT 
			--@XmlReferto.value('(/Referto/Id)[1]', 'uniqueidentifier') AS Id 
			@IdReferto
			, @XmlReferto.value('(/Referto/DataPartizione)[1]', 'smalldatetime') AS DataPartizione
			, @XmlReferto.value('(/Referto/IdEsterno)[1]', 'varchar(64)') AS IdEsterno
			--
			-- ATTENZIONE: per l'IdPaziente devo usare quello calcolato
			--
			--, @XmlReferto.value('(/Referto/IdPaziente)[1]', 'uniqueidentifier') AS IdPaziente
			, @IdPazienteSacAssociato AS IdPaziente
			--, @XmlReferto.value('(/Referto/DataInserimento)[1]', 'datetime') AS DataInserimento
			, GETDATE() AS DataInserimento
			--, @XmlReferto.value('(/Referto/DataModifica)[1]', 'datetime') AS DataModifica
			, GETDATE() AS DataModifica
			, @XmlReferto.value('(/Referto/AziendaErogante)[1]', 'varchar(16)') AS AziendaErogante
			, @XmlReferto.value('(/Referto/SistemaErogante)[1]', 'varchar(16)') AS SistemaErogante
			, @XmlReferto.value('(/Referto/RepartoErogante)[1]', 'varchar(64)') AS RepartoErogante
			, @XmlReferto.value('(/Referto/DataReferto)[1]', 'datetime') AS DataReferto
			, @XmlReferto.value('(/Referto/NumeroReferto)[1]', 'varchar(16)') AS NumeroReferto
			, @XmlReferto.value('(/Referto/NumeroNosologico)[1]', 'varchar(64)') AS NumeroNosologico
			, @XmlReferto.value('(/Referto/Cancellato)[1]', 'bit') AS Cancellato
			, @XmlReferto.value('(/Referto/NumeroPrenotazione)[1]', 'varchar(32)') AS NumeroPrenotazione
			, @XmlReferto.value('(/Referto/DataModificaEsterno)[1]', 'datetime') AS DataModificaEsterno
			, @XmlReferto.value('(/Referto/StatoRichiestaCodice)[1]', 'tinyint') AS StatoRichiestaCodice
			, @XmlReferto.value('(/Referto/RepartoRichiedenteCodice)[1]', 'varchar(16)') AS RepartoRichiedenteCodice
			, @XmlReferto.value('(/Referto/RepartoRichiedenteDescr)[1]', 'varchar(128)') AS RepartoRichiedenteDescr
			, @XmlReferto.value('(/Referto/IdOrderEntry)[1]', 'varchar(64)') AS IdOrderEntry
			, @XmlReferto.value('(/Referto/DataEvento)[1]', 'datetime') AS DataEvento
			, @XmlReferto.value('(/Referto/Firmato)[1]', 'bit') AS Firmato

		----------------------------------------------------------------
		--	INSERIMENTO Attributi del referto
		----------------------------------------------------------------
		INSERT INTO store.RefertiAttributi(IdRefertiBase,Nome,Valore,DataPartizione)
		SELECT 
			Attributo.Col.value('(IdRefertiBase)[1]','uniqueidentifier') AS IdRefertiBase
			, Attributo.Col.value('(Nome)[1]','varchar(64)') AS Nome
			, Attributo.Col.value('(Valore)[1]', 'varchar(8000)') AS Valore
			, Attributo.Col.value('(DataPartizione)[1]','smalldatetime') AS DataPartizione
		FROM 
			@XmlReferto.nodes('/Referto/Attributi/Attributo') AS Attributo(Col)


		----------------------------------------------------------------
		--	INSERIMENTO in PrestazioniBase
		----------------------------------------------------------------
		INSERT INTO [store].[PrestazioniBase]([ID],[IdRefertiBase],[IdEsterno],[DataInserimento],[DataModifica],[DataErogazione]
	           ,[PrestazioneCodice],[PrestazioneDescrizione],[SoundexPrestazione],[SezioneCodice],[SezioneDescrizione]
	           ,[SoundexSezione],[DataPartizione])
		SELECT 
			Prestazione.col.value('(Id)[1]', 'uniqueidentifier') AS Id
			, Prestazione.col.value('(IdRefertiBase)[1]', 'uniqueidentifier') AS IdRefertiBase
			, Prestazione.col.value('(IdEsterno)[1]', 'varchar(64)') AS IdEsterno
			, Prestazione.col.value('(DataInserimento)[1]', 'datetime') AS DataInserimento
			, Prestazione.col.value('(DataModifica)[1]', 'datetime') AS DataModifica
			, Prestazione.col.value('(DataErogazione)[1]', 'datetime') AS DataErogazione
			, Prestazione.col.value('(PrestazioneCodice)[1]', 'varchar(12)') AS PrestazioneCodice
			, Prestazione.col.value('(PrestazioneDescrizione)[1]', 'varchar(150)') AS PrestazioneCodice
			, Prestazione.col.value('(SoundexPrestazione)[1]', 'varchar(4)') AS PrestazioneCodice
			, Prestazione.col.value('(SezioneCodice)[1]', 'varchar(12)') AS SezioneCodice
			, Prestazione.col.value('(SezioneDescrizione)[1]', 'varchar(255)') AS SezioneDescrizione
			, Prestazione.col.value('(SoundexSezione)[1]', 'varchar(4)') AS SoundexSezione
			, Prestazione.col.value('(DataPartizione)[1]', 'smalldatetime') AS DataPartizione
		FROM 
			@XmlReferto.nodes('/Referto/PrestazioniBase/PrestazioneBase') AS Prestazione(Col)


		----------------------------------------------------------------
		--	INSERIMENTO in PrestazioniAttributi
		----------------------------------------------------------------
		INSERT INTO store.PrestazioniAttributi(IdPrestazioniBase,Nome,Valore,DataPartizione)
		SELECT 		
			Attributo.Col.value('(IdPrestazioniBase)[1]','uniqueidentifier') AS IdPrestazioniBase
			, Attributo.Col.value('(Nome)[1]','varchar(64)') AS Nome
			, Attributo.Col.value('(Valore)[1]', 'varchar(8000)') AS Valore
			, Attributo.Col.value('(DataPartizione)[1]','smalldatetime') AS DataPartizione
		FROM 
			@XmlReferto.nodes('/Referto/PrestazioniAttributi/PrestazioneAttributi') AS Attributo(Col)


		----------------------------------------------------------------
		--	INSERIMENTO in AllegatiBase
		----------------------------------------------------------------
		INSERT INTO [store].[AllegatiBase]([ID],[IdRefertiBase],[IdEsterno],[DataInserimento],[DataModifica],[DataFile],[MimeType]
					,[MimeData]
					,[DataPartizione],[MimeDataCompresso],[MimeStatoCompressione],[MimeDataOriginale])
		SELECT 
			Allegato.col.value('(Id)[1]', 'uniqueidentifier') AS Id
			, Allegato.col.value('(IdRefertiBase)[1]', 'uniqueidentifier') AS IdRefertiBase
			, Allegato.col.value('(IdEsterno)[1]', 'varchar(64)') AS IdEsterno
			, Allegato.col.value('(DataInserimento)[1]', 'datetime') AS DataInserimento
			, Allegato.col.value('(DataModifica)[1]', 'datetime') AS DataModifica
			, Allegato.col.value('(DataFile)[1]', 'datetime') AS DataFile
			, Allegato.col.value('(MimeType)[1]', 'varchar(50)') AS MimeType
			--, Allegato.col.value('(MimeData)[1]', 'image') AS MimeData --non dovrebbe essere più utilizzato
			, CAST(NULL AS IMAGE) AS MimeData --non dovrebbe essere più utilizzato
			, Allegato.col.value('(DataPartizione)[1]', 'smalldatetime') AS DataPartizione

			, Allegato.col.value('(MimeDataCompresso)[1]', 'varbinary(max)') AS MimeDataCompresso
			, Allegato.col.value('(MimeStatoCompressione)[1]', 'tinyint') AS MimeStatoCompressione
			, Allegato.col.value('(MimeDataOriginale)[1]', 'varbinary(max)') AS MimeDataOriginale

		FROM 
			@XmlReferto.nodes('/Referto/AllegatiBase/AllegatoBase') AS Allegato(Col)

		----------------------------------------------------------------
		--	INSERIMENTO in AllegatiAttributi
		----------------------------------------------------------------
		INSERT INTO store.AllegatiAttributi(IdAllegatiBase,Nome,Valore,DataPartizione)
		SELECT 		
			Attributo.Col.value('(IdAllegatiBase)[1]','uniqueidentifier') AS IdPrestazioniBase
			, Attributo.Col.value('(Nome)[1]','varchar(64)') AS Nome
			, Attributo.Col.value('(Valore)[1]', 'varchar(8000)') AS Valore
			, Attributo.Col.value('(DataPartizione)[1]','smalldatetime') AS DataPartizione
		FROM 
			@XmlReferto.nodes('/Referto/AllegatiAttributi/AllegatoAttributi') AS Attributo(Col)


		--
		-- Se si è verificato l'aggancio al paziente comando l'aggiornamento dell'anteprima
		--
		IF (NOT @IdPazienteSacAssociato IS NULL) AND (@IdPazienteSacAssociato <> '00000000-0000-0000-0000-000000000000')
		BEGIN
			EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPazienteSacAssociato, 1, 0, 0
		END

		--
		-- Restituisco l'id del referto e l'Id del paziente a ui il referto è stato associato
		--
		SELECT 
			@IdReferto AS IdReferto,  
			@IdPazienteSacAssociato AS IdPazienteSacAssociato
		--
		-- COMMIT
		--
		COMMIT

	END TRY
	BEGIN CATCH
		--
		-- Rollback delle modifiche
		--
		IF @@TRANCOUNT > 0 
			ROLLBACK
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BevsImportReferto. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)

	END CATCH

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertoImport] TO [ExecuteFrontEnd]
    AS [dbo];

