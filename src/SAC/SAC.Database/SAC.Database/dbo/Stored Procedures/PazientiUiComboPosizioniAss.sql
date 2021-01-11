
CREATE PROCEDURE [dbo].[PazientiUiComboPosizioniAss]

AS
BEGIN
	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------


	SELECT 
		Codice, Descrizione
	FROM PazientiPosizioneAss
UNION
	SELECT 
		null as Codice,
		' ' as Descrizione

END













GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiComboPosizioniAss] TO [DataAccessUi]
    AS [dbo];

