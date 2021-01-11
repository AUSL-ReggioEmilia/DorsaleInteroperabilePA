
CREATE PROCEDURE [ws3].[LayerRefertiFormatiByTipoReferto]
(
	@AziendaErogante VARCHAR(16)
	, @SistemaErogante VARCHAR(16)
	, @RepartoErogante VARCHAR(64)
)
AS
BEGIN 
/*
	CREATA DA ETTORE 2016-03-22:
	E' uguale alla [ws2].[LayerRefertiFormatiByTipoReferto]
	Fornisce le possibili "formattazioni del referto" (=visualizzazione) per un determinato tipo di referto
	identificato da @AziendaErogante, @SistemaErogante, @RepartoErogante
*/
	DECLARE @TmpTable AS TABLE (Id UNIQUEIDENTIFIER, Descrizione VARCHAR(128))
	
	IF @RepartoErogante = '' SET @RepartoErogante = NULL
	--
	-- Prima cerco con AziendaErogante, SistemaErogante, RepartoErogante valorizzato (Condizione più restrittiva)
	-- 
	INSERT INTO @TmpTable(Id , Descrizione )
	SELECT DISTINCT
		RF.Id
		, RF.Descrizione 
	FROM 
		LayerRefertiFormati AS RF
		INNER JOIN LayerRefertiFormatiNameSpace AS RFN
			ON RFN.IdLayerRefertiFormati = RF.Id
	WHERE 
		AziendaErogante = @AziendaErogante 
		AND SistemaERogante = @SistemaErogante
		AND (RepartoErogante = @RepartoErogante)

	--
	-- Poi cerco solo per AziendaErogante, SistemaErogante, RepartoErogante = NULL
	--
	INSERT INTO @TmpTable(Id , Descrizione )
	SELECT DISTINCT
		RF.Id
		, RF.Descrizione 
	FROM 
		LayerRefertiFormati AS RF
		INNER JOIN LayerRefertiFormatiNameSpace AS RFN
			ON RFN.IdLayerRefertiFormati = RF.Id
	WHERE 
		AziendaErogante = @AziendaErogante 
		AND SistemaERogante = @SistemaErogante
		AND RepartoErogante IS NULL
	--
	-- Restituisco le possibili formattazioni del referto
	--
	SELECT 
		Id
		, Descrizione 
	FROM 
		@TmpTable

END