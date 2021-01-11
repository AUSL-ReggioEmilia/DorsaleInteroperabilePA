CREATE PROCEDURE [dbo].[MntPazientiAnteprimaPurge]
(
	@MaxNumAnagraficheDaCancellare INTEGER = 1000
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RowCount INTEGER
	DECLARE @DateStart DATETIME
	
	IF @MaxNumAnagraficheDaCancellare IS NULL
		SET @MaxNumAnagraficheDaCancellare = 1000
		
	--
	-- Cancellazione delle anagrafiche NON ATTIVE
	--
	SET @RowCount = 0
	SET @DateStart = GETDATE()
	PRINT 'Inizio cancellazione anagrafiche: ' + CONVERT(VARCHAR(20) , @DateStart , 120)		
	DELETE FROM PazientiAnteprima 
	WHERE IdPaziente IN (
		SELECT TOP(@MaxNumAnagraficheDaCancellare)
			PA.IdPaziente 
		FROM 
			PazientiAnteprima AS PA WITH(NOLOCK)
			LEFT OUTER JOIN Pazienti AS P WITH(NOLOCK) --questa restituisce sole anagrafiche ATTIVE
				ON PA.IdPaziente = P.Id
		WHERE 
			P.Id IS NULL
		)
	SET @RowCount = @@ROWCOUNT
	PRINT 'Cancellate ' +  CAST( @RowCount AS VARCHAR(10)) + ' anagrafiche.' 
	PRINT 'Fine cancellazione anagrafiche : durata ' + CAST(DATEDIFF(ms, @DateStart ,GETDATE()) AS VARCHAR(10)) + ' ms'

END

