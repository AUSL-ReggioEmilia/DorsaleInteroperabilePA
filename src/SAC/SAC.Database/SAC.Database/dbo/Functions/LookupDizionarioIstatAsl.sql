
-- =============================================
-- Author:		Ettore
-- Create date: 2017-05-22
-- Description:	Esegue il looup della descrizione della ASL utilizzando la nuova tabella 
--				DizionarioIstataAsl sincronizzata con i dati di LHA tramite SacConnLha
-- =============================================
CREATE FUNCTION [dbo].[LookupDizionarioIstatAsl](
	@CodiceRegione AS varchar(3)
	, @CodiceAsl AS varchar(3)
	)
RETURNS VARCHAR(128)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(128)

	SELECT @Ret = DescrizioneAsl
		FROM DizionarioIstatAsl
		WHERE CodiceAsl = @CodiceAsl
			AND Codiceregione = @CodiceRegione
	--
	-- Se non trova restituisce la concatenazione di @Codiceregione+@CodiceAsl
	--
	IF @Ret IS NULL
		SET @Ret = @Codiceregione + @CodiceAsl
	--
	--
	--
	RETURN @Ret
END