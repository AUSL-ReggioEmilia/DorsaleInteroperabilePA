

-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-02-23
-- Description:	Lista di dati aggiuntivi testata
-- Modify date: 2015-04-28 Stefano: Aggiunto campo 'Visibile' in output 
-- Modify date: 2015-08-03 Stefano P.: Invertito il default del flag Visibile, aggiunto campo Descrizione
-- Modify date: 2017-10-12 Ordina i dati per inserimento usando il TS
--							Serve per mantenere inalterata la sequenza dei nodi xml
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniErogatiTestateDatiAggiuntiviList]
	@idOrdineTestata uniqueidentifier = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @DatiAggiuntivi xml
	
		SET @DatiAggiuntivi = 
		(
			SELECT
			  TestataOrdine.ID AS IDOrderEntry
			, (CAST(Operatore.query('/OperatoreType/Cognome/text()') as varchar(64)) + ' ' + CAST(Operatore.query('/OperatoreType/Nome/text()') as varchar(64))) AS Operatore
			, DatoAggiuntivo.DataInserimento
			, DatoAggiuntivo.DataModifica
			, DatoAggiuntivo.IDDatoAggiuntivo
			, DatoAggiuntivo.Nome
			, DatoAggiuntivo.TipoDato AS Tipo
			, DatoAggiuntivo.TipoContenuto
			, COALESCE(CAST(DatoAggiuntivo.ValoreDato AS varchar(8000)),
				DatoAggiuntivo.ValoreDatoVarchar, DatoAggiuntivo.ValoreDatoXml) AS Valore
			, CAST(COALESCE(DA.Visibile, 0) AS BIT) AS Visibile
			, CAST(COALESCE(DA.Descrizione,'') AS VARCHAR(256)) AS Descrizione
			
			FROM 
				dbo.OrdiniErogatiTestateDatiAggiuntivi AS DatoAggiuntivo
			INNER JOIN 
				dbo.OrdiniErogatiTestate TestataOrdine ON DatoAggiuntivo.IDOrdineErogatoTestata = TestataOrdine.ID
			LEFT JOIN 
				dbo.DatiAggiuntivi AS DA ON DatoAggiuntivo.Nome = DA.Nome
	
			WHERE
				TestataOrdine.ID = @idOrdineTestata
				
			ORDER BY 
				DatoAggiuntivo.TS			
				
			FOR XML AUTO, ELEMENTS
		)
		
		SELECT @DatiAggiuntivi AS DatiAggiuntivi
					
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniErogatiTestateDatiAggiuntiviList] TO [DataAccessUi]
    AS [dbo];

