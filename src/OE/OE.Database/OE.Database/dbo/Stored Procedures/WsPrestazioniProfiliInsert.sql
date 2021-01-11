







-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-05-29
-- Description:	Associa la prestazione al profilo
-- =============================================
CREATE PROCEDURE [dbo].[WsPrestazioniProfiliInsert]
	  @IDPadre uniqueidentifier
	, @IDFiglio uniqueidentifier

AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	BEGIN TRY

		INSERT INTO PrestazioniProfili
		(
			  ID
			, IDPadre
			, IDFiglio
		)
		VALUES
		(
			  @ID
			, @IDPadre
			, @IDFiglio
		)
			
		SELECT @@ROWCOUNT AS [ROWCOUNT]
								
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
		
		SELECT @@ROWCOUNT AS [ROWCOUNT]
	END CATCH
	
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsPrestazioniProfiliInsert] TO [DataAccessWs]
    AS [dbo];

