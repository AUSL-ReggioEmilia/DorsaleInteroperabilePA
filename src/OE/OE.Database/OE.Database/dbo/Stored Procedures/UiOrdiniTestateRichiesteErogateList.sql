

-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-27
-- Modify date: 2011-01-27
-- Description:	Lista distinct testate ordine richieste e erogate, raggruppate per sistema erogante
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniTestateRichiesteErogateList]
	 
	 @idOrdineTestata as uniqueidentifier
		
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT 
			  T.ID as Id
			, T.DataInserimento
			, T.DataModifica	
			, ISNULL(T.IDRichiestaErogante,'') AS IdRichiestaErogante
			--, COALESCE(OES.Descrizione, OESR.Descrizione) as StatoOrderEntry
			,dbo.GetStatoCalcolato(@idOrdineTestata) as StatoOrderEntry
			, (CAST(T.StatoErogante.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Codice/text()') as varchar(max))+' - '+CAST(T.StatoErogante.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Descrizione/text()') as varchar(max))) AS StatoErogante	

			, SE.CodiceAzienda AS CodiceAziendaSistemaErogante
			, SE.Codice AS CodiceSistemaErogante
			, T.IDSistemaErogante 
			, CAST (1 AS BIT) AS Erogato
			
		FROM 
			OrdiniErogatiTestate T
			LEFT JOIN Sistemi SR ON SR.ID = T.IDSistemaRichiedente
			LEFT JOIN Sistemi SE ON SE.ID = T.IDSistemaErogante
			--LEFT JOIN OrdiniErogatiStati OES ON OES.Codice = T.StatoOrderEntry
			LEFT JOIN OrdiniErogatiStatiRisposta OESR ON OESR.Codice = T.StatoRisposta
			
		WHERE T.IDOrdineTestata = @idOrdineTestata
		
		UNION
		
		SELECT NEWID() as Id, tmp.* FROM(
	
		SELECT DISTINCT
			 
			  '' as DataInserimento
			, '' as DataModifica	
			, '' as IdRichiestaErogante				
			, '' as StatoOrderEntry
			, '' as StatoErogante
			--, GETDATE() as Data			
			, SE.CodiceAzienda AS CodiceAziendaSistemaErogante
			, SE.Codice AS CodiceSistemaErogante	
			, ORR.IDSistemaErogante	
			, CAST (0 AS BIT) AS Erogato
			
		FROM
			Sistemi SE INNER JOIN OrdiniRigheRichieste ORR on ORR.IDSistemaErogante =  SE.ID
			
		WHERE
			ORR.IDOrdineTestata = @idOrdineTestata AND SE.Codice NOT IN 
			
																( -- Escludo le prestazioni che hanno un riferimento in erogato
																SELECT DISTINCT  SE.Codice AS CodiceSistemaErogante
																FROM 
																OrdiniErogatiTestate T
																LEFT JOIN Sistemi SR ON SR.ID = T.IDSistemaRichiedente
																LEFT JOIN Sistemi SE ON SE.ID = T.IDSistemaErogante
																--LEFT JOIN OrdiniErogatiStati OES ON OES.Codice = T.StatoOrderEntry
																LEFT JOIN OrdiniErogatiStatiRisposta OESR ON OESR.Codice = T.StatoRisposta			
																WHERE T.IDOrdineTestata = @idOrdineTestata
																)			
		) as tmp
							
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniTestateRichiesteErogateList] TO [DataAccessUi]
    AS [dbo];

