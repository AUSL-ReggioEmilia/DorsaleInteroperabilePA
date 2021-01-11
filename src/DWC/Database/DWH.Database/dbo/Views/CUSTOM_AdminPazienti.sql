

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2010-05-17
-- Modify date: 2016-05-11 sandro - Usa nuova vista sac.Pazienti
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE VIEW [dbo].[CUSTOM_AdminPazienti]
AS
SELECT pb.[Id]
	  ,pb.[Nome]
	  ,pb.[Cognome]
	  ,pb.[CodiceFiscale]
	  ,pb.[DataNascita]
	  ,pb.[LuogoNascitaDescrizione] AS [LuogoNascita]
	  ,(SELECT COUNT(*) FROM [store].[RefertiBase] rb
			WHERE rb.IdPaziente = pb.Id) AS NumeroReferti
  FROM [sac].[Pazienti] pb
