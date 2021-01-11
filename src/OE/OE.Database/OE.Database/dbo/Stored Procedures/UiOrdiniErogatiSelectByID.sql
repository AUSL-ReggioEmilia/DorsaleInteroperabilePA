







-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-27
-- Modify date: 2011-01-27
-- Description:	Testata ordine erogato
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniErogatiSelectByID]
	@ID uniqueidentifier
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			  T.ID
			, T.DataInserimento
			, T.DataModifica
			, T.IDTicketInserimento
			, T.IDTicketModifica
			, T.TS
			, T.IDOrdineTestata
			, T.IDSistemaRichiedente
			, T.IDRichiestaRichiedente
			, T.IDSistemaErogante
			, T.IDRichiestaErogante
			, T.StatoOrderEntry
			, T.StatoErogante
			, T.Data
			, T.Operatore
			, T.AnagraficaCodice
			, T.AnagraficaNome
			, T.PazienteIdRichiedente
			, T.PazienteIdSac
			, T.PazienteCognome
			, T.PazienteNome
			, T.PazienteDataNascita
			, T.PazienteSesso
			, T.PazienteCodiceFiscale
			, T.Paziente
			, T.Consensi
			, T.Note			 
			, SR.CodiceAzienda AS CodiceAziendaSistemaRichiedente
			, SR.Codice AS CodiceSistemaRichiedente
			, SE.CodiceAzienda AS CodiceAziendaSistemaErogante
			, SE.Codice AS CodiceSistemaErogante
						
		FROM 
			OrdiniErogatiTestate T
			INNER JOIN Sistemi SR ON SR.ID = T.IDSistemaRichiedente
			LEFT JOIN Sistemi SE ON SE.ID = T.IDSistemaErogante
			
		WHERE
			T.ID = @ID
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
































GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniErogatiSelectByID] TO [DataAccessUi]
    AS [dbo];

