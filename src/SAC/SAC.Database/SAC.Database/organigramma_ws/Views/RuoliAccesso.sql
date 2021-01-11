

-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-08
-- Description:	Lista degli Accessi per ruolo
-- Modify date: 2017-03-31 Stefano P.: Ottimizzata
-- ================================================
CREATE VIEW [organigramma_ws].[RuoliAccesso]
AS
	SELECT
		r.ID AS IdRuolo,
		r.Codice AS RuoloCodice,
		ra.CodiceAccesso AS Accesso
	FROM 
		[organigramma].[Ruoli] r
	CROSS APPLY 
		[organigramma].[OttieneAccessiPerIdRuolo](r.Id) ra
	WHERE 
		r.[Attivo] = 1