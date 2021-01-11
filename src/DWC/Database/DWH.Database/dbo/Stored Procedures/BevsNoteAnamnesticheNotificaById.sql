

-- =============================================
-- Author:		SimoneB
-- Create date: 2017-11-29
-- Description:	Notifica una nota anamnestica inserendola dentro [dbo].[CodaNoteAnamnesticheOutput]
-- =============================================
CREATE PROCEDURE [dbo].[BevsNoteAnamnesticheNotificaById]
(
	@IdNotaAnamnestica AS UNIQUEIDENTIFIER
	,@DataPartizione AS DATETIME 
)
AS 
BEGIN
	SET NOCOUNT ON
	
	DECLARE @AziendaErogante AS VARCHAR(16)
	DECLARE @SistemaErogante AS VARCHAR(16)
	DECLARE @OperazioneLog AS SMALLINT
	DECLARE @IdCorrelazione AS VARCHAR(64)
	DECLARE @TimeoutCorrelazione INT
	DECLARE @DataInserimento AS DATETIME
	DECLARE @DataModifica AS DATETIME
	DECLARE @IdEsterno AS VARCHAR(64)
	DECLARE @IdPaziente AS UNIQUEIDENTIFIER
	--
	-- Cerco i dati della nota anamnestica
	--
	SET @IdEsterno = NULL
	
	SELECT @DataInserimento = DataInserimento
		, @DataModifica = DataModifica 
		, @AziendaErogante = AziendaErogante
		, @SistemaErogante = SistemaErogante
		, @IdEsterno = IdEsterno
		, @IdPaziente = IdPaziente
	FROM store.NoteAnamnesticheBase 
	WHERE Id = @IdNotaAnamnestica 
		AND DataPartizione = @DataPartizione
	--
	-- Si notifica solo se è avvenuto l'aggancio paziente
	--
	IF NOT @IdEsterno IS NULL AND @IdPaziente <> '00000000-0000-0000-0000-000000000000' 			
	BEGIN
		--
		-- Verifico se è una importazione storica leggendo dagli attributi (per compatibilità)
		--	
		DECLARE @Storica VARCHAR(1) --valori: 0,1
		SELECT @Storica = CAST(Valore AS VARCHAR(1))
		FROM store.NoteAnamnesticheAttributi 
		WHERE IdNoteAnamnesticheBase = @IdNotaAnamnestica AND Nome = 'ImportazioneStorica'
		
		IF ISNULL(@Storica, '0') = 0
		BEGIN
			--
			-- Determino se inserimento/aggiornamento
			--
			IF @DataInserimento = @DataModifica
				SET @OperazioneLog = 0		--log di inserimento
			ELSE
				SET @OperazioneLog = 1		--log di modifica
			--
			-- Valorizzo l'Id di correlazione
			--
			SELECT @IdCorrelazione =  [dbo].[GetCodaNoteAnamnesticheOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante, @IdEsterno)
			--
			-- Valorizzo il timeout di correlazione
			--
			SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput', 'TimeoutCorrelazione'), 1)
			--
			-- Eseguo l'inserimento
			--
			INSERT INTO CodaNoteAnamnesticheOutput (IdNotaAnamnestica,Operazione, IdCorrelazione, CorrelazioneTimeout
											, OrdineInvio, Messaggio)
			VALUES(@IdNotaAnamnestica, @OperazioneLog , @IdCorrelazione , @TimeoutCorrelazione
					, 0 --Per le note anamnestiche non c'è un ordine di priorità.
					, dbo.GetNotaAnamnesticaXml(@IdNotaAnamnestica, @DataPartizione))
		END
	END

	RETURN 0
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsNoteAnamnesticheNotificaById] TO [ExecuteFrontEnd]
    AS [dbo];

