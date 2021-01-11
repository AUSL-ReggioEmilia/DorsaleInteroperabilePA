
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-10-01 Integrazione SAC
-- Modify date: 2016-10-05 Tabella SAC copiata in locale
-- Description:	Verifica e inserisce nei sistemi locale l'ID del SAC
-- =============================================
CREATE PROCEDURE [dbo].[CoreSistemiEstesaAllinea]
	@Id uniqueidentifier
   ,@Codice varchar(16)
   ,@CodiceAzienda varchar(16)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		--
		-- Cerca UO sul SAC
		--
		-- Cerco l'inserito per codice
		IF @ID IS NULL AND NOT @Codice IS NULL AND NOT @CodiceAzienda IS NULL
			SELECT @ID = Id FROM [SacOrganigramma].[Sistemi]
			WHERE Codice = @Codice AND Azienda = @CodiceAzienda

		-- Oppure cerco l'inserito per ID
		IF NOT @ID IS NULL AND @Codice IS NULL AND @CodiceAzienda IS NULL
			SELECT @Codice = Codice, @CodiceAzienda = Azienda FROM [SacOrganigramma].[Sistemi]
			WHERE @ID = Id
		
		-- Se non trova sul SAC esce
		IF @ID IS NULL OR @Codice IS NULL OR @CodiceAzienda IS NULL
			RETURN 0
		--
		-- Aggiorna o inserisce su OE
		--
		IF NOT EXISTS (SELECT * FROM SistemiEstesa WHERE Id = @ID)
		BEGIN
			------------------------------
			-- INSERT in locale
			------------------------------		
			INSERT INTO SistemiEstesa (ID, Codice, CodiceAzienda)
			VALUES	(@ID, @Codice, @CodiceAzienda)
		END
		ELSE
		BEGIN
			------------------------------
			-- UPDATE in locale
			------------------------------		
			UPDATE SistemiEstesa
				SET Codice = @Codice
					,CodiceAzienda = @CodiceAzienda
					,Attivo = 1
			WHERE ID = @ID
				AND (Codice != @Codice
					OR CodiceAzienda != @CodiceAzienda
					OR 	Attivo = 0)
		END

		RETURN 0
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)

		RETURN 1
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiEstesaAllinea] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiEstesaAllinea] TO [DataAccessWs]
    AS [dbo];

