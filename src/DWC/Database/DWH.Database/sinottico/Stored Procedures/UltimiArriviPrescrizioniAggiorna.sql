

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-02-27
-- Description:	Aggiornamento tabella sinottico.UltimiArriviPrescrizioni
-- =============================================
CREATE PROCEDURE [sinottico].[UltimiArriviPrescrizioniAggiorna]
(
	@TipoPrescrizione VARCHAR(32)
)
AS
BEGIN 
	SET NOCOUNT ON;
	--
	-- Tento sempre l'aggiornamento
	--
	UPDATE sinottico.UltimiArriviPrescrizioni
		SET DataArrivo = GETDATE()
	WHERE TipoPrescrizione = @TipoPrescrizione
	--
	-- Se non ho aggiornato nulla inserisco
	--
	IF  @@ROWCOUNT = 0
	BEGIN 
		INSERT INTO sinottico.UltimiArriviPrescrizioni(TipoPrescrizione , DataArrivo)
		VALUES (@TipoPrescrizione, GETDATE())
	END 
END