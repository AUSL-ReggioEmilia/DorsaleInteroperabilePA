

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-03-12
-- Description:	Sync Paziente Attributi
-- =============================================
CREATE PROCEDURE [dbo].[SyncPazienteById]
	 @IdSac AS UNIQUEIDENTIFIER
AS
BEGIN

	SET NOCOUNT ON
	--
	-- Controllo parametri
	--
	IF @IdSac IS NULL
		RETURN 1
	
	BEGIN TRAN
	--
	-- Change Id
	--
	PRINT 'Anagrafica Sync ID ' + '{' +
			CONVERT(VARCHAR(40), @IdSac) + '} ->'

	BEGIN TRY
		--
		-- Lista degli attributi
		--
		DECLARE @PazientiAttributi TABLE (IdSac UNIQUEIDENTIFIER, Nome VARCHAR(64), Valore SQL_VARIANT)
		INSERT INTO @PazientiAttributi EXEC [dbo].[GetSacPezienteAttributi] @IdSac
		
		DECLARE @AttribCount INT = 0
		SELECT @AttribCount = COUNT(*) FROM @PazientiAttributi
		PRINT '-- Trovati ' + CONVERT(VARCHAR(40), @AttribCount) + ' attributi'

		DELETE FROM dbo.DwhClinico_PazientiAttributi
		WHERE IdPazientiBase = @IdSac
		
		INSERT INTO dbo.DwhClinico_PazientiAttributi (IdPazientiBase, Nome, Valore)
		SELECT IdSac, Nome, Valore
		FROM @PazientiAttributi
		WHERE NOT Nome IN ('Id', 'DataInserimento', 'DataModifica', 'Cognome', 'Nome'
							, 'DataNascita', 'CodiceFiscale', 'Sesso')
				
		INSERT INTO dbo.DwhClinico_PazientiAttributi (IdPazientiBase, Nome, Valore)
		VALUES (@IdSac, 'SyncPaziente', GETDATE())			
							
		-------------------
		-- Fine procedura
		-------------------
		COMMIT
			
		RETURN 0	
	END TRY
	BEGIN CATCH
		-------------------
		-- Abort procedura
		-------------------
		
		PRINT '-- Errore ' + ERROR_MESSAGE() 

		IF @@TRANCOUNT > 0
			ROLLBACK
		
		RETURN 1
	END CATCH
END

