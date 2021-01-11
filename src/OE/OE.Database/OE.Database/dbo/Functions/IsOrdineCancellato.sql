

CREATE FUNCTION [dbo].[IsOrdineCancellato](
	@IDOrdineTestata AS UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN

DECLARE @NumRigheErogate AS INT
DECLARE @NumTestateNonErogate AS INT
DECLARE @Ret AS BIT = 0

	--
	-- Controlla se cancellata del richiedente
	--
	IF EXISTS (SELECT *
			  FROM [dbo].[OrdiniTestate] WITH(NOLOCK)
			  WHERE [ID] = @IDOrdineTestata
				AND StatoOrderEntry = 'CA')
		BEGIN
			SET @Ret = 1		
		END
	ELSE
		BEGIN
			--
			-- Conta se ci sono già delle righe in lavorazione
			--
			SELECT @NumRigheErogate = COUNT(*)
			  FROM [dbo].[OrdiniErogatiTestate] WITH(NOLOCK)
				INNER JOIN [dbo].[OrdiniRigheErogate] WITH(NOLOCK)
					ON [OrdiniErogatiTestate].Id = [OrdiniRigheErogate].IDOrdineErogatoTestata
			  WHERE [IDOrdineTestata] = @IDOrdineTestata

			IF @NumRigheErogate > 0
				BEGIN
					--
					-- Conta se sono tutte cancellate
					--
					SELECT @NumTestateNonErogate = COUNT(*)
					  FROM [dbo].[OrdiniErogatiTestate] WITH(NOLOCK)
					  WHERE [IDOrdineTestata] = @IDOrdineTestata
							AND StatoOrderEntry != 'CA'
					IF @NumTestateNonErogate = 0
						SET @Ret = 1
				END
		END
			
	RETURN @Ret	
END


