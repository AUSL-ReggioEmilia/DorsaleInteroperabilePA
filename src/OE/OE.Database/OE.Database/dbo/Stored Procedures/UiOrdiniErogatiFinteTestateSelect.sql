
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-02-25
-- Modify date: 2011-02-25
-- Description:	Testata erogato
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniErogatiFinteTestateSelect]
	@idOrdineTestata uniqueidentifier
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	
	
	select NEWID() as Id, tmp.* from(
	
		SELECT distinct
			 
			  '' as DataInserimento
			, '' as DataModifica	
			, '' as IdRichiestaErogante 
			, '' as StatoOrderEntry
			, '' as StatoErogante
			, GETDATE() as Data			
			, SE.CodiceAzienda AS CodiceAziendaSistemaErogante
			, SE.Codice AS CodiceSistemaErogante	
			, ORR.IDSistemaErogante	
		
		FROM
			Sistemi SE inner join OrdiniRigheRichieste ORR on ORR.IDSistemaErogante =  SE.ID
			
		WHERE
			ORR.IDOrdineTestata = @idOrdineTestata
		) as tmp
		
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniErogatiFinteTestateSelect] TO [DataAccessUi]
    AS [dbo];

