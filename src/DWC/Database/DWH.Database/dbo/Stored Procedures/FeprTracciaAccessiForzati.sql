
-- =============================================
-- Author:		Ettore
-- MODIFICA ETTORE 2013-05-24: UNION con tabella TracciaAccessi_Storico
-- MODIFICA ETTORE 2013-07-02: eliminazione del cursore utilizzato in precedenza
--						@OperatoreUtente oppure @OperatoreNome	deve essere valorizzato
--
-- MODIFICA ETTORE 2015-01-08: aggiunta la colonna che restituisce il "motivo di accesso"
-- MODIFICA ETTORE 2015-12-28: aggiunta la colonna che restituisce il "ruolo"
-- Modify date: 2016-05-11 sandro - Usa nuova func [sac].[OttienePazientePerGeneralita]
-- Modify date: 2018-10-09 sandro - Usa nuova func [sac].[OttienePazientePerIdSac]
--									Rimosso vincolo @OperatoreUtente oppure @OperatoreNome

-- Description:	Ritorna la lista degli accessi forzati
-- =============================================

CREATE PROCEDURE [dbo].[FeprTracciaAccessiForzati]
(
	@AccessoDataDa AS DATETIME = NULL,
	@AccessoDataA AS DATETIME = NULL,
	@OperatoreNome AS VARCHAR(128) = NULL,
	@PazienteCognome AS VARCHAR(64) = NULL
)WITH RECOMPILE
AS
BEGIN	
	SET NOCOUNT ON
	--
	-- Controllo parametri obbligatori
	--
	--IF ISNULL(@OperatoreNome, '') = '' AND  ISNULL(@PazienteCognome, '') = ''
	--BEGIN
	--	RAISERROR('Almeno uno dei parametri @OperatoreNome o @PazienteCognome deve essere valorizzato.',10,1)
	--	RETURN
	--END	
	--
	-- Limito la @AccessoDataDa 
	--
	IF @AccessoDataDa IS NULL 
		SET @AccessoDataDa = DATEADD(dd, -90, GETDATE())
	--
	-- Restituisco max 1000 record
	--
	SELECT TOP 1000 
		TracciaAccessi.Id,
		TracciaAccessi.Data AS AccessoData,
		TracciaAccessi.UtenteRichiedente AS OperatoreUtente,
		TracciaAccessi.NomeRichiedente AS OperatoreNome,
		Pazienti.Nome AS PazienteNome,
		Pazienti.Cognome AS PazienteCognome,
		Pazienti.CodiceFiscale AS PazienteCodiceFiscale,
		Pazienti.DataNascita AS PazienteDataNascita,
		Pazienti.LuogoNascitaDescrizione AS PazienteLuogoNascita,
		TracciaAccessi.MotivoAccesso,
		TracciaAccessi.RuoloUtenteDescrizione
	FROM	
		(
			SELECT Id, Data, UtenteRichiedente, NomeRichiedente, IdPazienti, Operazione, MotivoAccesso, RuoloUtenteDescrizione
			FROM TracciaAccessi WITH(NOLOCK)
			UNION
			SELECT Id, Data, UtenteRichiedente, NomeRichiedente, IdPazienti, Operazione, MotivoAccesso, RuoloUtenteDescrizione
			FROM TracciaAccessi_Storico WITH(NOLOCK)
		) AS TracciaAccessi

		OUTER APPLY [sac].[OttienePazientePerIdSac](TracciaAccessi.IdPazienti) AS Pazienti

	WHERE	
		(TracciaAccessi.Operazione = 'Forzatura del consenso per urgenze')
		AND (TracciaAccessi.Data >= @AccessoDataDa OR @AccessoDataDa IS NULL)
		AND (TracciaAccessi.Data <= DATEADD(minute, 1439, @AccessoDataA) OR @AccessoDataA IS NULL)
		AND (TracciaAccessi.NomeRichiedente LIKE @OperatoreNome + '%'  OR @OperatoreNome IS NULL)

		AND (@PazienteCognome IS NULL OR Pazienti.Cognome = @PazienteCognome)
	ORDER BY 
		TracciaAccessi.Data DESC
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprTracciaAccessiForzati] TO [ExecuteFrontEnd]
    AS [dbo];

