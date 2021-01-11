



-- =============================================
-- Author:		ETTORE
-- Create date: 2018-07-16
-- Description:	Restituisce lista dei destinatari più usati da un mittente
-- =============================================
CREATE PROCEDURE [frontend].[EmailDestinatariPreferitiCerca]
(
	@Mittente AS VARCHAR(128) 
)
AS
BEGIN
	SET NOCOUNT ON;

	--Il TOP potrebbe essere letto da configurazione
	SELECT TOP 5
		Destinatario As Email
		, COUNT(*) AS Numero
	FROM 
		dbo.NotificheEmail
	WHERE 
		Mittente = @Mittente 
		 --La data di inserimento minima della mail potrebbe essere letta da configurazione
		AND DataInserimento > DATEADD(month, -6, GETDATE())
		AND NOT Destinatario like '%;%' --escludo destinatari multipli per sicurezza
	GROUP BY 
		Destinatario
	ORDER BY 
		COUNT(*) DESC 

END