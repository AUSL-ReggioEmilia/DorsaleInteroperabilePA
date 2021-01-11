
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-10-29
-- Description:	Ritorna IdEsterno dall'IdGuid + @DataPartizione (opzionale)
-- =============================================
CREATE FUNCTION [dbo].[GetIdPrescrizioniIdEsterno] (@Id uniqueidentifier, @DataPartizione smalldatetime)  
RETURNS varchar(64) AS  
BEGIN 
DECLARE @Ret varchar(64)

	--Per effetto del partizionamento non esiste una vera UNIQUE su IDdGuid
	--	per qui ritornerà l'ultimo in ordine di DataPartizione

	SELECT TOP 1 @Ret = IdEsterno
	FROM [store].[Prescrizioni] WITH(NOLOCK)
	WHERE Id = @Id
		AND (@DataPartizione IS NULL OR DataPartizione = @DataPartizione)
	ORDER BY DataPartizione DESC

	-- Restituisco	
	RETURN @Ret
END