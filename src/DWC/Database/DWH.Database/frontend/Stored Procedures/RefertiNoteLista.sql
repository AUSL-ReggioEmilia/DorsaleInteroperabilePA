

-- =============================================
-- Author:		ETTORE
-- Create date: 2015-05-22
-- Description:	Restituisce tutte le note di un referto
--				Sostituisce la dbo.FevsRefertiNoteLista
--				Aggiunto calcolo filtro per data partizione e filtro per data partizione
--				Restituito il campo XML Oscuramenti
--				Utilizzato i campi Anteprima e SpecialitaErogante restituiti dalla vista
--				Utilizza la nuova vista dbo.UtentiSac che usa sinonimo verso il SAC e compone il campo Autore come Cognome + Nome
-- Modify date: 2016-05-11 - SANDRO: Usa nuova vista sac.Utenti
-- Modify date: 2019-01-31 - ETTORE: Eliminazione uso della tabella "dbo.RepartiEroganti"
-- =============================================
CREATE PROCEDURE [frontend].[RefertiNoteLista]
(
@IdReferti as uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON; 

	SELECT 
		RefertiNote.Id					--Guid della nota
		,RefertiNote.Data AS DataNota
		,Utenti.Cognome + ' ' + Utenti.Nome AS Autore
		,RefertiNote.Nota
		,RefertiNote.Notificata
		,SistemiEroganti.RuoloManager AS RuoloDelete
	FROM 
		RefertiNote
		INNER JOIN Sac.Utenti AS Utenti ON Utenti.Utente = RefertiNote.Utente
		INNER JOIN Referti ON Referti.Id = RefertiNote.IdRefertiBase
		LEFT OUTER JOIN SistemiEroganti 
			ON SistemiEroganti.AziendaErogante = Referti.AziendaErogante
				AND SistemiEroganti.SistemaErogante = Referti.SistemaErogante
	WHERE
		RefertiNote.IdRefertiBase = @IdReferti
		AND
		RefertiNote.Cancellata = 0
	ORDER BY
		RefertiNote.Data DESC

END



