
-- =============================================
-- Author: Alessandro Nostini
-- Create date: 2014-01-27
-- Modify date: 2014-01-27
-- Description:	Seleziona le riga ordine richieste by idordine e idRiga con dati sistema e prestazioni
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheRichiesteSelectByRigaRichiedente2]
	  @IDOrdineTestata uniqueidentifier
	, @IDRigaRichiedente varchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
		SELECT orr.ID
			, orr.IDOrdineTestata
			, orr.StatoOrderEntry
			, orr.DataModificaStato
			
			, orr.IDPrestazione
			, p.Codice AS CodicePrestazione
			, p.Descrizione AS DescrizionePrestazione
			, p.Tipo AS TipoPrestazione
			
			, orr.IDSistemaErogante
			, s.CodiceAzienda AS CodiceAziendaSistemaErogante
			, a.Descrizione AS DescrizioneAziendaSistemaErogante
			, s.Codice AS CodiceSistemaErogante
			, s.Descrizione AS DescrizioneSistemaErogante

			, orr.IDRigaOrderEntry
			, orr.IDRigaRichiedente
			, orr.IDRigaErogante
			, orr.IDRichiestaErogante
			, orr.StatoRichiedente
			, orr.Consensi
			
		FROM OrdiniRigheRichieste orr
			INNER JOIN Prestazioni p ON orr.IDPrestazione = p.ID
			INNER JOIN Sistemi s ON orr.IDSistemaErogante = s.ID
			INNER JOIN Aziende a ON s.CodiceAzienda = a.Codice
			
		WHERE orr.IDOrdineTestata = @IDOrdineTestata
			AND orr.IDRigaRichiedente = @IDRigaRichiedente
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniRigheRichiesteSelectByRigaRichiedente2] TO [DataAccessMsg]
    AS [dbo];

