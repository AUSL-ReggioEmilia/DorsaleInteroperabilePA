





-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-26
-- Modify date: 2011-02-11
-- Description:	Testata ordine
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniSelectByID]
	@ID uniqueidentifier
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, TS
			, IDSistemaRichiedente
			, NumeroNosologico
			, IDRichiestaRichiedente
			, DataRichiesta
			, StatoOrderEntry
			, StatoRichiedente
			, Data
			, Operatore
			--, CAST(Operatore.query('/OperatoreType/Cognome/text()') as varchar(max)) AS OperatoreCognome		
			, Priorita
			--, CAST(Priorita.query('/CodiceDescrizioneType/Codice/text()') as varchar(max)) AS PrioritaCodice		
			--, CAST(Priorita.query('/CodiceDescrizioneType/Descrizione/text()') as varchar(max)) AS PrioritaDescrizione				
			, TipoEpisodio
			, AnagraficaCodice
			, AnagraficaNome
			, PazienteIdRichiedente
			, PazienteIdSac
			, PazienteRegime
			, PazienteCognome
			, PazienteNome
			, PazienteDataNascita
			, PazienteSesso
			, PazienteCodiceFiscale
			, Paziente
			, Consensi
			, Note

		FROM 
			OrdiniTestate
			
		WHERE
			ID = @ID
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END






























GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniSelectByID] TO [DataAccessUi]
    AS [dbo];

