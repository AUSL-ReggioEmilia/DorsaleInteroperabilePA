
--
-- Ritorna 1 se l'ordine è completato o cancellato
--
CREATE FUNCTION [dbo].[IsOrdineSenzaRispostaOppureStato](
	@IDOrdineTestata AS UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN
--
-- SANDRO 2014-11-18
--
DECLARE @Ret AS BIT = 0
DECLARE @Erogato AS TABLE (StatoRisposta VARCHAR(2), StatoOrderEntry VARCHAR(2)
							,DataModifica DATETIME2)

DECLARE @RichiestaStatoOrderEntry AS VARCHAR(2)
DECLARE @RichiestaDataModifica AS DATETIME2

	--
	--Dati della richiesta
	SELECT @RichiestaStatoOrderEntry  = StatoOrderEntry
		, @RichiestaDataModifica = DataModifica FROM [dbo].[OrdiniTestate] WITH(NOLOCK)
					WHERE [ID] = @IDOrdineTestata
	--
	-- Controlla se in HD da più di N giorni
	IF @RichiestaStatoOrderEntry = 'HD'	AND @RichiestaDataModifica < DATEADD(dd, -30, GETDATE())
	BEGIN
		SET @Ret = 1		
	END ELSE BEGIN
		--
		-- Testate erogate 
		INSERT INTO @Erogato (StatoRisposta, StatoOrderEntry, DataModifica)
		SELECT StatoRisposta, StatoOrderEntry, DataModifica FROM [dbo].[OrdiniErogatiTestate] WITH(NOLOCK)
						  WHERE [IDOrdineTestata] = @IDOrdineTestata
		
		--
		-- Ci sono testate erogate
		IF NOT EXISTS (SELECT * FROM @Erogato) AND @RichiestaDataModifica < DATEADD(dd, -30, GETDATE())
		BEGIN
			SET @Ret = 1
		END ELSE BEGIN
			--
			-- Ci sono testate senza Risposta o Stato
			IF EXISTS (SELECT * FROM @Erogato
								WHERE (StatoOrderEntry IS NULL AND DataModifica < DATEADD(dd, -60, GETDATE()))
									OR (StatoRisposta IS NULL AND DataModifica < DATEADD(dd, -30, GETDATE()))
								)
			BEGIN
				SET @Ret = 1
			END
		END
	END
	RETURN @Ret	
END

