
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-03-09
-- Modify date: 2019-11-06: SANDRO - Legge la DataOperazione invece che la DataInserimento
-- Modify date: 2019-12-12: SANDRO - Ordinamento sia su DataOperazione che su DataInserimento
--
-- Description:	Legge la lista dei messaggi di RICHIESTA e STATO ordinati in sequenza temporale inversa
--				
--
-- =============================================
CREATE PROCEDURE [dbo].[UiTrackingList]
(
 @idOrdineTestata uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT Id, 
	   COALESCE(DataOperazione, DataInserimento) AS DataInserimento,
	   Sistema, 
	   CASE WHEN Tipo = 'Stato' THEN COALESCE((SELECT Descrizione from OrdiniErogatiStati where Codice = StatoOE)
												,(SELECT Descrizione from OrdiniErogatiStatiRisposta where Codice = StatoOE), StatoOE)

			ELSE (SELECT Descrizione from OrdiniStati where Codice = StatoOE) END AS StatoOE, 
	   Stato
	FROM
		(
		--
		-- Messaggi STATO
		--
		SELECT MS.[ID] as Id
     
			,MS.DataInserimento
			,Messaggio.value('declare default element namespace "http://schemas.progel.it/BT/OE/DataAccess/StatoParameter/1.1";declare namespace a="http://schemas.progel.it/BT/OE/QueueTypes/1.1";(/StatoParameter/StatoQueue/a:DataOperazione)[1]', 'DATETIME') AS DataOperazione

			,(SE.CodiceAzienda + ' ' + SE.Codice + ' ('+ CAST(Messaggio.query('declare default element namespace "http://schemas.progel.it/BT/OE/DataAccess/StatoParameter/1.1";declare namespace a="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/StatoParameter/StatoQueue/a:TipoStato/text()') AS VARCHAR(4)) +')') AS Sistema
			,MS.StatoOrderEntry AS StatoOE

			,[Stato]
			,CONVERT(VARCHAR(16), 'Stato') AS Tipo
      
		FROM MessaggiStati MS
			LEFT JOIN OrdiniErogatiTestate OET on OET.ID = MS.IDOrdineErogatoTestata
			LEFT JOIN Sistemi SE ON SE.ID = OET.IDSistemaErogante
					  
		WHERE OET.IDOrdineTestata = @IDOrdineTestata
		
		UNION ALL

		--
		-- Messaggi RICHIESTA
		--		
		SELECT MR.[ID] as Id
			,MR.DataInserimento
			,COALESCE(Messaggio.value('declare default element namespace "http://schemas.progel.it/BT/OE/DataAccess/RichiestaParameter/1.1";declare namespace a="http://schemas.progel.it/BT/OE/QueueTypes/1.1";(/RichiestaParameter/RichiestaQueue/a:DataOperazione)[1]', 'DATETIME')
					, MR.DataInserimento
				) AS DataOperazione

			,(SR.CodiceAzienda + ' ' + SR.Codice + ' (Ric.)') AS Sistema

			-- Il campo StatoOrderEntry non è valorizzato per le richiesta da MSG
			-- Da valutare di sistemare il processo di inserimento
			--
			-- sandro: 2019-11-06
			--
			,COALESCE( MR.StatoOrderEntry
					, Messaggio.value('declare default element namespace "http://schemas.progel.it/BT/OE/DataAccess/RichiestaParameter/1.1";declare namespace a="http://schemas.progel.it/BT/OE/QueueTypes/1.1";(/RichiestaParameter/RichiestaQueue/a:Testata/a:OperazioneOrderEntry)[1]', 'VARCHAR(4)')
				) AS StatoOE

			,[Stato]
			,CONVERT(VARCHAR(16), 'Richiesta') AS Tipo
      
       FROM MessaggiRichieste MR
			LEFT JOIN OrdiniTestate OT ON OT.ID = MR.IDOrdineTestata
			LEFT JOIN Sistemi SR ON SR.ID = OT.IDSistemaRichiedente
       
       WHERE MR.IDOrdineTestata = @IDOrdineTestata

	   ) AS Tracking
       
    ORDER BY Tracking.DataOperazione DESC, Tracking.DataInserimento DESC

END














GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiTrackingList] TO [DataAccessUi]
    AS [dbo];

