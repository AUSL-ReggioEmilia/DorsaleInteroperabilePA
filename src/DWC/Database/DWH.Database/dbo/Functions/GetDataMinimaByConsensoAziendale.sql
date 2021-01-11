

-- =============================================
-- Author:		Ettore
-- Create date: 2016-04-28
-- Modify date: 2017-01-17 - ETTORE: Se ConsensoAziendale=2(ConsensoDossier) e @DataDal è precedente alla data del Consenso Dossier allora la data minima è quella del Consenso Dossier
-- Description:	Fornisce la data minima da cui far partire le ricerche in base al consenso aziendale (GENERICO, DOSSIER, DOSSIERSTORICO)
-- =============================================
CREATE FUNCTION [dbo].[GetDataMinimaByConsensoAziendale]
(
	@DataDal					DATETIME				
	, @IdConsensoAziendale		INT
	, @ConsensoAziendaleData	DATETIME
)
RETURNS DATETIME
AS
BEGIN
/*
	Il filtro basato sul consenso determina la data minima di ricerca da usare nelle query.
		1-GENERICO: non si deve vedere nulla -> DataMinima = GETDATE()+10 anni
		2-DOSSIER: DataMinima = DataAcquisizione DOSSIER
		2-DOSSIERSTORICO: DataMinima = @DataDal 
*/
	DECLARE @DataMinima DATETIME = NULL
	--
	-- In base ai diversi tipi di consenso aziendale
	--
	IF (@IdConsensoAziendale IS NULL ) OR @IdConsensoAziendale = 1 --GENERICO
		--aggiungo 10 anni a oggi, non esistono oggetti con questa data nel database
		--lo store più recente accetta una "data partizione" = anno corrente + 1
		--In questo modo le query non restituiscono nulla
		SET @DataMinima = DATEADD(year, 10, GETDATE()) 
	ELSE IF (@IdConsensoAziendale = 2) --DOSSIER
	BEGIN
		----Le query restituiranno dati a partire dalla data @ConsensoAziendaleData
		--SET @DataMinima = @ConsensoAziendaleData
		--Se @DataDal è precedente alla data del Consenso Dossier allora la data minima è quella del Consenso Dossier
		IF @DataDal < @ConsensoAziendaleData
			SET @DataMinima = @ConsensoAziendaleData
		ELSE 
			SET @DataMinima = @DataDal 
	END
	ELSE IF (@IdConsensoAziendale = 3) --DOSSIERSTORICO
		--Le query restituiranno dati a partire dalla data @DataDal, che è quella passata alle SP
		SET @DataMinima = @DataDal 
	--
	-- Restituisco la data minima
	--
	RETURN @DataMinima
END