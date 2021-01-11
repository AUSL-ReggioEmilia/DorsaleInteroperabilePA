


-- =============================================
-- Author:
-- Create date: 
-- Description: Ricerca multi parametro su RefertiBase e [SAC_Pazienti]
-- Modify date: 2015-02-04 Stefano: Aggiunta chiamata a GetRefertoCodiciOscuramento
-- Modify date: 2015-06-15 Stefano: Corretto ordinamento nella query con TOP
-- Modify date: 2015-07-10 Ettore:  Utilizzo dbo.GetRefertoCodiciOscuramento2(), lettura da store.referti
-- Modify date: 2017-03-09 Ettore:  Restituzione di tutti i referti associati alla catena di fusione
-- Modify date: 2018-06-07 Ettore:  Utilizzo della vista store.RefertiBase
-- =============================================
CREATE PROCEDURE [dbo].[BeRefertiLista]
(
	@idReferto UNIQUEIDENTIFIER = NULL,
	@idEsterno VARCHAR(64) = NULL,
	@idPaziente UNIQUEIDENTIFIER = NULL,
	@dataModificaDAL DATETIME = NULL,
	@dataModificaAL DATETIME = NULL,
	@aziendaErogante VARCHAR(16) = NULL,
	@sistemaErogante VARCHAR(16) = NULL,
	@repartoErogante VARCHAR(64) = NULL,
	@dataReferto DATETIME = NULL,
	@numeroReferto VARCHAR(16) = NULL,
	@numeroNosologico VARCHAR(64) = NULL,
	@numeroPrenotazione VARCHAR(32) = NULL,
	@Cognome  VARCHAR(64) = NULL,
	@Nome  VARCHAR(64) = NULL,
	@CodiceFiscale VARCHAR(16) = NULL,
	@DataNascita DATE = NULL,
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
		
	IF @idReferto IS NOT NULL 
	BEGIN 
		PRINT 'Ricerca per @idReferto'
		INSERT INTO @REF (ID, DataPartizione) 
		SELECT ID, DataPartizione
		FROM  store.RefertiBase WITH(NOLOCK)
		WHERE ID = @idReferto		
	END
	ELSE
	IF @idEsterno IS NOT NULL 
	BEGIN 
		PRINT 'Ricerca per @idEsterno'
		INSERT INTO @REF (ID, DataPartizione) 
		SELECT ID, DataPartizione
		FROM  store.RefertiBase WITH(NOLOCK)
		WHERE IdEsterno = @idEsterno
	END 
	ELSE 
	BEGIN
		PRINT 'Ricerca per filtri generici'	
		--
		-- CONSIDERO LA PRESENZA DI TUTTI GLI ALTRI FILTRI
		--

		IF @dataModificaAL IS NULL SET @dataModificaAL = GETDATE()
		SET @DTReferto_DAL  = CAST(@dataReferto AS DATE)  --TRONCO ORE E MINUTI
		SET @DTReferto_AL   = @DTReferto_DAL + ' 23:59:59'
		--PRINT '@DTReferto_DAL=' + ISNULL(CONVERT(VARCHAR(30) , @DTReferto_DAL , 120) , 'NULL')
		--PRINT '@DTReferto_AL=' + ISNULL(CONVERT(VARCHAR(30) , @DTReferto_AL , 120) , 'NULL')

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
		--PRINT '@IdPaziente=' + ISNULL(CAST(@IdPaziente AS VARCHAR(40)), 'NULL')
				
		INSERT INTO @REF (ID, DataPartizione)
		SELECT TOP (@MaxRow)
			R.Id, R.DataPartizione
		FROM  
			store.RefertiBase AS R WITH(NOLOCK)
			INNER JOIN dbo.[SAC_Pazienti] AS P WITH(NOLOCK) --Tutti i pazienti anche i figli
				ON R.IdPaziente = P.Id
		WHERE
			    (@dataModificaDAL    IS NULL OR R.DataModifica BETWEEN @dataModificaDAL AND @dataModificaAL)
			AND (@aziendaErogante    IS NULL OR R.AziendaErogante = @aziendaErogante)
			AND (@sistemaErogante    IS NULL OR R.SistemaErogante = @sistemaErogante)
			AND (@repartoErogante    IS NULL OR R.RepartoErogante LIKE '%' + @repartoErogante + '%')
			AND (@dataReferto        IS NULL OR R.DataReferto BETWEEN @DTReferto_DAL AND @DTReferto_AL)
			AND (@numeroReferto      IS NULL OR R.NumeroReferto = @numeroReferto)
			AND (@numeroNosologico   IS NULL OR R.NumeroNosologico = @numeroNosologico)
			AND (@numeroPrenotazione IS NULL OR R.NumeroPrenotazione = @numeroPrenotazione)
			--Filtri sulla parte anagrafica
			AND (@Cognome IS NULL OR P.Cognome LIKE @Cognome + '%')
			AND (@Nome IS NULL OR P.Nome LIKE @Nome + '%')
			AND (@CodiceFiscale IS NULL OR P.CodiceFiscale = @CodiceFiscale)
			AND (@DataNascita IS NULL OR P.DataNascita = @DataNascita)
			AND (
				@idPaziente IS NULL OR R.IdPaziente IN (SELECT Id FROM @TablePazienti)
				)
		ORDER BY 
			R.DataReferto DESC
		
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
		R.IdEsterno,
		R.IdPaziente,
		R.DataInserimento,
		R.DataModifica,
		R.AziendaErogante,
		R.SistemaErogante,
		R.RepartoErogante,
		R.DataReferto,
		R.NumeroReferto,
		R.NumeroNosologico,
		R.NumeroPrenotazione,
		P.Cognome AS Cognome,
		P.Nome AS Nome,
		P.CodiceFiscale AS CodiceFiscale,
		P.DataNascita AS DataNascita,
		P.ComuneNascitaNome AS ComuneNascita,
		P.Tessera AS CodiceSanitario,		
		RepartoRichiedenteCodice,
		RepartoRichiedenteDescr,
		CONVERT(VARCHAR(16), R.StatoRichiestaCodice) AS StatoRichiestaCodice,
		dbo.GetRefertoStatoDesc(R.RepartoErogante, StatoRichiestaCodice, '' ) AS StatoRichiestaDescr,
		dbo.GetRefertoCodiciOscuramento2 --recupero l'eventuale codice oscuramento
		(
			R.Id,  
			R.IdEsterno, 
			R.DataPartizione,
			R.AziendaErogante,
			R.SistemaErogante,
			R.StrutturaEroganteCodice,
			R.NumeroNosologico,
			R.RepartoRichiedenteCodice,
			R.RepartoErogante,
			R.NumeroPrenotazione,
			R.NumeroReferto,
			R.IdOrderEntry,
			R.Confidenziale
		) AS CodiceOscuramento
		
	FROM store.Referti R WITH(NOLOCK)
		INNER JOIN @Ref AS REF
			ON R.Id = REF.ID
			AND R.DataPartizione = REF.DataPartizione
		INNER JOIN dbo.[SAC_Pazienti] P WITH(NOLOCK) --Tutti i pazienti anche i figli
			ON R.IdPaziente = P.Id
	ORDER BY 
		R.DataReferto DESC
				
	PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'	

END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRefertiLista] TO [ExecuteFrontEnd]
    AS [dbo];

