






-- =============================================
-- Author:		ETTORE
-- Create date: 2018-10-26
-- Description:	Nuova vista ad uso esclusivo accesso ESTERNO
--				Cancellato il filtro basato su PazientiCancellati
--				Usato filtro basato sugli oscuramenti per paziente per le note anamnestiche
-- =============================================
CREATE VIEW [DataAccess].[NoteAnamnestiche]
AS
	SELECT 
		Id, DataPartizione, IdEsterno, IdPaziente	
		, DataInserimento, DataModifica, DataModificaEsterno
		, StatoCodice, dbo.GetNotaAnamnesticaStatoDesc(StatoCodice, NULL) AS StatoDescrizione
		, AziendaErogante, SistemaErogante
		, DataNota, DataFineValidita	
		, TipoCodice, TipoDescrizione	
		, Contenuto, TipoContenuto	
		, ContenutoHtml
		, ContenutoText	
		,Cognome, Nome, Sesso, CodiceFiscale, DataNascita, ComuneNascita, CodiceSanitario	

		-- Converto in nVARCHAR perche XML non permette le query distribuite
		, CONVERT(NVARCHAR(MAX), Attributi) AS Attributi

		, CASE WHEN StatoCodice = 3
				THEN 1 ELSE 0 END AS Annullato
		
		, 0 AS OscuratoMassivo

		, 0 AS OscuratoPuntuale

		, CASE WHEN EXISTS (
						SELECT * FROM [dbo].[OttieniPazienteOscuramenti](IdPaziente) 
							WHERE OscuraNoteAnamnestiche = 1
							) 
			THEN 1 ELSE 0 END AS OscuratoPaziente
	FROM [store].[NoteAnamnestiche] WITH(NOLOCK)