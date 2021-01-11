
-- =============================================
-- Author:		
-- Modify date: 2013-11-05
-- Modify date: 2015-10-19 Sandro - Nuova [GetStatoCalcolatoRigheRichieste]
-- Modify date: 2015-10-20 StefanoP - Legge CORE_DataPianificata
-- Description:	Ritorna l'elenco delle righe richieste-erogate di un ordine
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniRigheList]
	@idTestataOrderEntry uniqueidentifier,
	@idTestataOrdineErogato uniqueidentifier = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	
		DECLARE @IDSistemaErogante uniqueidentifier = (select IDSistemaErogante from OrdiniErogatiTestate where ID = @idTestataOrdineErogato)
		DECLARE @RigheRichieste TABLE (IDRigaRichiesta uniqueidentifier,
									   DataInserimento datetime2(0),
									   DataModifica datetime2(0),
									   DataModificaStato datetime2(0),
									   IDOrdineTestata uniqueidentifier,
									   IDRigaRichiedente varchar(64),
									   StatoOrderEntry varchar(16),
									   StatoOrderEntryDescrizione varchar(128),
									   IDSistemaRichiedente uniqueidentifier,
									   IDPrestazione uniqueidentifier,
									   PrestazioneCodice varchar(16),
									   PrestazioneDescrizione varchar(256),
									   Consensi xml)

		-- Insert into
		INSERT INTO @RigheRichieste
			SELECT 
				  Rr.ID
				, Rr.DataInserimento
				, Rr.DataModifica
				, Rr.DataModificaStato
				, Rr.IDOrdineTestata
				, Rr.IDRigaRichiedente
				, Rr.StatoOrderEntry
				, dbo.[GetStatoCalcolatoRigheRichieste](T.StatoOrderEntry, Rr.StatoOrderEntry) AS StatoOrderEntryDescrizione
				, T.IDSistemaRichiedente
				, Rr.IDPrestazione
				, P.Codice				
				, CASE Tipo
					   WHEN 0 THEN ISNULL(P.[Descrizione],P.Codice)
					   WHEN 1 THEN  ISNULL('(Profilo) ' + P.[Descrizione],P.Codice)
					   WHEN 2 THEN  ISNULL('(Profilo) ' + P.[Descrizione],P.Codice)
					   ELSE ISNULL(P.[Descrizione],P.Codice)      
					   END
				  AS Descrizione       
				--, P.Descrizione
				, Rr.Consensi
			FROM OrdiniRigheRichieste Rr
				INNER JOIN OrdiniTestate T ON T.ID = Rr.IDOrdineTestata
				INNER JOIN Prestazioni P ON P.ID = Rr.IDPrestazione
			WHERE IDOrdineTestata = @IDTestataOrderEntry
			 AND (@idTestataOrdineErogato is null or Rr.IDSistemaErogante = @IDSistemaErogante)

		--
		-- Variabile tabella per le righe erogate
		--
		DECLARE @RigheErogate TABLE (IDOrdineTestata uniqueidentifier,
									 IDRigaErogata uniqueidentifier,
									 DataInserimento datetime2(0),
									 DataModifica datetime2(0),
									 DataModificaStato datetime2(0),
									 DataPianificata datetime2(0),
									 IDRigaRichiedente varchar(64),
									 IDRigaErogante varchar(64),
									 IDRichiestaErogante varchar(64),
									 IDSistemaRichiedente uniqueidentifier,
									 IDOrdineErogatoTestata uniqueidentifier,
									 StatoOrderEntry varchar(16),
									 StatoOrderEntryDescrizione varchar(128),
									 IDPrestazione uniqueidentifier,
									 PrestazioneCodice varchar(16),
									 PrestazioneDescrizione varchar(256),									 
									 StatoErogante xml,
									 Data datetime,
									 Operatore xml,
									 Consensi xml)
		-- Insert into
		INSERT INTO @RigheErogate 
			SELECT
				  T.IDOrdineTestata
				, Re.ID
				, Re.DataInserimento
				, Re.DataModifica
				, Re.DataModificaStato
				, NULL AS DataPianificata
				, Re.IDRigaRichiedente
				, Re.IDRigaErogante
				, T.IDRichiestaErogante
				, T.IDSistemaRichiedente
				, Re.IDOrdineErogatoTestata
				, Re.StatoOrderEntry 
				, ORES.Descrizione as StatoOrderEntryDescrizione
				, Re.IDPrestazione
				, P.Codice
				, P.Descrizione 
				, Re.StatoErogante
				, Re.Data
				, Re.Operatore 
				, Re.Consensi
				
			FROM OrdiniRigheErogate Re
				INNER JOIN OrdiniErogatiTestate T ON Re.IDOrdineErogatoTestata = T.ID
				INNER JOIN Prestazioni P ON P.ID = Re.IDPrestazione
				LEFT JOIN OrdiniRigheErogateStati ORES on ORES.Codice = Re.StatoOrderEntry
			WHERE T.IDOrdineTestata = @IDTestataOrderEntry
			  AND (@idTestataOrdineErogato IS NULL OR Re.IDOrdineErogatoTestata = @idTestataOrdineErogato)
		
		--
		-- CARICO (SE ESISTE) ANCHE LA DATAPIANIFICATA CHE E' UN DATO AGGIUNTIVO
		--
		UPDATE @RigheErogate  
		SET DataPianificata = CAST(DA.ValoreDato AS DATETIME2) 
		FROM @RigheErogate RE 
		INNER JOIN dbo.OrdiniRigheErogateDatiAggiuntivi DA ON RE.IDRigaErogata = DA.IDRigaErogata
				AND DA.Nome='CORE_DataPianificata'
				AND DA.IDDatoAggiuntivo = '00000001-0000-0000-0000-111111111111'


		--
		-- Full join
		--
		SELECT
			  Rr.IDRigaRichiesta as IdRigaRichiesta
			, Rr.DataInserimento AS DataInserimentoRigaRichiesta
			, Rr.DataModifica AS DataModificaRigaRichiesta
		    , Rr.DataModificaStato AS DataModificaStatoRigaRichiesta
			, Rr.IDRigaRichiedente as IdRigaRichiedente
			, Rr.IDSistemaRichiedente as IdSistemaRichiedente
			, Rr.StatoOrderEntry as StatoOrderEntryRichiedente
			, Rr.StatoOrderEntryDescrizione as StatoOrderEntryRichiedenteDescrizione
			, Re.IDRigaErogata as IdRigaErogata
			, COALESCE(Re.PrestazioneCodice, Rr.PrestazioneCodice) AS PrestazioneCodice
			, dbo.GetDescrizionePrestazioneByIDRigaRichiedente(Rr.IDOrdineTestata, Rr.IDRigaRichiedente) AS PrestazioneDescrizione
			, Re.DataInserimento AS DataInserimentoRigaErogata
			, Re.DataModifica AS DataModificaRigaErogata
			, Re.DataModificaStato AS DataModificaStatoRigaErogata
			, Re.DataPianificata as DataPianificataRigaErogata
			, Re.IDRigaErogante as IdRigaErogante
			, Re.IDRigaRichiedente as IdRigaRichiedenteDaErogante
			, Re.IDOrdineErogatoTestata as IdOrdineErogatoTestata
			, Re.StatoOrderEntry as StatoOrderEntryErogante
			, Re.StatoOrderEntryDescrizione as StatoOrderEntryEroganteDescrizione
			, Re.IDRichiestaErogante as IdRichiestaErogante
			, COALESCE(CAST(Re.StatoErogante.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Codice/text()') as varchar(max)), 
						CAST(Re.StatoErogante.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Descrizione/text()') as varchar(max))
						) AS StatoErogante	
			, Re.Data
			, (CAST(Re.Operatore.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:OperatoreType/s:Cognome/text()') as varchar(max)) + ' ' 
				+ CAST(Re.Operatore.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:OperatoreType/s:Nome/text()') as varchar(max))
					) as Operatore

		FROM @RigheRichieste Rr
			FULL OUTER JOIN @RigheErogate Re 
				ON Rr.PrestazioneCodice = Re.PrestazioneCodice AND Rr.IDOrdineTestata = Re.IDOrdineTestata
					
		ORDER BY Re.PrestazioneCodice
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniRigheList] TO [DataAccessUi]
    AS [dbo];

