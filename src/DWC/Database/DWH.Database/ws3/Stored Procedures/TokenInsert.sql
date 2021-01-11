

-- =============================================
-- Author:		Ettore
-- Create date: 2015-11-27
-- Modify date: 2016-03-29 Aggiunti dati per cache SE, UO e Accessi
-- Modify date: 2016-04-15 Stefano: Aggunto IdRuolo
-- Modify date: 2016-09-01 Ettore: Verifica che l'utente delegato appartenga al ruolo
-- Description:	Inserisce nel db il record associato al token
-- =============================================
CREATE PROCEDURE [ws3].[TokenInsert]
(
	@CodiceRuolo VARCHAR(16)
	, @UtenteProcesso VARCHAR(64)
	, @UtenteDelegato VARCHAR(64)
	, @IdToken UNIQUEIDENTIFIER OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CustomError BIT = 0
	DECLARE @Id UNIQUEIDENTIFIER
	DECLARE @IdRuolo UNIQUEIDENTIFIER
	DECLARE @DataInserimento DATETIME

	SET @Id = NEWID()
	SET @DataInserimento = GETUTCDATE()
	
	BEGIN TRY
		--
		-- MODIFICA ETTORE 2016-01-09: Verifica che l'utente delegato appartenga al ruolo
		--
		IF NOT EXISTS(SELECT * FROM [dbo].[OttieniSacRuoliPerUtente] (@UtenteDelegato) WHERE RuoloCodice = @CodiceRuolo)
		BEGIN
			DECLARE @Errore NVARCHAR(200);
			SET @Errore= N'[SecurityError]L''utente ''' + @UtenteDelegato + ''' non è associato al ruolo con codice ''' + @CodiceRuolo + '''.' 
			SET @CustomError = 1
			RAISERROR(@Errore, 16, 1)
			RETURN
		END
		
		-- Legge la lista dei SE dal SAC
		DECLARE @xmlSistemiEroganti xml
		SET @xmlSistemiEroganti = (SELECT * FROM [dbo].[OttieniSacSistemiErogantiPerRuolo]( @CodiceRuolo) SistemaErogante
									FOR XML AUTO, ROOT('SistemiEroganti')
								)

		-- Legge la lista delle UO dal SAC
		DECLARE @xmlUnitaOperative xml
		SET @xmlUnitaOperative = (SELECT * FROM [dbo].[OttieniSacUnitaOperativePerRuolo]( @CodiceRuolo) UnitaOperativa
									FOR XML AUTO, ROOT('UnitaOperative')
								)

		-- Legge la lista degli ACCESSI dal SAC
		DECLARE @xmlRuoliAccesso xml
		SET @xmlRuoliAccesso = (SELECT * FROM [dbo].[OttieniSacRuoliAccessoPerRuolo]( @CodiceRuolo) RuoloAccesso
									FOR XML AUTO, ROOT('RuoliAccesso')
								)

		-- LOOKUP DELL'ID RUOLO	
		SELECT @IdRuolo = [Id] 
		FROM dbo.SAC_Ruoli
		WHERE Codice = @CodiceRuolo
		
	
		INSERT INTO dbo.Tokens(Id, DataInserimento, CodiceRuolo, IdRuolo, UtenteProcesso, UtenteDelegato
								, CacheSistemiEroganti, CacheUnitaOperative, CacheRuoliAccesso)
		VALUES(@Id , @DataInserimento, @CodiceRuolo, @IdRuolo, @UtenteProcesso, @UtenteDelegato
								, @xmlSistemiEroganti, @xmlUnitaOperative, @xmlRuoliAccesso)
		--
		-- Restituisco l'Id del token
		--
		SET @IdToken = @Id
		
    END TRY
    BEGIN CATCH
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()
		DECLARE @report NVARCHAR(4000);
		IF @CustomError = 1 
			SELECT @report = @msg
		ELSE
			SELECT @report = @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)		
    END CATCH

END