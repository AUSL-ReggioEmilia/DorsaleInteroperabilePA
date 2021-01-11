



-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-02-01
-- Description:	Ottiene un SistemaErogante in base all'Id.
-- Modify date:	2018-02-06 - SimoneB: Restituisco anche il campo [GeneraAnteprimaReferto]
-- Modify date:	2018-06-27 - ETTORE: Gestione del nuovo campo [TipoNoteAnamnestiche]
-- =============================================
CREATE PROCEDURE [dbo].[BevsSistemiErogantiOttieni]
(
 @Id uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      [Id],
      [AziendaErogante],
      [SistemaErogante],
      [Descrizione],
      [RuoloVisualizzazione],
      [EmailControlloQualitaPassivo],
      [TipoReferti],
      [TipoRicoveri],
	  [TipoNoteAnamnestiche],
      [LoginToSac],
      [RuoloManager]
	  ,[GeneraAnteprimaReferto]
  FROM  [dbo].[SistemiEroganti]
  WHERE [Id] = @Id

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

