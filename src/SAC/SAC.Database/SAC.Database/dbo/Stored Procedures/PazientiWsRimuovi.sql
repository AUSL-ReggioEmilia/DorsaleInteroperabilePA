-- =============================================
-- Data create: 29/09/2011: 
-- Data modifica: 27/05/2016: review
-- Descrizione: 
-- =============================================
CREATE PROCEDURE [dbo].[PazientiWsRimuovi]
	  @Identity varchar(64)
	, @Provenienza varchar(16)
	, @IdProvenienza varchar(64)
AS
BEGIN

DECLARE @Ret AS int

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
	EXEC @Ret = dbo.PazientiWsBaseDelete @Identity, NULL, @Provenienza, @IdProvenienza
	RETURN @Ret
END
 





















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsRimuovi] TO [DataAccessWs]
    AS [dbo];

