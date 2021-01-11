


CREATE PROCEDURE [frontend].[MotiviAccessoLista]
AS
BEGIN 
/*

	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsMotiviAccessoLista
*/
	SET NOCOUNT ON;
	SELECT 
		Id
		, Descrizione
	FROM 
		MotiviAccesso
	ORDER BY 
		Ordine
END



