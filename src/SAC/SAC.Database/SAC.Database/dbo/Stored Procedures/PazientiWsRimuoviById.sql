
CREATE PROCEDURE [dbo].[PazientiWsRimuoviById]
	  @Identity varchar(64)

	, @Id uniqueidentifier
	, @Provenienza varchar(16)

AS
BEGIN

DECLARE @IdProvenienza varchar(64)
SET @IdProvenienza = NULL

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiCancellazione(@Identity) = 0
	BEGIN
		EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsRimuovi', 'Utente non ha i permessi di cancellazione!'

		RAISERROR('Errore di controllo accessi durante PazientiWsRimuovi!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	-- Cancella record
	---------------------------------------------------

	EXEC dbo.PazientiWsBaseDelete @Identity, @Id, @Provenienza, @IdProvenienza
									

	RETURN 1
	
END
 























GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsRimuoviById] TO [DataAccessWs]
    AS [dbo];

