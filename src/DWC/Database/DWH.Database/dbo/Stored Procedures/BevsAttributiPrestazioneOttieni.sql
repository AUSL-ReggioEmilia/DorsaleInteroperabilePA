
-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-03-24
-- Description:	Ottiene gli attributi di una prestazione in base all'id della prestazione.
-- =============================================
CREATE PROCEDURE [dbo].[BevsAttributiPrestazioneOttieni]
(
 @IdPrestazione UNIQUEIDENTIFIER
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT IdPrestazioniBase,
	Nome,
	Valore,
	DataPartizione
  FROM  [store].[PrestazioniAttributi]
  WHERE [IdPrestazioniBase] = @IdPrestazione
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsAttributiPrestazioneOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

