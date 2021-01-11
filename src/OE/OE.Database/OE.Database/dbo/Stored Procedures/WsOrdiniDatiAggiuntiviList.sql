
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-03-27
-- Modify date: 2015-08-03 Cambio del default Visibilita per i DatiAggiuntivi non classificati, ora è FALSE
-- Modify date: 2017-10-12 Ordina i dati per inserimento usando il TS
--							Serve per mantenere inalterata la sequenza dei nodi xml
-- Description:	Ritorna tutti i dati aggiuntivi di un ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniDatiAggiuntiviList]
	  @IDOrdineTestata uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DatiAggiuntiviNonClassificati AS BIT = 0

	SELECT  ID
		  , RiferimentoTipo
		  , RiferimentoId

		  , PrestazioneCodice
		  , PrestazioneSistemaCodice
		  , PrestazioneSistemaAzienda

		  , IDDatoAggiuntivo
		  , Nome
		  , TipoDato
		  , TipoContenuto
		  , ValoreDato
		  , ValoreDatoVarchar
		  , ValoreDatoXml
		  , ParametroSpecifico
		  , Persistente

		  , Descrizione
		  , Visibile
	FROM (
		--
		-- Unisco tutti i DatiAggiuntivi
		--
		SELECT  OTDA.ID
			  , CONVERT(VARCHAR(32), 'TestataRichiesta') AS RiferimentoTipo
			  , OTDA.IDOrdineTestata AS RiferimentoId

			  , CONVERT(VARCHAR(16), NULL) AS PrestazioneCodice
			  , CONVERT(VARCHAR(16), NULL)  AS PrestazioneSistemaCodice
			  , CONVERT(VARCHAR(16), NULL)  AS PrestazioneSistemaAzienda

			  , OTDA.IDDatoAggiuntivo
			  , OTDA.Nome
			  , OTDA.TipoDato
			  , OTDA.TipoContenuto
			  , OTDA.ValoreDato
			  , OTDA.ValoreDatoVarchar
			  , OTDA.ValoreDatoXml
			  , OTDA.ParametroSpecifico
			  , OTDA.Persistente

			  , DA.Descrizione
			  , ISNULL(DA.Visibile, @DatiAggiuntiviNonClassificati) AS Visibile

			  , OTDA.TS
			  , CONVERT(INT, 0) AS Ordinamento

		FROM dbo.OrdiniTestateDatiAggiuntivi OTDA
			LEFT OUTER JOIN dbo.DatiAggiuntivi DA ON DA.Nome = OTDA.Nome

		WHERE IDOrdineTestata = @IDOrdineTestata

		UNION ALL

		SELECT  ORRDA.ID
			  , CONVERT(VARCHAR(32), 'RigaRichiesta') AS RiferimentoTipo
			  , ORRDA.IDRigaRichiesta AS RiferimentoId

			  , P.Codice AS PrestazioneCodice
			  , S.Codice AS PrestazioneSistemaCodice
			  , S.CodiceAzienda AS PrestazioneSistemaAzienda

			  , ORRDA.IDDatoAggiuntivo
			  , ORRDA.Nome
			  , ORRDA.TipoDato
			  , ORRDA.TipoContenuto
			  , ORRDA.ValoreDato
			  , ORRDA.ValoreDatoVarchar
			  , ORRDA.ValoreDatoXml
			  , ORRDA.ParametroSpecifico
			  , ORRDA.Persistente

			  , DA.Descrizione
			  , ISNULL(DA.Visibile, @DatiAggiuntiviNonClassificati) AS Visibile

			  , ORRDA.TS
			  , CONVERT(INT, 2) AS Ordinamento

		FROM dbo.OrdiniRigheRichiesteDatiAggiuntivi ORRDA
			INNER JOIN dbo.OrdiniRigheRichieste ORR
				ON ORRDA.IDRigaRichiesta = ORR.ID

			INNER JOIN dbo.Prestazioni P
				ON P.ID =  ORR.IDPrestazione

			INNER JOIN dbo.Sistemi S
				ON S.ID = P.IDSistemaErogante

			INNER JOIN dbo.OrdiniTestate OT
				ON OT.ID = ORR.IDOrdineTestata 

			LEFT OUTER JOIN dbo.DatiAggiuntivi DA ON DA.Nome = ORRDA.Nome

		WHERE ORR.IDOrdineTestata = @IDOrdineTestata

		UNION ALL

		SELECT  OETDA.ID
			  , CONVERT(VARCHAR(32), 'TestataErogata') AS RiferimentoTipo
			  , OETDA.IDOrdineErogatoTestata AS RiferimentoId

			  , CONVERT(VARCHAR(16), NULL) AS PrestazioneCodice
			  , TES.Codice AS PrestazioneSistemaCodice
			  , TES.CodiceAzienda AS PrestazioneSistemaAzienda

			  , OETDA.IDDatoAggiuntivo
			  , OETDA.Nome
			  , OETDA.TipoDato
			  , OETDA.TipoContenuto
			  , OETDA.ValoreDato
			  , OETDA.ValoreDatoVarchar
			  , OETDA.ValoreDatoXml
			  , OETDA.ParametroSpecifico
			  , OETDA.Persistente

			  , DA.Descrizione
			  , ISNULL(DA.Visibile, @DatiAggiuntiviNonClassificati) AS Visibile

			  , OETDA.TS
			  , CONVERT(INT, 3) AS Ordinamento

		FROM OrdiniErogatiTestateDatiAggiuntivi OETDA
			
			INNER JOIN dbo.OrdiniErogatiTestate OET
				ON OET.ID = OETDA.IDOrdineErogatoTestata

			INNER JOIN dbo.Sistemi TES
				ON TES.ID = OET.IDSistemaErogante

			LEFT OUTER JOIN dbo.DatiAggiuntivi DA ON DA.Nome = OETDA.Nome

		WHERE OET.IDOrdineTestata = @IDOrdineTestata
	
		UNION ALL

		SELECT  OREDA.ID
			  , CONVERT(VARCHAR(32), 'RigaErogata') AS RiferimentoTipo
			  , OREDA.IDRigaErogata AS RiferimentoId

			  , P.Codice AS PrestazioneCodice
			  , TES.Codice AS PrestazioneSistemaCodice
			  , TES.CodiceAzienda AS PrestazioneSistemaAzienda

			  , OREDA.IDDatoAggiuntivo
			  , OREDA.Nome
			  , OREDA.TipoDato
			  , OREDA.TipoContenuto
			  , OREDA.ValoreDato
			  , OREDA.ValoreDatoVarchar
			  , OREDA.ValoreDatoXml
			  , OREDA.ParametroSpecifico
			  , OREDA.Persistente

			  , DA.Descrizione
			  , ISNULL(DA.Visibile, @DatiAggiuntiviNonClassificati) AS Visibile

			  , OREDA.TS
			  , CONVERT(INT, 4) AS Ordinamento

		FROM OrdiniRigheErogateDatiAggiuntivi OREDA
			INNER JOIN dbo.OrdiniRigheErogate ORE
				ON OREDA.IDRigaErogata = ORE.ID

			INNER JOIN dbo.Prestazioni P
				ON P.ID =  ORE.IDPrestazione

			INNER JOIN dbo.OrdiniErogatiTestate OET
				ON OET.ID = ORE.IDOrdineErogatoTestata

			INNER JOIN dbo.Sistemi TES
				ON TES.ID = OET.IDSistemaErogante

			LEFT OUTER JOIN dbo.DatiAggiuntivi DA ON DA.Nome = OREDA.Nome

		WHERE OET.IDOrdineTestata = @IDOrdineTestata
		
		--
		-- Fine Unione dei dati
		--
		) DatiAggiuntivi
	
	ORDER BY Ordinamento, TS

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniDatiAggiuntiviList] TO [DataAccessWs]
    AS [dbo];

