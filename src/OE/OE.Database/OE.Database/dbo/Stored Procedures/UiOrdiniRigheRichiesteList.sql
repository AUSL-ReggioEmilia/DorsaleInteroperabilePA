-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-30
-- Modify date: 2011-02-16
-- Modify date: 2015-10-19 Sandro: Usa nuova dbo.[GetStatoCalcolatoRigheRichieste]()
-- Modify date: 2015-10-20 Stefano: aggiunto campo DataPianificataRigaErogata
-- Description:	Seleziona le righe ordine richieste
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniRigheRichiesteList]
	@idTestataOrderEntry uniqueidentifier,
	@IDSistemaErogante uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY	

		SELECT
			  Rr.ID as IdRigaRichiesta
			, Rr.DataInserimento AS DataInserimentoRigaRichiesta
			, Rr.DataModifica AS DataModificaRigaRichiesta
		    , Rr.DataModificaStato AS DataModificaStatoRigaRichiesta
			, Rr.IDRigaRichiedente as IdRigaRichiedente
			, T.IDSistemaRichiedente as IdSistemaRichiedente
			, Rr.StatoOrderEntry as StatoOrderEntryRichiedente
			, dbo.[GetStatoCalcolatoRigheRichieste](T.StatoOrderEntry, Rr.StatoOrderEntry) AS StatoOrderEntryDescrizione
			, NULL as IdRigaErogata
			, P.Codice as PrestazioneCodice
			, CASE Tipo
					   WHEN 0 THEN ISNULL(P.[Descrizione],P.Codice)
					   WHEN 1 THEN  ISNULL('(Profilo) ' + P.[Descrizione],P.Codice)
					   WHEN 2 THEN  ISNULL('(Profilo) ' + P.[Descrizione],P.Codice)
					   ELSE ISNULL(P.[Descrizione],P.Codice)      
					   END
			  AS PrestazioneDescrizione			
			, NULL AS DataInserimentoRigaErogata
			, NULL AS DataModificaRigaErogata
			, NULL AS DataModificaStatoRigaErogata
			, NULL AS DataPianificataRigaErogata
			, NULL as IdRigaErogante
			, NULL as IdRigaRichiedenteDaErogante
			, NULL as IdOrdineErogatoTestata
			, NULL as StatoOrderEntryErogante
			, NULL as StatoOrderEntryEroganteDescrizione
			, NULL as IdRichiestaErogante
			, NULL AS StatoErogante	
			, NULL as Data
			, NULL as Operatore
		FROM OrdiniRigheRichieste Rr
				INNER JOIN OrdiniTestate T ON T.ID = Rr.IDOrdineTestata
				INNER JOIN Prestazioni P ON P.ID = Rr.IDPrestazione
			WHERE IDOrdineTestata = @IDTestataOrderEntry
		      and Rr.IDSistemaErogante = @IDSistemaErogante
					
		ORDER BY P.Codice
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniRigheRichiesteList] TO [DataAccessUi]
    AS [dbo];

