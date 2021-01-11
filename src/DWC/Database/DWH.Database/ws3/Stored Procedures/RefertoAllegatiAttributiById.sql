


CREATE PROCEDURE [ws3].[RefertoAllegatiAttributiById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN
	/*
		CREATA DA ETTORE 2016-03-22
		Restituisce gli attributi di TUTTI gli allegati associati al referto @IdReferti
		Questa SP dev essere utilizzata solo per ricavare il dettaglio del referto
		Il controllo di accesso deve essere fatto sul record del referto, perchè questa SP restituisce tutti i record associati al referto.
		Per questo motivo non c'è l'IdToken come parametro
	*/
	SET NOCOUNT ON

	SELECT	
		AAR.IdAllegatiBase 
		, AAR.Nome
		, AAR.Valore
	FROM	
		store.AllegatiAttributiReferto as AAR
	WHERE	
		AAR.IdRefertiBase = @IdReferti

END