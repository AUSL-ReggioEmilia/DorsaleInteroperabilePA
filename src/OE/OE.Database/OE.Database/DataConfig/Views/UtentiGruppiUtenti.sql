
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[UtentiGruppiUtenti]
AS
SELECT 
	Utente.[Id] AS IdUtente
	,Utente.[Utente]
	,Utente.[Descrizione] AS [UtenteDescrizione]

	,gu.[ID] AS IdGruppo
    ,gu.[Descrizione] AS Gruppo

 
  FROM [dbo].[GruppiUtenti] gu WITH(NOLOCK)

	INNER JOIN [dbo].[UtentiGruppiUtenti] AS ugu WITH(NOLOCK)
		ON gu.[ID] = ugu.[IDGruppoUtenti]

	INNER JOIN [dbo].[Utenti] AS Utente WITH(NOLOCK)
		ON ugu.IDUtente = Utente.ID
