

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-24
-- Modify date: 2014-03-27 Aggiunto campo CodiceSinonimo a Prestazione (manca)
--						   Aggiunto campo CancellazionePostInoltro a Sistema
-- Modify date: 2016-03-24 Rimossa importazione sistema
-- Modify date: 2018-06-15 Aggiunto campo Note, RichiedibileSoloDaProfilo a Prestazione
--						   Aggiunto a ProfiloPrestazioni: campo Note
--
-- Description:	Importa le configurazioni Prestazioni per Profilo
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceImportPrestazioniPerProfilo]
@xmlExport XML
AS
BEGIN
-- Importa [GruppiPrestazioni] per ID
-- (rimosso 2016-03-24) Importa [Sistemi] per Codice + Azienda 
-- Importa [Prestazioni] per Codice + sistema(Codice + Azienda)
-- Importa [PrestazioniProfili] 
-- Importa [DatiAccessori] per Codice
-- Importa [DatiAccessoriPrestazioni] per CodiceDatoAccessorio + CodicePrestazione + sistema(Codice + Azienda)
-- Importa [DatiAccessoriSistemi] per CodiceDatoAccessorio + sistema(Codice + Azienda)

	SET NOCOUNT ON

DECLARE @ImportaDatiAccessori BIT = 0


	DECLARE @h_xmlExport int
	EXEC sp_xml_preparedocument @h_xmlExport OUTPUT, @xmlExport
	
	-- GruppiPrestazioni per merge molti-molti
	DECLARE @ProfiliPrestazioni TABLE ([ID] [uniqueidentifier])

