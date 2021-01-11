








-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-27
-- Modify date: 2011-01-27
-- Description:	Riga erogata
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniRigheErogateSelectByID]
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
			, IDOrdineErogatoTestata
			, IDPrestazione
			, IDRigaRichiedente
			, IDRigaErogante
			, StatoErogante
			, Data
			, Operatore
			, Consensi
						
		FROM 
			OrdiniRigheErogate
			
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
    ON OBJECT::[dbo].[UiOrdiniRigheErogateSelectByID] TO [DataAccessUi]
    AS [dbo];

