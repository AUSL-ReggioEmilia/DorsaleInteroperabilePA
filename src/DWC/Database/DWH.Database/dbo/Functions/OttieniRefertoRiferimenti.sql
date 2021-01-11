
-- =============================================
-- Author:      Alessandro Nostini
-- Create date: 2020-04-24
--
-- Description: Ritorna la lista della catena di aggiornamenti
-- =============================================
CREATE FUNCTION [dbo].[OttieniRefertoRiferimenti]
(
 @IdReferto uniqueidentifier
,@DataPartizione smalldatetime
)  
RETURNS TABLE
AS
RETURN
(
	SELECT rbr.[IdRefertiBase]
		  ,rbr.[DataPartizione]
		  ,rbr.[DataModificaEsterno]

	  ,LAG(rbr.[IdEsterno], 1, rb.[IdEsterno]) OVER (ORDER BY rbr.[DataModificaEsterno]) AS [IdEsternoVecchio]
      ,rbr.[IdEsterno] AS [IdEsternoNuovo]
	  ,rb.[IdEsterno] AS [IdEsterno]

	FROM [store].[RefertiBaseRiferimenti] rbr
		INNER JOIN [store].[RefertiBase] rb
			ON rbr.[IdRefertiBase] = rb.Id
				AND rbr.[DataPartizione] = rb.[DataPartizione]

	WHERE rbr.[IdRefertiBase] = @IdReferto
		AND (rbr.[DataPartizione] = @DataPartizione OR @DataPartizione IS NULL)
)