-- Inizio MERGE -----------------------

	-------------------------------------------------------------------
	-- MERGE nuovi ProfiloPrestazioni 
	PRINT 'MERGE nuovi ProfiloPrestazioni'
	 
	MERGE INTO [dbo].[Prestazioni] AS Target
	USING (
			SELECT DISTINCT *
			FROM OPENXML (@h_xmlExport, '/ProfiliPrestazioni/ProfiloPrestazioni', 1)
				WITH ([ID] [uniqueidentifier]
					,[IDSistemaErogante] [uniqueidentifier]
					,[Codice] [varchar](16)
					,[Descrizione] [varchar](256)
					,[Tipo] [tinyint]
					,[Provenienza] [tinyint]
					,[Attivo] [bit])
					
			) AS Source
	ON (Target.[Codice] = Source.[Codice]
		AND Target.[IDSistemaErogante] = Source.[IDSistemaErogante])
	WHEN MATCHED THEN
		UPDATE SET Target.[Descrizione] = Source.[Descrizione]
			   ,Target.[Tipo] = Source.[Tipo]
			   ,Target.[Provenienza] = Source.[Provenienza]
			   ,Target.[Attivo] = Source.[Attivo]
			   ,Target.[DataModifica] = GETDATE()
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[Codice]
			   ,[Descrizione]
			   ,[Tipo]
			   ,[Provenienza]
			   ,[IDSistemaErogante]
			   ,[Attivo]
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
   			   ,GETDATE()
   			   ,'00000000-0000-0000-0000-000000000000'
   			   ,'00000000-0000-0000-0000-000000000000')
	           
	OUTPUT $action, Inserted.*, Deleted.*; 

	-- Rileggo ID per ProfiliPrestazioni per merge molti-molti
	INSERT INTO @ProfiliPrestazioni
	SELECT DISTINCT P.[ID] AS IDProfiloPrestazioni
	FROM OPENXML (@h_xmlExport, '/ProfiliPrestazioni/ProfiloPrestazioni', 1)
		WITH ([Codice] [varchar](16)
			, [IDSistemaErogante] [uniqueidentifier]) P_XML
		INNER JOIN [dbo].[Prestazioni] P ON P.[Codice] = P_XML.[Codice]
										AND P.[IDSistemaErogante] = P_XML.[IDSistemaErogante]

	-------------------------------------------------------------------
	-- Merge nuovi SISTEMI 
	--PRINT 'MERGE nuovi SISTEMI'
	--(rimosso 2016-03-24) 


	-------------------------------------------------------------------
	-- Merge nuove PRESTAZIONI 
	PRINT 'MERGE nuove PRESTAZIONI'
	
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
				FROM OPENXML (@h_xmlExport, '/ProfiliPrestazioni/ProfiloPrestazioni/Prestazioni/Prestazione', 1)
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
					
				INNER JOIN [dbo].[Sistemi] S ON P_IMP.[SistemaEroganteCodice] = S.[Codice]
										AND P_IMP.[SistemaEroganteAzienda] = S.[CodiceAzienda]
			WHERE (S.[ID] = '00000000-0000-0000-0000-000000000000'
					AND P_IMP.[Codice] LIKE 'ADM%')
				OR (S.[ID] <> '00000000-0000-0000-0000-000000000000'
					AND P_IMP.[Tipo] = 0)
									
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
	-- Merge nuove relazioni PROFILO-PRESTAZIONI 
	PRINT 'MERGE nuovi PROFILO-PRESTAZIONI'

	MERGE INTO [dbo].[PrestazioniProfili] AS Target
	USING (	
				SELECT DISTINCT 
						 Profilo.[ID] AS IDProfiloPrestazioni
						,Prestazioni.[ID] AS IDPrestazione
				FROM OPENXML (@h_xmlExport, '/ProfiliPrestazioni/ProfiloPrestazioni/Prestazioni/Prestazione', 1)
					WITH ([CodiceProfiloPrestazioni] [varchar](16)
						,[IDSistemaProfiloPrestazioni] [uniqueidentifier]
						,[Codice] [varchar](16)
						,[SistemaEroganteCodice] [varchar](64)
						,[SistemaEroganteAzienda] [varchar](64)
					) AS P_IMP
					
					INNER JOIN dbo.Sistemi S ON P_IMP.[SistemaEroganteCodice] = S.[Codice]
											AND P_IMP.[SistemaEroganteAzienda] = S.[CodiceAzienda]
					INNER JOIN dbo.Prestazioni ON Prestazioni.Codice = P_IMP.[Codice]
											AND Prestazioni.IDSistemaErogante = S.[ID]
					INNER JOIN dbo.Prestazioni Profilo ON Profilo.Codice = P_IMP.[CodiceProfiloPrestazioni]
											AND Profilo.IDSistemaErogante = P_IMP.[IDSistemaProfiloPrestazioni]
											
		) AS Source
	ON (Target.[IDPadre] = Source.[IDProfiloPrestazioni]
		AND Target.[IDFiglio] = Source.[IDPrestazione])
	--WHEN MATCHED THEN
	--	UPDATE SET Target.[IDFiglio] = Source.[IDPrestazione]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([ID]
			   ,[IDPadre]
			   ,[IDFiglio]
			   )
		VALUES ( NEWID()
			   ,Source.[IDProfiloPrestazioni]
			   ,Source.[IDPrestazione]
				)
	WHEN NOT MATCHED BY SOURCE AND Target.[IDPadre] IN (SELECT ID FROM @ProfiliPrestazioni) THEN
		DELETE 
	                   
	OUTPUT $action, Inserted.*, Deleted.*; 

	-----------------------------------------------------------------
	-- FLAG abilitazione import  DatiAccessori
	IF @ImportaDatiAccessori = 1
	BEGIN
		-----------------------------------------------------------------
		-- MERGE nuove DatiAccessori 
		
		PRINT 'MERGE nuovi DatiAccessori'

		MERGE INTO [dbo].[DatiAccessori] AS Target
		USING (	
				SELECT DISTINCT *
				FROM OPENXML (@h_xmlExport, '/ProfiliPrestazioni/ProfiloPrestazioni/DatiAccessori/DatoAccessorio', 1)
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
		PRINT 'MERGE nuovi DatiAccessori PRESTAZIONI'

		MERGE INTO [dbo].[DatiAccessoriPrestazioni] AS Target
		USING (	
					SELECT DISTINCT DAP_IMP.*
						, Prestazioni.ID AS IDPrestazione
					FROM OPENXML (@h_xmlExport, '/ProfiliPrestazioni/ProfiloPrestazioni/DatiAccessoriPrestazioni/DatoAccessorioPrestazione', 1)
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
		PRINT 'MERGE nuovi DatiAccessori SISTEMA'
		
		MERGE INTO [dbo].[DatiAccessoriSistemi] AS Target
		USING (	
				SELECT DISTINCT DAS_IMP.*
					, S.ID AS [IDSistema]
				FROM OPENXML (@h_xmlExport, '/ProfiliPrestazioni/ProfiloPrestazioni/DatiAccessoriSistemi/DatoAccessorioSistema', 1)
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
		 
		-----------------------------------------------------------------
	END --@ImportaDatiAccessori = 1
	
--Fine MERGE --------------------------------------------

	IF NOT @h_xmlExport IS NULL
		EXEC sp_xml_removedocument @h_xmlExport
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MaintenanceImportPrestazioniPerProfilo] TO [ExecuteImportExport]
    AS [dbo];

