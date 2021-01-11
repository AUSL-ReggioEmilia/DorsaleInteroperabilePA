






-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-26
-- Modify date: 2011-01-26
-- Description:	Testata ordine erogato
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniErogatiSelectByIDOrdine]
	@IDOrdineTestata uniqueidentifier
	
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
			T.IDOrdineTestata = @IDOrdineTestata
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END































GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniErogatiSelectByIDOrdine] TO [DataAccessUi]
    AS [dbo];

