


CREATE PROCEDURE [dbo].[PazientiMsgSinonimiByIdPaziente]
	@IdPaziente AS uniqueidentifier

AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT 
		  PF.Id    
		, PF.IdPaziente
		, PF.IdPazienteFuso
		, PF.ProgressivoFusione
		, PF.Abilitato

	FROM
		PazientiFusioni PF
		
		INNER JOIN Pazienti P ON PF.IdPazienteFuso = P.Id
	
	WHERE     
			PF.IdPaziente = @IdPaziente
		AND PF.Abilitato = 1
		
	ORDER BY P.DataDisattivazione DESC

END;









GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgSinonimiByIdPaziente] TO [DataAccessDll]
    AS [dbo];

