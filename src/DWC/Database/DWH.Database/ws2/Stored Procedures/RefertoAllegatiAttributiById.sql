
CREATE PROCEDURE [ws2].[RefertoAllegatiAttributiById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN
	/*
		CREATA DA ETTORE 2015-05-22:
			Sostituisce la dbo.Ws2RefertoAllegatiAttributiById
			
		Restituisce gli attributi delle prestazioni del referto con l'ID passato
		Questa SP dev essere utilizzata solo per ricavare il dettaglio del referto 
		Il controllo di accesso deve essere fatto sul record del referto, perchè questa SP restituisce tutti i record associati al referto.
		Utilizza la store.Allegati e la store.AllegatiAttributi

	*/
	SET NOCOUNT ON

	SELECT	AAR.IdAllegatiBase, 
			AAR.Nome,
			AAR.Valore
	FROM	
			store.AllegatiAttributiReferto as AAR
	WHERE	
		AAR.IdRefertiBase = @IdReferti

	RETURN @@ERROR
END
