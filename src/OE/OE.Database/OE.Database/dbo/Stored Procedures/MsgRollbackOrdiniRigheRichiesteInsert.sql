

-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-05-12
-- Modify date: 2011-05-12
-- Description:	Rollback di una nuova riga richiesta
-- =============================================
CREATE PROCEDURE [dbo].[MsgRollbackOrdiniRigheRichiesteInsert]
	  @ID uniqueidentifier
	, @DataInserimento datetime
	, @DataModifica datetime
	, @IDTicketInserimento uniqueidentifier
	, @IDTicketModifica uniqueidentifier
	, @IDOrdineTestata uniqueidentifier
	, @StatoOrderEntry varchar(16)
	, @DataModificaStato datetime
	, @IDPrestazione uniqueidentifier
	, @IDSistemaErogante uniqueidentifier
	, @IDRigaOrderEntry varchar(64)
	, @IDRigaRichiedente varchar(64)
	, @IDRigaErogante varchar(64)
	, @IDRichiestaErogante varchar(64)
	, @StatoRichiedente xml
	, @Consensi xml
	
AS
BEGIN
	--SET NOCOUNT ON;
	
	BEGIN TRY
		------------------------------
		-- INSERT
		------------------------------		
		INSERT INTO OrdiniRigheRichieste
		(
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, IDOrdineTestata
			, StatoOrderEntry
			, DataModificaStato
			, IDPrestazione
			, IDSistemaErogante
			, IDRigaOrderEntry
			, IDRigaRichiedente
			, IDRigaErogante
			, IDRichiestaErogante
			, StatoRichiedente
			, Consensi
		)
		VALUES
		(
			  @ID
			, @DataInserimento
			, @DataModifica
			, @IDTicketInserimento
			, @IDTicketModifica
			, @IDOrdineTestata
			, @StatoOrderEntry
			, @DataModificaStato
			, @IDPrestazione
			, @IDSistemaErogante
			, @IDRigaOrderEntry
			, @IDRigaRichiedente
			, @IDRigaErogante
			, @IDRichiestaErogante
			, @StatoRichiedente
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
    ON OBJECT::[dbo].[MsgRollbackOrdiniRigheRichiesteInsert] TO [DataAccessMsg]
    AS [dbo];

