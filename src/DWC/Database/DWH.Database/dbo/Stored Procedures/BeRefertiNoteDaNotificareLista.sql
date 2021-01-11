

CREATE PROCEDURE [dbo].[BeRefertiNoteDaNotificareLista]
(
	@IdRefertiBase as uniqueidentifier
)
AS
--
-- Seleziona tutte le note non notificate associate ad un referto
--
/*
	MODIFICA ETTORE 2015-05-20: 
		Per fare si che la tabella dbo.Utenti venga solo utilizzata per gli utenti applicativi 
		eseguo join con il campo Utemti della vista dbo.UtentiSac che usa alias verso il SAC.
		Compongo il campo Utente come Cognome + Nome
	MODIFICA SANDRO 2016-05-11 usa nuova vista Sac.Utenti
	MODIFICA ETTORE 2018-06-05: utilizzo della vista store.RefertiBase
*/
BEGIN
	SET NOCOUNT ON;

	SELECT 
		-- Dati associati al referto
		RB.SistemaErogante
		,RB.AziendaErogante
		,RB.RepartoErogante
		,RB.NumeroReferto
		,RB.NumeroNosologico
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( RB.Id, 'Cognome')) + ' ' +
					CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( RB.Id, 'Nome')) AS Paziente
		,RB.DataReferto
		-- Dati associati alla nota
		,RN.Id					--Guid della nota
		,RN.IdRefertiBase		--Guid del Dwh
		,RN.Data As DataNota
		,RN.Nota
		,RN.Notificata
		,Utenti.Cognome + ' ' + Utenti.Nome as Utente
		,SistemiEroganti.EmailControlloQualitaPassivo

	FROM 
		RefertiNote AS RN
		INNER JOIN store.RefertiBase AS RB ON RN.IdRefertiBase = RB.Id
		INNER JOIN Sac.Utenti AS Utenti ON Utenti.Utente = RN.Utente
		LEFT OUTER JOIN SistemiEroganti ON 
					(SistemiEroganti.SistemaErogante = RB.SistemaErogante)
					AND (SistemiEroganti.AziendaErogante = RB.AziendaErogante)

	WHERE
		(IdRefertiBase = @IdRefertiBase)
		AND
		(RN.Notificata = 0)
		AND
		(RN.Cancellata = 0)

	SET NOCOUNT OFF;
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRefertiNoteDaNotificareLista] TO [ExecuteService]
    AS [dbo];

