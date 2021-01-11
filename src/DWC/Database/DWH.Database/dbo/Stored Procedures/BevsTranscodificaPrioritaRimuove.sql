
-----------------------------------------------------------------


-- =============================================
-- Author:		ETTORE
-- Create date: 2018-05-29
-- Description:	Rimuove un record di transcodifica delle priorità
-- =============================================
CREATE PROCEDURE [dbo].[BevsTranscodificaPrioritaRimuove]
(
	@Id uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT ON;

	DELETE FROM [dbo].[TranscodificaPriorita]
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
    ON OBJECT::[dbo].[BevsTranscodificaPrioritaRimuove] TO [ExecuteFrontEnd]
    AS [dbo];

