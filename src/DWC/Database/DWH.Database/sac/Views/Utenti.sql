-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-05-05
-- Description:	Accecco al SAC lista utenti
-- =============================================
CREATE VIEW [sac].[Utenti]
AS
	SELECT [Id]
		, [Utente]
		, [Descrizione]
		, [Cognome]
		, [Nome]
		, [CodiceFiscale]
		, [Matricola]
		, [Email]
		, [Attivo]
	FROM dbo.SAC_Utenti WITH(NOLOCK)