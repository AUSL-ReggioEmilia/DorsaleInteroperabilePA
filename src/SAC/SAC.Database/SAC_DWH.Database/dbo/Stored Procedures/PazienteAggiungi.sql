CREATE PROCEDURE [dbo].[PazienteAggiungi]
	@LoginToSAC varchar(80),
	@IdEsterno  varchar(64),
	@AziendaErogante 	AS varchar (16),
	@SistemaErogante 	AS varchar (16),
	@RepartoErogante 	AS varchar (64),
	@IdAnagrafica		AS VARCHAR(64),
	@Sesso varchar(1),
	@Cognome  varchar(50),
	@Nome  varchar(50),
	@CodiceFiscale varchar(16),
	@DataNascita datetime,
	@LuogoNascita varchar(80)
 AS
 BEGIN 
--
-- Chiamata da SP EXT del DWH
--
	SET NOCOUNT ON
	--
	-- Se codicefiscale è vuoto lo imposto a 0000000000000000 cosi da richiedere sempre
	-- la creazione di una nuova posizione nel SAC
	--
	IF ISNULL(@CodiceFiscale,'') = ''
		SET @CodiceFiscale = '0000000000000000'

	IF @DataNascita IS NULL
		SET @DataNascita = '1800-01-01'
		
	IF NOT @LoginToSAC IS NULL 
	BEGIN
		--
		-- Impostando da DB come utente di login SAC_DWC non si impersonifica il reale sistema erogante (GST,ADT...)
		-- ma è come se il sistema erogante fosse il DwhClinico
		--
		IF @LoginToSAC = 'SAC_DWC'
			SET @IdAnagrafica = @IdEsterno
		--
		-- Se @IdAnagrafica è NULLO o vuoto lo valorizzo con l'IdEsterno
		-- altrimenti l'inserimento in dbo.SAC_PazientiDropTable dà errore
		--
		IF ISNULL(@IdAnagrafica,'') = ''
			SET @IdAnagrafica = @IdEsterno
		--
		-- Inserisco nella drop table del SAC solo se ho passato un set minimo di dati anagrafici
		--
		IF ISNULL(@Cognome,'') <> '' AND ISNULL(@Nome,'') <> '' AND ISNULL(@CodiceFiscale,'') <> ''
		BEGIN
			--------------------------------------------------------------
			-- Cambio utente per accesso al SAC
			--------------------------------------------------------------
			EXECUTE AS LOGIN = @LoginToSAC
			IF @@ERROR = 0
			BEGIN
				
				--------------------------------------------------------------
				-- Aggiunge paziente alla coda del SAC
				--------------------------------------------------------------
				
				DECLARE @ComuneNascitaCodice as varchar(6)

				SELECT TOP 1 @ComuneNascitaCodice = Codice
					FROM dbo.SAC_IstatComuni
					WHERE Nome = LTRIM(RTRIM(@LuogoNascita))
					
				IF @@ERROR <> 0 GOTO ERROR_EXIT

				INSERT dbo.SAC_PazientiDropTable 
							(Operazione, Id, Tessera, Cognome, Nome
							, DataNascita, Sesso, ComuneNascitaCodice, CodiceFiscale)
					VALUES
							(0, @IdAnagrafica, NULL, @Cognome, @Nome
							, @DataNascita, @Sesso, @ComuneNascitaCodice, @CodiceFiscale)
				--------------------------------------------------------------
				-- Ritorno all'utente iniziale
				--------------------------------------------------------------
				REVERT
				
			END
			IF @@ERROR <> 0
			BEGIN
				DECLARE @ErrMsg AS VARCHAR(500)
				SET @ErrMsg = 'Errore durante impersonificazione utente ' + @LoginToSAC + ' durante inserimento PazientiDropTable nel SAC!'
				RAISERROR(@ErrMsg, 16, 1)
				RETURN 1020
			END 
		END
	END


	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--     Completato
	---------------------------------------------------

	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	RETURN 1
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazienteAggiungi] TO [ExecuteDwh]
    AS [dbo];

