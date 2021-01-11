





-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-05-25
-- Description:	Seleziona un template utente per codice/utente
-- =============================================
CREATE PROCEDURE [dbo].[WsProfiloUtenteSelect]
	  @Codice varchar(16)
	, @Utente varchar(64)
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SELECT
			  P.ID
			, P.DataInserimento
			, P.DataModifica
			, P.TS
			, P.Codice
			, P.Descrizione
			, P.Tipo
			, P.Provenienza
						
		FROM 
			Prestazioni P
			
		WHERE 
				P.Codice = @Codice
			AND P.IDSistemaErogante = '00000000-0000-0000-0000-000000000000'
			AND P.UtenteInserimento = @Utente
			AND P.Attivo = 1
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END









GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsProfiloUtenteSelect] TO [DataAccessWs]
    AS [dbo];

