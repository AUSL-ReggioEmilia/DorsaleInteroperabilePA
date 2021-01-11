

-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2013-10-15 Copiata da [WsProfiliList]
-- Modify date: 2013-10-15 Sandro: Aggiunta select per i profili dell'utente
-- Modify date: 2013-10-16 Sandro: Aggiunto filtro Ennuple accessi (manca il filtro in NOT)
-- Modify date: 2014-10-17 Sandro: Usa nuovo func [GetProfiloGerarchia2] e filtro in NOT
-- Modify date: 2014-11-04 Sandro: Usa nuovo func [GetPrestazioniRichiedibili]
-- Modify date: 2018-02-06 SANDRO: Rimosso blocco di debug
-- Modify date: 2018-02-07 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
--									Rimosso WITH RECOMPILE e aggiunto OPTION (RECOMPILE)
--
-- Modify date: 2018-02-15 SANDRO: Usa nuova FUNC test.GetPrestazioniRichiedibili2
--
-- Description:	Seleziona una lista di profili
-- =============================================
CREATE PROCEDURE [dbo].[WsProfiliListByCodiceDescrizione]
      @utente VARCHAR (64)
	, @idUnitaOperativa UNIQUEIDENTIFIER
	, @idSistemaRichiedente UNIQUEIDENTIFIER
	, @codiceRegime VARCHAR(16)
	, @codicePriorita VARCHAR(16)
	, @idStato TINYINT = 1
	, @tipi VARCHAR(MAX) = NULL
	, @valore VARCHAR(256) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1
	
	BEGIN TRY
		--Se filtro scarso abbasso il TOP
		DECLARE @MaxRecord INT = 2000
		IF @valore IS NULL OR LEN(@valore) < 2
			SET @MaxRecord = 500

		-- Split tipi
		DECLARE @Value varchar(50), @Pos int
		DECLARE @tblFiltriTipo TABLE (Tipo tinyint)

		--Per default tutti
		IF @tipi IS NULL
			SET @tipi = '1,2,3'

		SET @tipi = LTRIM(RTRIM(@tipi))+ ','
		SET @Pos = CHARINDEX(',', @tipi, 1)

		IF REPLACE(@tipi, ',', '') <> ''
		BEGIN
			WHILE @Pos > 0
			BEGIN
				SET @Value = LTRIM(RTRIM(LEFT(@tipi, @Pos - 1)))
				
				--Filtro per escludere le prestazioni
				IF @Value <> '' AND @Value IN ('1', '2', '3')
				BEGIN
					INSERT INTO @tblFiltriTipo (Tipo) VALUES (@Value)
				END
				
				SET @tipi = RIGHT(@tipi, LEN(@tipi) - @Pos)
				SET @Pos = CHARINDEX(',', @tipi, 1)
			END
		END

		-- Prestazioni richiedibili
		-- Nuova func 2018-02-19 SANDRO
		DECLARE @RIC TABLE (Id uniqueidentifier) 
		INSERT INTO @RIC 
			SELECT Id FROM dbo.GetPrestazioniRichiedibili2(@utente, @idUnitaOperativa, @idSistemaRichiedente, GETDATE()
								, @codiceRegime, @codicePriorita, @idStato, NULL, @valore, NULL, 0, 1)

		-- Tutte i profili richiedibili e quelli di tipo 3 contestuali all'utente
		SELECT DISTINCT TOP (@MaxRecord) 
				  P.ID, P.DataInserimento, P.DataModifica, P.IDTicketInserimento, P.IDTicketModifica, P.TS
				, P.Codice, P.Descrizione, P.Tipo, P.Provenienza, P.IDSistemaErogante
				, S.CodiceAzienda AS CodiceAzienda, A.Descrizione AS DescrizioneAzienda
				, S.Codice AS CodiceSistema, S.Descrizione AS DescrizioneSistema

		FROM Prestazioni P
				INNER JOIN Sistemi S ON P.IDSistemaErogante = S.ID
				INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda

				-- Tipi di profili
				INNER JOIN @tblFiltriTipo FT ON FT.Tipo = P.Tipo

				--Prestazioni richiedibili
				INNER JOIN @RIC PR ON PR.ID = P.ID

		WHERE P.Attivo = 1
				AND P.Tipo <> 0
				
				--NO profili personali di altri utenti
				AND NOT (P.Tipo = 3 AND P.UtenteInserimento <> @utente)

				AND	(@valore IS NULL OR (P.Codice Like '%' + @valore + '%' OR P.Descrizione Like '%' + @valore + '%'))

		ORDER BY P.Codice
		--2018-02-07 Problema saltuario di time-out invece che quanche sec di exec
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
    ON OBJECT::[dbo].[WsProfiliListByCodiceDescrizione] TO [DataAccessWs]
    AS [dbo];

