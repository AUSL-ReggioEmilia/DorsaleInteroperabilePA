

CREATE FUNCTION [dbo].[RicalcolaGruppiOePerUtente]
(
@Utente VARCHAR (64)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT DISTINCT gu.ID, gu.Descrizione 
	FROM GruppiUtenti gu
		INNER JOIN UtentiGruppiUtenti ugu ON gu.ID = ugu.IDGruppoUtenti
		INNER JOIN Utenti u ON ugu.IDUtente = u.ID
			AND u.Attivo = 1
		--join per i gruppi sul SAC
		LEFT JOIN [SacOrganigramma].[GruppiUtenti] sac_gu WITH(NOLOCK)
			ON u.Utente = sac_gu.Gruppo
				AND sac_gu.Utente = @Utente
		--Cerca come utente o come membro nei gruppi sul SAC
	WHERE u.Utente = @Utente
			OR sac_gu.Utente = @Utente	
)
