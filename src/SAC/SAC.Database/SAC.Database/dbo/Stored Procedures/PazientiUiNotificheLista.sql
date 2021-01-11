


-- =============================================
-- Author:		
-- Create date: 
-- Description:	Restituisce l'elenco delle notifiche out del paziente
-- Modify date: 2018-08-07 ETTORE: Eliminato l'uso della tabella PazientiNotificheUtenti
--									Gestito i casi di notifica 8=Modifica consenso e 9=Modifica esenzione
--									Aggiunto ricerca anche sull'IdPazienteFuso per mostrare le notifiche di merge
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiNotificheLista]
(
	@IdPaziente as uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP 500
		Data, 
		Tipo, 
		Utente, 
		InvioData, 
		InvioUtente
	FROM (
		--Ricerca in PazientiNotifiche su IdPaziente
		SELECT
			P1.Data, 
			CASE 
				WHEN P1.Tipo = 0 THEN 'Orchestrazione' 
				WHEN P1.Tipo = 1 THEN 'Portale'
				WHEN P1.Tipo = 2 THEN 'Servizio Web'
				WHEN P1.Tipo = 3 THEN 'Job SQL'
				WHEN P1.Tipo = 4 THEN 'Notifica merge'
				WHEN P1.Tipo = 5 THEN 'Notifica merge'
				WHEN P1.Tipo = 6 THEN 'Notifica merge'
				WHEN P1.Tipo = 7 THEN 'Not. root fus.'
				WHEN P1.Tipo = 8 THEN 'Mod. Consenso'
				WHEN P1.Tipo = 9 THEN 'Mod. Esenzione'
			END AS Tipo, 
			UPPER(P1.Utente) as Utente, 
			P2.InvioData, 
			UPPER(P2.InvioUtente) as InvioUtente
		FROM PazientiNotifiche P1
			inner join PazientiNotificheUtenti P2 
				ON P1.Id = P2.IdPazientiNotifica	
			WHERE P1.IdPaziente = @IdPaziente

		--Ricerca in PazientiNotifiche su IdPazienteFuso
		UNION ALL
		SELECT
			P1.Data, 
			CASE 
				WHEN P1.Tipo = 0 THEN 'Orchestrazione' 
				WHEN P1.Tipo = 1 THEN 'Portale'
				WHEN P1.Tipo = 2 THEN 'Servizio Web'
				WHEN P1.Tipo = 3 THEN 'Job SQL'
				WHEN P1.Tipo = 4 THEN 'Notifica merge'
				WHEN P1.Tipo = 5 THEN 'Notifica merge'
				WHEN P1.Tipo = 6 THEN 'Notifica merge'
				WHEN P1.Tipo = 7 THEN 'Not. root fus.'
				WHEN P1.Tipo = 8 THEN 'Mod. Consenso'
				WHEN P1.Tipo = 9 THEN 'Mod. Esenzione'
			END AS Tipo, 
			UPPER(P1.Utente) as Utente, 
			P2.InvioData, 
			UPPER(P2.InvioUtente) as InvioUtente
		FROM PazientiNotifiche P1
			inner join PazientiNotificheUtenti P2 
				ON P1.Id = P2.IdPazientiNotifica	
			WHERE P1.IdPazienteFuso = @IdPaziente


		--Ricerca in PazientiNotifiche_Storico su IdPaziente
		UNION ALL
		SELECT
			P1.Data, 
			CASE 
				WHEN P1.Tipo = 0 THEN 'Orchestrazione' 
				WHEN P1.Tipo = 1 THEN 'Portale'
				WHEN P1.Tipo = 2 THEN 'Servizio Web'
				WHEN P1.Tipo = 3 THEN 'Job SQL'
				WHEN P1.Tipo = 4 THEN 'Notifica merge'
				WHEN P1.Tipo = 5 THEN 'Notifica merge'
				WHEN P1.Tipo = 6 THEN 'Notifica merge'
				WHEN P1.Tipo = 7 THEN 'Not. root fus.'
				WHEN P1.Tipo = 8 THEN 'Mod. Consenso'
				WHEN P1.Tipo = 9 THEN 'Mod. Esenzione'
			END AS Tipo, 
			UPPER(P1.Utente) as Utente, 
			P2.InvioData, 
			UPPER(P2.InvioUtente) as InvioUtente
		FROM PazientiNotifiche_Storico P1
			inner join PazientiNotificheUtenti_Storico P2 
				ON P1.Id = P2.IdPazientiNotifica	
			WHERE P1.IdPaziente = @IdPaziente

		--Ricerca in PazientiNotifiche_Storico su IdPazienteFuso
		UNION ALL
		SELECT
			P1.Data, 
			CASE 
				WHEN P1.Tipo = 0 THEN 'Orchestrazione' 
				WHEN P1.Tipo = 1 THEN 'Portale'
				WHEN P1.Tipo = 2 THEN 'Servizio Web'
				WHEN P1.Tipo = 3 THEN 'Job SQL'
				WHEN P1.Tipo = 4 THEN 'Notifica merge'
				WHEN P1.Tipo = 5 THEN 'Notifica merge'
				WHEN P1.Tipo = 6 THEN 'Notifica merge'
				WHEN P1.Tipo = 7 THEN 'Not. root fus.'
				WHEN P1.Tipo = 8 THEN 'Mod. Consenso'
				WHEN P1.Tipo = 9 THEN 'Mod. Esenzione'
			END AS Tipo, 
			UPPER(P1.Utente) as Utente, 
			P2.InvioData, 
			UPPER(P2.InvioUtente) as InvioUtente
		FROM PazientiNotifiche_Storico P1
			inner join PazientiNotificheUtenti_Storico P2 
				ON P1.Id = P2.IdPazientiNotifica	
			WHERE P1.IdPazienteFuso = @IdPaziente


	) AS TAB
	ORDER BY Data DESC

END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiNotificheLista] TO [DataAccessUi]
    AS [dbo];

