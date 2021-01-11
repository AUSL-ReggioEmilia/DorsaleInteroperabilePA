
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-05-30
-- Description:	Notifica un referto aggiungendolo al coda CodaRefertiOutput
--				Notificare anche nella coda CodaRefertiSole
-- Modify date: 2018-01-11 - ETTORE: Notifica anche nella coda CodaRefertiSole
-- Modify date: 2019-01-21 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaRefertiAggiungi])
-- =============================================
CREATE PROCEDURE [dbo].[BeRefertiNotificaById]
(
	@IdReferto AS UNIQUEIDENTIFIER 
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
	DECLARE @StatoRichiestaCodice TINYINT

	DECLARE @Storica VARCHAR(1) --valori: 0,1
	--
	-- Cerco i dati del referto
	-- Reset @IdEsterno per test se trova referto
	--
	SET @IdEsterno = NULL
	
	SELECT @DataInserimento = DataInserimento
		, @DataModifica = DataModifica 
		, @AziendaErogante = AziendaErogante
		, @SistemaErogante = SistemaErogante
		, @IdEsterno = IdEsterno
		, @IdPaziente = IdPaziente
		, @StatoRichiestaCodice = StatoRichiestaCodice 
		, @Storica = CAST([dbo].[GetRefertiAttributo2](Id, DataPartizione, 'ImportazioneStorica') AS VARCHAR(1))
	FROM store.RefertiBase 
	WHERE Id = @IdReferto
	--
	-- Si notifica solo se è avvenuto l'aggancio paziente
	--
	IF NOT @IdEsterno IS NULL AND @IdPaziente <> '00000000-0000-0000-0000-000000000000' 			
	BEGIN
		--
		-- Verifico se è una importazione storica leggendo dagli attributi (per compatibilità)
		--2019-01-22 Spostata lettura attributo nella query con function
		--
		IF ISNULL(@Storica, '0') = '0'
		BEGIN
			--
			-- Determino se inserimento/aggiornamento
			--
			IF @DataInserimento = @DataModifica
				SET @OperazioneLog = 0		--log di inserimento
			ELSE
				SET @OperazioneLog = 1		--log di modifica
			--
			-- Valorizzo l'Id e timeout di correlazione
			--
			SELECT @IdCorrelazione =  [dbo].[GetCodaRefertiOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante, @IdEsterno)
			SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput', 'TimeoutCorrelazione'), 1)

			---------------------------------------------------------------------------
			-- Eseguo l'inserimento nella coda di output standard
			---------------------------------------------------------------------------
			INSERT INTO CodaRefertiOutput (IdReferto,Operazione, IdCorrelazione, CorrelazioneTimeout
											, OrdineInvio, Messaggio)
			VALUES(@IdReferto, @OperazioneLog , @IdCorrelazione , @TimeoutCorrelazione
					, dbo.GetCodaRefertiOutputOrdineInvio(@SistemaErogante)
					, dbo.GetRefertoXml2(@IdReferto))

			---------------------------------------------------------------------------------------
			-- Eseguo l'inserimento nella tabella di output SOLE
			---------------------------------------------------------------------------------------

			EXEC [sole].[CodaRefertiAggiungi] @IdReferto, @OperazioneLog, 'Admin', @AziendaErogante
										, @SistemaErogante, @StatoRichiestaCodice
										, @DataModifica, NULL
		END
	END

	RETURN 0
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRefertiNotificaById] TO [ExecuteFrontEnd]
    AS [dbo];

