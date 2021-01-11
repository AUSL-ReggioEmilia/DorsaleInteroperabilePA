
--
-- Ritorna 1 se l'ordine è completato o cancellato
--
CREATE FUNCTION [dbo].[IsOrdineArchiviabile](
	@IDOrdineTestata AS UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN
--
-- SANDRO 2014-11-18 Usa EXISIS invece che COUNT e controlla le AE o AR
--
DECLARE @Ret AS BIT = 0
DECLARE @Erogato AS TABLE ( StatoRisposta VARCHAR(2), StatoOrderEntry VARCHAR(2))
	--
	-- Controlla se cancellata del richiedente
	--
	IF EXISTS (SELECT * FROM [dbo].[OrdiniTestate] WITH(NOLOCK)
					WHERE [ID] = @IDOrdineTestata
						AND StatoOrderEntry = 'CA')
	BEGIN
		SET @Ret = 1		
	END ELSE BEGIN
		--
		-- Ci sono testate erogate 
		INSERT INTO @Erogato (StatoRisposta, StatoOrderEntry)
		SELECT StatoRisposta, StatoOrderEntry FROM [dbo].[OrdiniErogatiTestate] WITH(NOLOCK)
						  WHERE [IDOrdineTestata] = @IDOrdineTestata
		
		--
		-- Ci sono testate erogate e NON ce ne sono NON in erorre 
		IF EXISTS (SELECT * FROM @Erogato) AND
				NOT EXISTS (SELECT * FROM @Erogato
							WHERE StatoRisposta != 'AE'
								AND StatoRisposta != 'AR')
		BEGIN
			SET @Ret = 1
		END ELSE BEGIN
			--
			-- Ci sono testate non erogate o cancellate o NULL
			IF EXISTS (SELECT * FROM @Erogato) AND
					NOT EXISTS (SELECT * FROM @Erogato
								WHERE (StatoOrderEntry != 'CM' AND StatoOrderEntry != 'CA')
										OR StatoOrderEntry IS NULL
								)
			BEGIN
				SET @Ret = 1
			END
		END
	END
	RETURN @Ret	
END


