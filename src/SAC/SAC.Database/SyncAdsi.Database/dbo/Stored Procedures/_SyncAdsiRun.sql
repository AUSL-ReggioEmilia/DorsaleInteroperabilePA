

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-10-16
-- Description:	Importa da AD utenti, gruppi e membri dei gruppi.
-- =============================================
CREATE PROCEDURE [dbo].[_SyncAdsiRun]
	@Incrementale BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DataFrom AS DATETIME
	SET @DataFrom = NULL
	
	DECLARE @LoginAdsi AS VARCHAR(255)
	DECLARE @DomainName nvarchar(255)
	
	SET @LoginAdsi =  dbo.ConfigAccountExec()
	SET @DomainName = dbo.ConfigNetbiosDomainName()

	--------------------------------------------------------------
	-- Cambio utente per accesso per il MAP sul linked server ADSI
	--------------------------------------------------------------
	IF NOT @LoginAdsi IS NULL
		EXECUTE AS LOGIN = @LoginAdsi

	IF @@ERROR = 0
	BEGIN
		IF @Incrementale = 1
		BEGIN
			SELECT @DataFrom = MAX([DataModificaEsterna])
			FROM [dbo].[OggettiActiveDirectory]
			WHERE Utente LIKE @DomainName + '\%'
		END

		PRINT 'Importo da ' + @DomainName
		PRINT 'Da ultima modifica: ' + ISNULL(CONVERT(VARCHAR(20), @DataFrom , 120), ' completo')
		
		--Eseguo SYNC
		EXEC [dbo].[SyncOrganigrammaUtenti] @DataFrom
		EXEC [dbo].[SyncOrganigrammaGruppi] @DataFrom
		EXEC [dbo].[SyncOrganigrammaMembri] @DataFrom		

		-- Ritorno all'utente iniziale
		IF NOT @LoginAdsi IS NULL
			REVERT
	END
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[_SyncAdsiRun] TO [adsi_dataaccess]
    AS [dbo];

