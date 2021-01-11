



-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-02-01
-- Description:	Modifica un SistemaErogante.
-- Modify date:	2018-02-06 - Simoneb: Gestito campo [GeneraAnteprimaReferto]
-- Modify date:	2018-06-27 - ETTORE: Gestione del nuovo campo [TipoNoteAnamnestiche]
-- =============================================
CREATE PROCEDURE [dbo].[BevsSistemiErogantiModifica]
(
 @Id uniqueidentifier,
 @RuoloVisualizzazione varchar(128),
 @EmailControlloQualitaPassivo varchar(128),
 @TipoReferti bit,
 @TipoRicoveri bit,
 @LoginToSac varchar(64),
 @RuoloManager varchar(128),
 @GeneraAnteprimaReferto BIT,
 @TipoNoteAnamnestiche bit = NULL
)
AS
BEGIN
  SET NOCOUNT OFF


    BEGIN TRANSACTION;

    UPDATE [dbo].[SistemiEroganti]
     SET
      [RuoloVisualizzazione] = NULLIF(@RuoloVisualizzazione, ''),
      [EmailControlloQualitaPassivo] = NULLIF(@EmailControlloQualitaPassivo, ''),
      [TipoReferti] = @TipoReferti,
      [TipoRicoveri] = @TipoRicoveri,
	  [TipoNoteAnamnestiche] = ISNULL(@TipoNoteAnamnestiche, 0),
      [LoginToSac] = NULLIF(@LoginToSac, ''),
      [RuoloManager] = NULLIF(@RuoloManager, '')
	  ,[GeneraAnteprimaReferto] = @GeneraAnteprimaReferto
     OUTPUT 
      INSERTED.[Id],
      INSERTED.[AziendaErogante],
      INSERTED.[SistemaErogante],
      INSERTED.[Descrizione],
      INSERTED.[RuoloVisualizzazione],
      INSERTED.[EmailControlloQualitaPassivo],
      INSERTED.[TipoReferti],
      INSERTED.[TipoRicoveri],
	  INSERTED.[TipoNoteAnamnestiche],
      INSERTED.[LoginToSac],
      INSERTED.[RuoloManager]
	  ,INSERTED.[GeneraAnteprimaReferto]
    WHERE [Id] = @Id

    COMMIT TRANSACTION;

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiModifica] TO [ExecuteFrontEnd]
    AS [dbo];

