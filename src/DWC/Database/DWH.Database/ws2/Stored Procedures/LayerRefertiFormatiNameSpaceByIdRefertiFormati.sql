
CREATE PROCEDURE [ws2].[LayerRefertiFormatiNameSpaceByIdRefertiFormati]
(
	@IdLayerRefertiFormati UNIQUEIDENTIFIER
	, @NameSpace VARCHAR(64)
)
AS
BEGIN 
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2LayerRefertiFormatiNameSpaceByIdRefertiFormati
		
	Restituisce sempre un solo record contenente la trasformazione xslt 
	e il campo ElaboraDati (0=Dati DWH,1=Dati erogante) che indica quali dati del referto utilizzare 
	Se NON esiste un record per il namespace @NameSpace restituisce il record con NameSpace=NULL
	(che deve esistere sempre per qualsiasi @IdRefertiFormati)
*/

	DECLARE @TmpTable AS TABLE (IdLayerRefertiFormati UNIQUEIDENTIFIER, [NameSpace] VARCHAR(64), Xslt VARCHAR(MAX), ElaboraDati tinyint)
	--
	-- Restituisco le possibili formattazioni del referto
	--
	INSERT INTO @TmpTable (IdLayerRefertiFormati, [NameSpace] , Xslt , ElaboraDati)
	SELECT 
		IdLayerRefertiFormati
		, [NameSpace] 
		, Xslt 
		, ElaboraDati 
	FROM 
		LayerRefertiFormatiNameSpace 
	WHERE IdLayerRefertiFormati = @IdLayerRefertiFormati
		AND [NameSpace] = @NameSpace
	
	IF NOT EXISTS (SELECT * FROM @TmpTable) 
	BEGIN
		INSERT INTO @TmpTable (IdLayerRefertiFormati, [NameSpace] , Xslt , ElaboraDati)	
		SELECT 
			IdLayerRefertiFormati
			, [NameSpace] 
			, Xslt 
			, ElaboraDati 
		FROM 
			LayerRefertiFormatiNameSpace 
		WHERE IdLayerRefertiFormati = @IdLayerRefertiFormati
			AND [NameSpace] IS NULL
	END 
	--
	-- Restituisco
	--
	SELECT 
		IdLayerRefertiFormati
		, [NameSpace] 
		, Xslt 
		, ElaboraDati 
	FROM 
		@TmpTable 
		
END

