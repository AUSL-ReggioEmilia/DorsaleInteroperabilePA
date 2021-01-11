

CREATE PROCEDURE [ws2].[RefertoPrestazioniAttributiById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertoPrestazioniAttributiById

	Restituisce gli attributi delle prestazioni del referto con l'ID passato
	
	Usa la vista store.PrestazioniAttributiReferto che restituisce 
	le UNION delle join fatte negli store 
*/
	SET NOCOUNT ON

	SELECT	IdPrestazioniBase, 
			Nome,
			Valore
	FROM	store.PrestazioniAttributiReferto
	WHERE	IdRefertiBase = @IdReferti

	RETURN @@ERROR
END 
