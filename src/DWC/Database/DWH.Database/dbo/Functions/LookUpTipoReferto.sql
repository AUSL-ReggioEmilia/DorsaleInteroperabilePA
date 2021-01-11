

-- =============================================
-- Author:		Ettore
-- Create date: 2016-04-26
-- Modify date: 2016-07-26: restituzione dell'icona di default
-- Description:	Lookup tipi referto
-- =============================================
CREATE FUNCTION [dbo].[LookUpTipoReferto]
(
	@SistemaErogante VARCHAR(16)
	, @SpecialitaErogante VARCHAR(64)
)
RETURNS 
    @Result TABLE (
		Id UNIQUEIDENTIFIER,
		Descrizione VARCHAR(128),
        SistemaErogante VARCHAR(16),
        SpecialitaErogante VARCHAR(64))

AS
BEGIN
	--
	-- Cerco match per SistemaErogante AND SpecialitaErogante
	-- Ordino DESC cosi per primo viene, eventualmente, restituito il record con SpecialitaErogante NOT NULL 
	--
	INSERT INTO @Result (Id, Descrizione , SistemaErogante, SpecialitaErogante)
	SELECT TOP 1 Id, Descrizione , SistemaErogante, SpecialitaErogante
	FROM dbo.TipiReferto
	WHERE 
		SistemaErogante = @SistemaErogante
		AND (
				SpecialitaErogante = @SpecialitaErogante 
				OR 
				SpecialitaErogante IS NULL
			)
	ORDER BY SpecialitaErogante DESC
	--
	-- Se non trovo cerco quella di default
	--
	IF NOT EXISTS(SELECT * FROM @Result ) 
	BEGIN 
		INSERT INTO @Result (Id, Descrizione , SistemaErogante, SpecialitaErogante)
		SELECT TOP 1 Id, Descrizione , SistemaErogante, SpecialitaErogante
		FROM dbo.TipiReferto
		WHERE 
			SistemaErogante = 'Altro'
	END 
	--
	-- Restituisco 
	--
	RETURN

END