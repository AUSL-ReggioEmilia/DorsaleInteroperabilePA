
-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 - ETTORE: usato le viste "store" al posto delle viste "dbo"
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[MntSpecialitaEroganteLABAggiungi]
(
@DateStart AS DATETIME,
@DateEnd AS DATETIME
)
AS
BEGIN
	DECLARE @IdReferto AS uniqueidentifier
	DECLARE @DataPartizione as smalldatetime
	DECLARE @PrestTipo_MIC AS BIT
	DECLARE @PrestTipo_LACC AS BIT
	DECLARE @SpecialitaErogante AS VARCHAR(50)

	--
	-- Aggiusto le date
	--
	IF @DateStart IS NULL 
		SET @DateStart = CAST(CONVERT(varchar(10), GETDATE() , 120) AS DATETIME)
	IF @DateEnd IS NULL 
		SET @DateEnd = GETDATE()
	SET @DateEnd = DATEADD(day, 1, @DateEnd)
	--
	-- Cursore
	--
	DECLARE CursorReferti CURSOR
	READ_ONLY
	FOR 
	SELECT
		Ref.Id AS IdReferto 
		, Ref.DataPartizione
	FROM store.RefertiBase Ref (nolock)
		 LEFT OUTER JOIN store.RefertiAttributi RefAtt (nolock)
			ON Ref.Id = RefAtt.IdRefertiBase and RefAtt.Nome = 'SpecialitaErogante'
	WHERE
		(RefAtt.IdRefertiBase IS NULL)
		AND 
		(Ref.SistemaErogante = 'LAB')
		AND 
		(Ref.DataReferto BETWEEN @DateStart AND @DateEnd)
	--
	-- Apro il cursore
	--
	OPEN CursorReferti
	FETCH NEXT FROM CursorReferti INTO @IdReferto, @DataPartizione 
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			--
			-- Verifico se esistono prestazioni con attributo PrestTipo con valore 'm'
			--
			SET @PrestTipo_MIC = 0
			IF 	EXISTS( SELECT TOP 1 prt.Id FROM store.Prestazioni prt (nolock) INNER JOIN store.PrestazioniAttributi AS prtAtt (nolock) ON prtAtt.IdPrestazioniBase = prt.Id
						WHERE (prt.IdRefertiBase = @Idreferto) and (prtAtt.Nome = 'PrestTipo') and (isnull(prtAtt.Valore,'') =  'm') )
				SET @PrestTipo_MIC = 1
			--
			-- Verifico se esistono prestazioni con attribito PrestTipo <> 'm' o senza attributo PrestTipo
			-- Attributo PrestTipo mancante equivale ad una prestazione con attributo PrestTipo con valore <> 'm'
			--
			SET @PrestTipo_LACC = 0
			IF 	EXISTS( SELECT TOP 1 prt.Id FROM store.Prestazioni prt (nolock) LEFT OUTER JOIN store.PrestazioniAttributi (nolock) AS prtAtt 
						ON prtAtt.IdPrestazioniBase = prt.Id  and (prtAtt.Nome = 'PrestTipo') 
						WHERE (prt.IdRefertiBase = @Idreferto) and (ISNULL(prtAtt.Nome,'PrestTipo') = 'PrestTipo') and (isnull(prtAtt.Valore,'') <>  'm') )
				SET @PrestTipo_LACC = 1
			--
			-- Valorizzo la specialità erogante
			--
			SET @SpecialitaErogante = 'LACC'
			IF @PrestTipo_MIC = 1 AND @PrestTipo_LACC = 1
				SET @SpecialitaErogante = 'LACC_MIC'
			ELSE
			IF @PrestTipo_MIC = 1 AND @PrestTipo_LACC = 0
				SET @SpecialitaErogante = 'MIC'
			ELSE
			IF @PrestTipo_MIC = 0 AND @PrestTipo_LACC = 1
				SET @SpecialitaErogante = 'LACC'
			ELSE
			IF @PrestTipo_MIC = 0 AND @PrestTipo_LACC = 0
				SET @SpecialitaErogante = 'LACC'
			--
			-- Aggiungo l'anteprima agli attributi del referto
			--
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES(@IdReferto, 'SpecialitaErogante', @SpecialitaErogante, @DataPartizione )
			--			
			-- DEBUG: Visualizza come verrebbe valorizzato l'attributo SpecialitaErogante per il referto corrente
			--
--			PRINT '@IdReferto=' + CAST(@IdReferto AS VARCHAR(40)) + ' @PrestTipo_MIC=' + CAST(@PrestTipo_MIC AS VARCHAR(1)) + ' @PrestTipo_LACC=' +  CAST(@PrestTipo_LACC AS VARCHAR(1)) + ' @SpecialitaErogante=' + @SpecialitaErogante

		END
		FETCH NEXT FROM CursorReferti INTO @IdReferto, @DataPartizione 
	END
	CLOSE CursorReferti
	DEALLOCATE CursorReferti

END
