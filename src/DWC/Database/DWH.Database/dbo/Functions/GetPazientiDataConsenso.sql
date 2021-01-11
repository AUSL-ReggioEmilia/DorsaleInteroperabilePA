
-- =============================================
-- Author:		Ettore
-- Create date: 2010-05-06 
-- Modify date: 2016-06-29 sandro - Usa nuova vista
-- Description:	Ottiene la data del consenso
-- =============================================
CREATE FUNCTION [dbo].[GetPazientiDataConsenso]
	(@IdPaziente UNIQUEIDENTIFIER)
RETURNS DATETIME
AS
BEGIN
  	DECLARE @DataConsenso DATETIME
	
	SELECT @DataConsenso = DataStato
	FROM [sac].[PazientiConsensi]
	WHERE IdPaziente = @IdPaziente
		AND Stato = 1
		AND Descrizione = 'Generico'
	--
	-- Restituisco
	--
	RETURN @DataConsenso
END

