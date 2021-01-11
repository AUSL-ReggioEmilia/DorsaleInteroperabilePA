

-- =============================================
-- Author:		ETTORE GARULLI
-- Create date: 2018-01-31
-- Description:	Offusca/DeOffusca i dati anagrafici e aggiorna il record SAC
-- =============================================
CREATE PROCEDURE [_anon].[MntDatiAnagraficiOffuscaDeOffuscaById]
(
	@Operazione VARCHAR(10) --Valori 'Offusca'/'DeOffusca'
	, @Simulazione BIT = 1
	, @IdPaziente UNIQUEIDENTIFIER			--IdPaziente SAC
	, @Cognome VARCHAR(64)					--Cognome originale
	, @Nome VARCHAR(64)						--Nome originale
	, @CognomeNuovo VARCHAR(64) OUTPUT	
	, @NomeNuovo VARCHAR(64) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF NOT @Operazione IN ('Offusca', 'DeOffusca') 
		BEGIN
			RAISERROR('I valori  possibili per @Operazione sono ''Offusca'' e ''DeOffusca''' , 16,1)
			RETURN
		END 
		--
		-- Cripto
		--
		IF @Operazione = 'Offusca' 
		BEGIN
			SELECT @CognomeNuovo = _anon.Offusca(@Cognome)
			SELECT @NomeNuovo = _anon.Offusca(@Nome)
		END
		ELSE
		IF @Operazione = 'DeOffusca' 
		BEGIN
			SELECT @CognomeNuovo = _anon.DeOffusca(@Cognome)
			SELECT @NomeNuovo = _anon.DeOffusca(@Nome)
		END

		IF @Simulazione = 0
		BEGIN 
			--
			-- Salvo sul database 
			--
			UPDATE dbo.Pazienti 
				SET Cognome = @CognomeNuovo
					, Nome = @NomeNuovo
			WHERE Id = @IdPaziente 
		END
	END TRY
	BEGIN CATCH
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = CHAR(9) + N'MntDatiAnagraficiOffuscaDeOffuscaById. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16,1)
	END CATCH

END