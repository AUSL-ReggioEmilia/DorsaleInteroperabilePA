

-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-07-20
-- Modify date: 2011-07-20
-- Description:	Inserisce una nuova riga richiesta
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteInsert]
	  @IDTicketInserimento uniqueidentifier
	, @IDOrdineTestata uniqueidentifier
	, @StatoOrderEntry varchar(16)
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

	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
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
			, @DataInserimento -- DataModifica
			, @IDTicketInserimento
			, @IDTicketInserimento --IDTicketModifica
			, @IDOrdineTestata
			, @StatoOrderEntry
			, @DataInserimento --DataModificaStato
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
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteInsert] TO [DataAccessWs]
    AS [dbo];

