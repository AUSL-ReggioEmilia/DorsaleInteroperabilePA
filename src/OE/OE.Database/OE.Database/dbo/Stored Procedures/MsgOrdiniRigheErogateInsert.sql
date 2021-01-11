

-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-15
-- Modify date: 2011-03-18
-- Description:	Inserisce una nuova riga erogata d'ordine
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheErogateInsert]
	  @IDTicketInserimento uniqueidentifier
	, @IDOrdineErogatoTestata uniqueidentifier
	, @StatoOrderEntry varchar(16)	
	, @IDPrestazione uniqueidentifier
	, @IDRigaRichiedente varchar(64)
	, @IDRigaErogante varchar(64)
	, @StatoErogante xml
	, @Data datetime
	, @Operatore xml
	, @Consensi xml
	
AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
	BEGIN TRY
		------------------------------
		-- INSERT
		------------------------------		
		INSERT INTO OrdiniRigheErogate
		(
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, IDOrdineErogatoTestata
			, StatoOrderEntry
			, DataModificaStato
			, IDPrestazione
			, IDRigaRichiedente
			, IDRigaErogante
			, StatoErogante
			, Data
			, Operatore
			, Consensi
		)
		VALUES
		(
			  @ID
			, @DataInserimento
			, @DataInserimento --DataModifica
			, @IDTicketInserimento
			, @IDTicketInserimento --IDTicketModifica
			, @IDOrdineErogatoTestata
			, @StatoOrderEntry
			, @DataInserimento --DataModificaStato
			, @IDPrestazione
			, @IDRigaRichiedente
			, @IDRigaErogante
			, @StatoErogante
			, @Data
			, @Operatore
			, @Consensi
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
    ON OBJECT::[dbo].[MsgOrdiniRigheErogateInsert] TO [DataAccessMsg]
    AS [dbo];

