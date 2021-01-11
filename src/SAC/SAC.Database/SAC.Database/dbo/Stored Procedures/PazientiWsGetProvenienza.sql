
CREATE PROCEDURE [dbo].[PazientiWsGetProvenienza]
(
	@Identity varchar(64)
)
AS
BEGIN

	DECLARE @Provenienza AS varchar(64)
	SET NOCOUNT ON;

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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsGetProvenienza] TO [DataAccessWs]
    AS [dbo];

