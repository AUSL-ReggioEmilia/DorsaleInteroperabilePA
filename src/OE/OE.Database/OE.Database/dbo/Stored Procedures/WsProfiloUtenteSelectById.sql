






-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-05-25
-- Description:	Seleziona un template utente per id
-- =============================================
CREATE PROCEDURE [dbo].[WsProfiloUtenteSelectById]
	@Id uniqueidentifier

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
				P.ID = @Id
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
    ON OBJECT::[dbo].[WsProfiloUtenteSelectById] TO [DataAccessWs]
    AS [dbo];

