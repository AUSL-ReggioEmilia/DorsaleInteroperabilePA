
CREATE PROCEDURE [dbo].[FeprRefertiStoricoTestata]
(
	@IdPaziente as uniqueidentifier
)
 AS
/*
	Restituisce i data anagrafici del paziente da visualizzare 
	in testata della lista dei suoi referti
*/
SET NOCOUNT ON

	SELECT 
		ID as IdPaziente,
		Cognome,	
		Nome,
		Convert(VarChar(20), DataNascita, 103) AS DataNascita,
		LuogoNascita,
		CodiceFiscale,
		CodiceSanitario
	FROM	
		Pazienti
	WHERE 
		Id = @IdPaziente


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiStoricoTestata] TO [ExecuteFrontEnd]
    AS [dbo];

