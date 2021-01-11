

-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-10-21
-- Description:	Ritorna un elenco di sistemi richiedenti
-- =============================================
CREATE PROCEDURE [dbo].[CoreSistemiRichiedentiList]
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
		SELECT
			  S.ID
			, A.Codice AS AziendaCodice
			, A.Descrizione AS AziendaDescrizione		
			, S.Codice AS SistemaCodice
			, S.Descrizione AS SistemaDescrizione
			
		FROM 
			Sistemi S
			INNER JOIN Aziende A ON S.CodiceAzienda = A.Codice
			
		WHERE 
			S.Richiedente = 1 and Attivo=1
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

























GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiRichiedentiList] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiRichiedentiList] TO [DataAccessWs]
    AS [dbo];

