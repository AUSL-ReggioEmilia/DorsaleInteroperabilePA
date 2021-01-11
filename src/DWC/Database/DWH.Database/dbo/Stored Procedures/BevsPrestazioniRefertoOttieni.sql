




-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-03-21
-- Description:	Ottiene una prestazione in base all' id del referto.
-- =============================================
CREATE PROCEDURE [dbo].[BevsPrestazioniRefertoOttieni]
(
 @IdReferto UNIQUEIDENTIFIER
)
AS
BEGIN
  SET NOCOUNT ON

  SELECT [ID]
      ,[DataPartizione]
      ,[IdRefertiBase]
      ,[IdEsterno]
      ,[DataInserimento]
      ,[DataModifica]
      ,[DataErogazione]
      ,[PrestazioneCodice]
      ,[PrestazioneDescrizione]
      ,[SoundexPrestazione]
      ,[SezioneCodice]
      ,[SezioneDescrizione]
      ,[SoundexSezione]
      ,[GravitaCodice]
      ,[GravitaDescrizione]
      ,[Risultato]
      ,[ValoriRiferimento]
      ,[SezionePosizione]
      ,[PrestazionePosizione]
      ,[Commenti]
      ,[Quantita]
      ,[UnitaDiMisura]
      ,[RangeValoreMinimo]
      ,[RangeValoreMassimo]
      ,[RangeValoreMinimoUnitaDiMisura]
      ,[RangeValoreMassimoUnitaDiMisura]
      ,[Attributi]
  FROM  [store].Prestazioni
  WHERE [IdRefertiBase] = @IdReferto
  ORDER BY DataModifica ASC
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsPrestazioniRefertoOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

