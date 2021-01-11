-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-08
-- Description:	Ritorna la lista dei ruoli per utente
-- =============================================
CREATE PROCEDURE [organigramma_ws].[RuoliOttieniPerUtente]
(
 @Utente varchar(128)
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		R.Id,
		R.Codice,
		R.Descrizione,
		R.Attivo
	FROM 
		[organigramma_ws].[RuoliUtenti] AS RU
	INNER JOIN
		organigramma.Ruoli as R ON RU.IdRuolo = R.Id
	--INNER JOIN organigramma_ws.Utenti as U ON RU.IdUtente = U.Id
	
	WHERE 
		RU.Utente = @Utente	
--		AND U.Attivo = 1
		AND R.Attivo = 1
	AND EXISTS (SELECT 1 FROM organigramma_ws.Utenti
				WHERE Utente = @Utente
				AND Attivo = 1)

	ORDER BY 
		RuoloCodice
	
END