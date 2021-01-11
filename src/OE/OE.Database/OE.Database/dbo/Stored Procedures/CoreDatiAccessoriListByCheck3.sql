
-- =============================================
-- Author:		Francesco P
-- Modify date: 2012-04-01
-- Modify date: 2013-07-01
-- Modify date: 2013-09-16 SANDRO Modifiche alle JOIN se non era valorizzato il dato aggiuntivo non ritornava
-- Modify date: 2013-10-03 SANDRO Modifiche ereditarietà proprietà DatiAggiuntivi
-- Modify date: 2013-10-08 SANDRO Errore su eslusione se di sistema
-- Modify date: 2013-10-10 SANDRO Rimossa parte di ereditabilita 
-- Modify date: 2013-10-11 SANDRO Ritorna tutta la gerarchia prestazioni dei profili
-- Modify date: 2015-01-15 SANDRO Se Profilo serve il Sistema erogante del profilo non del figlio
-- Modify date: 2017-02-28 SANDRO Aggiunti parametri per calcolo ENNUPLA
-- Modify date: 2017-11-27 SANDRO Primo giorno della settimana LUN
--
-- Description:	Seleziona i dati accessori per id richiesta
--
--					Pianificare la rimozione della SP, ancora referenziata 
--						nel TableAdapter ma non usata			
--
-- =============================================
CREATE PROCEDURE [dbo].[CoreDatiAccessoriListByCheck3]
 @IDOrdineTestata uniqueidentifier
-- Nuovi per ennupla
,@Utente VARCHAR(64)
,@idUnitaOperativa UNIQUEIDENTIFIER
,@idSistemaRichiedente UNIQUEIDENTIFIER
,@dataoraRichiesta DATETIME
,@codiceRegime VARCHAR(16)
,@codicePriorita VARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Imposta il primo giorno della settimana a LUNEDI
		SET DATEFIRST 1

		-- Dati accessori usabili
		DECLARE @E TABLE ([Codice] VARCHAR(64) NOT NULL)

		INSERT INTO @E([Codice])
		SELECT [Codice]	FROM [dbo].[GetDatiAccessoriUsabili]( @Utente, @idUnitaOperativa, @idSistemaRichiedente,
												@dataoraRichiesta, @codiceRegime, @codicePriorita, 1, NULL)

		SELECT 
			  DatiAccessori.Codice
			, DatiAccessori.Etichetta
			, DatiAccessori.IDRigaRichiesta
			, DatiAccessori.IDPrestazione			
			, P.Codice AS CodicePrestazione
			, DatiAccessori.IDSistemaErogante
			, S.Codice AS CodiceSistemaErogante
			, S.CodiceAzienda AS CodiceAziendaSistemaErogante
			, DatiAccessori.ValoreDato
			, DatiAccessori.ValoreDatoVarchar
			, DatiAccessori.ValoreDatoXml
			, DatiAccessori.ValidazioneRegex
			, DatiAccessori.ValidazioneMessaggio
			, DatiAccessori.DatoAccessorioRichiesta
			, DatiAccessori.Obbligatorio
		FROM 
			(
				SELECT  D.Codice, D.Etichetta
					  , R.ID AS IDRigaRichiesta
					  , NULLIF(D.ValidazioneRegex, '') AS ValidazioneRegex
					  , NULLIF(D.ValidazioneMessaggio,'') AS ValidazioneMessaggio
					  , gp.IdPadre AS IDPrestazione
					  , R.IDSistemaErogante
					  , NULLIF(RDA.ValoreDato, '') AS ValoreDato
					  , NULLIF(RDA.ValoreDatoVarchar, '') AS ValoreDatoVarchar
					  , CAST(RDA.ValoreDatoXml AS VARCHAR(MAX)) AS ValoreDatoXml
					  , 0 AS DatoAccessorioRichiesta
					  , D.Obbligatorio
				FROM 
					DatiAccessoriPrestazioni P
					INNER JOIN DatiAccessori D ON P.CodiceDatoAccessorio = D.Codice
					INNER JOIN dbo.[GetGerarchiaPrestazioniOrdineByIdTestata](@IDOrdineTestata) gp ON gp.IdFiglio = P.IDPrestazione

					INNER JOIN OrdiniRigheRichieste R ON R.IDPrestazione = gp.IdPadre
					LEFT JOIN OrdiniRigheRichiesteDatiAggiuntivi RDA ON D.Codice = RDA.Nome
											AND R.ID = RDA.IDRigaRichiesta
				WHERE P.Attivo = 1 
					AND COALESCE(P.Sistema, D.Sistema) = 0
					AND R.IDOrdineTestata = @IDOrdineTestata
					-- Escluse quelle legate al sistema
					AND NOT EXISTS ( SELECT * FROM DatiAccessoriSistemi S
								INNER JOIN Prestazioni PR ON S.ID = PR.IDSistemaErogante
							WHERE S.CodiceDatoAccessorio = P.CodiceDatoAccessorio
								AND PR.ID = P.IDPrestazione
								AND S.Attivo = 1
								AND PR.Attivo = 1)
					-- Solo se usabili
					AND (EXISTS (SELECT * FROM @E E WHERE E.Codice = D.Codice) OR @Utente IS NULL)
				UNION
				
				-- Dati accessori sistemi
				SELECT DISTINCT D.Codice, D.Etichetta
					  , NULL AS IDRigaRichiesta
					  , NULLIF(D.ValidazioneRegex, '') AS ValidazioneRegex
					  , NULLIF(D.ValidazioneMessaggio,'') AS ValidazioneMessaggio
					  , gp.IdPadre AS IDPrestazione
					  --Serve il Sistema erogante del profilo non S.IDSistema
					  , PP.IDSistemaErogante AS IDSistemaErogante
					  , NULLIF(RDA.ValoreDato, '') AS ValoreDato
					  , NULLIF(RDA.ValoreDatoVarchar, '') AS ValoreDatoVarchar
					  , CAST(RDA.ValoreDatoXml AS VARCHAR(MAX)) AS ValoreDatoXml
					  , 1 AS DatoAccessorioRichiesta
					  , D.Obbligatorio
				FROM 
					DatiAccessoriSistemi S
					INNER JOIN DatiAccessori D ON S.CodiceDatoAccessorio = D.Codice
					INNER JOIN Prestazioni P ON P.IDSistemaErogante = S.IDSistema
					INNER JOIN dbo.[GetGerarchiaPrestazioniOrdineByIdTestata](@IDOrdineTestata) gp ON gp.IdFiglio = P.ID
					
					--Serve il Sistema erogante del profilo
					INNER JOIN Prestazioni PP ON PP.ID = gp.IDPadre

					LEFT JOIN OrdiniTestateDatiAggiuntivi RDA ON D.Codice = RDA.Nome
											AND RDA.IDOrdineTestata = @IDOrdineTestata 
				WHERE S.Attivo = 1
					AND COALESCE(S.Sistema, D.Sistema) = 0
					-- Solo se usabili
					AND (EXISTS (SELECT * FROM @E E WHERE E.Codice = D.Codice) OR @Utente IS NULL)

			) AS DatiAccessori 
		
		LEFT JOIN Prestazioni P ON P.ID = DatiAccessori.IDPrestazione
		LEFT JOIN Sistemi S ON S.ID = DatiAccessori.IDSistemaErogante
		
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreDatiAccessoriListByCheck3] TO [DataAccessWs]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreDatiAccessoriListByCheck3] TO [DataAccessMsg]
    AS [dbo];

