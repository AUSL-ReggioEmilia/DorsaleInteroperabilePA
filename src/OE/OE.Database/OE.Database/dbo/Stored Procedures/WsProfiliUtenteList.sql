





-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-05-25
-- Description:	Seleziona una lista di template utente per sistema erogante
-- =============================================
CREATE PROCEDURE [dbo].[WsProfiliUtenteList]
	  @Valore varchar(16)
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
			, dbo.GetWsTotalePrestazioniProfilo(P.ID) AS NumeroPrestazioni
			, dbo.GetWsAggregazioneSistemiErogantiProfilo(P.ID) AS SistemiEroganti
			
		FROM 
			Prestazioni P
			
		WHERE 
			((@valore IS NULL) OR (P.Codice Like '%' + @valore + '%' OR P.Descrizione Like '%' + @valore + '%'))
			AND P.IDSistemaErogante = '00000000-0000-0000-0000-000000000000'
			AND P.UtenteInserimento = @Utente
			AND P.Tipo = 3
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
    ON OBJECT::[dbo].[WsProfiliUtenteList] TO [DataAccessWs]
    AS [dbo];

