

CREATE FUNCTION [dbo].[GetTreeFusione]
(
	@IdPazientePadre uniqueidentifier 
)
RETURNS 
@TempTable TABLE (
	  Id INT IDENTITY(1,1) NOT NULL
	, IdFiglio uniqueidentifier
	, IdPadre uniqueidentifier
	, Livello int
) 
AS
BEGIN
--
-- @IdPazientePadre può essere un padre qualsiasi (non solo la root della fusione) 
-- MODIFICA ETTORE 2017-02-01: aumentato il valore max del @Counter a 5000 (prima era 1000)
--

	declare @Counter int
	set @Counter = 0

	declare @IdFiglio uniqueidentifier
	declare @IdPadre uniqueidentifier
	declare @Livello int

	declare @IdStack int
	declare @tmpStack TABLE (
		  IdStack INT IDENTITY(1,1) NOT NULL
		, IdFiglio uniqueidentifier
		, IdPadre uniqueidentifier
		, Livello int
	) 
	--
	-- RICORDA:
	-- La tabella PazientiFusioni se filtrata per ProgressivoFusione=1 equivale ad un tree!!!
	--
	
	-- Inizializzo lo stack --questa restituisce CORRETTAMENTE uno o più record
	INSERT INTO @tmpStack (IdFiglio, IdPadre, Livello)
	SELECT IdPazienteFuso, IdPaziente, 0 AS Livello
	FROM PazientiFusioni with(nolock) WHERE IdPaziente = @IdPazientePadre and ProgressivoFusione=1
	
	WHILE (EXISTS(SELECT TOP 1 IdStack FROM @tmpStack)) and @Counter < 5000
	BEGIN
	
		set @Counter = @Counter + 1
		
		-- Estraggo dallo stack: leggo ultimo record inserito e lo cancello
		SELECT TOP 1 @IdStack=IdStack, @IdFiglio=IdFiglio, @IdPadre=IdPadre, @Livello = Livello
		FROM @tmpStack ORDER BY IdStack DESC
		
		DELETE FROM @tmpStack WHERE IdStack=@IdStack
		
		
		SET @Livello = @Livello  + 1
		-- Inserisco nello stack i figli del nodo corrente @Id
		INSERT INTO @tmpStack (IdFiglio, IdPadre, Livello)
		SELECT IdPazienteFuso, IdPaziente,  @Livello AS Livello
		FROM PazientiFusioni with(nolock) WHERE IdPaziente = @IdFiglio 
			and ProgressivoFusione=1

		--
		INSERT INTO @TempTable (IdFiglio, IdPadre, Livello)
		VALUES(@IdFiglio, @IdPadre, @Livello)

	END
	RETURN 
END


