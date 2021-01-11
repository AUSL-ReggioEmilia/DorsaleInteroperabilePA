
-- =============================================
-- Author:		simone B
-- Create date: 2018-03-26
-- Description:	Aggiorna un record di "dbo.EsenzioniUtenti"
-- =============================================
CREATE PROCEDURE [dbo].[EsenzioniUtentiUiUpdate]
	  @Id uniqueidentifier
	, @Lettura bit
	, @Scrittura bit
	, @Cancellazione bit
	, @LivelloAttendibilita tinyint
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

	UPDATE dbo.EsenzioniUtenti
	SET 
		  Provenienza = @Provenienza
		, Lettura = @Lettura
		, Scrittura = @Scrittura
		, Cancellazione = @Cancellazione
		, LivelloAttendibilita = @LivelloAttendibilita
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
	FROM dbo.EsenzioniUtenti
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
    ON OBJECT::[dbo].[EsenzioniUtentiUiUpdate] TO [DataAccessUi]
    AS [dbo];

