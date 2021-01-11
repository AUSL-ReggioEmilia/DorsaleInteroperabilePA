



-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-03-24
-- Description:	Ottiene gli allegati di un referto in base all'id.
-- =============================================
CREATE PROCEDURE [dbo].[BevsAllegatiRefertoOttieni]
(
 @IdReferto UNIQUEIDENTIFIER
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT [ID]
      ,[IdEsterno]
      ,[DataInserimento]
      ,[DataModifica]
      ,[DataFile]
      ,[MimeType]
      ,[NomeFile]
      ,[Descrizione]
      ,[Posizione]
      ,[StatoCodice]
      ,[StatoDescrizione]
	  ,[attributi]
  FROM [store].[Allegati]
  WHERE [IdRefertiBase] = @IdReferto
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsAllegatiRefertoOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

