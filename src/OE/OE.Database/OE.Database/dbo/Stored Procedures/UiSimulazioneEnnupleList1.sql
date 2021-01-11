

-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-02-23
-- Description:	S/leziona la prestazione per descrizione e unità operativa
-- Modified: il 05/08/2014 da Valerio Cremonini - Aggiunta il bit attivo/disattivo della prestazione
-- =============================================
CREATE PROCEDURE [dbo].[UiSimulazioneEnnupleList1]

	  @nomeUtente varchar(64)
	, @giorno as datetime2(0) 
	, @idUnitaOperativa uniqueidentifier
	, @idSistemaRichiedente uniqueidentifier
	, @codiceRegime varchar(16)
	, @codicePriorita varchar(16)
	, @idStato as tinyint = NULL
	, @prestazioneCodiceDescrizione as varchar(max) = NULL
    , @idSistemaErogante as uniqueidentifier = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1
		
	BEGIN TRY
	
			-- Tabella temporanea contenente le ennuple
		DECLARE @T TABLE (IdGruppoPrestazioni uniqueidentifier, [Not] bit NOT NULL) 
		DECLARE @ID TABLE (ID uniqueidentifier) 
		
		INSERT INTO @T 
			SELECT * FROM dbo.GetUiEnnuple1(@nomeUtente, @giorno, @idUnitaOperativa, @idSistemaRichiedente, @codiceRegime, @codicePriorita, @idStato)
			
        INSERT INTO @ID
			SELECT DISTINCT P1.ID FROM
		(
			SELECT PGP.IDPrestazione as ID
			FROM @T T
				INNER JOIN PrestazioniGruppiPrestazioni PGP on T.IdGruppoPrestazioni = PGP.IDGruppoPrestazioni				
			
		      WHERE T.[Not] = 0							
			UNION 
			
			SELECT P.ID
			FROM Prestazioni P		
				
			  WHERE (SELECT COUNT(*) FROM @T T WHERE T.[Not] = 0 AND IdGruppoPrestazioni IS NULL) >= 1								
		) P1 		
			
		EXCEPT
		
		-- Tutte le prestazioni in [Not]
		SELECT DISTINCT P2.* FROM
		(
			SELECT PGP.IDPrestazione as ID
			FROM @T T
				INNER JOIN PrestazioniGruppiPrestazioni PGP on T.IdGruppoPrestazioni = PGP.IDGruppoPrestazioni
			WHERE T.[Not] = 1
			
			UNION
			
			SELECT P.ID
			FROM Prestazioni P			
			WHERE (SELECT COUNT(*) FROM @T T WHERE T.[Not] = 1 AND IdGruppoPrestazioni IS NULL) >= 1
		) P2	

		-- Tutte le prestazioni ordinabili
		SELECT DISTINCT 
		P.ID, 
		P.DataInserimento, 
		P.DataModifica, 
		P.IDTicketInserimento, 
		P.IDTicketModifica, 
		P.TS, 
		P.Codice, 
		P.Descrizione + CASE WHEN P.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END AS Descrizione, 
		P.Tipo, 
		P.Provenienza, 
		P.IDSistemaErogante,
		P.Attivo,
		S.CodiceAzienda AS CodiceAzienda, 
		A.Descrizione AS DescrizioneAzienda, 
		S.Codice AS CodiceSistema, 
		S.Descrizione + CASE WHEN S.Attivo = 0 THEN ' (Disattivo)'  ELSE '' END AS DescrizioneSistema		
		
		FROM Prestazioni P INNER JOIN Sistemi S ON S.ID = P.IDSistemaErogante
						   INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda						
						   INNER JOIN @ID as Erogabile ON P.ID = Erogabile.ID
	    WHERE 
	     (@prestazioneCodiceDescrizione IS NULL OR P.[Codice] LIKE '%' + @prestazioneCodiceDescrizione + '%' OR P.Descrizione LIKE '%' + @prestazioneCodiceDescrizione + '%')
          AND (@idSistemaErogante IS NULL OR P.IDSistemaErogante = @idSistemaErogante)
  	
		ORDER BY P.Codice DESC
						
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END













GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSimulazioneEnnupleList1] TO [DataAccessUi]
    AS [dbo];

