
-----------------------------------------------------------------


-- =============================================
-- Author:		ETTORE
-- Create date: 2018-05-29
-- Description:	Restituisce un record di transcodifica delle priorità
-- =============================================
CREATE PROCEDURE [dbo].[BevsTranscodificaPrioritaOttieni]
(
	@Id uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT ON;

	SELECT 
		[Id],
		[AziendaErogante],
		[SistemaErogante],
		[CodiceEsterno],
		[Codice],
		[Descrizione]
	FROM  
		[dbo].[TranscodificaPriorita]
	WHERE 
		[Id] = @Id

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTranscodificaPrioritaOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

