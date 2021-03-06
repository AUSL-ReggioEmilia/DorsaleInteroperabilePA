﻿

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Modify date: 2016-11-25 Aggiunto campo Attivo
-- Description:	Ritorna un utente di AD per ID
-- =============================================
CREATE PROC [organigramma_da].[UtentiOttienePerId]
(
 @Id uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UtentiOttienePerId]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UtentiOttienePerId]!', 16, 1)
		RETURN
	END

	--Eseguo query
	SELECT [Id],
		[Utente],
		[Descrizione],
		[Cognome],
		[Nome],
		[CodiceFiscale],
		[Matricola],
		[Email],
		[Attivo]
	FROM  [organigramma_da].[Utenti]
	WHERE Id = @Id
END


