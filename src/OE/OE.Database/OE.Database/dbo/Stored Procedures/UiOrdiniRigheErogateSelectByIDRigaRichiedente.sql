









-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-27
-- Modify date: 2011-01-27
-- Description:	Riga erogata
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniRigheErogateSelectByIDRigaRichiedente]
	@IDRigaRichiedente varchar(64)
	
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
			IDRigaRichiedente = @IDRigaRichiedente
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

































GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniRigheErogateSelectByIDRigaRichiedente] TO [DataAccessUi]
    AS [dbo];

