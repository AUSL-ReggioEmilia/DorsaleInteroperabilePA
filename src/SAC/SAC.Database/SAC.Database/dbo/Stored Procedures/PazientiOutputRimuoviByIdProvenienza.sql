

-- =============================================
-- Data modifica: 29/09/2011
-- Data modifica: 27/052016
-- Descrizione	: Cancella per ID provenienza se della mia provenienza
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputRimuoviByIdProvenienza]
	@IdProvenienza varchar(64)
AS
BEGIN

DECLARE @Ret AS int
DECLARE @Identity AS varchar(64)
DECLARE @Provenienza varchar(16)

	SET NOCOUNT ON;

	-- Controllo accesso
	SET @Identity = USER_NAME()

	IF dbo.LeggePazientiPermessiCancellazione(@Identity) = 0
	BEGIN
		EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiOutputRimuoviByIdProvenienza', 'Utente non ha i permessi di cancellazione!'

		RAISERROR('Errore di controllo accessi durante PazientiOutputRimuoviByIdProvenienza!', 16, 1)
		RETURN
	END

	-- Calcolo provenienza da utente
	SET @Provenienza = dbo.LeggePazientiProvenienza(@Identity)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante PazientiOutputRimuoviByIdProvenienza!', 16, 1)
		RETURN
	END
	
	-- Cancella record
	EXEC @Ret = dbo.PazientiWsBaseDelete @Identity, NULL, @Provenienza, @IdProvenienza
	RETURN @Ret
END
 



























GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputRimuoviByIdProvenienza] TO [DataAccessSql]
    AS [dbo];

