

CREATE VIEW [dbo].[PazientiDecedutiOutput]
AS
/*
	CREATA DA ETTORE 2014-05-26: Restituisce i pazienti deceduti
		La vista PazientiDecessi esegue traslazione da IdPaziente a IdPaziente attivo/padre
		Il DISTINCT è necessario poichè la funzione dbo.GetPazientiDataDecesso() può restituire
		lo stesso [IdPaziente, DataDecesso] per record differenti
*/
	SELECT DISTINCT 
		IdPaziente
		, [dbo].[GetPazientiDataDecesso](IdPaziente) AS DataDecesso 
	FROM 
		PazientiDecessi WITH(NOLOCK)
	

GO
GRANT SELECT
    ON OBJECT::[dbo].[PazientiDecedutiOutput] TO [DataAccessSql]
    AS [dbo];

