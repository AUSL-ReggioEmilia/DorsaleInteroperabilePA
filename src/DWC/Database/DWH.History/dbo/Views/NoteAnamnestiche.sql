



-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-24
-- Description:	Vista nel singolo store delle NoteAnamnestiche
-- =============================================
CREATE VIEW [dbo].[NoteAnamnestiche]
AS
	SELECT Id
		, DataPartizione
		, IdEsterno
		, IdPaziente
		, DataInserimento
		, DataModifica
		, DataModificaEsterno
		, StatoCodice
		, AziendaErogante 
		, SistemaErogante
		, DataNota 
		, DataFineValidita
		, TipoCodice 
		, TipoDescrizione 
		--Il contenuto della nota
		, Contenuto 
		, TipoContenuto
		, ContenutoHtml 
		, ContenutoText 

		--I dati del paziente
		,CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(ID, DataPartizione, 'Cognome')) AS Cognome
		,CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(ID, DataPartizione, 'Nome')) AS Nome
		,CONVERT(VARCHAR(4), dbo.GetNoteAnamnesticheAttributo(ID, DataPartizione, 'Sesso')) AS Sesso
		,CONVERT(VARCHAR(16), dbo.GetNoteAnamnesticheAttributo(ID, DataPartizione, 'CodiceFiscale')) AS CodiceFiscale
		,dbo.GetNoteAnamnesticheAttributoDateTime(ID, DataPartizione, 'DataNascita') AS DataNascita
		,CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(ID, DataPartizione, 'ComuneNascita')) AS ComuneNascita
		,CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(ID, DataPartizione, 'CodiceSanitario')) AS CodiceSanitario

		--Tutti gli attributi
		,dbo.GetNoteAnamnesticheAttributiXml(ID, DataPartizione) AS Attributi

	FROM dbo.NoteAnamnesticheBase