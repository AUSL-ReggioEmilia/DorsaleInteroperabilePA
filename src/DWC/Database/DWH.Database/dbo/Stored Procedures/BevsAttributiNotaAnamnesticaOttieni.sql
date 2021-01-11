



-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-11-23
-- Description:	Ottiene gli attributi di una nota anamnestica in base all'id della Nota Anamnestica.
-- =============================================
CREATE PROCEDURE [dbo].[BevsAttributiNotaAnamnesticaOttieni]
(
 @IdNotaAnamnestica UNIQUEIDENTIFIER
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT IdNoteAnamnesticheBase,
	Nome,
	Valore,
	DataPartizione
  FROM  [store].[NoteAnamnesticheAttributi]
  WHERE [IdNoteAnamnesticheBase] = @IdNotaAnamnestica
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsAttributiNotaAnamnesticaOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

