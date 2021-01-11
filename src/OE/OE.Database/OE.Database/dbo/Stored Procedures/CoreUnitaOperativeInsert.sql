-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-11-18, eliminato il parametro @IDParametroSpecifico
-- Modify date: 2014-10-01, Sandro - Integrazione SAC
-- Description:	Inserisce una nuova unità operativa
-- =============================================
CREATE PROCEDURE [dbo].[CoreUnitaOperativeInsert]
	  @Codice varchar(16)
	, @Descrizione varchar(128)
	, @CodiceAzienda varchar(16)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		--Inserisco o riattivo sistema sul SAC (se ho i diritti) 
		EXEC [SacOrganigramma].[UnitaOperativeInserisceOppureModifica]	@Codice, @CodiceAzienda, @Descrizione, 1

		-- Allineo tabella locale
		EXEC [dbo].[CoreUnitaOperativeEstesaAllinea] NULL, @Codice, @CodiceAzienda

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
    ON OBJECT::[dbo].[CoreUnitaOperativeInsert] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUnitaOperativeInsert] TO [DataAccessWs]
    AS [dbo];

