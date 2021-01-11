


-- =============================================
-- Author:		ETTORE
-- Create date: 2020-01-30
-- Description:	Restituisce la lista delle provenienze ricercabili da WS
-- Modify date: 2020-04-09 - ETTORE: Ricerca Pazienti Solo Propri per Provenienza da WS [ASMN 8017]
--									Se il campo SoloPropriWS=1 allora la function restituisce solo la provenienza @ProvenienzaCorrente
-- =============================================
CREATE FUNCTION [dbo].[OttieneProvenienzeRicercabiliWs]
(	
	@ProvenienzaCorrente VARCHAR(16) 
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT Provenienza 
	FROM dbo.Provenienze 
	WHERE 
		(
			--
			-- Restituisce tutte le provenienze ricercabili
			-- se non specificato di usare solo la propria provenienza (SoloPropriWS=1)
			--
			DisabilitaRicercaWS = 0
			AND (SELECT SoloPropriWs FROM dbo.Provenienze WHERE Provenienza = @ProvenienzaCorrente) = 0
		)
		--
		-- Aggiungo la @ProvenienzaCorrente alla lista delle provenienze ricercabili
		--
		OR Provenienza = @ProvenienzaCorrente 
)