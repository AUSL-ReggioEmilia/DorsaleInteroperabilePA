
CREATE PROCEDURE [dbo].[ConsensiWsGetProvenienza]
	@Identity varchar(64)

AS
BEGIN

DECLARE @Provenienza AS varchar(64)

	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT @Provenienza = dbo.LeggeConsensiProvenienza(@Identity)

	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Utente non trovato!', 16, 1)
		RETURN
	END

	SELECT @Provenienza AS Provenienza

END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiWsGetProvenienza] TO [DataAccessWs]
    AS [dbo];

