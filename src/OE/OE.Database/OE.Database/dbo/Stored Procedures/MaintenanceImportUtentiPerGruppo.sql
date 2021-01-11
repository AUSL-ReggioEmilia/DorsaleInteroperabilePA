-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-24
-- Description:	Importa le configurazioni dei gruppi e degli utenti
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceImportUtentiPerGruppo]
	@xmlExport XML
AS
BEGIN
-- Importa [GruppiUtenti] per ID
-- Importa [Utenti] per Utente
-- Importa [UtentiGruppiUtenti] per Utente + IdGruppo
-- Importa [Ennuple] per ID (Sistemi per Codice + Azienda) non importa se GruppoPrestazioni non esiste

	SET NOCOUNT ON

	DECLARE @h_xmlExport int
	EXEC sp_xml_preparedocument @h_xmlExport OUTPUT, @xmlExport

	-- GruppiUtenti per merge molti-molti
	DECLARE @GruppiUtenti TABLE ([ID] [uniqueidentifier])
	INSERT INTO @GruppiUtenti
		SELECT [ID] AS IDGruppoUtenti
		FROM OPENXML (@h_xmlExport, '/GruppiUtenti/Gruppo', 1)
			WITH ([ID] [uniqueidentifier])

--INIZIO MERGE --------------------------------------------------------

	--------------------------------------------------------------------
	-- Merge nuovi GruppiUtenti 
	MERGE INTO [dbo].[GruppiUtenti] AS Target
	USING (	
			SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/GruppiUtenti/Gruppo', 1)
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

	--------------------------------------------------------------------
	-- Merge nuovi UTENTI 
	MERGE INTO [dbo].[Utenti] AS Target
	USING (	SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/GruppiUtenti/Gruppo/Utenti/Utente', 1)
			WITH ([ID] [uniqueidentifier] ,
					[Utente] [varchar](64),
					[Descrizione] [varchar](128),
					[Attivo] [bit],
					[Delega] [tinyint])
		) AS Source
	ON (Target.Utente = Source.Utente)
	WHEN MATCHED THEN
		UPDATE SET Target.[Descrizione] = Source.[Descrizione]
			   ,Target.[Utente] = Source.[Utente]
			   ,Target.[Attivo] = Source.[Attivo]
			   ,Target.[Delega] = Source.[Delega]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[Utente]
			   ,[Descrizione]
			   ,[Attivo]
			   ,[Delega]
			   )
		VALUES ( NEWID()
			   ,Source.[Utente]
			   ,Source.[Descrizione]
			   ,Source.[Attivo]
			   ,Source.[Delega])
	                   
	OUTPUT $action, Inserted.*, Deleted.*; 

	--------------------------------------------------------------------
	-- Merge nuove relazioni GRUPPO-UTENTI 
	MERGE INTO [dbo].[UtentiGruppiUtenti] AS Target
	USING (	

		SELECT DISTINCT 
				 U_INP.[IDGruppo] AS IDGruppoUtenti
				,Utenti.[ID] AS IDUtente
		FROM OPENXML (@h_xmlExport, '/GruppiUtenti/Gruppo/Utenti/Utente', 1)
			WITH ([IDGruppo] [uniqueidentifier]
				,[Utente] [varchar](64)
			) AS U_INP
			INNER JOIN Utenti ON Utenti.Utente = U_INP.Utente
						
		) AS Source
	ON (Target.[IDGruppoUtenti] = Source.[IDGruppoUtenti]
		AND Target.[IDUtente] = Source.[IDUtente])
	--WHEN MATCHED THEN
	--	UPDATE SET Target.[IDGruppoUtenti] = Source.[IDGruppoUtenti]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[IDGruppoUtenti]
			   ,[IDUtente]
			   )
		VALUES ( NEWID()
			   ,Source.[IDGruppoUtenti]
			   ,Source.[IDUtente]
				)
	WHEN NOT MATCHED BY SOURCE AND Target.[IDGruppoUtenti] IN (SELECT ID FROM @GruppiUtenti) THEN
		DELETE 
	                   
	OUTPUT $action, Inserted.*, Deleted.*; 

	-------------------------------------------------------------------
	-- MERGE nuove ENNUPLE
	MERGE INTO [dbo].[Ennuple] AS Target
	USING (	
				SELECT DISTINCT EN_XML.*
					, (SELECT ID FROM [Sistemi] S WHERE S.[Codice] = EN_XML.[SistemaRichiedenteCodice]
								AND S.[CodiceAzienda] = EN_XML.[SistemaRichiedenteAzienda]) AS IDSistemaRichiedente
					
				FROM OPENXML (@h_xmlExport, '/GruppiUtenti/Gruppo/Ennuple/Ennupla', 1)
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
		
				WHERE (EXISTS (SELECT * FROM [GruppiPrestazioni] WHERE [ID] = EN_XML.[IDGruppoPrestazioni])
					OR EN_XML.[IDGruppoPrestazioni] IS NULL)
										
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

--FINE MERGE --------------------------------------------------------

	IF NOT @h_xmlExport IS NULL
		EXEC sp_xml_removedocument @h_xmlExport

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MaintenanceImportUtentiPerGruppo] TO [ExecuteImportExport]
    AS [dbo];

