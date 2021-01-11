
CREATE PROCEDURE [dbo].[PuliziaLogLHA]
	     
AS
BEGIN

	DECLARE @NumGiorni AS INT
	
	SET @NumGiorni = 180
	
	DELETE FROM [Log]
	WHERE DataLog < DATEDIFF(dd, @NumGiorni, GETDATE())
					
	DELETE FROM [LogRichieste]
	WHERE DataRichiesta < DATEDIFF(dd, @NumGiorni, GETDATE())
	
	DELETE FROM [PazientiDropTable]
	WHERE DataLog < DATEDIFF(dd, @NumGiorni, GETDATE())
			AND NOT DataInvio IS NULL

	DELETE FROM [ConsensiDropTable]
	WHERE DataInserimento < DATEDIFF(dd, @NumGiorni, GETDATE())
		AND NOT DataElaborazione IS NULL
END

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



