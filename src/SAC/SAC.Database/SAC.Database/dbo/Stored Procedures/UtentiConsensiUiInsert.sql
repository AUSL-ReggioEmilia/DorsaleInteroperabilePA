
CREATE PROCEDURE [dbo].[UtentiConsensiUiInsert]
	  @Utente varchar(64)
	, @Provenienza varchar(16)
	, @Lettura bit
	, @Scrittura bit
	, @Cancellazione bit
	, @LivelloAttendibilita tinyint
	, @IngressoAck bit
	, @IngressoAckUrl varchar(255)
	, @NotificheAck bit
	, @NotificheUrl varchar(255)
	, @Disattivato tinyint

AS
BEGIN

DECLARE @Id AS uniqueidentifier

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------
	
	SET @Id = NewId()

	INSERT INTO dbo.ConsensiUtenti
		( Id
		, Utente
		, Provenienza
		, Lettura
		, Scrittura
		, Cancellazione
		, LivelloAttendibilita
		, IngressoAck
		, IngressoAckUrl
		, NotificheAck
		, NotificheUrl
		, Disattivato)
	VALUES
		( @Id
		, @Utente
		, @Provenienza
		, @Lettura
		, @Scrittura
		, @Cancellazione
		, @LivelloAttendibilita
		, @IngressoAck
		, @IngressoAckUrl
		, @NotificheAck
		, @NotificheUrl
		, @Disattivato)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Completato
	--  Ritorna i dati inseriti
	---------------------------------------------------

	COMMIT

	SELECT *
	FROM dbo.ConsensiUtenti
	WHERE Id = @Id

	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	RETURN 1

END
















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiConsensiUiInsert] TO [DataAccessUi]
    AS [dbo];

