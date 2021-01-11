


CREATE PROCEDURE [dbo].[PazientiMsgSinonimiSelectAll]
	@Id AS uniqueidentifier
AS
BEGIN

	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	/*
	SELECT     
		  PS.Id
		, PS.Provenienza
		, PS.IdProvenienza
		
	FROM
		PazientiSinonimi PS
		
		INNER JOIN Pazienti P ON PS.Provenienza = P.Provenienza AND PS.IdProvenienza = P.IdProvenienza
		
	WHERE     
			PS.IdPaziente = @Id
		AND PS.Abilitato = 1

	ORDER BY P.DataDisattivazione DESC
	*/
	
	-- La subquery ha lo scopo di ritornare un set di dati univoco dato che la join con la tabella pazienti
	-- potrebbe, se esistono pazienti aventi provenienza ed idprovenienza uguali nello stato fuso, duplicare i dati
	SELECT 
		Q.Id, Q.Provenienza, Q.IdProvenienza
	FROM (
		SELECT 
			  PS.Id
			, PS.Provenienza
			, PS.IdProvenienza
			, MAX(P.DataDisattivazione) AS DataDisattivazione
			
		FROM
			PazientiSinonimi PS
			
			INNER JOIN Pazienti P ON PS.Provenienza = P.Provenienza AND PS.IdProvenienza = P.IdProvenienza
		
		WHERE     
				PS.IdPaziente = @Id
			AND PS.Abilitato = 1
			AND P.Disattivato = 2
			
		GROUP BY 
			PS.Id, PS.Provenienza, PS.IdProvenienza		
	) AS Q
	
	ORDER BY 
		Q.DataDisattivazione DESC	

END;






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgSinonimiSelectAll] TO [DataAccessDll]
    AS [dbo];

