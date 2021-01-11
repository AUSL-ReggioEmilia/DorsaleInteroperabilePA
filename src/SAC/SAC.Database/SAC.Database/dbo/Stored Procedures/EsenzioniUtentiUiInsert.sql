

-- =============================================
-- Author:		simone B
-- Create date: 2018-03-26
-- Description:	Inserisce un record dentro "dbo.EsenzioniUtenti"
-- =============================================
CREATE PROCEDURE [dbo].[EsenzioniUtentiUiInsert]
	  @Utente varchar(64)
	, @Provenienza varchar(16)
	, @Lettura bit
	, @Scrittura bit
	, @Cancellazione bit
	, @LivelloAttendibilita tinyint
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

	INSERT INTO dbo.EsenzioniUtenti
		( Id
		, Utente
		, Provenienza
		, Lettura
		, Scrittura
		, Cancellazione
		, LivelloAttendibilita
		, Disattivato)
	VALUES
		( @Id
		, @Utente
		, @Provenienza
		, @Lettura
		, @Scrittura
		, @Cancellazione
		, @LivelloAttendibilita
		, @Disattivato)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Completato
	--  Ritorna i dati inseriti
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
    ON OBJECT::[dbo].[EsenzioniUtentiUiInsert] TO [DataAccessUi]
    AS [dbo];

