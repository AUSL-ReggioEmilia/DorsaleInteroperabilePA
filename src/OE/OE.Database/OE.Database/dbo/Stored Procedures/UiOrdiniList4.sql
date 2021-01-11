
-- =============================================
-- Author:      
-- Create date: 
-- Description: Recupera le informazioni dell'ordine, usata sia per lista che per dettaglio
-- Modify date: 2015-01-29 Stefano: aggiunto campo DescrizioneUnitaOperativaRichiedente
-- Modify date: 2015-04-17 Stefano: eliminati controlli di range dalle date dataInserimentoDa / A , dataRichiestaDa / A
-- Modify date: 2015-08-04 Stefano: corretto bug ricerca per data modifica
-- Modify date: 2015-09-03 Stefano: corretto bug ordinamento
-- Modify date: 2015-10-21 Stefano: Aggiunto filtro su stato Reinoltrato
-- Modify date: 2016-01-05 Stefano: Aggiunto parametro Ordinamento
-- Modify date: 2016-01-05 SimoneB: Aggiunto parametro UnitaOperativaRichiedente
-- =============================================

CREATE PROCEDURE [dbo].[UiOrdiniList4]

	@numeroRisultati INTEGER = 100,
	@Ordinamento VARCHAR(128) = NULL,
	@id UNIQUEIDENTIFIER=NULL, 
	@anno INT=NULL, 
	@numero INT=NULL, 
	@numeroNosologico VARCHAR (64)=NULL, 
	@idSistemaErogante UNIQUEIDENTIFIER=NULL, 
	@descrizioneStatoOrderEntry VARCHAR (64)=NULL, 
	@idSistemaRichiedente UNIQUEIDENTIFIER=NULL, 
	@idRichiestaRichiedente VARCHAR (64)=NULL, 
	@dataRichiestaDa DATETIME2 (0)=NULL, 
	@dataRichiestaA DATETIME2 (0)=NULL, 
	@dataInserimentoDa DATETIME2 (0)=NULL, 
	@dataInserimentoA DATETIME2 (0)=NULL, 
	@anagraficaCodice VARCHAR (64)=NULL, 
	@anagraficaNome VARCHAR (16)=NULL, 
	@pazienteCognome VARCHAR (64)=NULL, 
	@pazienteNome VARCHAR (64)=NULL, 
	@pazienteDataNascita DATE=NULL, 
	@pazienteCodiceFiscale VARCHAR (16)=NULL,
	@unitaOperativaRichiedente VARCHAR(64) = NULL

WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON
	
	--
	-- Combinazioni non possibili
	--
	
	IF (@dataInserimentoDa IS NOT NULL AND @dataInserimentoA IS NULL)
		OR ( @dataInserimentoDa IS NULL AND @dataInserimentoA IS NOT NULL) BEGIN
		RAISERROR (N'Se compilato DataInserimentoDa compilare anche DataInserimentoA e viceversa!', 16, 1)
		RETURN 1
	END
		
	IF (@dataRichiestaDa IS NOT NULL AND @dataRichiestaA IS NULL)
		OR (@dataRichiestaDa IS NULL AND @dataRichiestaA IS NOT NULL) BEGIN
		RAISERROR (N'Se compilato DataRichiestaDa compilare anche DataRichiestaA e viceversa!', 16, 1)
		RETURN 1
	END
		
	IF (@dataInserimentoDa > '1900-01-01' AND @dataInserimentoA < '2100-01-01')
		AND @dataRichiestaDa > '1900-01-01' AND @dataRichiestaA < '2100-01-01'	BEGIN
		RAISERROR (N'Se compilato DataInserimento non compilato DataRichiesta e viceversa!', 16, 1)
		RETURN 1
	END
	
	-- ORDINAMENTO DI DEFAULT PER DATAMODIFICA
	IF ISNULL(@Ordinamento ,'') = '' SET @Ordinamento = 'DataModifica@DESC'
	
	--
	-- Lista degli ordini trovati
	--
	DECLARE @TableIdOrdini AS TABLE (
		ID UNIQUEIDENTIFIER NOT NULL	
	)
	
	--
	-- Cerca per ID
	--
	IF @id IS NOT NULL
	BEGIN
		PRINT  'Cerca per OrdiniTestate.ID'
		INSERT INTO @TableIdOrdini
		SELECT ot.ID
		FROM OrdiniTestate ot WITH(NOLOCK)
		WHERE ot.ID = @id
	END
	--
	-- Cerca per IdRichiedente
	--
	ELSE IF @idRichiestaRichiedente IS NOT NULL
	BEGIN
		PRINT  'Cerca per OrdiniTestate.IDRichiestaRichiedente'
		INSERT INTO @TableIdOrdini
		SELECT ot.ID 
		FROM OrdiniTestate ot WITH(NOLOCK)
		WHERE ot.IDRichiestaRichiedente = @idRichiestaRichiedente
			AND (@idSistemaRichiedente IS NULL OR ot.IdSistemaRichiedente = @idSistemaRichiedente)
	END	
	--
	-- Cerca per NumeroNosologico
	--
	ELSE IF @NumeroNosologico IS NOT NULL
	BEGIN
		PRINT  'Cerca per OrdiniTestate.NumeroNosologico'	
		INSERT INTO @TableIdOrdini
		SELECT DISTINCT o.ID 
		FROM (
			--
			-- Uso SELECT di SELECT per ottimizzare la ricerca sullo stato
			--
			SELECT ot.ID
				--, ot.DataRichiesta AS Data
				, ot.DataInserimento
				, ot.StatoOrderEntry

			FROM OrdiniTestate ot WITH(NOLOCK)
			WHERE ot.NumeroNosologico = @NumeroNosologico
				--
				-- Filtro Sistema Richiedente
				--
				AND (@idSistemaRichiedente IS NULL OR ot.IdSistemaRichiedente = @idSistemaRichiedente)
			) o
		WHERE
			--
			-- Filtro per Stato
			--
			@descrizioneStatoOrderEntry IS NULL 
			OR 
			(@descrizioneStatoOrderEntry = 'Reinoltrato' AND dbo.IsOrdineReinoltrato(o.ID, o.DataInserimento) = 1 )
			OR
			(@descrizioneStatoOrderEntry = dbo.GetStatoSenzaSottostato2(o.ID, o.StatoOrderEntry) )
	
		OPTION (RECOMPILE)
	END		
	--
	-- Cerca per Anno/Numero
	--
	ELSE IF @anno IS NOT NULL AND @numero IS NOT NULL
	BEGIN
		PRINT  'Cerca per OrdiniTestate.Anno/Numero'
		INSERT INTO @TableIdOrdini
		SELECT ot.ID 
		FROM OrdiniTestate ot WITH(NOLOCK)
		WHERE ot.Anno = @anno 
		AND ot.Numero = @numero
	END
	
	--
	-- CERCO CONSIDERANDO TUTTI GLI ALTRI FILTRI
	--
	ELSE BEGIN
		
		PRINT  'CERCO CONSIDERANDO TUTTI GLI ALTRI FILTRI'
		
		INSERT INTO @TableIdOrdini
		
		SELECT TOP (@numeroRisultati)
			 ot.ID 

			/*,CASE --SCELGO QUALE CAMPO DATA USARE PER L'ORDINAMENTO IN BASE AI PARAMETRI RIEMPITI DALL'UTENTE
				WHEN @dataRichiestaDa IS NOT NULL THEN ot.DataRichiesta
				WHEN @dataInserimentoDa > '1900-01-01' THEN
				 (SELECT MAX(data)
				  FROM (SELECT ot.DataModifica AS data
						UNION ALL
						SELECT MAX(OrdiniRigheRichieste.DataModifica) AS data 
						FROM OrdiniRigheRichieste 
						WHERE IDOrdineTestata = ot.ID
	   				   ) AS TempTable
				 ) 
				ELSE ot.DataModifica
			END	AS Data*/
			
		
		FROM 
			dbo.OrdiniTestate ot WITH(NOLOCK)
			CROSS APPLY dbo.GetOrdineValidazione(ot.Validazione) VALI
			LEFT JOIN UnitaOperative uo on ot.IDUnitaOperativaRichiedente = uo.ID 
		WHERE
			(@idSistemaErogante IS NULL
			 OR 
			 (	@idSistemaErogante IS NOT NULL 
				AND EXISTS (SELECT 1 FROM dbo.OrdiniRigheRichieste WITH(NOLOCK) 
							WHERE IDOrdineTestata=ot.ID AND IdSistemaErogante = @IdSistemaErogante)
			 )
			)			
			AND ( (@dataInserimentoDa IS NULL AND @dataInserimentoA IS NULL)
					OR ot.DataModifica BETWEEN @dataInserimentoDa AND @dataInserimentoA					
				)			
			AND ( (@dataRichiestaDa IS NULL AND @dataRichiestaA IS NULL)
					OR ot.DataRichiesta BETWEEN @dataRichiestaDa AND @dataRichiestaA				
				)				
			AND (@idSistemaRichiedente IS NULL OR ot.IdSistemaRichiedente = @idSistemaRichiedente)
			
			--
			-- Filtri anagrafici
			--
			AND (@anagraficaCodice IS NULL OR ot.AnagraficaCodice = @anagraficaCodice)
			AND (@anagraficaNome IS NULL OR ot.AnagraficaNome = @anagraficaNome)
			AND (@pazienteCognome IS NULL OR ot.PazienteCognome = @pazienteCognome)
			AND (@PazienteNome IS NULL OR ot.PazienteNome = @pazienteNome)
			AND (@pazienteDataNascita IS NULL OR ot.PazienteDataNascita = @pazienteDataNascita)
			AND (@pazienteCodiceFiscale IS NULL OR ot.PazienteCodiceFiscale = @pazienteCodiceFiscale)
		
			--
			-- Filtro per Stato
			--
			AND(
				@descrizioneStatoOrderEntry IS NULL 
				OR 
				(@descrizioneStatoOrderEntry = 'Reinoltrato' AND dbo.IsOrdineReinoltrato(ot.ID, ot.DataInserimento) = 1 )
				OR
				(@descrizioneStatoOrderEntry = dbo.GetStatoSenzaSottostato2(ot.ID, ot.StatoOrderEntry) )
			   )
			AND (@unitaOperativaRichiedente IS NULL OR uo.Descrizione LIKE '%'+ @unitaOperativaRichiedente +'%')
					
		ORDER BY
			--
			--  ASCENDING --
			--
			 CASE WHEN @Ordinamento = 'DataInserimento@ASC' THEN ot.DataInserimento END
			,CASE WHEN @Ordinamento = 'DataModifica@ASC' THEN ot.DataModifica END
			,CASE WHEN @Ordinamento = 'DataRichiesta@ASC' THEN ot.DataRichiesta END															
			--NumeroOrdineSort
			,CASE WHEN @Ordinamento = 'NumeroOrdineSort@ASC' THEN ot.Anno END
			,CASE WHEN @Ordinamento = 'NumeroOrdineSort@ASC' THEN ot.Numero END			
		
			,CASE WHEN @Ordinamento = 'StatoOrderEntryDescrizione@ASC' THEN dbo.GetStatoCalcolato(ot.ID) END -- <-- DA VERIFICARE PRESTAZIONI
			--,CASE WHEN @Ordinamento = 'SistemaRichiedente@ASC' THEN ot. END
			,CASE WHEN @Ordinamento = 'IdRichiestaRichiedente@ASC' THEN ot.IdRichiestaRichiedente END
			
			--Sistemi Eroganti:
			--,CASE WHEN @Ordinamento = 'TipiRichieste@ASC' THEN TipiRichieste END
			
			--DatiAnagraficiPaziente
			,CASE WHEN @Ordinamento = 'DatiAnagraficiPaziente@ASC' THEN ot.PazienteCognome END
			,CASE WHEN @Ordinamento = 'DatiAnagraficiPaziente@ASC' THEN ot.PazienteNome END
			
			--CodiceAnagrafica
			,CASE WHEN @Ordinamento = 'CodiceAnagrafica@ASC' THEN ot.AnagraficaNome END
			,CASE WHEN @Ordinamento = 'CodiceAnagrafica@ASC' THEN ot.AnagraficaCodice END
			
			,CASE WHEN @Ordinamento = 'NumeroNosologico@ASC' THEN ot.NumeroNosologico END			
			,CASE WHEN @Ordinamento = 'TotaleRigheRichieste@ASC' THEN dbo.GetTotaleRigheRichiesteByIDOrdine(ot.ID) END -- <-- DA VERIFICARE PRESTAZIONI
			
			--,CASE WHEN @Ordinamento = 'DataAggiornamentoStato@ASC' THEN DataAggiornamentoStato END
			,CASE WHEN @Ordinamento = 'ValiditaOrdine@ASC' THEN VALI.Validita END
				
			--	
			-- DESCENDING --
			--
			,CASE WHEN @Ordinamento = 'DataInserimento@DESC' THEN ot.DataInserimento END DESC
			,CASE WHEN @Ordinamento = 'DataModifica@DESC' THEN ot.DataModifica END DESC
			,CASE WHEN @Ordinamento = 'DataRichiesta@DESC' THEN ot.DataRichiesta END DESC															
			--NumeroOrdineSort
			,CASE WHEN @Ordinamento = 'NumeroOrdineSort@DESC' THEN ot.Anno END DESC
			,CASE WHEN @Ordinamento = 'NumeroOrdineSort@DESC' THEN ot.Numero END DESC			
		
			,CASE WHEN @Ordinamento = 'StatoOrderEntryDescrizione@DESC' THEN dbo.GetStatoCalcolato(ot.ID) END  DESC -- <-- DA VERIFICARE PRESTAZIONI
			--,CASE WHEN @Ordinamento = 'SistemaRichiedente@DESC' THEN ot. END DESC
			,CASE WHEN @Ordinamento = 'IdRichiestaRichiedente@DESC' THEN ot.IdRichiestaRichiedente END DESC
			
			--Sistemi Eroganti:
			--,CASE WHEN @Ordinamento = 'TipiRichieste@DESC' THEN TipiRichieste END DESC
			
			--DatiAnagraficiPaziente
			,CASE WHEN @Ordinamento = 'DatiAnagraficiPaziente@DESC' THEN ot.PazienteCognome END DESC
			,CASE WHEN @Ordinamento = 'DatiAnagraficiPaziente@DESC' THEN ot.PazienteNome END DESC
			
			--CodiceAnagrafica
			,CASE WHEN @Ordinamento = 'CodiceAnagrafica@DESC' THEN ot.AnagraficaNome END DESC
			,CASE WHEN @Ordinamento = 'CodiceAnagrafica@DESC' THEN ot.AnagraficaCodice END DESC
			
			,CASE WHEN @Ordinamento = 'NumeroNosologico@DESC' THEN ot.NumeroNosologico END DESC	
			,CASE WHEN @Ordinamento = 'TotaleRigheRichieste@DESC' THEN dbo.GetTotaleRigheRichiesteByIDOrdine(ot.ID) END DESC-- <-- DA VERIFICARE PRESTAZIONI
			
			--,CASE WHEN @Ordinamento = 'DataAggiornamentoStato@DESC' THEN DataAggiornamentoStato END DESC
			,CASE WHEN @Ordinamento = 'ValiditaOrdine@DESC' THEN VALI.Validita END DESC
			
				
		OPTION (RECOMPILE)
	END 
	
	----
	---- Ritornano i dati
	----
	SELECT
       ol.Id
      ,ol.NumeroOrdine
      ,ol.NumeroOrdineSort
      ,ol.DataInserimento
      ,ol.DataModifica
      ,ISNULL(ol.TipiRichieste,'') AS TipiRichieste
      ,ol.DataRichiesta
      ,ol.DataPrenotazione
      ,ol.UnitaOperativaRichiedente
      ,ISNULL(ol.NumeroNosologico,'') AS NumeroNosologico
      ,ol.IdRichiestaRichiedente
      ,ol.SistemaRichiedente
      ,ol.StatoOrderEntry    
      ,ol.StatoOrderEntryDescrizione
      ,ol.DataAggiornamentoStato
      ,ISNULL(ol.Regime, '') AS Regime
      ,ISNULL(ol.Priorita, '') AS Priorita
      ,ol.AnagraficaNome
      ,ol.AnagraficaCodice
      ,ISNULL(ol.CodiceAnagrafica, '') AS CodiceAnagrafica
      ,ISNULL(ol.PazienteIdRichiedente, '') AS PazienteIdRichiedente
      ,ol.PazienteIdSac
      ,ISNULL(ol.PazienteRegime, '') AS PazienteRegime
      ,ol.PazienteCognome
      ,ol.PazienteNome
      ,ol.PazienteDataNascita
      ,ol.PazienteCodiceFiscale
      ,ol.DatiAnagraficiPaziente
      ,ol.TotaleRigheRichieste
      ,ol.ValiditaOrdine
      ,ol.MessaggioValidita
      ,ol.OperatoreCognome
      ,ol.OperatoreNome
      ,ol.OperatoreId
   	  ,ol.TicketInserimentoUserName
	  ,ol.TicketModificaUserName
	  ,ol.DescrizioneUnitaOperativaRichiedente

	FROM 
		dbo.OrdiniLista2 ol WITH(NOLOCK)
	INNER JOIN 
		@TableIdOrdini TORD	ON ol.Id = TORD.ID
	

	RETURN 0
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniList4] TO [DataAccessUi]
    AS [dbo];

