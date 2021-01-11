
-- =============================================
-- Data modifica: 29/09/2011
-- Data modifica: 27/052016
-- Descrizione	: Cancella per ID GUID se della mia provenienza
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputRimuoviById]
	  @Id uniqueidentifier
AS
BEGIN

DECLARE @Ret int

DECLARE @Identity AS varchar(64)
DECLARE @Provenienza varchar(16)

	SET NOCOUNT ON;

	-- Controllo accesso
	SET @Identity = USER_NAME()

	IF dbo.LeggePazientiPermessiCancellazione(@Identity) = 0
	BEGIN
		EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiOutputRimuoviById', 'Utente non ha i permessi di cancellazione!'

		RAISERROR('Errore di controllo accessi durante PazientiOutputRimuoviById!', 16, 1)
		RETURN
	END

	-- Calcolo provenienza da utente
	SET @Provenienza = dbo.LeggePazientiProvenienza(@Identity)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante PazientiOutputRimuoviById!', 16, 1)
		RETURN
	END
	
	-- Cancella record
	EXEC @Ret = dbo.PazientiWsBaseDelete @Identity, @Id, @Provenienza, NULL
							
	RETURN @Ret
END
 



























GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputRimuoviById] TO [DataAccessSql]
    AS [dbo];

