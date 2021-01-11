
-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-02-23
-- Modify date: Sandro 2013-10-02 Aggiunto filtro prestazioneAttivo=1
-- Modify date: Sandro 2013-10-02 Aggiunto filtro Sistema.Attivo=1 OR Sistema.ID = '00000000-0000-0000-0000-000000000000')
-- Description:	Ritorna un elenco di prestazioni
--					Usata nel WS CercaPrestazioniProfiliUtentePerCodiceODescrizione()
-- =============================================
CREATE PROCEDURE [dbo].[WsPrestazioniErogabiliProfiliListByCodiceDescrizione]
	  @utente varchar(64)
	, @idSistemaRichiedente uniqueidentifier
	, @idSistemaErogante uniqueidentifier
	, @valore varchar(256)
AS
BEGIN
-- Questo metodo è usato per cercare le prestazioni da usare in un profiloUtente
-- Non dovrebbe valutare le ennuple completamente per poter comporre il profilo anche fuori contesto
--
	SET NOCOUNT ON;

	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1
	
	BEGIN TRY
			--Se filtro scarso abbasso il TOP
		DECLARE @MaxRecord INT = 2000
		IF @valore IS NULL OR LEN(@valore) < 2
			SET @MaxRecord = 500
	
		-- Tabella temporanea contenente le ennuple
		DECLARE @T TABLE (IdGruppoPrestazioni uniqueidentifier, [Not] bit NOT NULL) 
		INSERT INTO @T 
			SELECT * FROM dbo.GetEnnupleProfili(@utente, @idSistemaRichiedente)

		-- Tutte le prestazioni ordinabili
		SELECT DISTINCT TOP (@MaxRecord) P1.* FROM
		(
			SELECT P.ID, P.DataInserimento, P.DataModifica, P.IDTicketInserimento, P.IDTicketModifica
				, P.TS, P.Codice, P.Descrizione, P.Tipo, P.Provenienza, P.IDSistemaErogante
				, S.CodiceAzienda AS CodiceAzienda, A.Descrizione AS DescrizioneAzienda
				, S.Codice AS CodiceSistema, S.Descrizione AS DescrizioneSistema
			FROM @T T
				INNER JOIN PrestazioniGruppiPrestazioni PGP on T.IdGruppoPrestazioni = PGP.IDGruppoPrestazioni
				INNER JOIN Prestazioni P on P.ID = PGP.IDPrestazione
				INNER JOIN Sistemi S ON P.IDSistemaErogante = S.ID
				INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda
			WHERE T.[Not] = 0
				AND P.Attivo = 1
				AND (S.Attivo = 1 OR S.ID = '00000000-0000-0000-0000-000000000000')
			
			UNION 
			
			SELECT P.ID, P.DataInserimento, P.DataModifica, P.IDTicketInserimento, P.IDTicketModifica
				, P.TS, P.Codice, P.Descrizione, P.Tipo, P.Provenienza, P.IDSistemaErogante
				, S.CodiceAzienda AS CodiceAzienda, A.Descrizione AS DescrizioneAzienda
				, S.Codice AS CodiceSistema, S.Descrizione AS DescrizioneSistema			
			FROM Prestazioni P
				INNER JOIN Sistemi S ON P.IDSistemaErogante = S.ID
				INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda	
			WHERE (SELECT COUNT(*) FROM @T T WHERE T.[Not] = 0 AND IdGruppoPrestazioni IS NULL)>= 1
				AND P.Attivo = 1
				AND (S.Attivo = 1 OR S.ID = '00000000-0000-0000-0000-000000000000')
		) P1
		WHERE
				((@valore IS NULL) OR (P1.Codice Like '%' + @valore + '%' OR P1.Descrizione Like '%' + @valore + '%'))
			AND ((@idSistemaErogante) IS NULL OR (P1.IDSistemaErogante = @idSistemaErogante))
 
		EXCEPT
		
		-- Tutte le prestazioni in [Not]
		SELECT DISTINCT P2.* FROM
		(
			SELECT P.ID, P.DataInserimento, P.DataModifica, P.IDTicketInserimento, P.IDTicketModifica
				, P.TS, P.Codice, P.Descrizione, P.Tipo, P.Provenienza, P.IDSistemaErogante
				, S.CodiceAzienda AS CodiceAzienda, A.Descrizione AS DescrizioneAzienda
				, S.Codice AS CodiceSistema, S.Descrizione AS DescrizioneSistema
			FROM @T T
				INNER JOIN PrestazioniGruppiPrestazioni PGP on T.IdGruppoPrestazioni = PGP.IDGruppoPrestazioni
				INNER JOIN Prestazioni P on P.ID = PGP.IDPrestazione
				INNER JOIN Sistemi S ON P.IDSistemaErogante = S.ID
				INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda				
			WHERE T.[Not] = 1
			
			UNION
			
			SELECT P.ID, P.DataInserimento, P.DataModifica, P.IDTicketInserimento, P.IDTicketModifica
				, P.TS, P.Codice, P.Descrizione, P.Tipo, P.Provenienza, P.IDSistemaErogante
				, S.CodiceAzienda AS CodiceAzienda, A.Descrizione AS DescrizioneAzienda
				, S.Codice AS CodiceSistema, S.Descrizione AS DescrizioneSistema
			FROM Prestazioni P
				INNER JOIN Sistemi S ON P.IDSistemaErogante = S.ID
				INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda
			WHERE (SELECT COUNT(*) FROM @T T WHERE T.[Not] = 1 AND IdGruppoPrestazioni IS NULL) >= 1
		) P2
			
		ORDER BY P1.Codice
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsPrestazioniErogabiliProfiliListByCodiceDescrizione] TO [DataAccessWs]
    AS [dbo];

