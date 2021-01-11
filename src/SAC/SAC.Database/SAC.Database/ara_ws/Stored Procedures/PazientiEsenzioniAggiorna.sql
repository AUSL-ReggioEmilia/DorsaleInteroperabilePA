




-- =============================================
-- Author:		Ettore
-- Create date: 2020-10-20
-- Description:	Salvataggio su SAC di Esenzioni + Fascie di reddito nella tabella delle Esenzioni
-- =============================================
CREATE PROCEDURE [ara_ws].[PazientiEsenzioniAggiorna]
(
	@Identity VARCHAR(64)
	, @IdPaziente uniqueidentifier	    -- IDSAC 
	, @PazientiEsenzioni AS [ara].[ParamPazientiEsenzioni] READONLY
	, @NotificaAnagraficaDaEseguire BIT OUTPUT
)
AS
BEGIN
	DECLARE @Checksum_OLD INT 
	DECLARE @Checksum_NEW INT 
	DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	DECLARE @Provenienza VARCHAR(16) = 'ARA'


	SET NOCOUNT ON;
	SET @NotificaAnagraficaDaEseguire = 0
	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------
	BEGIN TRANSACTION 
	BEGIN TRY

		SELECT @Checksum_OLD = CHECKSUM_AGG(CHECKSUM(CodiceEsenzione,CodiceDiagnosi,Patologica,DataInizioValidita,DataFineValidita,NumeroAutorizzazioneEsenzione,NoteAggiuntive
						,CodiceTestoEsenzione,TestoEsenzione,DecodificaEsenzioneDiagnosi,AttributoEsenzioneDiagnosi,OperatoreId,OperatoreCognome
						,OperatoreNome,OperatoreComputer))
		FROM dbo.PazientiEsenzioni 
		WHERE IdPaziente = @IdPaziente 
			AND Provenienza = @Provenienza --SOLO PROVENIENZA ARA


		SELECT @Checksum_NEW = CHECKSUM_AGG(CHECKSUM(CodiceEsenzione,CodiceDiagnosi,Patologica,DataInizioValidita,DataFineValidita,NumeroAutorizzazioneEsenzione,NoteAggiuntive
						,CodiceTestoEsenzione,TestoEsenzione,DecodificaEsenzioneDiagnosi,AttributoEsenzioneDiagnosi,OperatoreId,OperatoreCognome
						,OperatoreNome,OperatoreComputer))
		FROM @PazientiEsenzioni 

		IF ISNULL(@Checksum_NEW, '') <> ISNULL(@Checksum_OLD, '')
		BEGIN 

			DELETE FROM dbo.PazientiEsenzioni 
			WHERE IdPaziente = @IdPaziente 
				AND Provenienza = @Provenienza --SOLO PROVENIENZA ARA

			INSERT INTO dbo.PazientiEsenzioni
				(IdPaziente, DataInserimento, DataModifica, CodiceEsenzione,CodiceDiagnosi,Patologica,DataInizioValidita,DataFineValidita,NumeroAutorizzazioneEsenzione,NoteAggiuntive
				,CodiceTestoEsenzione,TestoEsenzione,DecodificaEsenzioneDiagnosi,AttributoEsenzioneDiagnosi,OperatoreId,OperatoreCognome
				,OperatoreNome,OperatoreComputer, Provenienza)
			SELECT 
				@IdPaziente,GetDate(), GetDate(), CodiceEsenzione,CodiceDiagnosi,Patologica,DataInizioValidita,DataFineValidita,NumeroAutorizzazioneEsenzione,NoteAggiuntive
				,CodiceTestoEsenzione,TestoEsenzione,DecodificaEsenzioneDiagnosi,AttributoEsenzioneDiagnosi,OperatoreId,OperatoreCognome
				,OperatoreNome,OperatoreComputer, @Provenienza
			FROM @PazientiEsenzioni AS TAB
			
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
		EXEC [dbo].[EsenzioniEventiInserisce] @Identity, 0,'ERRORE', @ProcName, @ErrMsg 
		-- PASSO FUORI L'ECCEZIONE
		;THROW;

	END CATCH

END