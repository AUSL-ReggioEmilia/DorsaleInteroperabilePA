
-- =============================================
-- Author:		Ettore
-- Create date: 2016-04-22
-- Create date: 2016-06-28 Calcolo consenso aziendale
--						   Query unica non funziona bene in ci sono condensi Generici acquisiti dopo il DossierStorico 
-- Create date: 2016-11-29 Sandro: Semplificata e split in due func
--
-- Description:	Restituisce il dati di consenso Sole
-- =============================================
CREATE FUNCTION [dbo].[OttieneConsensiSolePerIdPaziente]
(	
	@IdPaziente UNIQUEIDENTIFIER
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP 1
		  (CPA.IdTipo - 10) AS ConsensoSoleCodice
		, CPA.DataStato AS ConsensoSoleData
		, CT.Nome AS ConsensoSoleDescrizione
	FROM 
		dbo.ConsensiPazientiAggregati AS CPA
		INNER JOIN dbo.ConsensiTipo AS CT
			ON CT.Id = CPA.IdTipo
	WHERE 
		IdPaziente = @IdPaziente 
		AND Stato = 1			    --solo i consensi acquisiti (non negati)
		AND IdTipo IN (10,11,12)	--I consensi SOLE

	ORDER BY DataStato DESC, IdTipo DESC	
)