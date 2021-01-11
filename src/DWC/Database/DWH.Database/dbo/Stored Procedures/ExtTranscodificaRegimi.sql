-- =============================================
-- Author:		ETTORE
-- Create date: 2018-05-29
-- Description:	Esegue la transcodifica dei codici di regime
--				Se non restituisce nulla la DAE utilizzerà codice e descrizione forniti dall'erogante
-- =============================================
CREATE PROCEDURE dbo.ExtTranscodificaRegimi
(
	
	@AziendaErogante VARCHAR(16)
	, @SistemaErogante VARCHAR(16)
	, @CodiceEsterno VARCHAR(16)
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Codice
		, Descrizione  
	FROM 
		dbo.TranscodificaRegimi 
	WHERE
		AziendaErogante = @AziendaErogante 
		AND SistemaErogante = @SistemaErogante 
		AND CodiceEsterno = @CodiceEsterno 

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtTranscodificaRegimi] TO [ExecuteExt]
    AS [dbo];

