-----------------------------------------------------------------


-- =============================================
-- Author:		ETTORE
-- Create date: 2018-05-29
-- Description:	Rimuove un record di transcodifica dei regimi
-- =============================================
CREATE PROCEDURE [dbo].[BevsTranscodificaRegimiRimuove]
(
	@Id uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT ON;

	DELETE FROM [dbo].[TranscodificaRegimi]
	OUTPUT 
		DELETED.[Id],
		DELETED.[AziendaErogante],
		DELETED.[SistemaErogante],
		DELETED.[CodiceEsterno],
		DELETED.[Codice],
		DELETED.[Descrizione]
	WHERE [Id] = @Id

	RETURN 0
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTranscodificaRegimiRimuove] TO [ExecuteFrontEnd]
    AS [dbo];

