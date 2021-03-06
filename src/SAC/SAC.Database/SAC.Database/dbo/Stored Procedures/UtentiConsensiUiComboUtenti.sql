﻿
CREATE PROCEDURE [dbo].[UtentiConsensiUiComboUtenti]

AS
BEGIN
	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT Utente, ISNULL(Utente + ' (' + Descrizione + ')', Utente) AS Descrizione
	FROM dbo.Utenti
	WHERE Utente NOT IN (
					SELECT Utente FROM dbo.ConsensiUtenti
						)

	UNION

	SELECT 
		null as Utente
		, '- seleziona utente -' as Descrizione

	ORDER BY Descrizione

END



















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiConsensiUiComboUtenti] TO [DataAccessUi]
    AS [dbo];

