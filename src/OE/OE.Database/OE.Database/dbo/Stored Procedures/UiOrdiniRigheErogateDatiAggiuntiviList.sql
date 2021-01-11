-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-03-15
-- Description:	Lista di dati aggiuntivi riga erogata
-- Modify date: 2015-04-28 Stefano: Aggiunto campo 'Visibile' in output 
-- Modify date: 2015-08-03 Stefano P.: Invertito il default del flag Visibile, aggiunto campo Descrizione
-- Modify date: 2017-10-12 Ordina i dati per inserimento usando il TS
--							Serve per mantenere inalterata la sequenza dei nodi xml
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniRigheErogateDatiAggiuntiviList]
	@idRigaErogata uniqueidentifier = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @DatiAggiuntivi xml
	
		SET @DatiAggiuntivi = 
		(
			SELECT
			  TestataOrdine.ID AS IDOrderEntry
			, (CAST(TestataOrdine.Anno AS varchar(4)) + '/' + CAST(TestataOrdine.Numero AS varchar(16))) AS Protocollo
			, (CAST(TestataOrdine.Operatore.query('/OperatoreType/Cognome/text()') as varchar(64)) 
				+ ' ' + CAST(TestataOrdine.Operatore.query('/OperatoreType/Nome/text()') as varchar(64))) AS Operatore

			, DatoAggiuntivo.DataInserimento
			, DatoAggiuntivo.DataModifica
			, DatoAggiuntivo.IDDatoAggiuntivo
			, DatoAggiuntivo.Nome
			, DatoAggiuntivo.TipoDato AS Tipo
			, DatoAggiuntivo.TipoContenuto
			, COALESCE(CAST(DatoAggiuntivo.ValoreDato AS varchar(8000)), 
							DatoAggiuntivo.ValoreDatoVarchar, 
							DatoAggiuntivo.ValoreDatoXml) AS Valore
			, CAST(COALESCE(DA.Visibile, 0) AS BIT) AS Visibile
			, CAST(COALESCE(DA.Descrizione,'') AS VARCHAR(256)) AS Descrizione

			FROM 
				dbo.OrdiniRigheErogateDatiAggiuntivi AS DatoAggiuntivo
			INNER JOIN 
				dbo.OrdiniRigheErogate RigaErogata ON RigaErogata.ID = DatoAggiuntivo.IDRigaErogata			
			INNER JOIN 
				dbo.OrdiniErogatiTestate TestataErogataOrdine ON RigaErogata.IDOrdineErogatoTestata = TestataErogataOrdine.ID
			LEFT JOIN 
				dbo.OrdiniTestate TestataOrdine ON TestataErogataOrdine.IDOrdineTestata = TestataOrdine.ID
			LEFT JOIN 
				dbo.DatiAggiuntivi AS DA ON DatoAggiuntivo.Nome = DA.Nome
	
			WHERE 
				IDRigaErogata = @idRigaErogata
				
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
    ON OBJECT::[dbo].[UiOrdiniRigheErogateDatiAggiuntiviList] TO [DataAccessUi]
    AS [dbo];

