-----------------------------------------------------------------


-- =============================================
-- Author:		ETTORE
-- Create date: 2018-05-29
-- Description:	Restituisce una lista di transcodifiche dei regimi
-- =============================================
CREATE PROCEDURE [dbo].[BevsTranscodificaRegimiCerca]
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
		[dbo].[TranscodificaRegimi]
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
    ON OBJECT::[dbo].[BevsTranscodificaRegimiCerca] TO [ExecuteFrontEnd]
    AS [dbo];

