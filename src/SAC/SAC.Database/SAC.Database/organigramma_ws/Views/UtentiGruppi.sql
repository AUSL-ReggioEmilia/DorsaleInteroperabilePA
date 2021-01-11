



-- ================================================
-- Author:		ETTORE GARULLI
-- Create date: 2019-03-28
-- Description:	Lista dei Gruppi RECURSIVO dell'utente (membership di AD)
--				Efficiente se usata per cercare gli utenti di un o piu gruppi
--				Usata dalla SP UtentiOttienePerGruppo()
--				Derivata dalla [organigramma_da].[UtentiGruppi]
-- ================================================
CREATE VIEW [organigramma_ws].[UtentiGruppi]
AS
	SELECT DISTINCT 
	     Gruppi.id AS IdGruppo
		,Gruppi.Utente AS Gruppo
		,Utenti.IdFiglio AS IdUtente
		,Utenti.UtenteFiglio AS Utente
	FROM [organigramma].[OggettiActiveDirectory] Gruppi
		CROSS APPLY [organigramma].[OttieneUtentiPerIdGruppo](Gruppi.Id) Utenti
	WHERE Gruppi.Tipo = 'Gruppo'
		AND Gruppi.Attivo = 1