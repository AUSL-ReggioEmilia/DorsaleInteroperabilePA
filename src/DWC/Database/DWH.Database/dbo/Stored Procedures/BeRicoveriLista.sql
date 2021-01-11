




-- =============================================
-- Author:		Simone Bitti
-- Create date: 2017-03-09
-- Description: Ricerca multi parametro su RicoveriBase e [SAC_Pazienti]
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- =============================================
CREATE PROCEDURE [dbo].[BeRicoveriLista]
(
	@Id UNIQUEIDENTIFIER = NULL,
	@AziendaErogante VARCHAR(16) = NULL,
	@NumeroNosologico VARCHAR(64) = NULL,
	@Cognome  VARCHAR(64) = NULL,
	@Nome  VARCHAR(64) = NULL,
	@CodiceFiscale VARCHAR(16) = NULL,
	@DataNascita DATE = NULL,
	@dataModificaDAL DATETIME = NULL,
	@dataModificaAL DATETIME = NULL,
	@idPaziente UNIQUEIDENTIFIER = NULL,
	@MaxRow INTEGER = 1000
)
--WITH RECOMPILE -- VIENE IMPOSTATO NEL SINGOLO STATEMENT DOVE SERVE REALMENTE
AS
BEGIN
	SET NOCOUNT ON	

	DECLARE @T0 DATETIME = GETDATE()
	DECLARE	@DTReferto_DAL DATETIME
	DECLARE	@DTReferto_AL  DATETIME
	DECLARE @REF TABLE (ID UNIQUEIDENTIFIER, DataPartizione SMALLDATETIME)

	IF (@MaxRow IS NULL) OR (@MaxRow > 1000) SET @MaxRow = 1000
		
	IF @Id IS NOT NULL 
	BEGIN 
		PRINT 'Ricerca per @IdRicovero'
		INSERT INTO @REF (ID, DataPartizione) 
		SELECT ID, DataPartizione
		FROM  store.RicoveriBase WITH(NOLOCK)
		WHERE ID = @Id		
	END
	ELSE
	IF @AziendaErogante IS NOT NULL AND @NumeroNosologico IS NOT NULL 
	BEGIN 
		PRINT 'Ricerca per @AziendaErogante e @NumeroNosologico'
		INSERT INTO @REF (ID, DataPartizione) 
		SELECT ID, DataPartizione
		FROM  store.RicoveriBase WITH(NOLOCK)
		WHERE AziendaErogante = @AziendaErogante
			AND NumeroNosologico = @NumeroNosologico
	END 
	ELSE 
	BEGIN
		PRINT 'Ricerca per filtri generici'
		IF @dataModificaAL IS NULL SET @dataModificaAL = GETDATE()

		--
		-- Trovo il padre della catena di fusione e la lista dei fusi + l'attivo
		-- 
		DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
		IF NOT @IdPaziente IS NULL
		BEGIN 
			SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
			INSERT INTO @TablePazienti(Id)
			SELECT Id FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)	
		END 

						
		INSERT INTO @REF (ID, DataPartizione)
		SELECT TOP (@MaxRow)
			R.Id, R.DataPartizione
		FROM  
			store.RicoveriBase AS R WITH(NOLOCK)
			INNER JOIN dbo.[SAC_Pazienti] AS P WITH(NOLOCK) --Tutti i pazienti anche i figli
				ON R.IdPaziente = P.Id
		WHERE (@Cognome IS NULL OR P.Cognome LIKE @Cognome + '%')
			AND (@Nome IS NULL OR P.Nome LIKE @Nome + '%')
			AND (@CodiceFiscale IS NULL OR P.CodiceFiscale = @CodiceFiscale)
			AND (@DataNascita IS NULL OR P.DataNascita = @DataNascita)
			AND (
				@idPaziente IS NULL OR R.IdPaziente IN (SELECT Id FROM @TablePazienti)
				)
			AND  (@dataModificaDAL    IS NULL OR R.DataModifica BETWEEN @dataModificaDAL AND @dataModificaAL)

		ORDER BY 
			R.DataModifica DESC
		
		OPTION (RECOMPILE)		
	
	END
	
	PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'
		
	--
	-- QUERY DI OUTPUT		
	--
	PRINT 'Esecuzione query di output'
	SET @T0 = GETDATE()	
	
	SELECT 
		R.ID,
		R.IdPaziente,
		R.DataInserimento,
		R.DataModifica,
		R.AziendaErogante,
		R.SistemaErogante,
		R.RepartoErogante,
		--R.DataReferto,
		--R.NumeroReferto,
		R.NumeroNosologico,
		--R.NumeroPrenotazione,
		P.Cognome AS Cognome,
		P.Nome AS Nome,
		P.CodiceFiscale AS CodiceFiscale,
		P.DataNascita AS DataNascita,
		P.ComuneNascitaNome AS ComuneNascita,
		P.Tessera AS CodiceSanitario,		
		--RepartoRichiedenteCodice,
		--RepartoRichiedenteDescr,
		R.RepartoErogante,
		R.StatoCodice,
		dbo.GetRicoveroCodiciOscuramento(
			R.AziendaErogante,
			R.NumeroNosologico
		) AS CodiceOscuramento
		
	FROM store.Ricoveri R WITH(NOLOCK)
		INNER JOIN @Ref AS REF
			ON R.Id = REF.ID
			AND R.DataPartizione = REF.DataPartizione
		INNER JOIN dbo.[SAC_Pazienti] P WITH(NOLOCK) --Tutti i pazienti anche i figli
			ON R.IdPaziente = P.Id
	ORDER BY 
		R.DataModifica DESC
				
	PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'	

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRicoveriLista] TO [ExecuteFrontEnd]
    AS [dbo];

