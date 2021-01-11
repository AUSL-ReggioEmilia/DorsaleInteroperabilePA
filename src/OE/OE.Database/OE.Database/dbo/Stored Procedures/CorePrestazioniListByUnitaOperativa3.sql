

-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-10-23
-- Modify date: 2014-11-04 SANDRO: Usa la nuova Func GetPrestazioniRichiedibili() per valutare l'accesso
-- Modify date: 2018-02-07 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
--									Rimosso WITH RECOMPILE e aggiunto OPTION (RECOMPILE)
-- Modify date: 2018-06-19 SANDRO: Usa nuovo Func (già provata in ByIdGruppo)
--
-- Description:	Ritorna un elenco di prestazioni (con accesso) di un gruppo
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniListByUnitaOperativa3]
( @utente VARCHAR (64)
, @idUnitaOperativa UNIQUEIDENTIFIER
, @idSistemaRichiedente UNIQUEIDENTIFIER
, @idSistemaErogante UNIQUEIDENTIFIER
, @codiceRegime VARCHAR (16)
, @codicePriorita VARCHAR (16)
, @idStato TINYINT=1
, @valore VARCHAR (256)
)
AS
BEGIN
	SET NOCOUNT ON;

	-- Imposta il primo giorno della settimana su un numero compreso tra 1 e 7.
	SET DATEFIRST 1

	--Se filtro scarso abbasso il TOP
	DECLARE @MaxRecord INT = 1000
	IF @valore IS NULL OR LEN(@valore) < 2
		SET @MaxRecord = 200
		
	--Giorni storico da cercare
	DECLARE @StoricoGiorni INT = 30
	IF @valore IS NULL OR LEN(@valore) < 2
		SET @StoricoGiorni = 7

	-- Prestazioni richiedibili
	DECLARE @RIC TABLE (Id uniqueidentifier) 
	INSERT INTO @RIC 
		SELECT Id FROM dbo.GetPrestazioniRichiedibili2(@utente, @idUnitaOperativa, @idSistemaRichiedente
												, GETDATE(), @codiceRegime, @codicePriorita
												, @idStato, @idSistemaErogante, @valore
												, NULL, 1, 1)
	-- Altra subquery per ordine	
	SELECT P_RIC.*
	FROM (
		--Cerco tra prestazioni del paziente
		SELECT DISTINCT TOP(@MaxRecord) P.*
		FROM dbo.CorePrestazioniList P

			--Prestazioni richiedibili 
			INNER JOIN @RIC PR ON PR.ID = P.ID

			--Filtro per UO
			INNER JOIN OrdiniRigheRichieste ORR WITH(NOLOCK) ON ORR.IDPrestazione = P.ID
			INNER JOIN OrdiniTestate OT WITH(NOLOCK) ON OT.ID = ORR.IDOrdineTestata

		WHERE OT.IDUnitaOperativaRichiedente = @idUnitaOperativa
			AND OT.DataModifica > DATEADD(DAY, @StoricoGiorni * -1, GETDATE())

			AND (@idSistemaErogante IS NULL OR P.IDSistemaErogante = @idSistemaErogante)
			AND	(@valore IS NULL OR (P.Codice Like '%' + @valore + '%' OR P.Descrizione Like '%' + @valore + '%'))
		
		) P_RIC

	ORDER BY
		-- Ordinamento sulle Righe richieste
		(SELECT MAX(ORR.DataModifica)
			FROM OrdiniRigheRichieste ORR WITH(NOLOCK)
				INNER JOIN OrdiniTestate OT WITH(NOLOCK) ON OT.ID = ORR.IDOrdineTestata
			WHERE ORR.IDPrestazione = P_RIC.ID
				AND OT.IDUnitaOperativaRichiedente = @idUnitaOperativa
				AND OT.DataModifica > DATEADD(DAY, @StoricoGiorni * -1, GETDATE())
			) DESC
		, P_RIC.Codice

	-- Modify date: 2018-02-07 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
	OPTION (RECOMPILE)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniListByUnitaOperativa3] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniListByUnitaOperativa3] TO [DataAccessWs]
    AS [dbo];

