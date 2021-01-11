

-- =============================================
-- Author:		Marco Bellini
-- Create date: 2011-02-09
-- Description:	Looukup sugli stati dell'ordine
-- ModifyDate: 26/03/2019
-- By: LucaB
-- =============================================

CREATE  PROCEDURE [dbo].[UiLookupEnnupleStati]

	@ID tinyint = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SELECT ID, Descrizione, Note
			FROM EnnupleStati
			WHERE ID = @ID or @ID is null
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiLookupEnnupleStati] TO [DataAccessUi]
    AS [dbo];

