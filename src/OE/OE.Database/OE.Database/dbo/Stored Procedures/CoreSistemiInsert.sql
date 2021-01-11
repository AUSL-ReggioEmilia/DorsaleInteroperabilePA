
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-10-20
-- Modify date: 2014-10-01 Sandro - Integrazione SAC
-- Description:	Inserisce un nuovo sistema
-- =============================================
CREATE PROCEDURE [dbo].[CoreSistemiInsert]
	  @Codice varchar(16)
	, @Descrizione varchar(128)
	, @Erogante bit
	, @Richiedente bit
	, @CodiceAzienda varchar(16)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		--Inserisco o riattivo sistema sul SAC (se ho i diritti) 
		EXEC [SacOrganigramma].[SistemiInserisceOppureModifica]	@Codice, @CodiceAzienda, @Descrizione, @Erogante, @Richiedente, 1

		-- Allineo tabella locale
		EXEC [dbo].[CoreSistemiEstesaAllinea] NULL, @Codice, @CodiceAzienda
		
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
    ON OBJECT::[dbo].[CoreSistemiInsert] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiInsert] TO [DataAccessWs]
    AS [dbo];

