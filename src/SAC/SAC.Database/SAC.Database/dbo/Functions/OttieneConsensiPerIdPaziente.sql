

-- =============================================
-- Author:		Ettore
-- Create date: 2016-04-22
-- Create date: 2016-06-28 Calcolo consenso aziendale
--						   Query unica non funziona bene in ci sono condensi Generici acquisiti dopo il DossierStorico
--
--	DISMESSA 2016-11-26 Non efficente per una vista publica
--
-- Description:	Restituisce il dati di consenso Aziendale e Sole
-- =============================================
CREATE FUNCTION [dbo].[OttieneConsensiPerIdPaziente]
(	
	@IdPaziente UNIQUEIDENTIFIER
)
RETURNS @Table TABLE
(
	IdConsensoAziendale		INTEGER,
	ConsensoAziendaleData	DATETIME,
	ConsensoAziendaleDescrizione VARCHAR(64),
	IdConsensoSole			INTEGER,
	ConsensoSoleData		DATETIME,
	ConsensoSoleDescrizione VARCHAR(64)
)
AS
BEGIN
	DECLARE @IdConsensoSole		INTEGER
	DECLARE @ConsensoSoleData		DATETIME
	DECLARE @ConsensoSoleDescrizione VARCHAR(64)
	DECLARE @IdConsensoAziendale INTEGER
	DECLARE @ConsensoAziendaleData	DATETIME
	DECLARE @ConsensoAziendaleDescrizione VARCHAR(64)
	
	---------------------------------------------------
	-- Cerco il consenso aziendale
	---------------------------------------------------
	DECLARE @TabConsensiPaziente TABLE (IdTipo TINYINT, DataStato DATETIME, Nome VARCHAR(64))
	--
	-- Carico nella tabella temporanea i consensi aziendali del paziente a stato Attivo (Stato=1)
	--	
	INSERT INTO @TabConsensiPaziente (IdTipo, DataStato, Nome)
	SELECT
		CPA.IdTipo
		, CPA.DataStato
		, CT.Nome
	FROM 
		dbo.ConsensiPazientiAggregati AS CPA
		INNER JOIN dbo.ConsensiTipo AS CT
			ON CT.Id = CPA.IdTipo
	WHERE 
		IdPaziente = @IdPaziente 
		AND Stato = 1			--solo i consensi acquisiti (non negati)
		AND IdTipo IN (1,2,3)	--I consensi aziendali GENERICO, DOSSIER, DOSSIERSTORICO

	IF EXISTS(SELECT * FROM @TabConsensiPaziente WHERE IdTipo = 1 )
	BEGIN 
		SET @IdConsensoAziendale = 1
		IF EXISTS(SELECT * FROM @TabConsensiPaziente WHERE IdTipo = 2 )
		BEGIN
			SET @IdConsensoAziendale = 2
			IF EXISTS(SELECT * FROM @TabConsensiPaziente WHERE IdTipo = 3 )
			BEGIN 
				SET @IdConsensoAziendale = 3
			END 
		END 
	END 
	--
	-- Se ho trovato un consenso aziendale cerco la data di acquisizione e il suo nome
	--
	IF NOT @IdConsensoAziendale IS NULL
	BEGIN 
		SELECT 
			@ConsensoAziendaleData=DataStato, 
			@ConsensoAziendaleDescrizione=Nome 
		FROM @TabConsensiPaziente 
		WHERE IdTipo = @IdConsensoAziendale
	END

	---------------------------------------------------
	-- Ricavo il consenso SOLE (livello SOLE))
	---------------------------------------------------
	SELECT TOP 1 
		@IdConsensoSole	= (CPA.IdTipo) - 10
		, @ConsensoSoleData = CPA.DataStato
		, @ConsensoSoleDescrizione = CT.Nome
	FROM 
		dbo.ConsensiPazientiAggregati AS CPA
		INNER JOIN dbo.ConsensiTipo AS CT
			ON CT.Id = CPA.IdTipo
	WHERE 
		IdPaziente = @IdPaziente 
		AND Stato = 1						--solo i consensi acquisiti (non negati)
		AND (10 <= IdTipo AND IdTipo <= 12) --I consensi SOLE: SOLE-LIVELLO0, SOLE-LIVELLO1, SOLE-LIVELLO2

	ORDER BY DataStato DESC, IdTipo DESC	
	--
	-- Restituisco i dati di consenso
	--
	INSERT INTO @Table
	SELECT @IdConsensoAziendale 
		, @ConsensoAziendaleData 
		, @ConsensoAziendaleDescrizione 
		, @IdConsensoSole 
		, @ConsensoSoleData 
		, @ConsensoSoleDescrizione 
	
	RETURN 
END