
-- =============================================
-- Author:		Ettore
-- Create date: 2013-06-07
-- Description:	Restituisce la descrizione associata allo stato in RicoveriBase.StatoCodice
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveriStatiDescrizione]
(
	@Id TINYINT
)
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @Ret VARCHAR(64)
	--
	--
	--	
	SELECT @Ret = Descrizione 
	FROM RicoveriStati 
	WHERE Id = @Id
	--
	-- Se non ho trovato una descrizione
	--
	IF @Ret IS NULL
		SET @Ret = 'Stato Sconosciuto'
	--
	-- Restituisco 
	--
	RETURN @Ret 
END
