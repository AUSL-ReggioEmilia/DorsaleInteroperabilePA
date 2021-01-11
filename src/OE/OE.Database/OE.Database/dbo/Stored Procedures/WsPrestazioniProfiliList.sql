








-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-05-29
-- Description:	Lista di prestazioni associati ad un profilo
-- =============================================
CREATE PROCEDURE [dbo].[WsPrestazioniProfiliList]
	@IDPadre uniqueidentifier

AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT 
			  P.ID
			, P.Codice
			, P.Descrizione
			, P.IDSistemaErogante
			, P.Tipo
			, S.CodiceAzienda AS CodiceAziendaSistemaErogante
			, A.Descrizione AS DescrizioneAziendaSistemaErogante
			, S.Codice AS CodiceSistemaErogante
			, S.Descrizione AS DescrizioneSistemaErogante
			
		FROM 
			PrestazioniProfili PP 
		
			INNER JOIN Prestazioni P ON P.ID = PP.IDFiglio
			INNER JOIN Sistemi S ON S.ID = P.IDSistemaErogante
			INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda
		
		WHERE
			PP.IDPadre = @IDPadre
			
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
    ON OBJECT::[dbo].[WsPrestazioniProfiliList] TO [DataAccessWs]
    AS [dbo];

