


-- =============================================
-- Author:      
-- Create date: 
-- Description: Aggiorna un record di dbo.Provenienze
-- Modify date: 2016-08-11 Stefano P: Aggiunto campo FusioneAutomatica
-- Modify date: 2020-02-03 ETTORE: Aggiunto campo "DisabilitaRicercaWS" [ASMN 7700]
-- Modify date: 2020-04-09 ETTORE: Aggiunto campo "SoloPropriWS" [ASMN 8017]
-- =============================================
CREATE PROCEDURE [dbo].[ProvenienzeUiUpdate]
(
	  @Provenienza AS varchar(16)
	, @Descrizione AS varchar(128)
	, @EmailResponsabile AS varchar(128)
	, @FusioneAutomatica bit = 0
	, @DisabilitaRicercaWS bit = 0
	, @SoloPropriWS bit = 0
)
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

	UPDATE dbo.Provenienze SET 
		  Descrizione = @Descrizione
		, EmailResponsabile = @EmailResponsabile
		, FusioneAutomatica = @FusioneAutomatica
		, DisabilitaRicercaWS = @DisabilitaRicercaWS 
		, SoloPropriWS = @SoloPropriWS 
	WHERE 
		Provenienza = @Provenienza

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Completato
	--  Ritorna i dati aggiornati
	---------------------------------------------------

	COMMIT
	
	SELECT *
	FROM dbo.Provenienze
	WHERE Provenienza = @Provenienza
	
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
    ON OBJECT::[dbo].[ProvenienzeUiUpdate] TO [DataAccessUi]
    AS [dbo];

