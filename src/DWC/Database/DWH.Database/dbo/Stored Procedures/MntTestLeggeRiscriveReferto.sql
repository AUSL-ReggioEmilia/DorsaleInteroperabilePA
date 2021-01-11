
-- =============================================
-- Author:		SANDRO
-- Create date: 2019-02-19
-- Description:	Test lettura e riscrittura referto
-- =============================================
CREATE PROCEDURE [dbo].[MntTestLeggeRiscriveReferto]
(
@IdReferto UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY
		--
		-- Data del referto per ricalcolare la Partizione
		--
		DECLARE @DataReferto DATETIME = NULL

		SELECT @DataReferto = DataReferto
		FROM [store].[RefertiBase]
		WHERE Id = @IdReferto
	
		DECLARE @tblRefertiBase AS TABLE
			(Id uniqueidentifier, DataPartizione smalldatetime ,IdEsterno varchar(64) ,IdPaziente uniqueidentifier ,DataInserimento datetime ,DataModifica datetime ,AziendaErogante varchar(16)
			 ,SistemaErogante varchar(16) ,RepartoErogante varchar(64) ,DataReferto datetime ,NumeroReferto varchar(16) ,NumeroNosologico varchar(64) ,Cancellato bit ,NumeroPrenotazione varchar(32)
			 ,DataModificaEsterno datetime ,StatoRichiestaCodice tinyint ,RepartoRichiedenteCodice varchar(16) ,RepartoRichiedenteDescr varchar(128) ,IdOrderEntry varchar(64) ,DataEvento datetime
			 ,Firmato bit)
		DECLARE @tblRefertiBaseRiferimenti AS TABLE
			(Id uniqueidentifier, DataPartizione smalldatetime ,IdRefertiBase uniqueidentifier ,IdEsterno varchar(64) ,DataInserimento datetime ,DataModificaEsterno datetime)
		DECLARE @tblRefertiAttributi AS TABLE
			(IdRefertiBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)
		DECLARE @tblPrestazioniBase AS TABLE
			(ID uniqueidentifier, IdRefertiBase uniqueidentifier, IdEsterno varchar(64), DataInserimento datetime, DataModifica datetime, DataErogazione datetime, PrestazioneCodice varchar(12), PrestazioneDescrizione varchar(150)
			, SoundexPrestazione varchar(4), SezioneCodice varchar(12), SezioneDescrizione varchar(255), SoundexSezione varchar(4), DataPartizione smalldatetime)
		DECLARE @tblPrestazioniAttributi AS TABLE
			(IdPrestazioniBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)
		DECLARE @tblAllegatiBase AS TABLE
			(ID uniqueidentifier, IdRefertiBase uniqueidentifier, IdEsterno varchar(64), DataInserimento datetime, DataModifica datetime, DataFile datetime
			, MimeType varchar(50), MimeData image, DataPartizione smalldatetime, MimeDataCompresso varbinary(max), MimeStatoCompressione tinyint, MimeDataOriginale varbinary(max))	
		DECLARE @tblAllegatiAttributi AS TABLE
			(IdAllegatiBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)

		--
		-- Cancellazione delle tabelle temporanee
		--
		DELETE FROM @tblRefertiBase
		DELETE FROM @tblRefertiBaseRiferimenti
		DELETE FROM @tblRefertiAttributi
		DELETE FROM @tblPrestazioniBase
		DELETE FROM @tblPrestazioniAttributi
		DELETE FROM @tblAllegatiBase
		DELETE FROM @tblAllegatiAttributi
		--
		-- Calcolo la data di partizione
		-- Il referto è già presente quindi questa operazione va sempre a buon fine
		-- 
		DECLARE @DataPartizione_New AS SMALLDATETIME
		SET @DataPartizione_New = CAST(@DataReferto AS SMALLDATETIME)
		-----------------------------------------------------------------------------------------------------------------------------------
		-- Caricamento delle tabelle temporanee con i dati del referto corrente e impostazione della data partizione corretta 
		-----------------------------------------------------------------------------------------------------------------------------------
		--
		-- @tblRefertiBase
		--
		INSERT INTO @tblRefertiBase(
			Id,DataPartizione,IdEsterno,IdPaziente,DataInserimento,DataModifica,AziendaErogante,SistemaErogante,RepartoErogante
			,DataReferto,NumeroReferto,NumeroNosologico,Cancellato,NumeroPrenotazione,DataModificaEsterno,StatoRichiestaCodice,RepartoRichiedenteCodice
			,RepartoRichiedenteDescr,IdOrderEntry,DataEvento,Firmato)
		SELECT            
			Id,
			@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
			,IdEsterno,IdPaziente,DataInserimento,DataModifica,AziendaErogante,SistemaErogante,RepartoErogante
			,DataReferto,NumeroReferto,NumeroNosologico,Cancellato,NumeroPrenotazione,DataModificaEsterno,StatoRichiestaCodice,RepartoRichiedenteCodice
			,RepartoRichiedenteDescr,IdOrderEntry,DataEvento,Firmato
		FROM store.RefertiBase WHERE Id = @IdReferto
		--
		-- @tblRefertiBaseRiferimenti
		--
		INSERT INTO @tblRefertiBaseRiferimenti
			(Id,DataPartizione,IdRefertiBase,IdEsterno,DataInserimento,DataModificaEsterno)
		SELECT 
			Id
			,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
			,IdRefertiBase,IdEsterno,DataInserimento,DataModificaEsterno
		FROM store.RefertiBaseRiferimenti
		WHERE IdRefertiBase = @IdReferto
		--
		-- @tblRefertiAttributi
		--
		INSERT INTO @tblRefertiAttributi(IdRefertiBase,Nome,Valore,DataPartizione)
		SELECT IdRefertiBase,Nome,Valore
				,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
		FROM store.RefertiAttributi WHERE IdRefertiBase = @IdReferto
		--
		-- @tblPrestazioniBase
		--
		INSERT INTO @tblPrestazioniBase
			(ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataErogazione,PrestazioneCodice,PrestazioneDescrizione
			,SoundexPrestazione,SezioneCodice,SezioneDescrizione,SoundexSezione,DataPartizione)
		SELECT 
			ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataErogazione,PrestazioneCodice,PrestazioneDescrizione
			,SoundexPrestazione,SezioneCodice,SezioneDescrizione,SoundexSezione
			,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
		FROM store.PrestazioniBase WHERE IdRefertiBase = @IdReferto
		--
		-- @tblPrestazioniAttributi
		--
		INSERT INTO @tblPrestazioniAttributi
			(IdPrestazioniBase,Nome,Valore,DataPartizione)
		SELECT 	
			IdPrestazioniBase,Nome,Valore
			,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
		FROM store.PrestazioniAttributi WHERE IdPrestazioniBase IN (
			--Leggo dalla tabella temporanea appena caricata
			SELECT Id FROM @tblPrestazioniBase 
		)
		--
		-- @tblAllegatiBase
		--
		INSERT INTO @tblAllegatiBase
			(ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataFile,MimeType,MimeData,DataPartizione,MimeDataCompresso,MimeStatoCompressione, MimeDataOriginale)
		SELECT            
			ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataFile,MimeType,MimeData
			,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
			,MimeDataCompresso, MimeStatoCompressione, MimeDataOriginale
		FROM store.AllegatiBase WHERE IdRefertiBase = @IdReferto
		--
		-- @tblAllegatiAttributi
		--
		INSERT INTO @tblAllegatiAttributi
			(IdAllegatiBase,Nome,Valore,DataPartizione)
		SELECT 	
			IdAllegatiBase,Nome,Valore
			,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
		FROM store.AllegatiAttributi WHERE IdAllegatiBase IN (
			--Leggo dalla tabella temporanea appena caricata
			SELECT Id FROM @tblAllegatiBase
		)
	-----------------------------------------------------------------------------------------------------------------------------------
	-- Fine caricamento delle tabelle temporanee
	-----------------------------------------------------------------------------------------------------------------------------------

		--
		-- Cancellazione del referto attuale: questo ordine deve essere l'inverso di quello usato nella data access per inserire
		--
		DELETE FROM store.AllegatiAttributi WHERE IdAllegatiBase IN (
			--Leggo dalla tabella temporanea
			SELECT Id FROM @tblAllegatiBase 
		)					
		DELETE FROM store.AllegatiBase WHERE IdRefertiBase = @IdReferto					
		DELETE FROM store.PrestazioniAttributi WHERE IdPrestazioniBase IN (
			--Leggo dalla tabella temporanea
			SELECT Id FROM @tblPrestazioniBase
		)
		DELETE FROM store.PrestazioniBase WHERE IdRefertiBase = @IdReferto					
		DELETE FROM store.RefertiAttributi WHERE IdRefertiBase = @IdReferto					
		DELETE FROM store.RefertiBaseRiferimenti WHERE IdRefertiBase = @IdReferto
		DELETE FROM store.RefertiBase WHERE Id = @IdReferto
		--
		-- Inserimento dei dati del referto con data di partizione corretta (SQL trova da solo in quale store inserire i dati)
		--
		--
		-- RefertiBase
		--
		INSERT INTO store.RefertiBase(
			Id,DataPartizione,IdEsterno,IdPaziente,DataInserimento,DataModifica,AziendaErogante,SistemaErogante,RepartoErogante
			,DataReferto,NumeroReferto,NumeroNosologico,Cancellato,NumeroPrenotazione,DataModificaEsterno,StatoRichiestaCodice,RepartoRichiedenteCodice
			,RepartoRichiedenteDescr,IdOrderEntry,DataEvento,Firmato)
		SELECT            
			Id,DataPartizione,IdEsterno,IdPaziente,DataInserimento,DataModifica,AziendaErogante,SistemaErogante,RepartoErogante
			,DataReferto,NumeroReferto,NumeroNosologico,Cancellato,NumeroPrenotazione,DataModificaEsterno,StatoRichiestaCodice,RepartoRichiedenteCodice
			,RepartoRichiedenteDescr,IdOrderEntry,DataEvento,Firmato
		FROM @tblRefertiBase 
		--
		-- RefertiBaseRiferimenti
		--
		INSERT INTO store.RefertiBaseRiferimenti
			(Id,DataPartizione,IdRefertiBase,IdEsterno,DataInserimento,DataModificaEsterno)
		SELECT 
			Id,DataPartizione,IdRefertiBase,IdEsterno,DataInserimento,DataModificaEsterno
		FROM @tblRefertiBaseRiferimenti
		--
		-- RefertiAttributi
		--
		INSERT INTO store.RefertiAttributi(IdRefertiBase,Nome,Valore,DataPartizione)
		SELECT IdRefertiBase,Nome,Valore,DataPartizione 
		FROM @tblRefertiAttributi
		--
		-- PrestazioniBase
		--
		INSERT INTO store.PrestazioniBase
			(ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataErogazione,PrestazioneCodice,PrestazioneDescrizione
			,SoundexPrestazione,SezioneCodice,SezioneDescrizione,SoundexSezione,DataPartizione)
		SELECT 
			ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataErogazione,PrestazioneCodice,PrestazioneDescrizione
			,SoundexPrestazione,SezioneCodice,SezioneDescrizione,SoundexSezione,DataPartizione 
		FROM @tblPrestazioniBase 
		--
		-- PrestazioniAttributi
		--
		INSERT INTO store.PrestazioniAttributi
			(IdPrestazioniBase,Nome,Valore,DataPartizione)
		SELECT 	
			IdPrestazioniBase,Nome,Valore,DataPartizione
		FROM @tblPrestazioniAttributi
		--
		-- AllegatiBase
		--
		INSERT INTO store.AllegatiBase
			(ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataFile,MimeType,MimeData,DataPartizione,MimeDataCompresso,MimeStatoCompressione, MimeDataOriginale)
		SELECT            
			ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataFile,MimeType,MimeData,DataPartizione,MimeDataCompresso,MimeStatoCompressione, MimeDataOriginale
		FROM @tblAllegatiBase
		--
		-- AllegatiAttributi
		--
		INSERT INTO store.AllegatiAttributi
			(IdAllegatiBase,Nome,Valore,DataPartizione)
		SELECT 	
			IdAllegatiBase,Nome,Valore,DataPartizione
		FROM @tblAllegatiAttributi					
		--
		-- COMMIT DELLA TRANSAZIONE
		--
		COMMIT
		
		PRINT '---------------------------------------'
		PRINT 'Letura e riscrittura referto completata'				
		PRINT '---------------------------------------'
		
		SELECT [dbo].[GetRefertoXml2](@IdReferto)

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION
				
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'Errore: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		PRINT '---------------------------'
		PRINT @report;						
		PRINT '---------------------------'
	END CATCH
END