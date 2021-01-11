





-- =============================================
-- Author:		Ettore
-- Create date: 2020-10-20
-- Description:	Salvataggio su SAC dei consensi provenienri da ARA
--				Cancellazione e reinserimento
-- =============================================
CREATE PROCEDURE [ara_ws].[PazientiConsensiAggiorna]
(
	@Identity VARCHAR(64)
	, @IdPaziente uniqueidentifier	    -- IDSAC 
	, @PazientiConsensi AS [ara].[ParamPazientiConsensi] READONLY
	, @NotificaAnagraficaDaEseguire BIT OUTPUT
)
AS
BEGIN
	DECLARE @Checksum_OLD INT 
	DECLARE @Checksum_NEW INT 
	DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	DECLARE @Provenienza VARCHAR(16) = 'ARA'
	DECLARE @MetodoAssociazione VARCHAR(32) = NULL


	SET NOCOUNT ON;
	SET @NotificaAnagraficaDaEseguire = 0
	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------
	BEGIN TRANSACTION 
	BEGIN TRY

		SELECT @Checksum_OLD = CHECKSUM_AGG(CHECKSUM(IdProvenienza, IdTipo,	DataStato, Stato, OperatoreId, OperatoreCognome, OperatoreNome,	OperatoreComputer, CAST(Attributi AS VARCHAR(MAX))))
		FROM dbo.Consensi
		WHERE IdPaziente = @IdPaziente 
			AND Provenienza = @Provenienza 
		
		SELECT @Checksum_NEW = CHECKSUM_AGG(CHECKSUM(IdProvenienza, IdTipo,	DataStato, Stato, OperatoreId, OperatoreCognome, OperatoreNome,	OperatoreComputer, CAST(Attributi AS VARCHAR(MAX))))
		FROM @PazientiConsensi 

		IF @Checksum_OLD <> @Checksum_NEW 
		BEGIN 

			DELETE FROM dbo.Consensi
			WHERE IdPaziente = @IdPaziente 
				AND Provenienza = @Provenienza --SOLO PROVENIENZA ARA

			INSERT INTO dbo.Consensi(Provenienza, IdProvenienza, IdPaziente, IdTipo, DataStato, Stato, 
					OperatoreId, OperatoreCognome, OperatoreNome, OperatoreComputer, MetodoAssociazione, Attributi)
			SELECT 
				@Provenienza, IdProvenienza, @IdPaziente, IdTipo, DataStato, Stato, 
					OperatoreId, OperatoreCognome, OperatoreNome, OperatoreComputer, @MetodoAssociazione, Attributi
			FROM @PazientiConsensi AS TAB
			
			SET @NotificaAnagraficaDaEseguire = 1
		END
		--
		--
		--
		COMMIT

	END TRY
	BEGIN CATCH
		---------------------------------------------------
		--     ROLLBACK TRANSAZIONE
		---------------------------------------------------
		IF @@TRANCOUNT > 0 ROLLBACK
		SET @NotificaAnagraficaDaEseguire = 0

		---------------------------------------------------
		--     GESTIONE ERRORI (LOG E PASSO FUORI)
		---------------------------------------------------
		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE()    
		-----EXEC dbo.ConsensiEventiAvvertimento @Identity, 0, @ProcName, @ErrMsg
		EXEC dbo.ConsensiEventiErrore @Identity, 0, @ProcName, @ErrMsg
		-- PASSO FUORI L'ECCEZIONE
		;THROW;

	END CATCH

END