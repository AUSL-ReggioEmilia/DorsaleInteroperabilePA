
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-24
-- Modify date: 2014-03-27 Aggiunto campo CodiceSinonimo a Prestazione (manca)
--						   Aggiunto campo CancellazionePostInoltro a Sistema
-- Modify date: 2016-03-24 Rimosso importazione sistema
-- Modify date: 2018-06-15 Aggiunto campo Note, RichiedibileSoloDaProfilo a Prestazione
--						   Aggiunto a ProfiloPrestazioni: campo Note
--
-- Description:	Importa le configurazioni Prestazioni per Sistema
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceImportPrestazioniPerSistema]
@xmlExport XML
AS
BEGIN
-- (rimosso 2016-03-24) Importa [Sistemi] per Codice + Azienda
-- Importa [Prestazioni] per Codice + sistema(Codice + Azienda)
-- Importa [DatiAccessori] per Codice
-- Importa [DatiAccessoriPrestazioni] per CodiceDatoAccessorio + CodicePrestazione + sistema(Codice + Azienda)
-- Importa [DatiAccessoriSistemi] per CodiceDatoAccessorio + sistema(Codice + Azienda)
-- Importa [EnnupleAccessi] per ID (Sistemi per Codice + Azienda) non importa se GruppoUtenti non esiste

	SET NOCOUNT ON

	DECLARE @h_xmlExport int
	EXEC sp_xml_preparedocument @h_xmlExport OUTPUT, @xmlExport

	-- Sistemi eroganti per decodifica
	DECLARE @SistemiImportati TABLE ([ID] [uniqueidentifier] ,[Codice] [varchar](16),[CodiceAzienda] [varchar](16))
	INSERT INTO @SistemiImportati
	SELECT *
	FROM OPENXML (@h_xmlExport, '/Sistemi/Sistema', 1)
		WITH ([ID] [uniqueidentifier]
			,[Codice] [varchar](16)
			,[CodiceAzienda] [varchar](16))

-- INIZIO MERGE -----------------------------------

	-------------------------------------------------------------------
	-- Merge nuovi SISTEMI 
	-- (rimosso 2016-03-24) 


	-------------------------------------------------------------------
	-- Merge nuovi PRESTAZIONI 
	MERGE INTO [dbo].[Prestazioni] AS Target
	USING (	SELECT P_IMP.[ID], P_IMP.[Codice], P_IMP.[Descrizione], P_IMP.[Tipo], P_IMP.[Provenienza]
					, P_IMP.[Attivo], P_IMP.[CodiceSinonimo]
					, S_IMP.[Codice] AS CodiceSistema, S_IMP.[CodiceAzienda], S.[ID] AS [IDSistemaErogante]
					, P_IMP.[Note], P_IMP.[RichiedibileSoloDaProfilo]
		FROM OPENXML (@h_xmlExport, '/Sistemi/Sistema/Prestazioni/Prestazione', 1)
			WITH ([ID] [uniqueidentifier]
				,[Codice] [varchar](16)
				,[Descrizione] [varchar](256)
				,[Tipo] [tinyint]
				,[Provenienza] [tinyint]
				,[IDSistemaErogante] [uniqueidentifier]
				,[Attivo] [bit]
				,[CodiceSinonimo] [varchar](16)
				,[Note] [varchar](1024)
				,[RichiedibileSoloDaProfilo] [Bit]
				) P_IMP
			INNER JOIN @SistemiImportati S_IMP ON P_IMP.[IDSistemaErogante] = S_IMP.[ID]
			INNER JOIN Sistemi S ON S_IMP.[Codice] = S.[Codice]
									AND S_IMP.[CodiceAzienda] = S.[CodiceAzienda]
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
		VALUES ( Source.[ID]
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
	-- MERGE nuove DatiAccessori 
	MERGE INTO [dbo].[DatiAccessori] AS Target
	USING (	
			SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/Sistemi/Sistema/DatiAccessori/DatoAccessorio', 1)
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
	-- MERGE nuove DatiAccessoriPrestazioni 
	MERGE INTO [dbo].[DatiAccessoriPrestazioni] AS Target
	USING (	
				SELECT DISTINCT DAP_IMP.*
					, Prestazioni.ID AS IDPrestazione
				FROM OPENXML (@h_xmlExport, '/Sistemi/Sistema/DatiAccessoriPrestazioni/DatoAccessorioPrestazione', 1)
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
			FROM OPENXML (@h_xmlExport, '/Sistemi/Sistema/DatiAccessoriSistemi/DatoAccessorioSistema', 1)
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
	-- MERGE nuove ENNUPLE ACCESSI
	MERGE INTO [dbo].[EnnupleAccessi] AS Target
	USING (	
	
			SELECT *
				, (SELECT ID FROM [Sistemi] WHERE [Codice] = EN_XML.[SistemaEroganteCodice]
											 AND [CodiceAzienda] = EN_XML.[SistemaEroganteAzienda]) AS [IDSistemaErogante]
			FROM (
				SELECT DISTINCT *
				FROM OPENXML (@h_xmlExport, '/Sistemi/Sistema/EnnupleAccessi/EnnuplaAccesso', 1)
					WITH ([ID] [uniqueidentifier],
						[IDGruppoUtenti] [uniqueidentifier],
						[Descrizione] [varchar](256),
						[R] [bit],
						[I] [bit],
						[S] [bit],
						[Not] [bit],
						[IDStato] [tinyint],
						[SistemaEroganteCodice] [varchar](64),
						[SistemaEroganteAzienda] [varchar](64)
						)) AS EN_XML
			WHERE (EXISTS (SELECT * FROM [GruppiUtenti] WHERE [ID] = EN_XML.[IDGruppoUtenti])
														OR EN_XML.[IDGruppoUtenti] IS NULL)				
		) AS Source
	ON (Target.[ID] = Source.[ID])
	WHEN MATCHED THEN
		UPDATE SET Target.[IDGruppoUtenti] = Source.[IDGruppoUtenti]
			, Target.[IDSistemaErogante]= Source.[IDSistemaErogante]
			, Target.[Descrizione] = Source.[Descrizione]
			, Target.[R] = Source.[R]
			, Target.[I] = Source.[I]
			, Target.[S] = Source.[S]
			, Target.[Not] = Source.[Not]
			, Target.[IDStato] = Source.[IDStato]
			, Target.[DataModifica] = GETDATE()
		
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
				,[IDGruppoUtenti]
				,[IDSistemaErogante]
				,[Descrizione]
				,[R]
				,[I]
				,[S]
				,[Not]
				,[IDStato]
				,[DataInserimento]
				,[DataModifica]
				,[UtenteInserimento]
				,[UtenteModifica])
    	VALUES ( Source.[ID]
			   ,Source.[IDGruppoUtenti]
			   ,Source.[IDSistemaErogante]
			   ,Source.[Descrizione]
			   ,Source.[R]
			   ,Source.[I]
			   ,Source.[S]
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
    ON OBJECT::[dbo].[MaintenanceImportPrestazioniPerSistema] TO [ExecuteImportExport]
    AS [dbo];

