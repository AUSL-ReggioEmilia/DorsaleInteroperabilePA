






-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-05-25
-- Description:	Inserisce un nuovo template utente
-- =============================================
CREATE PROCEDURE [dbo].[WsProfiloUtenteInsert]
	  @Descrizione varchar(256)
	, @UtenteInserimento varchar(64)
	, @Codice varchar(16) out
		
AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier = NEWID()	
	DECLARE @DataInserimento datetime = GETDATE()	
	
	SELECT @Codice = dbo.[GetProgressivoPrestazioni](0)
	
	BEGIN TRY

		INSERT INTO Prestazioni
		(
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, Codice
			, Descrizione
			, Tipo
			, Provenienza
			, IDSistemaErogante
			, Attivo
			, UtenteInserimento
			, UtenteModifica
		)
		VALUES
		(
			  @ID
			, @DataInserimento
			, @DataInserimento --DataModifica
			, '00000000-0000-0000-0000-000000000000' --IDTicketInserimento
			, '00000000-0000-0000-0000-000000000000' --IDTicketModifica
			, @Codice
			, @Descrizione
			, 3 -- Template Utente
			, 2 -- Ws
			, '00000000-0000-0000-0000-000000000000' --IDSistemaErogante
			, 1
			, @UtenteInserimento
			, @UtenteInserimento --UtenteModifica
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
    ON OBJECT::[dbo].[WsProfiloUtenteInsert] TO [DataAccessWs]
    AS [dbo];

