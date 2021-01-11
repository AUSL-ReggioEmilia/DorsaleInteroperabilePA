

-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-02-01
-- Description:	Rimuove un nuovo SistemaErogante in base all'Id.
-- =============================================
CREATE PROCEDURE [dbo].[BevsSistemiErogantiRimuove]
(
 @Id uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

    BEGIN TRANSACTION;

    DELETE FROM [dbo].[SistemiEroganti]
     OUTPUT 
      DELETED.[Id],
      DELETED.[AziendaErogante],
      DELETED.[SistemaErogante],
      DELETED.[Descrizione],
      DELETED.[RuoloVisualizzazione],
      DELETED.[EmailControlloQualitaPassivo],
      DELETED.[TipoReferti],
      DELETED.[TipoRicoveri],
      DELETED.[LoginToSac],
      DELETED.[RuoloManager]
    WHERE [Id] = @Id

    COMMIT TRANSACTION;

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiRimuove] TO [ExecuteFrontEnd]
    AS [dbo];

