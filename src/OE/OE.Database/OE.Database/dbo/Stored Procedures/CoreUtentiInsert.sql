
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-09-07
-- Modify date: 2018-10-16 - Lunghezza utente e desc
-- Description:	Inserisce un nuovo utente
-- =============================================
CREATE PROCEDURE [dbo].[CoreUtentiInsert]
(
 @Utente varchar(256)
,@Descrizione varchar(1024)
,@Attivo bit
,@Delega tinyint
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	DECLARE @DataCreazione datetime
	SET @DataCreazione = GETDATE()
	
	BEGIN TRY
		------------------------------
		-- INSERT
		------------------------------	
		INSERT INTO Utenti
		(
			  ID
			, Utente
			, Descrizione
			, Attivo
			, Delega
		)
		VALUES
		(
			  @ID
			, @Utente
			, @Descrizione
			, @Attivo
			, @Delega
		)
		
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUtentiInsert] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUtentiInsert] TO [DataAccessWs]
    AS [dbo];

