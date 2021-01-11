

-- =============================================
-- Author:      ETTORE G.
-- Create date:
-- MODIFICA ETTORE 2013-07-02: eliminazione del cursore utilizzato in precedenza
--							@PazienteCognome	OBBLIGATORIO
--							@PazienteNome		OBBLIGATORIO	
-- MODIFICA ETTORE 2015-01-08: aggiunta la colonna che restituisce il "motivo di accesso"						
-- MODIFICA ETTORE 2015-12-28: aggiunta la colonna che restituisce il "ruolo"	
-- Modify date: 2015-10-30 Stefano P: Aggiunto campo note
-- Modify date: 2016-05-11 sandro - Usa nuova func [sac].[OttienePazientePerGeneralita]
-- Modify date: 2018-04-24 ETTORE - Aggiunti i nuovi campi NumeroRecord, ConsensoPaziente, IdNotaAnamnestica
-- Description: Report accessi agli oggetti di un paziente 
-- =============================================
CREATE PROCEDURE [dbo].[FeprTracciaAccessiPaziente]
(
	@AccessoDataDa AS DATETIME = NULL,
	@AccessoDataA AS DATETIME = NULL,
	@PazienteCognome AS VARCHAR(64) = NULL,
	@PazienteNome AS VARCHAR(64) = NULL,
	@CodiceSanitario AS VARCHAR(16) = NULL
)WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON
	--
	-- Controllo parametri obbligatori
	--
	IF ISNULL(@PazienteCognome, '') = '' OR ISNULL(@PazienteNome, '') = ''
	BEGIN
		RAISERROR('I parametri @PazienteCognome e @PazienteNome sono obbligatori.', 16, 1)
		RETURN 1
	END
	
	IF @CodiceSanitario = ''
		SET @CodiceSanitario = NULL
	--
	-- Limito la data @AccessoDataDa 
	--
	IF @AccessoDataDa IS NULL 
		SET @AccessoDataDa = DATEADD(dd, -90, GETDATE())
		

	DECLARE @TempPazienti TABLE (IdPaziente UNIQUEIDENTIFIER
                                   ,PazienteNome VARCHAR(64), PazienteCognome VARCHAR(64)
                                   ,PazienteCodiceFiscale VARCHAR(64), PazienteDataNascita DATETIME
                                   ,PazienteLuogoNascita VARCHAR(128), PazienteCodiceSanitario VARCHAR(32))
	--
	-- Carico tabella temporanea dei pazienti
	--                                   
	INSERT INTO @TempPazienti (IdPaziente,PazienteNome, PazienteCognome, PazienteCodiceFiscale
								, PazienteDataNascita, PazienteLuogoNascita, PazienteCodiceSanitario)
	SELECT P.Id, P.Nome, P.Cognome, P.CodiceFiscale
			, P.DataNascita, P.LuogoNascitaDescrizione
			, NULL CodiceSanitario
	FROM [sac].[OttienePazientiPerGeneralita](100000, @PazienteCognome, @PazienteNome, NULL, NULL, NULL, @CodiceSanitario) P
	
	--                                   
	-- Cerco gli accessi in TracciaAccessi e in TracciaAccessi_Storico
	--
	SELECT TOP 1000
		TracciaAccessi.Id,
		TracciaAccessi.Data ,
		TracciaAccessi.UtenteRichiedente ,
		TracciaAccessi.NomeRichiedente ,
		Pazienti.PazienteNome,
		Pazienti.PazienteCognome,
		Pazienti.PazienteCodiceFiscale,
		Pazienti.PazienteDataNascita,
		Pazienti.PazienteLuogoNascita, 
		Pazienti.IdPaziente,
		Pazienti.PazienteCodiceSanitario,
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
		  SELECT Id, Data, UtenteRichiedente, NomeRichiedente, Operazione, IdPazienti, IdReferti, MotivoAccesso, Note, RuoloUtenteDescrizione
				, NumeroRecord, ConsensoPaziente, IdNotaAnamnestica
		  FROM TracciaAccessi WITH(NOLOCK)
		  UNION 
		  SELECT Id, Data, UtenteRichiedente, NomeRichiedente, Operazione, IdPazienti, IdReferti, MotivoAccesso, Note, RuoloUtenteDescrizione
				, NumeroRecord, ConsensoPaziente, IdNotaAnamnestica
		  FROM TracciaAccessi_Storico WITH(NOLOCK)
		) AS TracciaAccessi
          
		INNER JOIN @TempPazienti Pazienti
			  ON Pazienti.IdPaziente = TracciaAccessi.IdPazienti 

	WHERE 
		(TracciaAccessi.Data >= @AccessoDataDa OR @AccessoDataDa IS NULL)
		AND   
		(TracciaAccessi.Data <= DATEADD(minute, 1439, @AccessoDataA) OR @AccessoDataA IS NULL)
	ORDER BY 
		TracciaAccessi.Data DESC
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprTracciaAccessiPaziente] TO [ExecuteFrontEnd]
    AS [dbo];

