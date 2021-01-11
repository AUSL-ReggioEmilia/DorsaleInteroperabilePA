
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-02-25
-- Modify date: 2011-02-25
-- Description:	Testata erogato
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniErogatiTestateSelect]
	@idOrdineTestata uniqueidentifier
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			  T.ID
			, COALESCE(StatoOrderEntryAggregato, StatoOrderEntry) as StatoOrderEntry
			, COALESCE(CAST(T.StatoErogante.query('/CodiceDescrizioneType/Descrizione/text()') as varchar(max)),CAST(T.StatoErogante.query('/CodiceDescrizioneType/Codice/text()') as varchar(max))) as StatoErogante
			, Data
			--, Operatore
			, SE.CodiceAzienda AS CodiceAziendaSistemaErogante
			, SE.Codice AS CodiceSistemaErogante
			--, AnagraficaCodice
			--, AnagraficaNome
			--, PazienteIdRichiedente
			--, PazienteIdSac
			--, PazienteCognome
			--, PazienteNome
			--, PazienteDataNascita
			--, PazienteSesso
			--, PazienteCodiceFiscale
		
		FROM
			OrdiniErogatiTestate T INNER JOIN Sistemi SE ON SE.ID = T.IDSistemaRichiedente
			
		WHERE
			T.IDOrdineTestata = @idOrdineTestata
		
		
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END





































GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniErogatiTestateSelect] TO [DataAccessUi]
    AS [dbo];

