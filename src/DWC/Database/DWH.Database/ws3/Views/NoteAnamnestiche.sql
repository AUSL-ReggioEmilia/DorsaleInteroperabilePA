




-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-24
-- Modify date: 2018-10-26 ETTORE: gestione della tabella OscuramentiPaziente per oscurare TUTTE le note anamnestiche di un determinato paziente
--								Cancellata la parte di filtro che usa la tabella PazientiCancellati
-- Description:	Vista da usare nelle SP per le note anamnestiche
--				Non restituisco le note anamnestiche che non sono più valide
-- =============================================
CREATE VIEW [ws3].[NoteAnamnestiche]
AS

SELECT 
	[Id] 
      ,[DataPartizione]
      ,[IdEsterno]
      ,[IdPaziente]
      ,[DataInserimento]
      ,[DataModifica]
      ,[DataModificaEsterno]
	  ,[AziendaErogante]
      ,[SistemaErogante]
	  ,[StatoCodice]
	  --Uso un FUNCTION per ottenere la descrizione dello stato della nota
	  ,dbo.GetNotaAnamnesticaStatoDesc([StatoCodice], NULL) AS StatoDescrizione
      ,[TipoCodice]
      ,[TipoDescrizione]
      ,[DataNota]
      ,[DataFineValidita]
      ,[Contenuto]			--usato solo nel dettaglio
      ,[TipoContenuto]		--usato solo nel dettaglio
      ,[ContenutoHtml]		--usato solo nel dettaglio
      ,[ContenutoText]
      ,[Cognome]
      ,[Nome]
      ,[Sesso]
      ,[CodiceFiscale]
      ,[DataNascita]
      ,[ComuneNascita]
      ,[CodiceSanitario]
      ,[Attributi]

	FROM [store].[NoteAnamnestiche]
	WHERE 
		--
		-- Non restituisco le note nello stato "CANCELLATO"
		--
		StatoCodice <> 3 
		--
		-- Non restituisco le note anamnestiche che non sono più valide
		--
		AND ISNULL(DataFineValidita, GETDATE()) >= CAST(GETDATE() AS DATE)
		--
		-- Verifico se per tale paziente le note anamestiche sono oscurate
		--
		AND NOT EXISTS (SELECT * FROM [dbo].[OttieniPazienteOscuramenti](IdPaziente) WHERE OscuraNoteAnamnestiche = 1)