

-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-04-02
-- Modify date: 2013-09-11 SANDRO: Aggiunti campi alla select Sistema e ValoreDefault
-- Modify date: 2013-10-03 SANDRO Modifiche ereditarietà proprietà DatiAggiuntivi
-- Modify date: 2013-10-08 SANDRO Errore su eslusione se di sistema
-- Modify date: 2013-10-10 SANDRO Nuovo campo NomeDatoAggiuntivo e rimossa parte di ereditabilita 
-- Modify date: 2013-10-11 SANDRO Ritorna tutta la gerarchia prestazioni dei profili
-- Modify date: 2014-11-04 SANDRO Usa [GetProfiloGerarchia2]
-- Modify date: 2016-08-25 SANDRO Nuovo dato [ConcatenaNomeUguale]
-- Modify date: 2017-02-28 SANDRO Aggiunti parametri per calcolo ENNUPLA
-- Modify date: 2017-11-27 SANDRO Primo giorno della settimana LUN
-- Modify date: 2018-07-27 SANDRO Aggiunto 	OPTION (RECOMPILE)
--
-- Description:	Seleziona i dati accessori per id prestazioni
-- =============================================
CREATE PROCEDURE [dbo].[CoreDatiAccessoriListByIDsPrestazioni4]
 @IDs varchar(max)
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

		------------------------------
		-- SPLIT ID Prestazioni
		------------------------------	
		DECLARE @Value varchar(50), @Pos int
		DECLARE @tblPrestazioni TABLE (ID uniqueidentifier, IdPadre uniqueidentifier)

		SET @IDs = LTRIM(RTRIM(@IDs))+ ','
		SET @Pos = CHARINDEX(',', @IDs, 1)

		IF REPLACE(@IDs, ',', '') <> ''
		BEGIN
			WHILE @Pos > 0
			BEGIN
				SET @Value = LTRIM(RTRIM(LEFT(@IDs, @Pos - 1)))
				IF @Value <> '' AND dbo.[IsGuid](@Value) = 1
				BEGIN
					-- Controllo se esiste ed il  tipo
					--   aggiungo prestazione o le prestazioni del profilo
					DECLARE @Tipo INT
					SET @Tipo = NULL
					SELECT @Tipo = Tipo FROM Prestazioni WHERE ID = @Value
					IF @Tipo IS NOT NULL
						IF @Tipo = 0
							-- Aggingo se prestazione
							INSERT INTO @tblPrestazioni (ID, IdPadre)
								SELECT ID, @Value AS IdPadre FROM Prestazioni
								WHERE ID = @Value
						ELSE
							--Tutta la gerarchia se un profilo
							INSERT INTO @tblPrestazioni (ID, IdPadre)
								SELECT IDFiglio, @Value
								FROM [dbo].[GetProfiloGerarchia2](@Value)
				END
				
				SET @IDs = RIGHT(@IDs, LEN(@IDs) - @Pos)
				SET @Pos = CHARINDEX(',', @IDs, 1)
			END
		END

		-- Dati accessori usabili
		DECLARE @E TABLE ([Codice] VARCHAR(64) NOT NULL)
		INSERT INTO @E([Codice])
		SELECT [Codice]	FROM [dbo].[GetDatiAccessoriUsabili]( @Utente, @idUnitaOperativa, @idSistemaRichiedente,
												@dataoraRichiesta, @codiceRegime, @codicePriorita, 1, NULL)
			
		-- Dati accessori prestazioni
		SELECT
			  D.Codice, D.DataInserimento, D.DataModifica
  			, CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000') AS IDTicketInserimento
			, CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000') AS IDTicketModifica
			, D.Descrizione, D.Etichetta, D.Tipo
			, D.Obbligatorio
			, D.Ripetibile
			, D.Valori
			, D.Ordinamento, D.Gruppo
			, D.ValidazioneRegex, D.ValidazioneMessaggio
			, Prestazioni.IdPadre AS IDPrestazione
			, 0 AS DatoAccessorioRichiesta
			, COALESCE(P.Sistema, D.Sistema) AS Sistema	--Solo se Sistema è sulla prestazione valuto anche il default
			, CASE WHEN P.Sistema IS NULL THEN D.ValoreDefault ELSE
				 COALESCE(P.ValoreDefault, D.ValoreDefault) END AS ValoreDefault
			, NomeDatoAggiuntivo
			, ConcatenaNomeUguale
		FROM
			DatiAccessoriPrestazioni P
			INNER JOIN DatiAccessori D ON P.CodiceDatoAccessorio = D.Codice
			INNER JOIN @tblPrestazioni Prestazioni ON P.IDPrestazione = Prestazioni.ID
		WHERE 			
			-- Escluse quelle legate al sistema
			NOT EXISTS ( SELECT * FROM DatiAccessoriSistemi S
								INNER JOIN Prestazioni PR ON S.ID = PR.IDSistemaErogante
							WHERE S.CodiceDatoAccessorio = P.CodiceDatoAccessorio
								AND PR.ID = P.IDPrestazione
								AND S.Attivo = 1
								AND PR.Attivo = 1)			
			-- Solo se usabili
			AND (EXISTS (SELECT * FROM @E E WHERE E.Codice = D.Codice) OR @Utente IS NULL)
		UNION
			
		-- Dati accessori sistemi
		SELECT
			  D.Codice, D.DataInserimento, D.DataModifica
 			, CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000') AS IDTicketInserimento
			, CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000') AS IDTicketModifica
			, D.Descrizione, D.Etichetta, D.Tipo
			, D.Obbligatorio
			, D.Ripetibile
			, D.Valori
			, D.Ordinamento, D.Gruppo
			, D.ValidazioneRegex, D.ValidazioneMessaggio
			, Prestazioni.IdPadre AS IDPrestazione
			, 1 AS DatoAccessorioRichiesta
			, COALESCE(S.Sistema, D.Sistema) AS Sistema	--Solo se Sistema è sulla prestazione valuto anche il default
			, CASE WHEN S.Sistema IS NULL THEN D.ValoreDefault ELSE
				 COALESCE(S.ValoreDefault, D.ValoreDefault) END AS ValoreDefault
			, NomeDatoAggiuntivo
			, ConcatenaNomeUguale
		FROM 
			DatiAccessoriSistemi S
			INNER JOIN DatiAccessori D ON S.CodiceDatoAccessorio = D.Codice
			INNER JOIN Prestazioni P ON P.IDSistemaErogante = S.IDSistema
			INNER JOIN @tblPrestazioni Prestazioni ON Prestazioni.ID = P.ID
		WHERE S.IDSistema = P.IDSistemaErogante
			AND S.Attivo = 1
			AND P.Attivo = 1
			-- Solo se usabili
			AND (EXISTS (SELECT * FROM @E E WHERE E.Codice = D.Codice) OR @Utente IS NULL)

		ORDER BY
			DatoAccessorioRichiesta DESC, Codice, IDPrestazione
		
		-- 2018-07-27
		OPTION (RECOMPILE)
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreDatiAccessoriListByIDsPrestazioni4] TO [DataAccessWs]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreDatiAccessoriListByIDsPrestazioni4] TO [DataAccessMsg]
    AS [dbo];

