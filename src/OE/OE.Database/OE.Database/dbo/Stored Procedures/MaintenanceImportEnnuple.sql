
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-24
-- Modify date: 2014-03-27 Aggiunto campo Preferiti a GruppiPrestazioni
--						   Aggiunto campo CancellazionePostInoltro a Sistema
-- Modify date: 2014-10-15 Sandro Aggiorna Sistemi sul SAC
-- Modify date: 2014-10-15 Sandro Aggiorna UnitaOperativie sul SAC
-- Modify date: 2016-03-24 Importo sistema se non ASMN-OE
-- Description:	Importa le configurazioni delle ennuple
--					gruppi di prestazioni, gruppi di utenti
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceImportEnnuple]
	@xmlExport XML
AS
BEGIN
-- Importa [GruppiPrestazioni] per ID
-- Importa [GruppiUtenti] per ID
-- Importa [Sistemi] per Codice + Azienda
-- Importa [UnitaOperative] per Codice + Azienda
-- Importa [Ennuple] per ID (UnitaOperative e Sistemi per Codice + Azienda)

	SET NOCOUNT ON

	DECLARE @h_xmlExport int
	EXEC sp_xml_preparedocument @h_xmlExport OUTPUT, @xmlExport
	
-- Inizio MERGE -----------------------

	-------------------------------------------------------------------
	-- MERGE nuovi GruppiPrestazioni 
	MERGE INTO [dbo].[GruppiPrestazioni] AS Target
	USING (
			SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/Ennuple/Ennupla/GruppiPrestazioni/GruppoPrestazioni', 1)
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

	--------------------------------------------------------------------
	-- Merge nuovi GruppiUtenti 
	MERGE INTO [dbo].[GruppiUtenti] AS Target
	USING (	
			SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/Ennuple/Ennupla/GruppiUtenti/GruppoUtenti', 1)
				WITH ([ID] [uniqueidentifier]
					,[Descrizione] [varchar](128))
			) AS Source
	ON (Target.ID = Source.ID)
	WHEN MATCHED THEN
		UPDATE SET Target.[Descrizione] = Source.[Descrizione]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[Descrizione])
		VALUES ( Source.[ID]
			   ,Source.[Descrizione])
	           
	OUTPUT $action, Inserted.*, Deleted.*; 

	-------------------------------------------------------------------
	-- Merge nuovi SISTEMI RICHIEDENTE
	MERGE INTO [dbo].[Sistemi] AS Target
	USING (	SELECT *
			FROM OPENXML (@h_xmlExport, '/Ennuple/Ennupla/SistemiRichiedenti/SistemaRichiedente', 1)
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
	-- Merge nuovi UNITA OPERATIVE
	MERGE INTO [dbo].[UnitaOperative] AS Target
	USING (	SELECT *
			FROM OPENXML (@h_xmlExport, '/Ennuple/Ennupla/UnitaOperative/UnitaOperativa', 1)
				WITH ([ID] [uniqueidentifier]
					,[Codice] [varchar](16)
					,[Descrizione] [varchar](128)
					,[CodiceAzienda] [varchar](16)
					,[Attivo] [bit])
		) AS Source
	ON (Target.[Codice] = Source.[Codice]
		AND Target.[CodiceAzienda] = Source.[CodiceAzienda])
	WHEN MATCHED THEN
		UPDATE SET Target.[Descrizione] = Source.[Descrizione]
			   ,Target.[Attivo] = Source.[Attivo]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[Codice]
			   ,[Descrizione]
			   ,[CodiceAzienda]
			   ,[Attivo])
		VALUES ( NEWID()
			   ,Source.[Codice]
			   ,Source.[Descrizione]
			   ,Source.[CodiceAzienda]
			   ,Source.[Attivo])
	           
	OUTPUT $action, Inserted.*, Deleted.*; 
	
	-------------------------------------------------------------------
	-- MERGE nuove ENNUPLE
	MERGE INTO [dbo].[Ennuple] AS Target
	USING (	
			SELECT *
				, (SELECT ID FROM [Sistemi] WHERE [Codice] = EN_XML.[SistemaRichiedenteCodice]
												 AND [CodiceAzienda] = EN_XML.[SistemaRichiedenteAzienda]) AS [IDSistemaRichiedente]
												 
				, (SELECT ID FROM [UnitaOperative] WHERE [Codice] = EN_XML.[UnitaOperativaCodice]
												 AND [CodiceAzienda] = EN_XML.[UnitaOperativaAzienda]) AS [IDUnitaOperativa]
			FROM (
					SELECT DISTINCT *
					FROM OPENXML (@h_xmlExport, '/Ennuple/Ennupla', 1)
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
							[CodiceRegime] [varchar](16),
							[CodicePriorita] [varchar](16),
							[Not] [bit],
							[IDStato] [tinyint],
							[SistemaRichiedenteCodice] [varchar](16),
							[SistemaRichiedenteAzienda] [varchar](16),
							[UnitaOperativaCodice] [varchar](16),
							[UnitaOperativaAzienda] [varchar](16)
							)) AS EN_XML
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
    ON OBJECT::[dbo].[MaintenanceImportEnnuple] TO [ExecuteImportExport]
    AS [dbo];

