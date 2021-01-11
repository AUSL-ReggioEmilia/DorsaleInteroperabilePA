

-- =============================================
-- Author:	SimoneB
-- Create date: 2017-11-29
-- Description: Ricerca multi parametro su NoteAnamnesticheBase e [SAC_Pazienti] per la riassociazione delle note anamnestiche.
-- =============================================
CREATE PROCEDURE [dbo].[BevsNoteAnamnesticheRiassociazioneLista]
(
	@IdNota UNIQUEIDENTIFIER = NULL,
	@idEsterno VARCHAR(64) = NULL,
	@idPaziente UNIQUEIDENTIFIER = NULL,
	@dataModificaDAL DATETIME = NULL,
	@dataModificaAL DATETIME = NULL,
	@aziendaErogante VARCHAR(16) = NULL,
	@sistemaErogante VARCHAR(16) = NULL,
	@dataNota DATETIME = NULL,
	@NoteAnamnesticheOrfane BIT = 0,
	@MaxRow INTEGER = 1000
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON	

	--
	--DICHIARO LE VARIBAILI @DTNota_DAL e @DTNota_AL.
	--
	DECLARE
		@DTNota_DAL  AS DATETIME,
		@DTNota_AL   AS DATETIME

	--
	--DICHIARO LA TABELLA TEMPORANEA "NOTE".
	--
	DECLARE @NOTE AS TABLE (ID UNIQUEIDENTIFIER, DataPartizione SMALLDATETIME)

	DECLARE @T0 DATETIME
	
	--
	--SE @MAXROW E' VUOTO ALLORA IMPOSTO 1000.
	--
	IF @MaxRow IS NULL SET @MaxRow = 1000
	
	--
	--SE IDNOTA NON E' VUOTA ALLORA ESEGUO LA RICERCA PER ID DELLA NOTA
	--
	IF @IdNota IS NOT NULL 
		BEGIN 
			PRINT 'Ricerca per @IdNota'
		
			INSERT INTO @NOTE (ID, DataPartizione) 
			SELECT ID, DataPartizione
			FROM  store.NoteAnamnesticheBase WITH(NOLOCK)
			WHERE ID = @IdNota		
				AND ( 
					 (@NoteAnamnesticheOrfane = 1 AND IdPaziente ='00000000-0000-0000-0000-000000000000')
					 OR
					 (@NoteAnamnesticheOrfane = 0 AND (@idPaziente IS NULL OR IdPaziente = @idPaziente))
					)
		END
	--
	--SE ID ESTERNO E' VALORIZZATO ALLORA ESEGUO LA RICERCA PER ID ESTERNO
	--
	ELSE IF @idEsterno IS NOT NULL 
		BEGIN 
			PRINT 'Ricerca per @idEsterno'
		
			INSERT INTO @NOTE (ID, DataPartizione) 
			SELECT ID, DataPartizione
			FROM  store.NoteAnamnesticheBase WITH(NOLOCK)
			WHERE IdEsterno = @idEsterno
				AND ( 
					 (@NoteAnamnesticheOrfane = 1 AND IdPaziente ='00000000-0000-0000-0000-000000000000')
					 OR
					 (@NoteAnamnesticheOrfane = 0 AND (@idPaziente IS NULL OR IdPaziente = @idPaziente))
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
			END		
				
			--
			--VALORIZZO LE VARIABILI DATA NOTA DAL E AL.
			--
			SET @DTNota_DAL  = CAST(@dataNota AS DATE)  --TRONCO ORE E MINUTI
			SET @DTNota_AL   = @DTNota_DAL + ' 23:59:59'
			
			SET @T0 = GETDATE()
		
			
			INSERT INTO @NOTE (ID, DataPartizione) 
			SELECT TOP (@MaxRow)
				R.Id, R.DataPartizione
			FROM  
				store.NoteAnamnesticheBase AS R WITH(NOLOCK)		
			WHERE (@dataModificaDAL IS NULL OR R.DataModifica BETWEEN @dataModificaDAL AND @dataModificaAL)
				AND (@aziendaErogante IS NULL OR R.AziendaErogante = @aziendaErogante)
				AND (@sistemaErogante IS NULL OR R.SistemaErogante = @sistemaErogante)
				AND (@dataNota IS NULL OR R.DataNota BETWEEN @DTNota_DAL AND @DTNota_AL)
				AND ( 
					 (@NoteAnamnesticheOrfane = 1 AND R.IdPaziente ='00000000-0000-0000-0000-000000000000')
					 OR
					 (@NoteAnamnesticheOrfane = 0 AND (@idPaziente IS NULL OR R.IdPaziente = @idPaziente))
					)
			ORDER BY 
				R.DataNota DESC
		
			PRINT 'Durata: ' + CAST(DATEDIFF(millisecond, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'
	END
	--
	-- QUERY DI OUTPUT		
	--
	PRINT 'Esecuzione query di output'
	SET @T0 = GETDATE()	
	
	SELECT 
		NA.ID,
		NA.IdEsterno,
		NA.IdPaziente,
		NA.DataInserimento,
		NA.DataModifica,
		NA.AziendaErogante,
		NA.SistemaErogante,
		NA.DataNota,
		NA.StatoCodice,
		NA.DataFineValidita,
		NA.DataPartizione,
		NA.Contenuto,
		NA.ContenutoText,
		NA.TipoCodice,
		NA.TipoDescrizione,
		NA.TipoContenuto,
		dbo.GetNotaAnamnesticaStatoDesc(NA.StatoCodice, NULL) AS StatoCodiceDesc,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(NA.Id, NA.DataPartizione, 'Cognome')) AS Cognome,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(NA.Id, NA.DataPartizione, 'Nome')) AS Nome,
		CONVERT(VARCHAR(1), dbo.GetNoteAnamnesticheAttributo(NA.Id, NA.DataPartizione, 'Sesso')) AS Sesso,
		CONVERT(VARCHAR(16), dbo.GetNoteAnamnesticheAttributo(NA.Id, NA.DataPartizione, 'CodiceFiscale')) AS CodiceFiscale,
		dbo.GetNoteAnamnesticheAttributoDatetime(NA.Id, NA.DataPartizione, 'DataNascita') AS DataNascita,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo( NA.Id, NA.DataPartizione, 'ComuneNascita')) AS ComuneNascita,
		CONVERT(VARCHAR(4), dbo.GetNoteAnamnesticheAttributo( NA.Id, NA.DataPartizione, 'ProvinciaNascita')) AS ProvinciaNascita,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo( NA.Id, NA.DataPartizione, 'CodiceAnagraficaCentrale')) AS CodiceAnagraficaCentrale,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo( NA.Id, NA.DataPartizione, 'NomeAnagraficaCentrale')) AS NomeAnagraficaCentrale,
	
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

	FROM store.NoteAnamnesticheBase NA WITH(NOLOCK)
		INNER JOIN @NOTE AS NOTE
			ON NA.Id = NOTE.ID
			AND NA.DataPartizione = NOTE.DataPartizione
			
		LEFT JOIN dbo.[SAC_Pazienti] SAC WITH(NOLOCK) 
			ON 	@NoteAnamnesticheOrfane = 0 
			AND	NA.IdPaziente = SAC.Id
			
	ORDER BY 
		NA.DataNota DESC
	OPTION (RECOMPILE)
		
	PRINT 'Durata: ' + CAST(DATEDIFF(millisecond, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'	

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsNoteAnamnesticheRiassociazioneLista] TO [ExecuteFrontEnd]
    AS [dbo];

