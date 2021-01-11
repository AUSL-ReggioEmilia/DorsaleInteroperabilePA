
-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-09
-- Description:	Ritorna la lista degli Utenti che hanno un determinato Ruolo
-- Modify date: 2019-03-28 - ETTORE: modificata la SP perchè la versione originale va in timeout perchè
--									 utilizza la vista [organigramma_ws].[RuoliUtenti] che è fatta per cercare i ruoli a partire dagli utenti 
--									 Eseguendo tutta la parte di SELECT relativa ai gruppi nella seconda parte della UNION la SP impiega quasi 1 secondo 
--									 per restituire circa 20 record. Per questo motivo ho spezzato la query: prima ricavo i membri dei gruppi e li memorizzo in una tabella temporanea
--									 poi metto in join tale tabella con gli utenti.
-- =============================================
CREATE PROCEDURE [organigramma_ws].[UtentiOttieniPerRuolo]
(
	@CodiceRuolo varchar(16)
)
AS
BEGIN
	SET NOCOUNT ON
	--Tabella temporanea per memorizzare i membri dei gruppi
	DECLARE @Tab_Membri AS TABLE (IdFiglio UNIQUEIDENTIFIER)

	--
	-- Memorizzo gli Id dei membri dei gruppi assoxiati al ruolo
	--
	INSERT INTO @Tab_Membri (IdFiglio)
	SELECT 
			UG.IdFiglio
	FROM [organigramma].[RuoliOggettiActiveDirectory] AS ROAD
        inner join  [organigramma].[OggettiActiveDirectory] OAD
            on OAD.Id = ROAD.IdUtente
            AND  OAD.[Tipo] = 'Gruppo'

        inner join [organigramma].[Ruoli] AS R
            ON R.ID = ROAD.IdRuolo
        -- Function table ricorsiva per ottenere i membri del gruppo
		-- Non usare la CROSS APPLY perchè filtra prima; usando OUTER APPLY la function viene eseguita DOPO le prime JOIN 
		-- e quindi la funzione viene eseguita su un insieme già filtrato
        OUTER APPLY [organigramma].[OttieneUtentiPerIdGruppo](OAD.Id) UG
	WHERE 
		R.Codice = @CodiceRuolo 
		--Elimino i record con IdFiglio = NULL che verrebero restituiti causa OUTER APPLY quando non viene matchato nulla
		AND NOT UG.IdFiglio IS NULL

	--
	-- Eseguo query che restituisce i dati
	--
	-- Restituisce gli utenti associati al ruolo
	SELECT 
			U.[Id],
			U.[Utente],
			U.[Descrizione],
			U.[Cognome],
			U.[Nome],
			U.[CodiceFiscale],
			U.[Matricola],
			U.[Email],
			U.[Attivo]
	FROM 
		organigramma_ws.Utenti AS U 
		inner join [organigramma].[RuoliOggettiActiveDirectory] AS ROAD
			ON ROAD.IdUtente = U.id
		inner join [organigramma].[Ruoli] AS R
			ON R.ID = ROAD.IdRuolo
	WHERE 
		R.Codice = @CodiceRuolo 
	UNION 
	-- Restituisce gli utenti membri dei gruppi associati al ruolo
	SELECT 
			U.[Id],
			U.[Utente],
			U.[Descrizione],
			U.[Cognome],
			U.[Nome],
			U.[CodiceFiscale],
			U.[Matricola],
			U.[Email],
			U.[Attivo]
	FROM 
		@Tab_Membri AS M
		INNER JOIN [organigramma].[OggettiActiveDirectory] AS U 
			ON U.Id =M.IdFiglio 
				AND U.Tipo = 'Utente'
	ORDER BY 
		U.[Utente]
	
END