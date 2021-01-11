
CREATE FUNCTION [dbo].[GetPazientiAnteprima]
(
	@IdPaziente uniqueidentifier
)
RETURNS VARCHAR(300)
AS
BEGIN
/*
	MODIFICA ETTORE 2015-02-11: Utilizzo della tabella PazientiAnteprima
		Se l'anteprima è presente in tabella uso i dati in tabella altrimenti
		calcolo l'anteprima al volo
*/
	DECLARE @Anteprima VARCHAR(300)
	DECLARE @AnteprimaReferti VARCHAR(300)
	DECLARE @AnteprimaRicoveri VARCHAR(300)

	SELECT 
		@AnteprimaReferti = AnteprimaReferti
		, @AnteprimaRicoveri = AnteprimaRicoveri
	FROM 
		PazientiAnteprima WITH(NOLOCK)
	WHERE IdPaziente = @IdPaziente
	
	IF ISNULL(@AnteprimaReferti,'') = '' 
	BEGIN
		SET @AnteprimaReferti = dbo.GetPazientiAnteprimaReferti(@IdPaziente)
	END
	IF ISNULL(@AnteprimaRicoveri, '') = ''
	BEGIN
		SET @AnteprimaRicoveri = dbo.GetPazientiAnteprimaRicoveri(@IdPaziente)
	END
	--
	-- Concateno
	--	
	SET @Anteprima = @AnteprimaReferti + '<br />' + @AnteprimaRicoveri
	--
	-- Restituisco
	--
	RETURN ISNULL(@Anteprima, '')

END

