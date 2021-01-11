


-- =============================================
-- Author:      ETTORE
-- Create date: 
--Ritorna la lista degli accessi per operatore
--MODIFICA ETTORE 2013-07-02: eliminazione del cursore utilizzato in precedenza
--						@OperatoreUtente oppure @OperatoreNome	deve essere valorizzato
--MODIFICA ETTORE 2015-01-08: aggiunta la colonna che restituisce il "motivo di accesso"								
--MODIFICA ETTORE 2015-12-28: aggiunta la colonna che restituisce il "ruolo"		
-- Modify date: 2015-10-30 Stefano P: Aggiunto campo note
-- Modify date: 2015-10-30 Sandro: Usa nuova func [sac].[OttienePazientePerIdSac]
-- Modify date: 2018-04-24 ETTORE - Aggiunti i nuovi campi NumeroRecord, ConsensoPaziente, IdNotaAnamnestica
-- Modify date: 2020-02-20 KYRYLO - Split del parametro @OperatoreUtente in @OperatoreDominio e @OperatoreAccount 
-- Description: Report accessi per operatore 
-- =============================================
CREATE PROCEDURE [dbo].[FeprTracciaAccessiOperatore]
(
	@AccessoDataDa AS DATETIME = NULL,
	@AccessoDataA AS DATETIME = NULL,
	@OperatoreDominio AS VARCHAR(64) = NULL,	--Dominio dell'utente richiedente la pagina del front end
	@OperatoreAccount AS VARCHAR(64) = NULL,	--Account dell'utente richiedente la pagina del front end
	@OperatoreNome AS VARCHAR(128) = NULL		--Nome e Cognome dell'utente richiedente la pagina del front end
) WITH RECOMPILE
AS
BEGIN
	DECLARE @OperatoreUtente AS VARCHAR(128)
	SET NOCOUNT ON
	-- Modify date: 2020-02-20 KYRYLO - Split del parametro @OperatoreUtente in @OperatoreDominio e @OperatoreAccount 
	SET @OperatoreUtente = @OperatoreDominio + '\' + @OperatoreAccount
	--
	-- Controllo parametri obbligatori
	--
	IF ISNULL(@OperatoreUtente, '') = '' AND  ISNULL(@OperatoreNome, '') = ''
	BEGIN
		RAISERROR('Il parametro @OperatoreUtente oppure il parametro @OperatoreNome deve essere valorizzato.', 16, 1)
		RETURN 1
	END	
	--
	-- Limito la @AccessoDataDa 
	--
	IF @AccessoDataDa IS NULL 
		SET @AccessoDataDa = DATEADD(dd, -90, GETDATE())
		
	SELECT TOP 1000 --------------->>
		TracciaAccessi.Id,
		TracciaAccessi.Data ,
		TracciaAccessi.UtenteRichiedente ,
		TracciaAccessi.NomeRichiedente ,
		P.Nome AS PazienteNome,
		P.Cognome AS PazienteCognome,
		P.CodiceFiscale AS PazienteCodiceFiscale,
		P.DataNascita AS PazienteDataNascita,
		P.LuogoNascitaDescrizione AS PazienteLuogoNascita,
		P.Id AS IdPaziente,
		NULL AS PazienteCodiceSanitario,
		TracciaAccessi.Operazione,
		TracciaAccessi.IdReferti,
		TracciaAccessi.MotivoAccesso,
		TracciaAccessi.Note, 
		TracciaAccessi.RuoloUtenteDescrizione,
		TracciaAccessi.NumeroRecord, 
		TracciaAccessi.ConsensoPaziente, 
		TracciaAccessi.IdNotaAnamnestica
	FROM	
		(
			SELECT Id, Data, UtenteRichiedente, NomeRichiedente, IdReferti, Operazione, IdPazienti, MotivoAccesso, Note, RuoloUtenteDescrizione 
				, NumeroRecord, ConsensoPaziente, IdNotaAnamnestica
			FROM TracciaAccessi WITH(NOLOCK)
			UNION ALL
			SELECT Id, Data, UtenteRichiedente, NomeRichiedente, IdReferti, Operazione, IdPazienti, MotivoAccesso, Note, RuoloUtenteDescrizione
				, NumeroRecord, ConsensoPaziente, IdNotaAnamnestica
			FROM TracciaAccessi_Storico WITH(NOLOCK)
		) AS TracciaAccessi 
		
		CROSS APPLY [sac].[OttienePazientePerIdSac](TracciaAccessi.IdPazienti) AS P

	WHERE	
		(TracciaAccessi.Data >= @AccessoDataDa OR @AccessoDataDa IS NULL)
		AND	(TracciaAccessi.Data <= DATEADD(minute, 1439, @AccessoDataA) OR @AccessoDataA IS NULL)		
		AND	(TracciaAccessi.NomeRichiedente LIKE @OperatoreNome + '%' OR @OperatoreNome IS NULL)
		AND	(TracciaAccessi.UtenteRichiedente LIKE @OperatoreUtente + '%' OR @OperatoreUtente IS NULL)

	ORDER BY
		TracciaAccessi.Data DESC
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprTracciaAccessiOperatore] TO [ExecuteFrontEnd]
    AS [dbo];

