


-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-27
-- Modify date: 2011-01-27
-- Description:	Lista di testate ordine erogate
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniErogatiList]
	 
	 @idOrdineTestata as uniqueidentifier
		
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT 
			  T.ID as Id
			, T.DataInserimento
			, T.DataModifica	
			, ISNULL(T.IDRichiestaErogante,'') as IdRichiestaErogante
			, dbo.GetStatoCalcolato(@idOrdineTestata) as StatoOrderEntry
			, (CAST(T.StatoErogante.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Codice/text()') as varchar(max)) + ' - ' +
				   CAST(T.StatoErogante.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Descrizione/text()') as varchar(max))
				   ) AS StatoErogante	

			, SE.CodiceAzienda AS CodiceAziendaSistemaErogante
			, SE.Codice AS CodiceSistemaErogante
		FROM 
			OrdiniErogatiTestate T
			LEFT JOIN Sistemi SR ON SR.ID = T.IDSistemaRichiedente
			LEFT JOIN Sistemi SE ON SE.ID = T.IDSistemaErogante
			LEFT JOIN OrdiniErogatiStatiRisposta OESR ON OESR.Codice = T.StatoRisposta
			
		WHERE T.IDOrdineTestata = @idOrdineTestata
							
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniErogatiList] TO [DataAccessUi]
    AS [dbo];

