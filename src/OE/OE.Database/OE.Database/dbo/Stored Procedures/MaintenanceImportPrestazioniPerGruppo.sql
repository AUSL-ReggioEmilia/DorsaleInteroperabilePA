

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-24
-- Modify date: 2014-03-27 Aggiunto campo CodiceSinonimo a Prestazione (manca)
--						   Aggiunto campo CancellazionePostInoltro a Sistema
-- Modify date: 2014-10-15 Sandro Aggiorna Sistemi sul SAC
-- Modify date: 2016-03-24 Importo sistema se non ASMN-OE
-- Modify date: 2018-06-15 Aggiunto campo Note, RichiedibileSoloDaProfilo a Prestazione
--						   Aggiunto a ProfiloPrestazioni: campo Note
--
-- Description:	Importa le configurazioni Prestazioni per Gruppo
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceImportPrestazioniPerGruppo]
@xmlExport XML
AS
BEGIN
-- Importa [GruppiPrestazioni] per ID
-- Importa [Sistemi] per Codice + Azienda
-- Importa [Prestazioni] per Codice + sistema(Codice + Azienda)
-- Importa [PrestazioniGruppiPrestazioni] per CodicePrestazione + sistema(Codice + Azienda)
-- Importa [DatiAccessori] per Codice
-- Importa [DatiAccessoriPrestazioni] per CodiceDatoAccessorio + CodicePrestazione + sistema(Codice + Azienda)
-- Importa [DatiAccessoriSistemi] per CodiceDatoAccessorio + sistema(Codice + Azienda)
-- Importa [Ennuple] per ID (Sistemi per Codice + Azienda) non importa UnitaOperative o GruppoUtenti non esiste

	SET NOCOUNT ON

	DECLARE @h_xmlExport int
	EXEC sp_xml_preparedocument @h_xmlExport OUTPUT, @xmlExport
	
	-- GruppiPrestazioni per merge molti-molti
	DECLARE @GruppiPrestazioni TABLE ([ID] [uniqueidentifier])
	INSERT INTO @GruppiPrestazioni
		SELECT DISTINCT [ID] AS IDGruppoPrestazioni
		FROM OPENXML (@h_xmlExport, '/GruppiPrestazioni/Gruppo', 1)
			WITH ([ID] [uniqueidentifier])
	
