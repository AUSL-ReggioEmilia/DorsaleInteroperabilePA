




-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-25
-- Description:	Calcolo della singola avvertenza 
--		@IdAvvertenza	--per ora non lo usiamo
--		@Query			--la query da eseguire
--		@Risultato		--l'avvertenza da restituire se @Query restituisce 1
--		@Avvertenza		--testo visualizzato nella UI
-- =============================================
CREATE PROCEDURE [dbo].[MntRefertiAvvertenzeCalcola]
(
@IdReferto UNIQUEIDENTIFIER
, @IdAvvertenza UNIQUEIDENTIFIER
, @Query NVARCHAR(MAX)
, @Risultato VARCHAR(1024)
, @Avvertenza  VARCHAR(1024) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @T0 DATETIME2
	DECLARE @ParmDefinition NVARCHAR(1024)		--definizione dei parametri della query: FISSI
	DECLARE @QueryExist NVARCHAR(MAX) = ''
	
	--Eseguo la QUERY 	
	DECLARE @Result BIT --il risultato della query: 0 o 1, true o false
	SET @ParmDefinition = N'@IdReferto UNIQUEIDENTIFIER, @Result BIT OUTPUT';

	SET @QueryExist = 'SET @Result = 0
		IF EXISTS(' + @Query +  ') 
		SET @Result = CAST(1 AS BIT)'
	
	SET @T0 = SYSDATETIME()

	EXECUTE sp_executesql @QueryExist, @ParmDefinition, @IdReferto = @IdReferto, @Result = @Result OUTPUT
	
	PRINT '    @IdAvvertenza=' + CAST(@IdAvvertenza AS VARCHAR(40)) +' Durata=' + CAST(DATEDIFF(ms, @T0, SYSDATETIME()) AS VARCHAR(10)) + ' ms'		
	
	--Restituisco l'avvertenza (@Risultato) se il risultato della query è 1
	IF @Result <> 0
		SET @Avvertenza = @Risultato 

END