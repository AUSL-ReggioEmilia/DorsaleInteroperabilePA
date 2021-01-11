
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-24
-- Modify date: 2014-03-27 Aggiunto campo CodiceSinonimo a Prestazione (manca)
--						   Aggiunto campo CancellazionePostInoltro a Sistema
-- Modify date: 2014-10-15 Sandro Aggiorna Sistemi sul SAC
-- Modify date: 2016-03-24 Importo sistema se non ASMN-OE
-- Description:	Importa le configurazioni Ennulpe accessi
--					dei gruppi utenti e sistemi
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceImportEnnupleAccessi]
	@xmlExport XML
AS
BEGIN
-- Importa [GruppiUtenti] per ID
-- Importa [Sistemi] per Codice + Azienda
-- Importa [Prestazioni] per Codice + Sistema
-- Importa [EnnupleAccessi] per ID (Sistemi per Codice + Azienda)

	SET NOCOUNT ON

	DECLARE @h_xmlExport int
	EXEC sp_xml_preparedocument @h_xmlExport OUTPUT, @xmlExport

--INIZIO MERGE --------------------------------------------------------

	--------------------------------------------------------------------
	-- Merge nuovi GruppiUtenti 
	MERGE INTO [dbo].[GruppiUtenti] AS Target
	USING (	
			SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/EnnupleAccessi/EnnuplaAccessi/GruppiUtenti/GruppoUtenti', 1)
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
	-- Merge nuovi SISTEMI
	MERGE INTO [dbo].[Sistemi] AS Target
	USING (	
			SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/EnnupleAccessi/EnnuplaAccessi/Sistemi/Sistema', 1)
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
			FROM (
				SELECT DISTINCT *			
				FROM OPENXML (@h_xmlExport, '/EnnupleAccessi/EnnuplaAccessi/Sistemi/Sistema/Prestazioni/Prestazione', 1)
					WITH ([ID] [uniqueidentifier]
						,[Codice] [varchar](16)
						,[Descrizione] [varchar](256)
						,[Tipo] [tinyint]
						,[Provenienza] [tinyint]
						,[Attivo] [bit]
						,[CodiceSinonimo] [varchar](16)
						,[SistemaEroganteCodice] [varchar](64)
						,[SistemaEroganteAzienda] [varchar](64)
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
   			   ,'00000000-0000-0000-0000-000000000000')
	                   
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
				FROM OPENXML (@h_xmlExport, '/EnnupleAccessi/EnnuplaAccessi', 1)
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

--FINE MERGE --------------------------------------------------------

	IF NOT @h_xmlExport IS NULL
		EXEC sp_xml_removedocument @h_xmlExport
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MaintenanceImportEnnupleAccessi] TO [ExecuteImportExport]
    AS [dbo];

