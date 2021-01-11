-- =============================================
-- Author:		Ettore
-- Create date: 2015-11-12
-- Modify date: 2016-08-11 Sandro: Nuova struttura tabell ebase+attributi invece che XML
-- Description:	Restituisce la lista degli allegati associati alla prescrizione
-- =============================================
CREATE PROCEDURE [ws3].[PrescrizioneAllegatiById]
(
	@IdPrescrizione  uniqueidentifier
	, @DataPartizione SMALLDATETIME
)
AS
BEGIN
	SET NOCOUNT ON
	SELECT 	
		Id
		, IdPrescrizioniBase AS IdPrescrizioni
		, IdEsterno 
		, TipoContenuto
		, Contenuto
		, Attributi
	FROM	
		store.PrescrizioniAllegati
	WHERE	
		IdPrescrizioniBase= @IdPrescrizione
		AND DataPartizione = @DataPartizione

	RETURN @@ERROR
END