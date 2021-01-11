
-- =============================================
-- Author:		...
-- Create date: ...
-- Modify sate: 2016-05-26 Rimosso controllo accesso di lettura
-- Description:	Ritorna la lista dei sinonimi
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputSinonimiByIdPaziente]
	@IdPaziente uniqueidentifier

AS
BEGIN

DECLARE @Identity AS varchar(64)

	SET NOCOUNT ON;

	IF @IdPaziente IS NULL
	BEGIN
		RAISERROR('Il parametro IdPaziente non può essere NULL!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	-- La subquery ha lo scopo di ritornare un set di dati univoco dato che la join con la tabella pazienti
	-- potrebbe, se esistono pazienti aventi provenienza ed idprovenienza uguali nello stato fuso, duplicare i dati
	SELECT 
		Q.IdPaziente, Q.Provenienza, Q.IdProvenienza
	FROM (
		SELECT 
			  O.IdPaziente
			, O.Provenienza
			, O.IdProvenienza
			, MAX(P.DataDisattivazione) AS DataDisattivazione
			
		FROM
			dbo.PazientiSinonimiSpResult O
			
			INNER JOIN Pazienti P ON O.Provenienza = P.Provenienza AND O.IdProvenienza = P.IdProvenienza
		
		WHERE     
				O.IdPaziente = @IdPaziente
			AND O.Abilitato = 1
			AND P.Disattivato = 2
			
		GROUP BY 
			O.IdPaziente, O.Provenienza, O.IdProvenienza		
	) AS Q
	
	ORDER BY 
		Q.DataDisattivazione DESC

END











GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputSinonimiByIdPaziente] TO [DataAccessSql]
    AS [dbo];

