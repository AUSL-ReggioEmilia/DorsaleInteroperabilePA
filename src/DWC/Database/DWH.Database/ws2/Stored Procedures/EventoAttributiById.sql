
CREATE PROCEDURE [ws2].[EventoAttributiById]
(
	@IdEventi  uniqueidentifier
)
AS
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2EventoAttributiById
		Usa la vista store.EventiAttributi
		Restituisce gli attributi dell'Evento con Id = @IdEventi
*/
	SET NOCOUNT ON

	SELECT	
			IdEventiBase, 
			Nome,
			Valore
	FROM	
			store.EventiAttributi
	WHERE	
			IdEventiBase = @IdEventi

	RETURN @@ERROR

