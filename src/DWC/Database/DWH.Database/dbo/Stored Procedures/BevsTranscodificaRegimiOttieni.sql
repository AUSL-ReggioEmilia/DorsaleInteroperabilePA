-----------------------------------------------------------------


-- =============================================
-- Author:		ETTORE
-- Create date: 2018-05-29
-- Description:	Restituisce un record di transcodifica dei regimi
-- =============================================
CREATE PROCEDURE [dbo].[BevsTranscodificaRegimiOttieni]
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
		[dbo].[TranscodificaRegimi]
	WHERE 
		[Id] = @Id

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTranscodificaRegimiOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

