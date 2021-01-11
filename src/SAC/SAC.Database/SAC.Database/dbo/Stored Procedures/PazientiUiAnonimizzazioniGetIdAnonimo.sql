
CREATE PROCEDURE [dbo].[PazientiUiAnonimizzazioniGetIdAnonimo]
(
	@IdAnonimo VARCHAR(16) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- Questa SP viene chiamata dalla SP AnonimizzazioniUiInserisci
	-- Crea un codice del tipo AN14A001
	--
	DECLARE @Anno VARCHAR(4)
	DECLARE @Contatore VARCHAR(8)
	DECLARE @AsciCode INT 
	
	SET @IdAnonimo = NULL
	--
	-- Prelevo l'anno corrente
	--
	SET @Anno = CAST(YEAR(GETDATE()) AS VARCHAR(4))
	
	BEGIN TRANSACTION
	BEGIN TRY
		--
		-- Calcolo nuovo contatore
		--
		SELECT TOP 1 @Contatore = Contatore
		FROM PazientiAnonimizzazioniContatori
		WHERE Anno = @Anno 
		ORDER BY Contatore DESC
		IF @Contatore IS NULL 
		BEGIN
			SET @Contatore = 'A000'
		END
		ELSE
		BEGIN
			DECLARE @Counter AS INT 
			DECLARE @Lettera AS VARCHAR(1)
			SET @Counter = CAST(RIGHT(@Contatore,3) AS INTEGER)
			SET @Lettera = LEFT(@Contatore,1) 
			SET @Counter = @Counter + 1
			IF @Counter > 999 
			BEGIN
				SET @Counter = 0
				SET @AsciCode =  ASCII(@Lettera) + 1				
				IF @AsciCode <= 90 -- 90 = Z 
					SET @Lettera = CHAR(@AsciCode)
				ELSE
					--Non posso creare il codice
					SET @Lettera = NULL
			END
			-- Se @Lettera è NULL -> @Contatore è NULL
			SET @Contatore = @Lettera + RIGHT('0000' + CAST(@Counter AS VARCHAR(3)), 3)
		END
		--
		-- Lo scrivo nella tabella dei contatori
		--
		IF NOT @Contatore IS NULL
		BEGIN
			INSERT INTO PazientiAnonimizzazioniContatori(Anno, Contatore)
			VALUES (@Anno, @Contatore)
		END
		
		COMMIT TRANSACTION
		
		--
		-- Valorizzo @IdAnonimo che verrà usato per compilare il Cognome e il Nome del nuovo record
		--
		SET @IdAnonimo = 'AN' + SUBSTRING(@Anno,3,2) + @Contatore
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
		  ROLLBACK TRANSACTION;
		END

		DECLARE @ErrorLogId INT
		EXECUTE LogError @ErrorLogId OUTPUT;
		EXECUTE RaiseErrorByIdLog @ErrorLogId 
		RETURN @ErrorLogId
		
	END CATCH

END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiAnonimizzazioniGetIdAnonimo] TO [DataAccessUi]
    AS [dbo];

