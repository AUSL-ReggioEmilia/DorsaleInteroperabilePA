





-- =============================================
-- Author:		Ettore
-- Create date: 2015-11-12
-- Modify date: 2016-10-07 Sposta attributi nelle viste sugli store
-- Modify date: 2016-11-17 ETTORE Aggiunto il campo PropostaTerapeutica
-- Modify date: 2018-10-26 ETTORE: gestione della tabella OscuramentiPaziente per oscurare TUTTE le prescrizioni di un determinato paziente
--								Cancellata la parte di filtro che usa la tabella PazientiCancellati
-- Description:	Vista da usare nelle SP delle prescrizioni
-- =============================================
CREATE VIEW [ws3].[Prescrizioni]
AS
	SELECT Id, DataPartizione, IdEsterno, IdPaziente
		, DataInserimento, DataModifica, DataModificaEsterno
		, StatoCodice, TipoPrescrizione, DataPrescrizione, NumeroPrescrizione
		, QuesitoDiagnostico
		, MedicoPrescrittoreCodiceFiscale
		, Cognome
		, Nome
		, Sesso
		, CodiceFiscale
		, DataNascita
		, ComuneNascita
		, CodiceSanitario
		, MedicoPrescrittoreCognome
		, MedicoPrescrittoreNome
		, PrioritaCodice
		, EsenzioneCodici
		, Prestazioni
		, Farmaci
		, PropostaTerapeutica
		, Attributi
	FROM [store].[Prescrizioni]
	--
	-- Elimino i record oscurati per Paziente
	-- 
	WHERE 
		--
		-- Verifico se per tale paziente le prescrizioni sono oscurate
		--
		NOT EXISTS (SELECT * FROM [dbo].[OttieniPazienteOscuramenti](IdPaziente) WHERE OscuraPrescrizioni = 1)