﻿-----------------------------------------------------------------



-- =============================================
-- Author:		ETTORE
-- Create date: 2018-05-29
-- Description:	Modifica un record di transcodifica dei regimi
-- =============================================
CREATE PROCEDURE [dbo].[BevsTranscodificaRegimiModifica]
(
	@Id uniqueidentifier,
	@AziendaErogante varchar(16),
	@SistemaErogante varchar(16),
	@CodiceEsterno varchar(16),
	@Codice varchar(16),
	@Descrizione varchar(64)
)
AS
BEGIN
  SET NOCOUNT ON;

	UPDATE [dbo].[TranscodificaRegimi]
	SET
		[AziendaErogante] = @AziendaErogante,
		[SistemaErogante] = @SistemaErogante,
		[CodiceEsterno] = @CodiceEsterno,
		[Codice] = @Codice,
		[Descrizione] = @Descrizione
	OUTPUT 
		INSERTED.[Id],
		INSERTED.[AziendaErogante],
		INSERTED.[SistemaErogante],
		INSERTED.[CodiceEsterno],
		INSERTED.[Codice],
		INSERTED.[Descrizione]
	WHERE [Id] = @Id

	RETURN 0
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTranscodificaRegimiModifica] TO [ExecuteFrontEnd]
    AS [dbo];

