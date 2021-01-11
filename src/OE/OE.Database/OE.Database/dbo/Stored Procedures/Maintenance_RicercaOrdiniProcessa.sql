
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-02-26
--
-- Description:	Processa la cosa coda degli ordini modificati
-- =============================================
CREATE PROCEDURE [dbo].[Maintenance_RicercaOrdiniProcessa]
(
 @NoInformation BIT = 1
,@BatchSize INT = 1000
)
AS
BEGIN
	SET NOCOUNT ON
	--
	-- Legge il primo record dalla coda
	--
	DECLARE @CountTotali INT = 0
	DECLARE @Err as INT

	DECLARE @IdOrdineTestata uniqueidentifier
	DECLARE @DataInserimentoUtc datetime2
	DECLARE @ret int

	DECLARE @tblDatePianificate TABLE (IDOrdineErogatoTestata UNIQUEIDENTIFIER
										,IDRigaErogata UNIQUEIDENTIFIER
										,DataPianificata DATETIME2
										)

	DECLARE @tblOrdine TABLE (IdOrdineTestata UNIQUEIDENTIFIER,
										 IdOrdineTestataErogata UNIQUEIDENTIFIER,
										 DataModifica DATETIME2(7),
										 IdSistemaErogante UNIQUEIDENTIFIER,
										 SistemaEroganteDescrizione VARCHAR(32),
										 IdSistemaRichiedente UNIQUEIDENTIFIER,
										 SistemaRichiedenteDescrizione VARCHAR(32),
										 IdUnitaOperativa UNIQUEIDENTIFIER,
										 UnitaOperativaDescrizione VARCHAR(32),
										 OrderEntryStato VARCHAR(16),
										 OrderEntryStatoDescrizione VARCHAR(64),
										 DataModificaStato DATETIME2(7),
										 DataPrenotazioneRichiesta DATETIME2(7),
										 DataPrenotazioneErogante DATETIME2(7),
										 DataPianificazioneErogante DATETIME2(7)
										 )

	DECLARE @CountInserted INT = 0
	DECLARE @CountUpdated INT = 0

	--
	-- Legge il primo disponibile
	--
	EXEC @ret = [dbo].[RicercaOrdiniCodaOttieni] @IdOrdineTestata = @IdOrdineTestata OUTPUT
											, @DataInserimentoUtc = @DataInserimentoUtc OUTPUT
	SELECT @Err = @@ERROR

	WHILE @ret = 0 AND @Err = 0
	BEGIN
		--
		-- Log ordine corrente
		--
		IF @NoInformation = 0
		BEGIN
			PRINT ''
			PRINT CONVERT(VARCHAR(20), GETDATE(), 120)
					+ ': Ordine Id = '	+ CONVERT(VARCHAR(40), @IdOrdineTestata)
					+ ' DataModifica = ' + CONVERT(VARCHAR(20), @DataInserimentoUtc, 120)
		END
		--
		-- Processa i dati dell'ordine
		--
		BEGIN TRY
			--
			-- Reset var
			--
			SET @Err = 0
			--
			-- Leggo i dati dell'ORDINE
			--
			DELETE FROM @tblOrdine

			INSERT INTO @tblOrdine (IdOrdineTestata, IdOrdineTestataErogata, DataModifica,
									IdSistemaErogante, SistemaEroganteDescrizione,
									IdSistemaRichiedente, SistemaRichiedenteDescrizione,
									IdUnitaOperativa, UnitaOperativaDescrizione,
									OrderEntryStato, OrderEntryStatoDescrizione, DataModificaStato,
									DataPrenotazioneRichiesta, DataPrenotazioneErogante, DataPianificazioneErogante)

			SELECT   ot.ID AS [IdOrdineTestata]
					,ISNULL(oet.ID, '00000000-0000-0000-0000-000000000000') AS [IdOrdineTestataErogata]
					,COALESCE(ot.DataModifica, oet.DataModifica) AS [DataModifica]

					,oet.IDSistemaErogante
					,se.Codice + '@' + se.CodiceAzienda AS [SistemaEroganteDescrizione]

					,ot.IDSistemaRichiedente
					,sr.Codice + '@' + sr.CodiceAzienda AS [SistemaRichiedenteDescrizione]

					,ot.IDUnitaOperativaRichiedente
					,uor.Codice + '@' + uor.CodiceAzienda AS [UnitaOperativaDescrizione]

					,CASE WHEN ot.StatoOrderEntry IN ('CA', 'HD') THEN ot.StatoOrderEntry
							ELSE COALESCE(oet.StatoOrderEntry, oet.StatoRisposta, ot.StatoOrderEntry) END AS [OrderEntryStato]
					,[dbo].[GetWsDescrizioneStato2](ot.ID) AS [OrderEntryStatoDescrizione]
					,ot.DataModificaStato AS [DataModificaStato]

					,ot.DataPrenotazione AS [DataPrenotazioneRichiesta]
					,oet.DataPrenotazione AS [DataPrenotazioneErogante]
					,CONVERT(DATETIME2, NULL) AS [DataPianificazioneErogante]

			FROM [dbo].[OrdiniTestate] ot
				INNER JOIN [dbo].[Sistemi] sr
					ON ot.IDSistemaRichiedente = sr.ID

				INNER JOIN [dbo].[UnitaOperative] uor
					ON ot.IDUnitaOperativaRichiedente = uor.ID

				INNER JOIN [dbo].[OrdiniErogatiTestate] oet
					ON oet.IDOrdineTestata = ot.ID

				INNER JOIN [dbo].[Sistemi] se
					ON oet.IDSistemaErogante = se.ID

			WHERE ot.Id = @IdOrdineTestata

			--
			-- Leggo le date pianificate dell'ORDINE
			--
			--IDDatoAggiuntivo	Nome
			--00000001-0000-0000-0000-111111111111	CORE_DataPianificata

			DELETE FROM @tblDatePianificate

			-- Sulla testata dell'erogato
			--
			INSERT INTO @tblDatePianificate (IDOrdineErogatoTestata, IDRigaErogata, DataPianificata)
			SELECT oetda.[IDOrdineErogatoTestata]
				,CONVERT(UNIQUEIDENTIFIER, NULL) AS [IDRigaErogata]
				,CONVERT(DATETIME2, oetda.ValoreDato, 126) [DataPianificata]

			FROM [dbo].[OrdiniErogatiTestateDatiAggiuntivi] oetda
				INNER JOIN [dbo].[OrdiniErogatiTestate] oet
					ON oetda.IDOrdineErogatoTestata = oet.ID

			WHERE IDDatoAggiuntivo = '00000001-0000-0000-0000-111111111111'
				AND TipoDato = 'xs:dateTime'
				AND CONVERT(VARCHAR(32), ValoreDato) LIKE '%T%'
				AND oet.IdOrdineTestata = @IdOrdineTestata

			-- Sulle righe dell'erogato
			--
			INSERT INTO @tblDatePianificate (IDOrdineErogatoTestata, IDRigaErogata, DataPianificata)
			SELECT oet.ID AS [IDOrdineErogatoTestata]
				, ore.ID AS [IDRigaErogata]
				, CONVERT(DATETIME2, oreda.ValoreDato, 126) [DataPianificata]

			FROM [dbo].[OrdiniRigheErogateDatiAggiuntivi] oreda
				INNER JOIN [dbo].[OrdiniRigheErogate] ore
					ON oreda.IDRigaErogata = ore.ID

				INNER JOIN [dbo].[OrdiniErogatiTestate] oet
					ON ore.IDOrdineErogatoTestata = oet.ID

			WHERE oreda.IDDatoAggiuntivo = '00000001-0000-0000-0000-111111111111'
				AND oreda.TipoDato = 'xs:dateTime'
				AND CONVERT(VARCHAR(32), oreda.ValoreDato) LIKE '%T%'
				AND oet.IdOrdineTestata = @IdOrdineTestata

			--
			-- UPDATE ORDINE con DataPianificazione
			--
			UPDATE @tblOrdine
				SET DataPianificazioneErogante = dp.DataPianificazione 
			FROM @tblOrdine o
				INNER JOIN (
							SELECT IDOrdineErogatoTestata, MIN(DataPianificata) DataPianificazione
							FROM @tblDatePianificate
							GROUP BY IDOrdineErogatoTestata
							) dp
				ON o.IdOrdineTestataErogata = dp.IDOrdineErogatoTestata

			--
			-- Log processo
			--

			DECLARE @xmlOrdine XML = CONVERT(XML,(  SELECT *
													FROM @tblOrdine Ordine
													FOR XML AUTO)
													)
			DECLARE @xmlDatePianificate XML = CONVERT(XML,(  SELECT *
															FROM @tblDatePianificate DatePianificate
															FOR XML AUTO)
													)

			INSERT INTO [dbo].[RicercaOrdiniProcessoLog] ([IdOrdineTestata], [XmlOrdine],[XmlDatePianificazione])
			VALUES ( @IdOrdineTestata, @xmlOrdine, @xmlDatePianificate)

			--
			-- Aggiorno dati Ricerca
			--
			SET @CountInserted = 0
			SET @CountUpdated = 0

			-- Modifico gli esistenti
			--
			UPDATE [dbo].[RicercaOrdini]
			   SET [IdSistemaErogante] = o.IdSistemaErogante
				  ,[SistemaEroganteDescrizione] = o.SistemaEroganteDescrizione
				  ,[IdSistemaRichiedente] = o.IdSistemaRichiedente
				  ,[SistemaRichiedenteDescrizione] = o.SistemaRichiedenteDescrizione
				  ,[IdUnitaOperativa] = o.IdUnitaOperativa
				  ,[UnitaOperativaDescrizione] = o.UnitaOperativaDescrizione

				  ,[OrderEntryStato] = o.OrderEntryStato
				  ,[OrderEntryStatoDescrizione] = o.OrderEntryStatoDescrizione
				  ,[DataModificaStato] = o.DataModificaStato

				  ,[DataPrenotazioneRichiesta] = o.DataPrenotazioneRichiesta
				  ,[DataPrenotazioneErogante] = o.DataPrenotazioneErogante
				  ,[DataPianificazioneErogante] = o.DataPianificazioneErogante
				  ,[DataModificaPianificazione] = CASE WHEN fore.[DataPianificazioneErogante] IS NULL AND o.DataPianificazioneErogante IS NULL THEN o.DataModificaStato
													WHEN fore.[DataPianificazioneErogante] = o.DataPianificazioneErogante THEN fore.[DataModificaPianificazione]
													ELSE o.DataModifica END

			FROM [dbo].[RicercaOrdini] fore
				INNER JOIN @tblOrdine o
				ON fore.IdOrdineTestata = o.IdOrdineTestata
					AND fore.IdOrdineTestataErogata = o.IdOrdineTestataErogata

			SET @CountUpdated = @@ROWCOUNT

			-- Inserisco i nuovi
			--
			INSERT INTO [dbo].[RicercaOrdini]
					   ([IdOrdineTestata], [IdOrdineTestataErogata]
					   ,[IdSistemaErogante], [SistemaEroganteDescrizione]
					   ,[IdSistemaRichiedente], [SistemaRichiedenteDescrizione]
					   ,[idUnitaOperativa], [UnitaOperativaDescrizione]
					   ,[OrderEntryStato], [OrderEntryStatoDescrizione], [DataModificaStato]
					   ,[DataPrenotazioneRichiesta], [DataPrenotazioneErogante]
					   ,[DataPianificazioneErogante]
					   ,[DataModificaPianificazione])
			SELECT      o.IdOrdineTestata, o.IdOrdineTestataErogata
					   ,o.IdSistemaErogante, o.SistemaEroganteDescrizione
					   ,o.IdSistemaRichiedente, o.SistemaRichiedenteDescrizione
					   ,o.IdUnitaOperativa, o.UnitaOperativaDescrizione

					   ,o.OrderEntryStato, o.OrderEntryStatoDescrizione
					   ,o.DataModificaStato

					   ,o.DataPrenotazioneRichiesta
					   ,o.DataPrenotazioneErogante
					   ,o.DataPianificazioneErogante
					   ,o.DataModificaStato AS [DataModificaPianificazione] 
			FROM @tblOrdine o
			WHERE NOT EXISTS(
							SELECT * FROM [dbo].[RicercaOrdini] fore
							WHERE fore.IdOrdineTestata = o.IdOrdineTestata
								AND fore.IdOrdineTestataErogata = o.IdOrdineTestataErogata
							)

			SET @CountInserted = @@ROWCOUNT

			IF @NoInformation = 0
			BEGIN
				PRINT ''
				PRINT CONVERT(VARCHAR(20), GETDATE(), 120)
						+ ': Inseriti = '	+ CONVERT(VARCHAR(40), @CountInserted)
						+ ': Aggiornati = '	+ CONVERT(VARCHAR(40), @CountUpdated)
			END

		END TRY  
		BEGIN CATCH 
			--
			-- ERROR: Esce dal loop
			--
			SELECT @Err = @@ERROR
			SET @ret = -1

			PRINT CONVERT(VARCHAR(20), GETDATE(), 120)
				+ ': Errore = '	+ CONVERT(VARCHAR(40), @Err)
		END CATCH

		--
		-- Prossimo record
		--
		SET @CountTotali = @CountTotali + 1
		IF @BatchSize > @CountTotali AND @Err = 0
		BEGIN
			--
			-- Legge dalla coda
			--
			SET @IdOrdineTestata = NULL
			SET @DataInserimentoUtc = NULL

			EXEC @ret = [dbo].[RicercaOrdiniCodaOttieni] @IdOrdineTestata = @IdOrdineTestata OUTPUT
													, @DataInserimentoUtc = @DataInserimentoUtc OUTPUT
			SELECT @Err = @@ERROR

		END ELSE BEGIN
			--
			-- Esce dal loop
			--
			SET @ret = -1
		END
	END

	IF @NoInformation = 0
	BEGIN
		PRINT ''
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120)
				+ ': Processati  = '	+ CONVERT(VARCHAR(10), @CountTotali)
	END
END