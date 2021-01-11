-- =============================================
-- Author:      
-- Create date: 
-- Description: Descrizione
-- Modify date: 2015-11-27 Stefano P.: Aggiunto parametro Provenienza
-- =============================================
CREATE PROCEDURE [dbo].[UtentiConsensiUiUpdate]
	  @Id uniqueidentifier
	--, @Utente varchar(64)	
	, @Lettura bit
	, @Scrittura bit
	, @Cancellazione bit
	, @LivelloAttendibilita tinyint
	, @IngressoAck bit
	, @IngressoAckUrl varchar(255)
	, @NotificheAck bit
	, @NotificheUrl varchar(255)
	, @Disattivato tinyint
	, @Provenienza varchar(16) = NULL

AS
BEGIN

	SET NOCOUNT ON;	

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Aggiorna i dati senza controllo della concorrenza
	---------------------------------------------------

	UPDATE dbo.ConsensiUtenti
	SET 
		  Provenienza = @Provenienza
		, Lettura = @Lettura
		, Scrittura = @Scrittura
		, Cancellazione = @Cancellazione
		, LivelloAttendibilita = @LivelloAttendibilita
		, IngressoAck = @IngressoAck
		, IngressoAckUrl = @IngressoAckUrl
		, NotificheAck = @NotificheAck
		, NotificheUrl = @NotificheUrl
		, Disattivato = @Disattivato
		
	WHERE 
		Id = @Id

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Completato
	--  Ritorna i dati aggiornati
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
    ON OBJECT::[dbo].[UtentiConsensiUiUpdate] TO [DataAccessUi]
    AS [dbo];

