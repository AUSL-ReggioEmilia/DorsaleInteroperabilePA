
-- =============================================
-- Author:		SimoneB
-- Create date: 20118-04-09
-- Description: Restituisce la provenienza da EsenzioniUtenti
-- =============================================
CREATE FUNCTION [dbo].[LeggeEsenzioniProvenienza]
	( 
	@Utente VARCHAR(64) = NULL
	)
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(64)
	
	IF @Utente IS NULL
		SELECT @Ret= CU.[Provenienza] 
		FROM dbo.[EsenzioniUtenti] AS CU
		WHERE CU.[Utente] =USER_NAME()
	ELSE
		SELECT @Ret=CU.[Provenienza]
		FROM dbo.[EsenzioniUtenti] AS CU
		WHERE CU.[Utente] =@Utente
	
	RETURN NULLIF(@Ret, '')
END