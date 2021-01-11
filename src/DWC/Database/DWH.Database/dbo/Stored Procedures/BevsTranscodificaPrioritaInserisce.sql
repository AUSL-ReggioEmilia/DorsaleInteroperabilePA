

-----------------------------------------------------------------


-- =============================================
-- Author:		ETTORE
-- Create date: 2018-05-29
-- Description:	Inserisce un record di transcodifica delle priorità
-- =============================================
CREATE PROCEDURE [dbo].[BevsTranscodificaPrioritaInserisce]
(
	@AziendaErogante varchar(16),
	@SistemaErogante varchar(16),
	@CodiceEsterno varchar(16),
	@Codice varchar(16),
	@Descrizione varchar(64)
)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [dbo].[TranscodificaPriorita]
		(
		[AziendaErogante],
		[SistemaErogante],
		[CodiceEsterno],
		[Codice],
		[Descrizione]
		)
	OUTPUT 
		INSERTED.[Id],
		INSERTED.[AziendaErogante],
		INSERTED.[SistemaErogante],
		INSERTED.[CodiceEsterno],
		INSERTED.[Codice],
		INSERTED.[Descrizione]
	VALUES
		(
		@AziendaErogante,
		@SistemaErogante,
		@CodiceEsterno,
		@Codice,
		@Descrizione
		)

	RETURN 0

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTranscodificaPrioritaInserisce] TO [ExecuteFrontEnd]
    AS [dbo];

