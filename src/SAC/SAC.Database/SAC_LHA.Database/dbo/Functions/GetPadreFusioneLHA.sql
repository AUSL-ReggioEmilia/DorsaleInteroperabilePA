


CREATE FUNCTION [dbo].[GetPadreFusioneLHA]
(
	@IdPersona numeric(10, 0)
)
RETURNS numeric(10, 0)

AS
BEGIN

	DECLARE @IdPersonaTemp numeric(10,0)
	DECLARE @MaxCicli AS INT
	DECLARE @CounterCicli AS INT
	DECLARE @Civetta AS INT
	SET @Civetta = 1
	
	SET @MaxCicli = 2000
	SET @CounterCicli = 0
		
	WHILE (@Civetta = 1) AND (@CounterCicli < @MaxCicli)
	BEGIN
		SET @CounterCicli = @CounterCicli + 1 
		
		-- Restituisce NULL se @IdPersona non è fuso oppure @IdPaziente è la root della fusione
		SET @IdPersonaTemp = NULL
		SELECT @IdPersonaTemp = IdVincente FROM AppCn_Fusioni with(nolock) WHERE (IdVittima = @IdPersona)
		
		IF @IdPersonaTemp IS NULL
		BEGIN
			-- Pongo fine al ciclo: non è un paziente fuso oppure è il padre di una fusione
			SET @Civetta = 0
		END
		ELSE
		BEGIN
			-- Imposto per cercare il padre di questo @IdPaziente
			SET @IdPersona = @IdPersonaTemp 
		END 
		
	END
	
	RETURN @IdPersona

END



