

-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-12-21
-- Description:	Ottiene la provenienza per l'utente passato 
-- =============================================
CREATE  PROCEDURE [pazienti_ws].[ProvenienzaOttieni]
(
	@Identity varchar(64)
)
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @Provenienza AS VARCHAR(64)

	SELECT @Provenienza = dbo.LeggePazientiProvenienza(@Identity)
	IF @Provenienza IS NULL
	BEGIN
		DECLARE @ErrMsg AS varchar(1024)
		SET @ErrMsg = 'Utente non trovato! @Identity=' + @Identity
		RAISERROR(@ErrMsg, 16, 1)
		RETURN
	END
	SELECT @Provenienza AS Provenienza
END