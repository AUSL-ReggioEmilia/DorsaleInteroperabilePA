
-- =============================================
-- Author:		Ettore
-- Create date: 2016-05-04
-- Description:	Controlla se il ricovero è oscurato: restituisce 0 se il ricovero è oscurato
-- =============================================
CREATE FUNCTION [dbo].[CheckRicoveroOscuramenti]
(
	  @IdRuolo UNIQUEIDENTIFIER		--IdRuolo scelto dall'utente loggato
	, @AziendaErogante VARCHAR(16)
	, @NumeroNosologico VARCHAR(64)
)
RETURNS BIT
AS
BEGIN
	DECLARE @Ret AS BIT = 1
	DECLARE @NumOscDistinti INT
	DECLARE @NumOscPerRuolo INT
	DECLARE @OscuramentiTable TABLE (CodiceOscuramento INT, IdRuolo UNIQUEIDENTIFIER)
	--
	-- Inserisco in tabella temporanea
	--
	INSERT INTO 
		@OscuramentiTable (CodiceOscuramento , IdRuolo)
	SELECT 
		CodiceOscuramento, IdRuolo 
	FROM 
		dbo.GetRicoveroOscuramenti(@AziendaErogante, @NumeroNosologico)
	
	IF @@ROWCOUNT > 0
	BEGIN 	
		--
		-- Calcolo il numero dei codici di oscuramento univoci
		--
		SELECT @NumOscDistinti = COUNT(DISTINCT CodiceOscuramento) 
		FROM @OscuramentiTable 
				
		IF @NumOscDistinti > 0 
		BEGIN 
			--
			-- Calcolo il numero di oscuramenti bypassabili dall'IdRuolo corrente
			--
			SELECT @NumOscPerRuolo = COUNT(DISTINCT CodiceOscuramento) 
			FROM @OscuramentiTable 
			WHERE IdRuolo = @IdRuolo 
				
			--
			-- Se i due valori sono diversi allora esiste un codice di oscuramento che non è 
			-- associato all'IdRuolo corrente per cui il referto non sarà visibile al ruolo corrente
			--
			IF @NumOscDistinti <> @NumOscPerRuolo
				SET @Ret = 0
		END
	END
	
	RETURN @Ret

END