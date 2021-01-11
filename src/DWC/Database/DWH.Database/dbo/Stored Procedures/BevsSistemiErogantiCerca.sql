


-- =============================================
-- Author:		Simone Bitti
-- Modify date: 2017-02-01
-- Description:	Cerca un SistemaErogante
-- Modify date:	2018-02-06 - SimoneB : Aggiunta gestione del nuovo campo [GeneraAnteprimaReferto]
-- Modify date:	2018-06-27 - ETTORE: Gestione del nuovo campo [TipoNoteAnamnestiche]
-- =============================================
CREATE PROCEDURE [dbo].[BevsSistemiErogantiCerca]
(
	@AziendaErogante varchar(16) = NULL,
	@SistemaErogante varchar(16) = NULL,
	@Descrizione varchar(128) = NULL,
	@RuoloVisualizzazione varchar(128) = NULL,
	@EmailControlloQualitaPassivo varchar(128) = NULL,
	@TipoReferti bit = NULL,
	@TipoRicoveri bit = NULL,
	@LoginToSac varchar(64) = NULL,
	@RuoloManager varchar(128) = NULL,
	@Top INT = NULL,
	@GeneraAnteprimaReferto BIT = NULL,
	@TipoNoteAnamnestiche bit = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT ON

  SELECT TOP (ISNULL(@Top, 100)) 
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
	[RuoloManager],
	[GeneraAnteprimaReferto]
  FROM  
	[dbo].[SistemiEroganti]
  WHERE 
	(AziendaErogante LIKE @AziendaErogante + '%' OR @AziendaErogante IS NULL) AND 
	(SistemaErogante LIKE @SistemaErogante + '%' OR @SistemaErogante IS NULL) AND 
	(Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND 
	(RuoloVisualizzazione LIKE @RuoloVisualizzazione + '%' OR @RuoloVisualizzazione IS NULL) AND 
	(EmailControlloQualitaPassivo LIKE @EmailControlloQualitaPassivo + '%' OR @EmailControlloQualitaPassivo IS NULL) AND 
	(TipoReferti = @TipoReferti OR @TipoReferti IS NULL) AND 
	(TipoRicoveri = @TipoRicoveri OR @TipoRicoveri IS NULL) AND 
	(TipoNoteAnamnestiche = @TipoNoteAnamnestiche OR @TipoNoteAnamnestiche IS NULL) AND 
	(LoginToSac LIKE @LoginToSac + '%' OR @LoginToSac IS NULL) AND 
	(RuoloManager LIKE @RuoloManager + '%' OR @RuoloManager IS NULL) 
	AND (@GeneraAnteprimaReferto IS NULL OR GeneraAnteprimaReferto = @GeneraAnteprimaReferto)

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiCerca] TO [ExecuteFrontEnd]
    AS [dbo];

