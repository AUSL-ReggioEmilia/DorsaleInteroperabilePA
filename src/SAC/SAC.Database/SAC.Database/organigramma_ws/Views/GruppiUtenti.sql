


-- ================================================
-- Author:		ETTORE
-- Create date: 2019-02-08
-- Description:	Lista dei Gruppi RECURSIVO dell'utente (membership di AD)
--				Efficiente se usata per cercare i gruppi di un o piu utente
--				Usata dalla SP GruppiOttienePerUtente()
--				Ad uso dello schmema organigramma_ws: COPIATA dalla [organigramma_da].[GruppiUtenti] 
-- ================================================
CREATE VIEW [organigramma_ws].[GruppiUtenti]
AS
	SELECT DISTINCT 
		 Gruppi.IdFiglio AS IdGruppo
		,Gruppi.UtenteFiglio AS Gruppo
	    ,Utenti.id AS IdUtente
		,Utenti.Utente AS Utente
	FROM [organigramma].[OggettiActiveDirectory] Utenti
		CROSS APPLY [organigramma].[OttieneGruppiPerIdUtente](Utenti.Id) Gruppi
	WHERE Utenti.Tipo = 'Utente'
		AND Utenti.Attivo = 1