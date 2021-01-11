-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-02-23
-- Modify date: 2015-04-28 Stefano P.: Aggiunto campo 'Visibile' in output 
-- Modify date: 2015-08-03 Stefano P.: Invertito il default del flag Visibile, aggiunto campo Descrizione
-- Modify date: 2017-10-12 Ordina i dati per inserimento usando il TS
--							Serve per mantenere inalterata la sequenza dei nodi xml
-- Description:	Lista di dati aggiuntivi testata
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniTestateDatiAggiuntiviList]
	@idOrdineTestata uniqueidentifier = NULL	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @DatiAggiuntivi XML
	
		SET @DatiAggiuntivi = 
		(
			SELECT
			  TestataOrdine.ID AS IDOrderEntry
			, (CAST(TestataOrdine.Anno AS VARCHAR(4)) + '/' + CAST(TestataOrdine.Numero AS VARCHAR(16))) AS Protocollo
			, (CAST(Operatore.query('/OperatoreType/Cognome/text()') AS VARCHAR(64)) 
				+ ' ' + CAST(Operatore.query('/OperatoreType/Nome/text()') AS VARCHAR(64))) AS Operatore				
			, DatoAggiuntivo.DataInserimento
			, DatoAggiuntivo.DataModifica				
			, DatoAggiuntivo.IDDatoAggiuntivo
			, DatoAggiuntivo.Nome
			, DatoAggiuntivo.TipoDato AS Tipo
			, DatoAggiuntivo.TipoContenuto
			, COALESCE(CAST(DatoAggiuntivo.ValoreDato AS VARCHAR(8000)), 
						DatoAggiuntivo.ValoreDatoVarchar, DatoAggiuntivo.ValoreDatoXml) AS Valore
			, CAST(COALESCE(DA.Visibile, 0) AS BIT) AS Visibile
			, CAST(COALESCE(DA.Descrizione,'') AS VARCHAR(256)) AS Descrizione

			FROM 
				dbo.OrdiniTestateDatiAggiuntivi AS DatoAggiuntivo
			INNER JOIN 
				dbo.OrdiniTestate AS TestataOrdine ON DatoAggiuntivo.IDOrdineTestata = TestataOrdine.ID 
			LEFT JOIN 
				dbo.DatiAggiuntivi AS DA ON DatoAggiuntivo.Nome = DA.Nome
				
			WHERE 
				DatoAggiuntivo.IDOrdineTestata = @idOrdineTestata
				
			ORDER BY 
				DatoAggiuntivo.TS			
				
			FOR XML AUTO, ELEMENTS
		)
		
		SELECT @DatiAggiuntivi AS DatiAggiuntivi
					
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniTestateDatiAggiuntiviList] TO [DataAccessUi]
    AS [dbo];

