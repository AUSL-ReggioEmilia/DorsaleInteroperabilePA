
-- =============================================
-- Author:		ETTORE GARULLI
-- Create date: 2018-02-05
-- Description:	Restituisce TRUE se per il sistema passato deve essere autogenerato l'attributo "Anteprima" per il referto
-- =============================================
CREATE PROCEDURE [dbo].[ExtRefertiGeneraAnteprima]
(
	@AziendaErogante VARCHAR(16)
	, @SistemaErogante VARCHAR(16)
)
AS
BEGIN
	SET NOCOUNT ON;

	IF ISNULL(@AziendaErogante, '') = '' OR ISNULL(@SistemaErogante, '') = ''
	BEGIN
		RAISERROR('@AziendaErogante e @SistemaErogante sono obbligatori.', 16,1)
		RETURN 
	END 
	--
	-- Restitusco il campo GeneraAnteprimaReferto 
	--
	SELECT 
		GeneraAnteprimaReferto 
	FROM 
		SistemiEroganti 
	WHERE AziendaErogante = @AziendaErogante 
		AND SistemaErogante = @SistemaErogante

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiGeneraAnteprima] TO [ExecuteExt]
    AS [dbo];

