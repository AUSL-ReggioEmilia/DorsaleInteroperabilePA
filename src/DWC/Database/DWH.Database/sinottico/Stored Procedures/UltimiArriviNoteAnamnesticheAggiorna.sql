﻿-- =============================================
-- Author:		ETTORE
-- Create date: 2020-02-27
-- Description:	Aggiornamento tabella sinottico.UltimiArriviNoteAnamnestiche
-- =============================================
CREATE PROCEDURE [sinottico].[UltimiArriviNoteAnamnesticheAggiorna]
(
	@AziendaErogante VARCHAR(16)
	, @SistemaErogante VARCHAR(16)
)
AS
BEGIN 
	SET NOCOUNT ON;
	--
	-- Tento sempre l'aggiornamento
	--
	UPDATE sinottico.UltimiArriviNoteAnamnestiche
		SET DataArrivo = GETDATE()
	WHERE AziendaErogante = @AziendaErogante AND SistemaErogante = @SistemaErogante
	--
	-- Se non ho aggiornato nulla inserisco
	--
	IF  @@ROWCOUNT = 0
	BEGIN 
		INSERT INTO sinottico.UltimiArriviNoteAnamnestiche(AziendaErogante, SistemaErogante, DataArrivo)
		VALUES (@AziendaErogante, @SistemaErogante, GETDATE())
	END 
END