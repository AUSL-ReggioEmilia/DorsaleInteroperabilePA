



-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-03-09
-- Description:	Ottiene un ricovero in base all'Id.
-- =============================================
CREATE PROCEDURE [dbo].[BevsRicoveriOttieni]
(
 @IdRicovero uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT [Id]
      ,[DataPartizione]
      ,[DataInserimento]
      ,[DataModifica]
      ,[StatoCodice]
      ,[NumeroNosologico]
      ,[AziendaErogante]
      ,[SistemaErogante]
      ,[RepartoErogante]
      ,[IdPaziente]
      ,[OspedaleCodice]
      ,[OspedaleDescr]
      ,[TipoRicoveroCodice]
      ,[TipoRicoveroDescr]
      ,[Diagnosi]
      ,[DataAccettazione]
      ,[RepartoAccettazioneCodice]
      ,[RepartoAccettazioneDescr]
      ,[DataTrasferimento]
      ,[RepartoCodice]
      ,[RepartoDescr]
      ,[SettoreCodice]
      ,[SettoreDescr]
      ,[LettoCodice]
      ,[DataDimissione]
      ,[Cognome]
      ,[Nome]
      ,[Sesso]
      ,[CodiceFiscale]
      ,[DataNascita]
      ,[ComuneNascita]
      ,[CodiceSanitario]
      ,[Attributi]
  FROM  [store].[Ricoveri]
  WHERE [Id] = @IdRicovero

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRicoveriOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

