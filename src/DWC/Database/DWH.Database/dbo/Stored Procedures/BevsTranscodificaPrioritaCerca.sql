
-----------------------------------------------------------------


-- =============================================
-- Author:		ETTORE
-- Create date: 2018-05-29
-- Description:	Restituisce una lista di transcodifiche delle priorità
-- =============================================
CREATE PROCEDURE [dbo].[BevsTranscodificaPrioritaCerca]
(
	@AziendaErogante varchar(16) = NULL,
	@SistemaErogante varchar(16) = NULL,
	@CodiceEsterno varchar(16) = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT ON;

	SELECT TOP 1000
		[Id],
		[AziendaErogante],
		[SistemaErogante],
		[CodiceEsterno],
		[Codice],
		[Descrizione]
	FROM  
		[dbo].[TranscodificaPriorita]
	WHERE 
		(AziendaErogante LIKE @AziendaErogante + '%' OR @AziendaErogante IS NULL) AND 
		(SistemaErogante LIKE @SistemaErogante + '%' OR @SistemaErogante IS NULL) AND 
		(CodiceEsterno LIKE @CodiceEsterno + '%' OR @CodiceEsterno IS NULL) 
	Order by 
		[AziendaErogante],
		[SistemaErogante],
		[CodiceEsterno]

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTranscodificaPrioritaCerca] TO [ExecuteFrontEnd]
    AS [dbo];

