
-- =============================================
-- Author:      Simone B.
-- Create date: 2017-10-16
-- Description: Inserisce l'evento di erase di un evento dentro CodaEventiSole
-- Modify date: 2017-12-11: ETTORE: non devono essere restituiti gli eventi dei nosologici che sono delle prenotazioni
-- Modify date: 2017-12-28: ETTORE: usata la funzione che restituisce l'xml per SOLE
--							Usata la funzione [dbo].[CreaEventoAnnullamentoRicovero]() per creare l'evento di ERASE
-- Modify date: 2019-01-15 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaEventiAggiungi])
-- Modify date: 2019-02-25 - SANDRO - Aggiunto @StatoCodice a EXEC [sole].[CodaEventiAggiungi]

-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiCodaEventiSoleInserisce]
(
	@IdOscuramento UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @MsgError VARCHAR(256)
	--
	-- DICHIARO LE VARIABILI NECESSARIE PER INSERIRE L'EVENTO DI ERASE.
	--
	DECLARE @AziendaErogante AS VARCHAR(16)
	DECLARE @NumeroNosologico AS VARCHAR(16)
	DECLARE @SistemaErogante AS VARCHAR(16)
	DECLARE @XmlEventoErase AS XML
	DECLARE @IdEventoAccettazione UNIQUEIDENTIFIER
	DECLARE @Messaggio AS VARCHAR(16)
	--
	-- DICHIARO LA TABELLA TEMPORANEA IN CUI INSERISCO GLI EVENTI ASSOCIATI ALL'OSCURAMENTO.
	--
	DECLARE @TableEventi AS TABLE(IdEvento UNIQUEIDENTIFIER, AziendaErogante VARCHAR(16), SistemaErogante VARCHAR(16), IdPaziente UNIQUEIDENTIFIER 
					,TipoEventoCodice VARCHAR(16), NumeroNosologico VARCHAR(64),DataModifica DATETIME)
	--
	-- RIEMPO LA TABELLA TEMPORANEA ESCLUDENTO IL TIPO DI EVENTO FITTIZIO LA.
	-- ESCLUDO ANCHE GLI EVENTI CHE SONO DELLE PRENOTAZIONI
	-- Un IdOscuramento è associato ad un solo nosologico
	--2019-01-16 Agiunto DataModifica, rimosso DataModificaEsterno
	--
	INSERT INTO @TableEventi(IdEvento, AziendaErogante, SistemaErogante, IdPaziente
								, TipoEventoCodice, NumeroNosologico, DataModifica)
	SELECT E.Id, E.AziendaErogante, E.SistemaErogante, E.IdPaziente
					, E.TipoEventoCodice, E.NumeroNosologico, E.DataModifica
	FROM [store].[EventiBase] AS E
		CROSS APPLY [dbo].[OttieniEventoOscuramenti](@IdOscuramento, 'puntuali', 'SOLE', E.AziendaErogante, E.NumeroNosologico) AS EO
	WHERE 
		(NOT TipoEventoCodice = 'LA') --eventi fittizio di collegamento fra ricovero e prenotazione
	AND 
		(NOT TipoEventoCodice IN ('IL', 'ML', 'DL', 'RL', 'SL')) --escludo le prenotazioni
	ORDER BY DataModificaEsterno

	--
	-- Controllo che ci siano dei record nella tabella degli eventi: se non ce ne sono non faccio nulla
	--
	IF EXISTS(SELECT * FROM @TableEventi) 
	BEGIN 
		--
		-- VERIFICO CHE L'OSCURAMENTO NON SIA ASSOCIATO A PIÙ NOSOLOGICI.
		--
		IF (SELECT COUNT(*) FROM (SELECT AziendaErogante,NumeroNosologico FROM  @TableEventi  GROUP BY AziendaErogante, NumeroNosologico) as T1) > 1
		BEGIN 
			--QUESTA NON SI DOVREBBE MAI VERIFICARE A MENO CHE NON SI MODIFICHINO GLI OSCURAMENTI PUNTULI PER I RICOVERI/EVENTI
			--IN MODO TALE CHE UN OSCURAMENTO PUNTULE POSSA OSCURARE NOSOLOGICI DIVERSI
			SET @MsgError = 'L''oscuramento è associato a più di un nosologico!'
			RAISERROR(@MsgError, 16,1)
			RETURN
		END 
		--
		-- VERIFICO SE ESISTONO DEGLI EVENTI CON IdPaziente NON VALIDO.
		--
		IF EXISTS(SELECT * FROM @TableEventi WHERE IdPaziente = '00000000-0000-0000-0000-000000000000')
		BEGIN 
			SET @MsgError = 'Almeno uno degli eventi del nosologico risulta non associato al paziente!'
			RAISERROR(@MsgError, 16,1)
			RETURN
		END 
		-- 
		-- Se sono qui esistono N eventi di un solo nosologico: memorizzo alcuni dati dell'evento di accettazione
		--
		SELECT TOP 1
			 @AziendaErogante = AziendaErogante
			,@NumeroNosologico = NumeroNosologico
			,@IdEventoAccettazione = IdEvento 
			,@SistemaErogante = SistemaErogante
		FROM @TableEventi WHERE TipoEventoCodice = 'A'
		--
		-- VERIFICO CHE ESISTA L'EVENTO DI ACCETTAZIONE, PERCHÈ LO USO PER CREARE L'EVENTO DI ERASE
		--
		IF @IdEventoAccettazione IS NULL
		BEGIN
			SET @MsgError = 'Il ricovero [' +  @AziendaErogante + ', ' + @NumeroNosologico + '] non ha l''evento di accettazione'
			RAISERROR(@MsgError, 16, 1)
			RETURN
		END

		--------------------------------------------------------------------------------
		-- Creo l'evento di ERASE per la coda Sole
		--------------------------------------------------------------------------------
		DECLARE @IdEventoErase UNIQUEIDENTIFIER = NEWID()
		SELECT @XmlEventoErase  = [dbo].[CreaEventoAnnullamentoRicovero] ([sole].[OttieneEventoXml](@IdEventoAccettazione), @IdEventoErase
																		, 'E', 'Cancellazione')
		--
		-- Data evento come ultimo, ordine considera anche IdSequenza
		-- 2019-01-16
		DECLARE @DataModificaMax DATETIME
		SELECT @DataModificaMax = MAX(DataModifica) FROM @TableEventi

		---------------------------------------
		-- NOTIFICA DELL'EVENTO DI ERASE NELLA CODA SOLE (di tipo Oscuramento)
		-- INDICO CHE L'OPERAZIONE DI INSERIMENTO PROVIENE DALLA PAGINA DEGLI OSCURAMENTI SUL DWH.
		---------------------------------------
		--
		-- Prendo alcune informazioni dalla tabella dei ricoveri: leggo lo stato del ricovero
		--2019-01-16
		-- Operazione tipo 2
						
		EXEC [sole].[CodaEventiAggiungi] @IdEventoErase, 2, 'Oscuramenti', @AziendaErogante, @SistemaErogante, 0
												, 'E', @DataModificaMax, @NumeroNosologico, @XmlEventoErase

	END --IF EXISTS(SELECT * FROM @TableEventi) 
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiCodaEventiSoleInserisce] TO [ExecuteFrontEnd]
    AS [dbo];

