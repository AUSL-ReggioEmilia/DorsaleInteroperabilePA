


CREATE PROCEDURE [ws3].[RefertoPrestazioniAttributiById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-22:
		Restituisce TUTTI gli attributi delle PRESTAZIONI associate al referto @IdReferti
		Questa SP dev essere utilizzata solo per ricavare il dettaglio del referto
		Il controllo di accesso deve essere fatto sul record del referto per questo motivo non c'è il parametro @IdToken
*/
	SET NOCOUNT ON

	SELECT	
		IdPrestazioniBase, 
		Nome,
		Valore
	FROM	
		store.PrestazioniAttributiReferto
	WHERE	
		IdRefertiBase = @IdReferti

END