CREATE PROCEDURE [dbo].[GetPazienteConsenso]
	@IdPazienteSac  UNIQUEIDENTIFIER,
	@TipoConsenso VARCHAR(16) OUTPUT,
	@StatoConsenso BIT OUTPUT,
	@DataStatoConsenso Datetime OUTPUT
AS
BEGIN
--
-- Chiamata da SP EXT del DWH
--
	SET NOCOUNT ON

	DECLARE @Error AS INT
	DECLARE @ReturnError AS INT
	
	--------------------------------------------------------------
	-- Cambio utente per accesso al SAC
	--------------------------------------------------------------
	EXECUTE AS LOGIN = 'SAC_DWC'
	SET @Error = @@ERROR
	IF @Error <> 0
		BEGIN
			SET @ReturnError = 10000 --errore di login
			GOTO ERROR_EXIT
		END
	ELSE
		BEGIN
			-- Verify the context switch.
			--SELECT SUSER_NAME(), USER_NAME();
			--------------------------------------------------------------
			-- Leggo il consenso dal SAC e aggiorno la tabella dei consensi nel DWH
			--------------------------------------------------------------

			-- ************************ INIZIO NUOVA
			CREATE TABLE #TempTable (Id uniqueidentifier, Provenienza varchar(16), IdProvenienza varchar(64), IdPaziente uniqueidentifier,
									Tipo varchar(64) null, DataStato datetime, Stato bit, OperatoreId varchar(64) null, OperatoreCognome varchar(64) null,
									OperatoreNome varchar(64) null, OperatoreComputer varchar(64) null, PazienteCognome varchar(64) null, PazienteNome varchar(64) null,
									PazienteTessera varchar(16) null, PazienteCodiceFiscale varchar(16) null, PazienteDataNascita datetime null, PazienteComuneNascitaCodice varchar(6) null,
									PazienteComuneNascitaNome varchar(128) null, PazienteNazionalitaCodice varchar(3) null, PazienteNazionalitaNome varchar(128) null
									)
			INSERT INTO #TempTable EXEC dbo.SAC_ConsensiOutputByIdPaziente  @IdPazienteSac
				
			IF @@ERROR <> 0 
			BEGIN
				-- Cancello la tab temporanea
				DROP TABLE #TempTable
				REVERT
				SET @ReturnError = 10001 --errore lettura consenso sul SAC
				GOTO ERROR_EXIT
			END
			
			-- Leggo i dati restituiti dalla SP e li memorizzo nelle variabili:
			SELECT TOP 1 @TipoConsenso = Tipo
						, @StatoConsenso=Stato
						, @DataStatoConsenso = DataStato 
			FROM #TempTable AS TAB WHERE Tipo = 'Generico'
			
			-- Cancello la tab temporanea
			DROP TABLE #TempTable

			--------------------------------------------------------------
			-- Ritorno all'utente iniziale
			--------------------------------------------------------------
			REVERT
		END

	RETURN 0

ERROR_EXIT:
	---------------------------------------------------
	--     Error
	---------------------------------------------------

	RETURN @ReturnError
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetPazienteConsenso] TO [ExecuteDwh]
    AS [dbo];

