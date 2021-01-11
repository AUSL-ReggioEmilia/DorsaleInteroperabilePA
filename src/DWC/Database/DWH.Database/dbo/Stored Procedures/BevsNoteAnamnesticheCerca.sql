




-- =============================================
-- Author: Simone Bitti
-- Create date:	2017-11-22
-- Description: Stored procedure di ricerca delle Note Anamnestiche.
-- Modify date:	2018-06-15 - ETTORE: Gestione della DataFineValidita
-- =============================================
CREATE PROCEDURE [dbo].[BevsNoteAnamnesticheCerca]
(
	@IdNotaAnamnestica UNIQUEIDENTIFIER = NULL,
	@IdEsterno VARCHAR(64) = NULL,
	@IdPaziente UNIQUEIDENTIFIER = NULL,
	@DataModificaDAL DATETIME = NULL,
	@DataModificaAL DATETIME = NULL,
	@AziendaErogante VARCHAR(16) = NULL,
	@SistemaErogante VARCHAR(16) = NULL,
	@DataNota DATETIME = NULL,
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
	DECLARE	@DTNota_DAL DATETIME
	DECLARE	@DTNota_AL  DATETIME
	DECLARE @NOTE TABLE (ID UNIQUEIDENTIFIER, DataPartizione SMALLDATETIME)

	IF (@MaxRow IS NULL) OR (@MaxRow > 1000) SET @MaxRow = 1000

	-- Impostazione dei NULL: se variabile = '' allora la imposto a NULL
	SET @IdEsterno = NULLIF(@IdEsterno,'')
	SET @AziendaErogante = NULLIF(@AziendaErogante,'')
	SET @SistemaErogante = NULLIF(@SistemaErogante,'')
	SET @Cognome = NULLIF(@Cognome,'')
	SET @Nome = NULLIF(@Nome,'')
	SET @CodiceFiscale = NULLIF(@CodiceFiscale,'')
	
		
	IF @IdNotaAnamnestica IS NOT NULL 
	BEGIN 
		PRINT 'Ricerca per @IdNota'
		INSERT INTO @NOTE (ID, DataPartizione) 
		SELECT ID, DataPartizione
		FROM store.NoteAnamnesticheBase WITH(NOLOCK)
		WHERE ID = @IdNotaAnamnestica		
	END
	ELSE
	IF @idEsterno IS NOT NULL 
	BEGIN 
		PRINT 'Ricerca per @IdEsterno'
		INSERT INTO @NOTE (ID, DataPartizione) 
		SELECT ID, DataPartizione
		FROM  store.NoteAnamnesticheBase WITH(NOLOCK)
		WHERE IdEsterno = @idEsterno
	END 
	ELSE 
	BEGIN
		PRINT 'Ricerca per filtri generici'	
		--
		-- CONSIDERO LA PRESENZA DI TUTTI GLI ALTRI FILTRI
		--

		IF @dataModificaAL IS NULL SET @dataModificaAL = GETDATE()
		SET @DTNota_DAL  = CAST(@DataNota AS DATE)  --TRONCO ORE E MINUTI
		SET @DTNota_AL   = @DTNota_DAL + ' 23:59:59'

		--
		-- TROVO IL PADRE DELLA CATENA DI FUSIONE E LA LISTA DEI FUSI + L'ATTIVO
		-- 
		DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
		IF NOT @IdPaziente IS NULL
		BEGIN 
			SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
			INSERT INTO @TablePazienti(Id)
			SELECT Id FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)	
		END 
		--PRINT '@IdPaziente=' + ISNULL(CAST(@IdPaziente AS VARCHAR(40)), 'NULL')
				
		INSERT INTO @NOTE (ID, DataPartizione)
		SELECT TOP (@MaxRow)
			N.Id, N.DataPartizione
		FROM  
			store.NoteAnamnesticheBase AS N WITH(NOLOCK)
			INNER JOIN dbo.[SAC_Pazienti] AS P WITH(NOLOCK) --TUTTI I PAZIENTI ANCHE I FIGLI
				ON N.IdPaziente = P.Id
		WHERE
			    (@dataModificaDAL IS NULL OR N.DataModifica BETWEEN @dataModificaDAL AND @dataModificaAL)
			AND (@aziendaErogante IS NULL OR N.AziendaErogante = @aziendaErogante)
			AND (@sistemaErogante IS NULL OR N.SistemaErogante = @sistemaErogante)
			AND (@DataNota IS NULL OR N.DataNota BETWEEN @DTNota_DAL AND @DTNota_AL)
			--FILTRI SULLA PARTE ANAGRAFICA
			AND (@Cognome IS NULL OR P.Cognome LIKE @Cognome + '%')
			AND (@Nome IS NULL OR P.Nome LIKE @Nome + '%')
			AND (@CodiceFiscale IS NULL OR P.CodiceFiscale = @CodiceFiscale)
			AND (@DataNascita IS NULL OR P.DataNascita = @DataNascita)
			AND (
				@idPaziente IS NULL OR N.IdPaziente IN (SELECT Id FROM @TablePazienti)
				)
		ORDER BY 
			N.DataNota DESC
		
		OPTION (RECOMPILE)		
	
	END
	
	PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'
		
	--
	-- QUERY DI OUTPUT		
	--
	PRINT 'Esecuzione query di output'
	SET @T0 = GETDATE()	
	
	SELECT 
		N.ID,
		N.IdEsterno,
		N.IdPaziente,
		N.DataInserimento,
		N.DataModifica,
		N.AziendaErogante,
		N.SistemaErogante,
		N.StatoCodice,
		N.Contenuto,
		N.ContenutoText,
		N.TipoCodice,
		N.TipoDescrizione,
		N.TipoContenuto,
		N.DataNota,
		N.DataFineValidita,
		N.DataPartizione,
		CASE StatoCodice WHEN '0' THEN 'In corso'
						WHEN '1' THEN 'Completata'
						WHEN '2' THEN 'Variata'
						WHEN '3' THEN 'Cancellata'
						ELSE '' END	 AS StatoCodiceDesc,
		P.Cognome AS Cognome,
		P.Nome AS Nome,
		P.CodiceFiscale AS CodiceFiscale,
		P.DataNascita AS DataNascita,
		P.ComuneNascitaNome AS ComuneNascita,
		P.Tessera AS CodiceSanitario
	FROM store.NoteAnamnesticheBase N WITH(NOLOCK)
		INNER JOIN @NOTE AS NOTE
			ON N.Id = NOTE.ID
			AND N.DataPartizione = NOTE.DataPartizione
		INNER JOIN dbo.[SAC_Pazienti] P WITH(NOLOCK) --TUTTI I PAZIENTI ANCHE I FIGLI
			ON N.IdPaziente = P.Id
	ORDER BY 
		N.DataNota DESC
				
	PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'	

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsNoteAnamnesticheCerca] TO [ExecuteFrontEnd]
    AS [dbo];

