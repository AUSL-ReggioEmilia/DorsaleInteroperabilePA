


-- =============================================
-- Author:		SANDRO
-- Create date: 2015-05-22
-- Modify date: 2016-06-07 - SANDRO: Rimosso filtro E.StatoCodice = 0
-- Modify date: 2018-10-26 - ETTORE: Cancellato filtro basato su PazientiCancellati
--									 Aggiunto filtro basato sugli oscuramenti per paziente per le prescrizioni
-- Description:	Nuova vista ad uso esclusivo accesso ESTERNO
-- =============================================
CREATE VIEW [DataAccess].[Prescrizioni]
AS
	SELECT Id, DataPartizione, IdEsterno, IdPaziente
		, DataInserimento, DataModifica, DataModificaEsterno
		, StatoCodice, TipoPrescrizione, DataPrescrizione, NumeroPrescrizione
		, MedicoPrescrittoreCodiceFiscale, QuesitoDiagnostico
		, Cognome ,Nome ,Sesso ,CodiceFiscale ,DataNascita ,ComuneNascita ,CodiceSanitario
		, Prestazioni, Farmaci, PropostaTerapeutica

		-- Converto in nVARCHAR perche XML non permette le query distribuite
		, CONVERT(NVARCHAR(MAX), Attributi) AS Attributi

		, CASE WHEN I.StatoCodice = 3
				THEN 1 ELSE 0 END AS Annullato
	
		, CASE WHEN EXISTS (
							SELECT * FROM [dbo].[OttieniPazienteOscuramenti](IdPaziente) 
								WHERE OscuraPrescrizioni = 1
								) 
				THEN 1 ELSE 0 END AS OscuratoPaziente

	FROM [store].[Prescrizioni] I WITH(NOLOCK)