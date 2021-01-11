-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-10-21
-- Description: Ritorna 1 se l'ordine è stato Reinoltrato
-- Modify date: 
-- =============================================
CREATE FUNCTION dbo.IsOrdineReinoltrato (
	@IDOrdineTestata AS UNIQUEIDENTIFIER,
	@OrdineDataInserimento AS DATETIME2(0)
) RETURNS BIT
AS
BEGIN

	DECLARE @Ret AS BIT = 0

	SELECT @Ret = 1
	WHERE EXISTS
	(
		SELECT *
		FROM 
			dbo.MessaggiRichieste MR WITH(NOLOCK)
		WHERE 
			MR.IDOrdineTestata = @IDOrdineTestata
			AND MR.StatoOrderEntry = 'RI'
			AND MR.DataInserimento >= @OrdineDataInserimento
			AND MR.DataInserimento = (
				 -- L'ultimo deve essere un RI
				 SELECT MAX(MRL.DataInserimento)
				 FROM dbo.MessaggiRichieste MRL WITH(NOLOCK)
				 WHERE MRL.IDOrdineTestata = @IDOrdineTestata
				  AND MRL.DataInserimento >= @OrdineDataInserimento
			 )
	)

	RETURN @Ret	
END