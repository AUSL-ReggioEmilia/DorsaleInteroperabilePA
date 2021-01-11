
CREATE PROCEDURE [dbo].[FeprPrestazioniMatriceTestata]
(
	@IdPaziente as uniqueidentifier
)
AS
/*
	Ritorna i data anagrafica del paziente da visualizzare 
	in testata della lista dei suoi referti
*/
	SET NOCOUNT ON
	SELECT ID as IdPaziente,
		Cognome,	
		Nome,
		Convert(VarChar(20), DataNascita, 103) AS DataNascita,
		LuogoNascita,
		CodiceFiscale,
		CodiceSanitario
	FROM	
		dbo.Pazienti
	WHERE 
		Id = @IdPaziente


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprPrestazioniMatriceTestata] TO [ExecuteFrontEnd]
    AS [dbo];

