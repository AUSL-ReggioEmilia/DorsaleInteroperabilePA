






-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-11-23
-- Description:	Ottiene una nota anamnestica in base all'id.
-- Modify date: 2017-12-27 ETTORE: Aggiunto la descrizione dello stato della nota anamnestica(StatoDescrizione)
-- Modify date:	2018-06-15 - ETTORE: Gestione della DataFineValidita
-- =============================================
CREATE PROCEDURE [dbo].[BevsNotaAnamnesticaOttieni]
(
	@IdNotaAnamnestica uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT [Id]
      ,[DataPartizione]
      ,[IdEsterno]
      ,[IdPaziente]
      ,[DataInserimento]
      ,[DataModifica]
      ,[DataModificaEsterno]
      ,[StatoCodice]
	  ,dbo.GetNotaAnamnesticaStatoDesc(StatoCodice, NULL) AS StatoDescrizione
      ,[AziendaErogante]
      ,[SistemaErogante]
      ,[DataNota]
	  ,[DataFineValidita]
      ,[TipoCodice]
      ,[TipoDescrizione]
      ,[Contenuto]
      ,[TipoContenuto]
      ,[ContenutoHtml]
      ,[ContenutoText]
      ,[Cognome]
      ,[Nome]
      ,[Sesso]
      ,[CodiceFiscale]
      ,[DataNascita]
      ,[ComuneNascita]
      ,[CodiceSanitario]
      ,[Attributi]
  FROM 
	[store].[NoteAnamnestiche]
  WHERE 
	[Id] = @IdNotaAnamnestica



END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsNotaAnamnesticaOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

