
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2017-10-25
-- Modify date: 2019-01-15 Rename e cambio schema
-- Modify date: 2020-11-16 Aggiunto dato IdDocumento e usa la nuova SP [dbo].[RefertoAttributoAggiorna]
--							Gli attributi aggiunti ora saranno persistenti ($@)
--
-- Description:	Salva negli attributi l'esito dell'invio a SOLE
-- =============================================
CREATE PROCEDURE [sole_da].[StatoInvioRefertoAggiorna]
(
 @IdReferto uniqueidentifier
,@EsitoInvio varchar(16)
,@DataInvio datetime
,@IdDocumento varchar(64) = NULL
)
AS
BEGIN
	SET NOCOUNT ON
	--
	-- Cerca la DataPartizione
	--
	DECLARE @DataPartizione AS SMALLDATETIME = NULL
	SELECT @DataPartizione = DataPartizione FROM [store].[RefertiBase]
		WHERE Id = @IdReferto

	IF NOT @DataPartizione IS NULL
	BEGIN
			
		BEGIN TRANSACTION
		BEGIN TRY
			DECLARE @NameDataInvio VARCHAR(19) = REPLACE(CONVERT(VARCHAR(19), @DataInvio, 126), '-', '')
			DECLARE	@ret int = 0
			--
			-- Data  (ultimo)
			--
			DECLARE @AttribNomeData VARCHAR(64) = '$@Sole-DataInvio'
			EXEC @ret = [dbo].[RefertoAttributoAggiorna] @IdReferto, @DataPartizione, @AttribNomeData, @DataInvio

			IF @ret <> 0 RAISERROR ('Error in [dbo].[RefertoAttributoAggiorna]! Nome=%s', 16, 1, @AttribNomeData)
			--
			-- Esito (ultimo)
			--
			DECLARE @AttribNomeEsito VARCHAR(64) = '$@Sole-EsitoInvio'
			EXEC @ret = [dbo].[RefertoAttributoAggiorna] @IdReferto, @DataPartizione, @AttribNomeEsito, @EsitoInvio

			IF @ret <> 0 RAISERROR ('Error in [dbo].[RefertoAttributoAggiorna]! Nome=%s', 16, 1, @AttribNomeEsito)
			--
			-- IdDocumento (ultimo)
			--
			DECLARE @AttribNomeIdDocumento VARCHAR(64) = '$@Sole-IdDocumento'
			EXEC @ret = [dbo].[RefertoAttributoAggiorna] @IdReferto, @DataPartizione, @AttribNomeIdDocumento, @IdDocumento

			IF @ret <> 0 RAISERROR ('Error in [dbo].[RefertoAttributoAggiorna]! Nome=%s', 16, 1, @AttribNomeIdDocumento)
			--
			-- Esito (storico, concateno DataInvio nel nome)
			--
			SET @AttribNomeEsito = @AttribNomeEsito + '-' + @NameDataInvio
			EXEC @ret = [dbo].[RefertoAttributoAggiorna] @IdReferto, @DataPartizione, @AttribNomeEsito, @EsitoInvio

			IF @ret <> 0 RAISERROR ('Error in [dbo].[RefertoAttributoAggiorna]! Nome=%s', 16, 1, @AttribNomeEsito)
			--
			-- IdDocumento (storico, concateno DataInvio nel nome)
			--
			SET @AttribNomeIdDocumento = @AttribNomeIdDocumento + '-' + @NameDataInvio
			EXEC @ret = [dbo].[RefertoAttributoAggiorna] @IdReferto, @DataPartizione, @AttribNomeIdDocumento, @IdDocumento

			IF @ret <> 0 RAISERROR ('Error in [dbo].[RefertoAttributoAggiorna]! Nome=%s', 16, 1, @AttribNomeIdDocumento)
			--
			-- Salva tutto
			--
			COMMIT
			RETURN 0
		END TRY
		BEGIN CATCH
			--
			-- Erorr
			--
			ROLLBACK
			PRINT 'Errore durante la SP [sole_da].[StatoInvioRefertoAggiorna]'
			RETURN @@error
		END CATCH
	END
END