-- Inizio MERGE -----------------------

	-------------------------------------------------------------------
	-- MERGE nuovi GruppiPrestazioni 
	MERGE INTO [dbo].[GruppiPrestazioni] AS Target
	USING (
			SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/GruppiPrestazioni/Gruppo', 1)
				WITH ([ID] [uniqueidentifier]
					,[Descrizione] [varchar](128)
					,[Preferiti] [bit])
			) AS Source
	ON (Target.ID = Source.ID)
	WHEN MATCHED THEN
		UPDATE SET Target.[Descrizione] = Source.[Descrizione]
					,Target.[Preferiti] = Source.[Preferiti]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[Descrizione]
			   ,[Preferiti])
		VALUES ( Source.[ID]
			   ,Source.[Descrizione]
			   ,Source.[Preferiti])
	           
	OUTPUT $action, Inserted.*, Deleted.*; 

	-------------------------------------------------------------------
	-- Merge nuovi SISTEMI
	MERGE INTO [dbo].[Sistemi] AS Target
	USING (	
			SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/GruppiPrestazioni/Gruppo/Sistemi/Sistema', 1)
				WITH ([ID] [uniqueidentifier]
					,[Codice] [varchar](16)
					,[Descrizione] [varchar](128)
					,[Erogante] [bit]
					,[Richiedente] [bit]
					,[CodiceAzienda] [varchar](16)
					,[Attivo] [bit])
			WHERE [ID] <> '00000000-0000-0000-0000-000000000000'
		) AS Source
	ON (Target.[Codice] = Source.[Codice]
		AND Target.[CodiceAzienda] = Source.[CodiceAzienda])
	WHEN MATCHED THEN
		UPDATE SET Target.[Descrizione] = Source.[Descrizione]
			   ,Target.[Erogante] = Source.[Erogante]
			   ,Target.[Richiedente] = Source.[Richiedente]
			   ,Target.[Attivo] = Source.[Attivo]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[Codice]
			   ,[Descrizione]
			   ,[Erogante]
			   ,[Richiedente]
			   ,[CodiceAzienda]
			   ,[Attivo])
		VALUES ( NEWID()
			   ,Source.[Codice]
			   ,Source.[Descrizione]
			   ,Source.[Erogante]
			   ,Source.[Richiedente]
			   ,Source.[CodiceAzienda]
			   ,Source.[Attivo])
	           
	OUTPUT $action, Inserted.*, Deleted.*; 
	
	-------------------------------------------------------------------
	-- Merge nuovi PRESTAZIONI 
	MERGE INTO [dbo].[Prestazioni] AS Target
	USING (
			SELECT P_IMP.[ID], P_IMP.[Codice], P_IMP.[Descrizione], P_IMP.[Tipo], P_IMP.[Provenienza]
						, P_IMP.[Attivo], P_IMP.[CodiceSinonimo]
						, P_IMP.[SistemaEroganteCodice] AS CodiceSistema
						, P_IMP.[SistemaEroganteAzienda] AS CodiceAzienda
						, S.[ID] AS [IDSistemaErogante]
						, P_IMP.[Note]
						, P_IMP.[RichiedibileSoloDaProfilo]
			FROM (
				SELECT DISTINCT *			
				FROM OPENXML (@h_xmlExport, '/GruppiPrestazioni/Gruppo/Prestazioni/Prestazione', 1)
					WITH ([ID] [uniqueidentifier]
						,[Codice] [varchar](16)
						,[Descrizione] [varchar](256)
						,[Tipo] [tinyint]
						,[Provenienza] [tinyint]
						,[Attivo] [bit]
						,[CodiceSinonimo] [varchar](16)
						,[SistemaEroganteCodice] [varchar](64)
						,[SistemaEroganteAzienda] [varchar](64)
						,[Note] [varchar](1024)
						,[RichiedibileSoloDaProfilo] [Bit]
						)) P_IMP
						
				INNER JOIN Sistemi S ON P_IMP.[SistemaEroganteCodice] = S.[Codice]
										AND P_IMP.[SistemaEroganteAzienda] = S.[CodiceAzienda]
		) AS Source
	ON (Target.[Codice] = Source.[Codice]
		AND Target.[IDSistemaErogante] = Source.[IDSistemaErogante])
	WHEN MATCHED THEN
		UPDATE SET Target.[Descrizione] = Source.[Descrizione]
			   ,Target.[Tipo] = Source.[Tipo]
			   ,Target.[Provenienza] = Source.[Provenienza]
			   ,Target.[Attivo] = Source.[Attivo]
			   ,Target.[CodiceSinonimo] = Source.[CodiceSinonimo]
			   ,Target.[DataModifica] = GETDATE()
			   ,Target.[Note] = Source.[Note]
			   ,Target.[RichiedibileSoloDaProfilo] = Source.[RichiedibileSoloDaProfilo]

	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[Codice]
			   ,[Descrizione]
			   ,[Tipo]
			   ,[Provenienza]
			   ,[IDSistemaErogante]
			   ,[Attivo]
			   ,[CodiceSinonimo]
			   ,[DataModifica]
			   ,[IDTicketInserimento]
			   ,[IDTicketModifica]
			   ,[Note]
			   ,[RichiedibileSoloDaProfilo]
			   )
		VALUES ( NEWID()
			   ,Source.[Codice]
			   ,Source.[Descrizione]
			   ,Source.[Tipo]
			   ,Source.[Provenienza]
			   ,Source.[IDSistemaErogante]
			   ,Source.[Attivo]
			   ,Source.[CodiceSinonimo]
   			   ,GETDATE()
   			   ,'00000000-0000-0000-0000-000000000000'
   			   ,'00000000-0000-0000-0000-000000000000'
	           ,Source.[Note]
			   ,Source.[RichiedibileSoloDaProfilo])

	OUTPUT $action, Inserted.*, Deleted.*; 

	-------------------------------------------------------------------
	-- Merge nuove relazioni GRUPPO-PRESTAZIONI 
	MERGE INTO [dbo].[PrestazioniGruppiPrestazioni] AS Target
	USING (	
				SELECT DISTINCT 
						 P_IMP.[IDGruppo] AS IDGruppoPrestazioni
						,Prestazioni.[ID] AS IDPrestazione
				FROM OPENXML (@h_xmlExport, '/GruppiPrestazioni/Gruppo/Prestazioni/Prestazione', 1)
					WITH ([IDGruppo] [uniqueidentifier]
						,[Codice] [varchar](16)
						,[SistemaEroganteCodice] [varchar](64)
						,[SistemaEroganteAzienda] [varchar](64)
					) AS P_IMP
					
					INNER JOIN Sistemi S ON P_IMP.[SistemaEroganteCodice] = S.[Codice]
											AND P_IMP.[SistemaEroganteAzienda] = S.[CodiceAzienda]
					INNER JOIN Prestazioni ON Prestazioni.Codice = P_IMP.Codice
											AND Prestazioni.IDSistemaErogante = S.ID
		) AS Source
	ON (Target.[IDGruppoPrestazioni] = Source.IDGruppoPrestazioni
		AND Target.[IDPrestazione] = Source.IDPrestazione)
	--WHEN MATCHED THEN
	--	UPDATE SET Target.[IDPrestazione] = Source.[IDPrestazione]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[IDGruppoPrestazioni]
			   ,[IDPrestazione]
			   )
		VALUES ( NEWID()
			   ,Source.[IDGruppoPrestazioni]
			   ,Source.[IDPrestazione]
				)
	WHEN NOT MATCHED BY SOURCE AND Target.[IDGruppoPrestazioni] IN (SELECT ID FROM @GruppiPrestazioni) THEN
		DELETE 
	                   
	OUTPUT $action, Inserted.*, Deleted.*; 

	-------------------------------------------------------------------
	-- MERGE nuove DatiAccessori 
	MERGE INTO [dbo].[DatiAccessori] AS Target
	USING (	
			SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/GruppiPrestazioni/Gruppo/DatiAccessori/DatoAccessorio', 1)
				WITH ([Codice] [varchar](64)
					,[Descrizione] [varchar](256)
					,[Etichetta] [varchar](64)
					,[Tipo] [varchar](32)
					,[Obbligatorio] [bit]
					,[Ripetibile] [bit]
					,[Valori] [varchar](max)
					,[Ordinamento] [int]
					,[Gruppo] [varchar](64)
					,[ValidazioneRegex] [varchar](max)
					,[ValidazioneMessaggio] [varchar](max)
					,[Sistema] [bit]
					,[ValoreDefault] [varchar](1024)
					,[NomeDatoAggiuntivo] [varchar](64))
			
		) AS Source
	ON (Target.[Codice] = Source.[Codice])
	WHEN MATCHED THEN
		UPDATE SET Target.[Descrizione] = Source.[Descrizione]
			, Target.[Etichetta] = Source.[Etichetta]
			, Target.[Tipo] = Source.[Tipo]
			, Target.[Obbligatorio] = Source.[Obbligatorio]
			, Target.[Ripetibile] = Source.[Ripetibile]
			, Target.[Valori] = Source.[Valori]
			, Target.[Ordinamento] = Source.[Ordinamento]
			, Target.[Gruppo] = Source.[Gruppo]
			, Target.[ValidazioneRegex] = Source.[ValidazioneRegex]
			, Target.[Sistema] = Source.[Sistema]
			, Target.[ValoreDefault] = Source.[ValoreDefault]
			, Target.[NomeDatoAggiuntivo] = Source.[NomeDatoAggiuntivo]
		
	WHEN NOT MATCHED BY TARGET THEN
	    INSERT ([Codice]
			   ,[Descrizione]
			   ,[Etichetta]
			   ,[Tipo]
			   ,[Obbligatorio]
			   ,[Ripetibile]
			   ,[Valori]
			   ,[Ordinamento]
			   ,[Gruppo]
			   ,[ValidazioneRegex]
			   ,[ValidazioneMessaggio]
			   ,[Sistema]
			   ,[ValoreDefault]
			   ,[NomeDatoAggiuntivo]
			   ,[DataModifica]
			   ,[UtenteInserimento]
			   ,[UtenteModifica]
			   )
    	VALUES ( Source.[Codice]
			   ,Source.[Descrizione]
			   ,Source.[Etichetta]
			   ,Source.[Tipo]
			   ,Source.[Obbligatorio]
			   ,Source.[Ripetibile]
			   ,Source.[Valori]
			   ,Source.[Ordinamento]
			   ,Source.[Gruppo]
			   ,Source.[ValidazioneRegex]
			   ,Source.[ValidazioneMessaggio]
			   ,Source.[Sistema]
			   ,Source.[ValoreDefault]
			   ,Source.[NomeDatoAggiuntivo]		   
			   ,GETDATE()
			   ,SUSER_NAME()
			   ,SUSER_NAME()
			   )
         
	OUTPUT $action, Inserted.*, Deleted.*; 

	-------------------------------------------------------------------
	-- MERGE nuove DatiAccessori PRESTAZIONI
	MERGE INTO [dbo].[DatiAccessoriPrestazioni] AS Target
	USING (	
				SELECT DISTINCT DAP_IMP.*
					, Prestazioni.ID AS IDPrestazione
				FROM OPENXML (@h_xmlExport, '/GruppiPrestazioni/Gruppo/DatiAccessoriPrestazioni/DatoAccessorioPrestazione', 1)
					WITH ([ID] [uniqueidentifier]
						,[CodiceDatoAccessorio] [varchar](64)
						,[Attivo] [bit]
						,[Sistema] [bit]
						,[ValoreDefault] [varchar](1024)
						,[PrestazioneCodice] [varchar](64)
						,[PrestazioneSistemaEroganteCodice] [varchar](64)
						,[PrestazioneSistemaEroganteAzienda] [varchar](64)
						) DAP_IMP

				INNER JOIN Sistemi S ON DAP_IMP.[PrestazioneSistemaEroganteCodice] = S.[Codice]
										AND DAP_IMP.[PrestazioneSistemaEroganteAzienda] = S.[CodiceAzienda]
				INNER JOIN Prestazioni ON Prestazioni.Codice = DAP_IMP.[PrestazioneCodice]
										AND Prestazioni.IDSistemaErogante = S.ID
		) AS Source
	ON (Target.[CodiceDatoAccessorio] = Source.[CodiceDatoAccessorio]
		AND Target.[IDPrestazione] = Source.[IDPrestazione])
	WHEN MATCHED THEN
		UPDATE SET Target.[Attivo] = Source.[Attivo]
			, Target.[Sistema] = Source.[Sistema]
			, Target.[ValoreDefault] = Source.[ValoreDefault]
		
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[CodiceDatoAccessorio]
			   ,[IDPrestazione]
			   ,[Attivo]
			   ,[Sistema]
			   ,[ValoreDefault])
    	VALUES ( NEWID()
			   ,Source.[CodiceDatoAccessorio]
			   ,Source.[IDPrestazione]
			   ,Source.[Attivo]
			   ,Source.[Sistema]
			   ,Source.[ValoreDefault])
         
	OUTPUT $action, Inserted.*, Deleted.*; 

	-------------------------------------------------------------------
	-- MERGE nuove DatiAccessori SISTEMA
	MERGE INTO [dbo].[DatiAccessoriSistemi] AS Target
	USING (	
			SELECT DISTINCT DAS_IMP.*
				, S.ID AS [IDSistema]
			FROM OPENXML (@h_xmlExport, '/GruppiPrestazioni/Gruppo/DatiAccessoriSistemi/DatoAccessorioSistema', 1)
				WITH ([ID] [uniqueidentifier]
					,[CodiceDatoAccessorio] [varchar](64)
					,[Attivo] [bit]
					,[Sistema] [bit]
					,[ValoreDefault] [varchar](1024)
					,[SistemaEroganteCodice] [varchar](64)
					,[SistemaEroganteAzienda] [varchar](64)
					) DAS_IMP
			INNER JOIN Sistemi S ON DAS_IMP.[SistemaEroganteCodice] = S.[Codice]
									AND DAS_IMP.[SistemaEroganteAzienda] = S.[CodiceAzienda]
		) AS Source
	ON (Target.[CodiceDatoAccessorio] = Source.[CodiceDatoAccessorio]
		AND Target.[IDSistema] = Source.[IDSistema])
	WHEN MATCHED THEN
		UPDATE SET Target.[Attivo] = Source.[Attivo]
			, Target.[Sistema] = Source.[Sistema]
			, Target.[ValoreDefault] = Source.[ValoreDefault]
		
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[CodiceDatoAccessorio]
			   ,[IDSistema]
			   ,[Attivo]
			   ,[Sistema]
			   ,[ValoreDefault])
    	VALUES ( NEWID()
			   ,Source.[CodiceDatoAccessorio]
			   ,Source.[IDSistema]
			   ,Source.[Attivo]
			   ,Source.[Sistema]
			   ,Source.[ValoreDefault])
         
	OUTPUT $action, Inserted.*, Deleted.*; 

	-------------------------------------------------------------------
	-- MERGE nuove ENNUPLE
	MERGE INTO [dbo].[Ennuple] AS Target
	USING (	
				SELECT DISTINCT EN_XML.*
					, (SELECT ID FROM [Sistemi] S WHERE S.[Codice] = EN_XML.[SistemaRichiedenteCodice]
								AND S.[CodiceAzienda] = EN_XML.[SistemaRichiedenteAzienda]) AS IDSistemaRichiedente
					
				FROM OPENXML (@h_xmlExport, '/GruppiPrestazioni/Gruppo/Ennuple/Ennupla', 1)
					WITH ([ID] [uniqueidentifier],
						[IDGruppoUtenti] [uniqueidentifier],
						[IDGruppoPrestazioni] [uniqueidentifier],
						[Descrizione] [varchar](256),
						[OrarioInizio] [time](0),
						[OrarioFine] [time](0),
						[Lunedi] [bit],
						[Martedi] [bit],
						[Mercoledi] [bit],
						[Giovedi] [bit],
						[Venerdi] [bit],
						[Sabato] [bit],
						[Domenica] [bit],
						[IDUnitaOperativa] [uniqueidentifier],
						[CodiceRegime] [varchar](16),
						[CodicePriorita] [varchar](16),
						[Not] [bit],
						[IDStato] [tinyint],
						[SistemaRichiedenteCodice] [varchar](16),
						[SistemaRichiedenteAzienda] [varchar](16)
						) AS EN_XML
		
				WHERE (EXISTS (SELECT * FROM [GruppiUtenti] WHERE [ID] = EN_XML.[IDGruppoUtenti])	
							OR EN_XML.[IDGruppoUtenti] IS NULL)					
					AND (EXISTS (SELECT * FROM [UnitaOperative] WHERE [ID] = EN_XML.[IDUnitaOperativa])
						OR EN_XML.[IDUnitaOperativa] IS NULL)					
		) AS Source
	ON (Target.[ID] = Source.[ID])
	WHEN MATCHED THEN
		UPDATE SET Target.[IDGruppoUtenti] = Source.[IDGruppoUtenti]
			, Target.[IDGruppoPrestazioni]= Source.[IDGruppoPrestazioni]
			, Target.[Descrizione] = Source.[Descrizione]
			, Target.[OrarioInizio] = Source.[OrarioInizio]
			, Target.[OrarioFine] = Source.[OrarioFine]
			, Target.[Lunedi] = Source.[Lunedi]
			, Target.[Martedi] = Source.[Martedi]
			, Target.[Mercoledi] = Source.[Mercoledi]
			, Target.[Giovedi] = Source.[Giovedi]
			, Target.[Venerdi] = Source.[Venerdi]
			, Target.[Sabato] = Source.[Sabato]
			, Target.[Domenica] = Source.[Domenica]
			, Target.[IDUnitaOperativa] = Source.[IDUnitaOperativa]
			, Target.[IDSistemaRichiedente] = Source.[IDSistemaRichiedente]
			, Target.[CodiceRegime] = Source.[CodiceRegime]
			, Target.[CodicePriorita] = Source.[CodicePriorita]
			, Target.[Not] = Source.[Not]
			, Target.[IDStato] = Source.[IDStato]
			, Target.[DataModifica] = GETDATE()
		
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
				,[IDGruppoUtenti]
				,[IDGruppoPrestazioni]
				,[Descrizione]
				,[OrarioInizio]
				,[OrarioFine]
				,[Lunedi]
				,[Martedi]
				,[Mercoledi]
				,[Giovedi]
				,[Venerdi]
				,[Sabato]
				,[Domenica]
				,[IDUnitaOperativa]
				,[IDSistemaRichiedente]
				,[CodiceRegime]
				,[CodicePriorita]
				,[Not]
				,[IDStato]
				,[DataInserimento]
				,[DataModifica]
				,[UtenteInserimento]
				,[UtenteModifica])
    	VALUES ( Source.[ID]
			   ,Source.[IDGruppoUtenti]
			   ,Source.[IDGruppoPrestazioni]
			   ,Source.[Descrizione]
			   ,Source.[OrarioInizio]
			   ,Source.[OrarioFine]
			   ,Source.[Lunedi]
			   ,Source.[Martedi]
			   ,Source.[Mercoledi]
			   ,Source.[Giovedi]
			   ,Source.[Venerdi]
			   ,Source.[Sabato]
			   ,Source.[Domenica]
			   ,Source.[IDUnitaOperativa]
			   ,Source.[IDSistemaRichiedente]
			   ,Source.[CodiceRegime]
			   ,Source.[CodicePriorita]
			   ,Source.[Not]
			   ,Source.[IDStato]
			   ,GETDATE()
			   ,GETDATE()
			   ,'Sistema'
			   ,'Sistema')
         
	OUTPUT $action, Inserted.*, Deleted.*; 


--Fine MERGE --------------------------------------------

	IF NOT @h_xmlExport IS NULL
		EXEC sp_xml_removedocument @h_xmlExport

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MaintenanceImportPrestazioniPerGruppo] TO [ExecuteImportExport]
    AS [dbo];

