

-- =============================================
-- Author:		ETTORE 
-- Create date: 2015-02-09:
-- Description:	Utilizzata sia da SP front end web che ExtXXX per impostare il ricalcolo dell'anteprima 
--				L'@IdPaziente passato come parametro potrebbe essere sia ATTIVO che FUSO quindi lo traslo sempre nell'ATTIVO
--				Questa SP viene chiamata da altre SP e quindi NON HA il GRANT.
-- Modify date: 2017-11-21: Aggiunta la gestione delle NoteAnamnestiche
-- =============================================
CREATE PROCEDURE [dbo].[CorePazientiAnteprimaSetCalcolaAnteprima] 
(	
	@IdPaziente UNIQUEIDENTIFIER
	, @AggiornaAnteprimaReferti BIT
	, @AggiornaAnteprimaRicoveri BIT
	, @AggiornaAnteprimaNoteAnamnestiche BIT = 0 --Imposto valore di default
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RowCount INTEGER
	SET @RowCount = 0
	
	IF (NOT @IdPaziente IS NULL) AND @IdPaziente <> '00000000-0000-0000-0000-000000000000'
	BEGIN
		--
		-- Traslo l'@IdPaziente nell'attivo
		--
		SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
		--
		-- Eseguo UPDATE
		--
		IF @AggiornaAnteprimaReferti = 1 AND @AggiornaAnteprimaRicoveri = 1
		BEGIN 
			UPDATE PazientiAnteprima
				SET CalcolaAnteprimaReferti = GETDATE()
					, CalcolaAnteprimaRicoveri = GETDATE()
			WHERE IdPaziente = @IdPaziente
			SET @RowCount = @@ROWCOUNT
		END
		ELSE
		IF @AggiornaAnteprimaReferti = 1 
		BEGIN 
			UPDATE PazientiAnteprima
				SET CalcolaAnteprimaReferti = GETDATE()
			WHERE IdPaziente = @IdPaziente
			SET @RowCount = @@ROWCOUNT
		END
		ELSE
		IF @AggiornaAnteprimaRicoveri = 1 
		BEGIN 
			UPDATE PazientiAnteprima
				SET CalcolaAnteprimaRicoveri = GETDATE()
			WHERE IdPaziente = @IdPaziente
			SET @RowCount = @@ROWCOUNT
		END
		ELSE
		IF @AggiornaAnteprimaNoteAnamnestiche = 1 
		BEGIN 
			UPDATE PazientiAnteprima
				SET CalcolaAnteprimaNoteAnamnestiche = GETDATE()
			WHERE IdPaziente = @IdPaziente
			SET @RowCount = @@ROWCOUNT
		END
		--
		-- Se non ho eseguito UPDATE provo inserimento. 
		-- Se in errore non faccio nulla: il record l'ha inserito un altro processo
		--
		BEGIN TRY
			IF @RowCount = 0 
			BEGIN 
				INSERT INTO PazientiAnteprima(IdPaziente, CalcolaAnteprimaReferti, CalcolaAnteprimaRicoveri, CalcolaAnteprimaNoteAnamnestiche)
				SELECT @IdPaziente, GETDATE(), GETDATE(), GETDATE()
			END
		END TRY
		BEGIN CATCH
		END CATCH
	END
END

