








-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-27
-- Modify date: 2011-02-16
-- Description:	Riga richiesta
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniRigheRichiesteSelectByID]
	@ID uniqueidentifier
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, TS
			, IDOrdineTestata
			, IDPrestazione
			, IDSistemaErogante
			, IDRigaOrderEntry
			, IDRigaRichiedente
			, IDRigaErogante
			, IDRichiestaErogante
			, Consensi
						
		FROM 
			OrdiniRigheRichieste
			
		WHERE
			ID = @ID
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
































GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniRigheRichiesteSelectByID] TO [DataAccessUi]
    AS [dbo];

