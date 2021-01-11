


CREATE FUNCTION [dbo].[GetTreeFusioniLHA]
(
	@Padre numeric(10,0)
)

RETURNS 
@TempTable TABLE (
	  Id INT IDENTITY(1,1) NOT NULL
	, IdVittima numeric(10,0)
	, IdVincente numeric(10,0)
	, CodiceFiscaleVittima nvarchar(16)
	, CodiceFiscaleVincente nvarchar(16)
	, TimestampFusione datetime
) 
	
AS
BEGIN

	declare @IdVittima numeric(10,0)
	declare @IdVincente numeric(10,0)
	declare @CodiceFiscaleVittima nvarchar(16)
	declare @CodiceFiscaleVincente nvarchar(16)
	declare @TimestampFusione datetime
	
	declare @IdStack int
	declare @tmpStack TABLE (
		  IdStack INT IDENTITY(1,1) NOT NULL
		, IdVittima numeric(10,0)
		, IdVincente numeric(10,0)
		, CodiceFiscaleVittima nvarchar(16)
		, CodiceFiscaleVincente nvarchar(16)
		, TimestampFusione datetime
	) 
	
	-- Inizializzo lo stack
	INSERT INTO @tmpStack (IdVittima, IdVincente , CodiceFiscaleVittima, CodiceFiscaleVincente, TimestampFusione) 
	SELECT IdVittima, IdVincente , CodiceFiscaleVittima, CodiceFiscaleVincente, TimestampFusione
	FROM AppCn_Fusioni with(nolock) WHERE IdVincente = @Padre
	
	WHILE (EXISTS(SELECT TOP 1 IdStack FROM @tmpStack))
	BEGIN
		-- Estraggo dallo stack: leggo ultimo record inserito e lo cancello
		SELECT TOP 1 @IdStack=IdStack, @IdVittima=IdVittima, @IdVincente=IdVincente, @CodiceFiscaleVittima=CodiceFiscaleVittima, @CodiceFiscaleVincente=CodiceFiscaleVincente, @TimestampFusione=TimestampFusione
		FROM @tmpStack ORDER BY IdStack DESC
		
		DELETE FROM @tmpStack WHERE IdStack=@IdStack
		
		-- Inserisco nello stack i figli del nodo corrente @Id
		INSERT INTO @tmpStack (IdVittima, IdVincente , CodiceFiscaleVittima, CodiceFiscaleVincente, TimestampFusione) 
		SELECT IdVittima, IdVincente, CodiceFiscaleVittima, CodiceFiscaleVincente, TimestampFusione
		FROM AppCn_Fusioni with(nolock) WHERE IdVincente = @IdVittima

		--
		INSERT INTO @TempTable (IdVittima, IdVincente , CodiceFiscaleVittima, CodiceFiscaleVincente, TimestampFusione) 
		VALUES(@IdVittima, @IdVincente , @CodiceFiscaleVittima, @CodiceFiscaleVincente, @TimestampFusione)

	END
	RETURN 
END



