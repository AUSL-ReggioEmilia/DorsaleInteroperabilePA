

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Modify date: 2016-10-10 XML ritornato come NVARCHAR(MAX) (no query discribuite)
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[DatiAccessori]
AS
SELECT [Codice]
      ,[Descrizione]
      ,[Etichetta]
      ,[NomeDatoAggiuntivo]
      ,[Tipo]
      ,[Obbligatorio]
      ,[Ripetibile]
      ,[Valori]
      ,[Ordinamento]
      ,[Gruppo]
      ,[ValidazioneRegex]
      ,[ValidazioneMessaggio]
      ,ISNULL([Sistema], 0) AS [TipoSistema]
      ,[ValoreDefault]
      
      ,CONVERT(NVARCHAR(MAX), (SELECT IdSistemaErogante, SistemaErogante, Attivo, TipoSistema, ValoreDefault
						FROM [DataConfig].[DatiAccessoriSistema] AS Sistema
						WHERE [CodiceDatoAccessorio] = [Codice]
						FOR XML AUTO, ROOT('Sistemi')
						)) AS UsatoSistemi
 
      ,CONVERT(NVARCHAR(MAX), (SELECT PrestazioneCodice, IdSistemaErogante, SistemaErogante
								, PrestazioneCodiceSinonimo, PrestazioneDescrizione
								, PrestazioneTipo, Attivo, TipoSistema, ValoreDefault
						FROM [DataConfig].[DatiAccessoriPrestazioni] AS Prestazione
						WHERE [CodiceDatoAccessorio] = [Codice]
						FOR XML AUTO, ROOT('Prestazioni')
						)) AS UsatoPrestazioni
    
      ,[DataInserimento]
      ,[DataModifica]
      ,[UtenteInserimento]
      ,[UtenteModifica]
  FROM [dbo].[DatiAccessori] WITH(NOLOCK)

