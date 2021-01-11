
-- =============================================
-- Author:		
-- Create date: 
-- Description:	Completa l'operazione di inserimento di un evento scrivendo nelle tabelle di notifica
-- Modify date: 2017-11-10 ETTORE: aggiundo la notifica nella tabella di coda SOLE
-- Modify date: 2017-12-18 ETTORE: Gestito il NULL del campo @TipoRicoveroCodice
-- Modify date: 2017-12-29 ETTORE: Si inviano a SOLE solo alcuni tipi di eventi ADT di ricovero (non si inviano gli eventi delle liste di prenotazione)
--									Per inserire nella coda SOLE devono essere verificate le seguenti condizioni: 
--									@RicoveroStatoCodice <> 255 AND @TipoEventoCodice IN ('A','D','R','X','E') AND @TipoRicoveroCodice IN ('O','D','A')
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2019-01-15 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaEventiAggiungi])
-- Modify date: 2019-02-25 - SANDRO - Aggiunto @StatoCodice a EXEC [sole].[CodaEventiAggiungi]

-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiBeforeProcess]
(
	@IdEsterno AS VARCHAR(64), 
	@Operazione AS smallint --Aggiornamento=0, Rimozione=1
)
AS 
BEGIN 
	----------------------------------------------------------
	-- Log di cancellazione eventi (NON IMPLEMENTATA NELLA DLL)
	-- Quindi questa SP non viene mai chiamata con Operazione = 1
	-- ma solo con Operazione = 0, quindi in realtà non esegue mai nulla
	----------------------------------------------------------
	SET NOCOUNT ON;
	DECLARE @IdEvento AS UNIQUEIDENTIFIER 
	DECLARE @AziendaErogante AS VARCHAR(16)
	DECLARE @SistemaErogante AS VARCHAR(16)
	DECLARE @NumeroNosologico AS VARCHAR(64)
	DECLARE @OperazioneLog AS smallint
	DECLARE @IdCorrelazione AS VARCHAR(64)
	DECLARE @TimeoutCorrelazione INT
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @TipoEventoCodice VARCHAR(16)
	DECLARE @DataModifica DATETIME
	DECLARE @StatoCodice TINYINT

	IF @Operazione = 1	--se è una Rimozione di un evento
	BEGIN
		SELECT @IdEvento = Id 
			, @AziendaErogante = AziendaErogante
			, @SistemaErogante = SistemaErogante 
			, @NumeroNosologico = NumeroNosologico 
			, @IdPaziente = IdPaziente
			, @TipoEventoCodice = TipoEventoCodice
			, @DataModifica = DataModifica
			, @StatoCodice = StatoCodice
		FROM [store].[EventiBase]
		WHERE IdEsterno = @IdEsterno
			
		IF NOT (@IdEvento IS NULL)
		BEGIN 
			--
			-- Si notifica solo se è avvenuto l'aggancio paziente
			--
			IF @IdPaziente <> '00000000-0000-0000-0000-000000000000' 
			BEGIN 
				--
				-- Inserimento nella tabella di LOG
				--
				SET @OperazioneLog = 2	--log di cancellazione
				--
				-- Valorizzo l'Id di correlazione
				--
				SELECT @IdCorrelazione =  [dbo].[GetCodaEventiOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante,  @NumeroNosologico)
				--
				-- Valorizzo il timeout di correlazione
				--
				SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput',	'TimeoutCorrelazione'), 1)
				
				-------------------------------------------------------------------------------
				-- Eseguo l'inserimento nella tabella di out standard
				-------------------------------------------------------------------------------
				INSERT INTO CodaEventiOutput (IdEvento,Operazione, IdCorrelazione, CorrelazioneTimeout ,OrdineInvio, Messaggio)
				VALUES(@IdEvento, @OperazioneLog, @IdCorrelazione, @TimeoutCorrelazione, 0, dbo.GetEventoXml2(@IdEvento))
				
				--------------------------------------------------------------------------------
				-- Eseguo l'inserimento nella tabella di coda SOLE
				--------------------------------------------------------------------------------
				-- 2019-01-16 Precarico messaggio solo in cancellazione
				DECLARE @XmlEventoSole XML 
				SET @XmlEventoSole = [sole].[OttieneEventoXml](@IdEvento)
				
				EXEC [sole].[CodaEventiAggiungi] @IdEvento, @OperazioneLog, 'DAE', @AziendaErogante, @SistemaErogante, @StatoCodice
												, @TipoEventoCodice, @DataModifica, @NumeroNosologico, @XmlEventoSole 
			END
		END 		
	END
	--
	-- Se nessun errore
	--
	SELECT INSERTED_COUNT = 1
	RETURN 0
	
END 



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiBeforeProcess] TO [ExecuteExt]
    AS [dbo];

