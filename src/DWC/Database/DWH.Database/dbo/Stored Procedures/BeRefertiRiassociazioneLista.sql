
-- =============================================
-- Author:
-- Create date: 
-- Description: Ricerca multi parametro su RefertiBase e [SAC_Pazienti]
-- Modify date: 2015-02-04 Stefano: Ora utilizza GetRefertiAttributo2, corretto comportamento flag @RefertiOrfani
-- Modify date: 2015-06-15 Stefano: Corretto ordinamento nella query con TOP
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- =============================================
CREATE PROCEDURE [dbo].[BeRefertiRiassociazioneLista]
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
	@RefertiOrfani BIT = 0,
	@MaxRow INTEGER = 1000
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON	

	DECLARE
		@DTReferto_DAL  AS DATETIME,
		@DTReferto_AL   AS DATETIME
	DECLARE @REF AS TABLE (ID UNIQUEIDENTIFIER, DataPartizione SMALLDATETIME)
	DECLARE @T0 DATETIME
	
	IF @MaxRow IS NULL SET @MaxRow = 1000
	
	IF @idReferto IS NOT NULL 
	BEGIN 
		PRINT 'Ricerca per @idReferto'
		
		INSERT INTO @REF (ID, DataPartizione) 
		SELECT ID, DataPartizione
		FROM  store.RefertiBase WITH(NOLOCK)
		WHERE ID = @idReferto		
			AND ( 
				 (@RefertiOrfani = 1 AND IdPaziente ='00000000-0000-0000-0000-000000000000')
				 OR
				 (@RefertiOrfani = 0 AND (@idPaziente IS NULL OR IdPaziente = @idPaziente))
				)
	END
	ELSE
	IF @idEsterno IS NOT NULL 
	BEGIN 
		PRINT 'Ricerca per @idEsterno'
		
		INSERT INTO @REF (ID, DataPartizione) 
		SELECT ID, DataPartizione
		FROM  store.RefertiBase WITH(NOLOCK)
		WHERE IdEsterno = @idEsterno
			AND ( 
				 (@RefertiOrfani = 1 AND IdPaziente ='00000000-0000-0000-0000-000000000000')
				 OR
				 (@RefertiOrfani = 0 AND (@idPaziente IS NULL OR IdPaziente = @idPaziente))
				)
	END 
	ELSE 
	BEGIN
		PRINT 'Ricerca filtri generici'	
		--  
		-- CONSIDERO LA PRESENZA DI TUTTI GLI ALTRI FILTRI	  
		--
		IF @dataModificaDAL IS NOT NULL 
		BEGIN   	
			SET @dataModificaDAL = CAST(@dataModificaDAL AS DATE) --TRONCO ORE E MINUTI
			SET @dataModificaAL  = CAST(COALESCE(@dataModificaAL, GETDATE() ) AS DATE)
			SET @dataModificaAL  = @dataModificaAL + ' 23:59:59'
			--PRINT '@dataModificaDAL=' + ISNULL(CONVERT(VARCHAR(30) , @dataModificaDAL , 120), 'NULL')
			--PRINT '@dataModificaAL=' + ISNULL(CONVERT(VARCHAR(30) , @dataModificaAL , 120), 'NULL')
		END				
		SET @DTReferto_DAL  = CAST(@dataReferto AS DATE)  --TRONCO ORE E MINUTI
		SET @DTReferto_AL   = @DTReferto_DAL + ' 23:59:59'
		--PRINT '@DTReferto_DAL=' + ISNULL(CONVERT(VARCHAR(30) , @DTReferto_DAL , 120) , 'NULL')
		--PRINT '@DTReferto_AL=' + ISNULL(CONVERT(VARCHAR(30) , @DTReferto_AL , 120) , 'NULL')
			
		SET @T0 = GETDATE()
		
		INSERT INTO @REF (ID, DataPartizione) 
		SELECT TOP (@MaxRow)
			R.Id, R.DataPartizione
		FROM  
			store.RefertiBase AS R WITH(NOLOCK)		
		WHERE 			  
			    (@dataModificaDAL    IS NULL OR R.DataModifica BETWEEN @dataModificaDAL AND @dataModificaAL)
			AND (@aziendaErogante    IS NULL OR R.AziendaErogante = @aziendaErogante)
			AND (@sistemaErogante    IS NULL OR R.SistemaErogante = @sistemaErogante)
			AND (@repartoErogante    IS NULL OR R.RepartoErogante LIKE '%' + @repartoErogante + '%')
			AND (@dataReferto        IS NULL OR R.DataReferto BETWEEN @DTReferto_DAL AND @DTReferto_AL)
			AND (@numeroReferto      IS NULL OR R.NumeroReferto = @numeroReferto)
			AND (@numeroNosologico   IS NULL OR R.NumeroNosologico = @numeroNosologico)
			AND (@numeroPrenotazione IS NULL OR R.NumeroPrenotazione = @numeroPrenotazione)
			AND ( 
				 (@RefertiOrfani = 1 AND R.IdPaziente ='00000000-0000-0000-0000-000000000000')
				 OR
				 (@RefertiOrfani = 0 AND (@idPaziente IS NULL OR R.IdPaziente = @idPaziente))
				)
		ORDER BY 
			R.DataReferto DESC
		
		PRINT 'Durata: ' + CAST(DATEDIFF(millisecond, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'
	END
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
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( R.Id, R.DataPartizione, 'Cognome')) AS Cognome,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( R.Id, R.DataPartizione, 'Nome')) AS Nome,
		CONVERT(VARCHAR(1), dbo.GetRefertiAttributo2( R.Id, R.DataPartizione, 'Sesso')) AS Sesso,
		CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2( R.Id, R.DataPartizione, 'CodiceFiscale')) AS CodiceFiscale,
		dbo.GetRefertiAttributo2DateTime( R.Id, R.DataPartizione, 'DataNascita') AS DataNascita,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( R.Id, R.DataPartizione, 'ComuneNascita')) AS ComuneNascita,
		CONVERT(VARCHAR(4), dbo.GetRefertiAttributo2( R.Id, R.DataPartizione, 'ProvinciaNascita')) AS ProvinciaNascita,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( R.Id, R.DataPartizione, 'CodiceAnagraficaCentrale')) AS CodiceAnagraficaCentrale,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( R.Id, R.DataPartizione, 'NomeAnagraficaCentrale')) AS NomeAnagraficaCentrale,
	
	-- DATI LETTI DAL SAC :
		SAC.Cognome AS SACCognome,
		SAC.Nome AS SACNome,
		SAC.CodiceFiscale AS SACCodiceFiscale,
		SAC.DataNascita AS SACDataNascita,		
		CASE SAC.ComuneNascitaCodice
			WHEN '000000' THEN NULL
			ELSE SAC.ComuneNascitaNome
		END AS SACComuneNascita,		
		CASE SAC.ProvinciaNascitaNome 
			WHEN '??' THEN NULL
			ELSE SAC.ProvinciaNascitaNome
		END AS SACProvincaNascita,
	
		SAC.Provenienza as SACProvenienza,
		SAC.IdProvenienza as SACIdProvenienza		

	FROM store.RefertiBase R WITH(NOLOCK)
		INNER JOIN @Ref AS REF
			ON R.Id = REF.ID
			AND R.DataPartizione = REF.DataPartizione
			
		LEFT JOIN dbo.[SAC_Pazienti] SAC WITH(NOLOCK) 
			ON 	@RefertiOrfani = 0 
			AND	R.IdPaziente = SAC.Id
			
	ORDER BY 
		R.DataReferto DESC
	OPTION (RECOMPILE)
		
	PRINT 'Durata: ' + CAST(DATEDIFF(millisecond, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'	

END









GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRefertiRiassociazioneLista] TO [ExecuteFrontEnd]
    AS [dbo];

