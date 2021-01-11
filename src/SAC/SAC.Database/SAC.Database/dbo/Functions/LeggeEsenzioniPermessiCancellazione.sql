

-- =============================================
-- Author:		SimoneB
-- Create date: 20118-04-09
-- Description: Verifica se l'utente passato ha i permessi di cancellazione sulle esenzioni
-- =============================================
CREATE FUNCTION [dbo].[LeggeEsenzioniPermessiCancellazione]
	( 
	@Utente VARCHAR(64) = NULL
	)
RETURNS BIT
AS
BEGIN
	DECLARE @Ret AS BIT
	
	IF @Utente IS NULL
		SELECT @Ret = EU.[Cancellazione]
		FROM dbo.[EsenzioniUtenti] AS EU
		 INNER JOIN dbo.[Utenti] AS U ON EU.Utente = U.Utente
		WHERE 
			EU.[Utente]=USER_NAME()
			AND U.[Disattivato] = 0
			AND EU.[Disattivato] = 0
	ELSE
		SELECT @Ret=EU.[Cancellazione]
		FROM dbo.[EsenzioniUtenti] AS EU
			INNER JOIN [Utenti] AS U ON EU.[Utente] = U.[Utente]
		WHERE 
			EU.[Utente]=@Utente
			AND U.[Disattivato] = 0
			AND EU.[Disattivato] = 0
	
	RETURN ISNULL(@Ret, 0)
END