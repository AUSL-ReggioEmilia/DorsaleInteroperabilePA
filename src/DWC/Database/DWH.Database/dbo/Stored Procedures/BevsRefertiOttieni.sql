




-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-03-24
-- Description:	Ottiene un referto in base all'Id.
-- =============================================
CREATE PROCEDURE [dbo].[BevsRefertiOttieni]
(
 @IdReferto uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT [ID]
      ,[DataPartizione]
      ,[IdEsterno]
      ,[IdPaziente]
      ,[DataInserimento]
      ,[DataModifica]
      ,[AziendaErogante]
      ,[SistemaErogante]
      ,[RepartoErogante]
      ,[DataReferto]
      ,[DataEvento]
      ,[NumeroReferto]
      ,[NumeroNosologico]
      ,[NumeroPrenotazione]
      ,[IdOrderEntry]
      ,[Firmato]
      ,[RepartoRichiedenteCodice]
      ,[RepartoRichiedenteDescr]
      ,[StatoRichiestaCodice]
      ,[StatoRichiestaDescr]
      ,[NomeStile]
      ,[Cognome]
      ,[Nome]
      ,[Sesso]
      ,[CodiceFiscale]
      ,[DataNascita]
      ,[ComuneNascita]
      ,[CodiceSanitario]
      ,[PrioritaCodice]
      ,[PrioritaDescr]
      ,[TipoRichiestaCodice]
      ,[TipoRichiestaDescr]
      ,[Referto]
      ,[MedicoRefertanteCodice]
      ,[MedicoRefertanteDescr]
      ,[SpecialitaErogante]
      ,[StrutturaEroganteCodice]
      ,[Confidenziale]
      ,[Anteprima]
      ,[Attributi]
  FROM  [store].Referti
  WHERE [Id] = @IdReferto

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertiOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

