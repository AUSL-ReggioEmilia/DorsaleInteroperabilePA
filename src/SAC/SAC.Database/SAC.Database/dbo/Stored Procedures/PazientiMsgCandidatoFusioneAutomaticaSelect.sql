






-- =============================================
-- Author:		ETTORE
-- Create date: 2019-10-21
-- Description:	Cerca il paziente attivo valido come paziente di destinazione durante una fusione 
--				automatica ricercandolo per Cognome, Nome e CodiceFiscale
--				Restituisce la data di decesso. 
--				Esclude le anagrafiche con provenienza impostata con FusioneAutomatica = 0
--				Gestisce la fusione automatica delle anagrafiche con stesso livello attendibilià in base a configurazione
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgCandidatoFusioneAutomaticaSelect]
	  @Utente AS varchar(64)
	, @IdProvenienza AS varchar(64)
	, @CodiceFiscale AS varchar(16)
	, @Cognome AS varchar(64)
	, @Nome AS varchar(64)
	, @LivelloAttendibilita TINYINT --livello attendibilità dell'anagrafica in fase di INSERT/UPDATE
AS
BEGIN
	DECLARE @Provenienza AS varchar(16)
	DECLARE @FusionePazientiConUgualeAttendibilita BIT = 0

	SET NOCOUNT ON;
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	IF dbo.LeggePazientiPermessiLettura(@Utente) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Utente, 0, 'PazientiMsgCandidatoFusioneAutomaticaSelect', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi!', 16, 1)
		RETURN 1002
	END
	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------
	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante PazientiMsgCandidatoFusioneAutomaticaSelect!', 16, 1)
		RETURN 1003
	END
	---------------------------------------------------
	-- Controllo del Codice Fiscale, Cognome e Nome
	---------------------------------------------------

	IF @CodiceFiscale IS NULL
	BEGIN
		RAISERROR('Errore ''CodiceFiscale'' non valorizzato durante PazientiMsgCandidatoFusioneAutomaticaSelect!', 16, 1)
		RETURN 1004
	END
	IF @Cognome IS NULL
	BEGIN
		RAISERROR('Errore ''Cognome'' non valorizzato durante PazientiMsgCandidatoFusioneAutomaticaSelect!', 16, 1)
		RETURN 1004
	END
	IF @Nome IS NULL
	BEGIN
		RAISERROR('Errore ''Nome'' non valorizzato durante PazientiMsgCandidatoFusioneAutomaticaSelect!', 16, 1)
		RETURN 1004
	END
	
	IF @CodiceFiscale = '0000000000000000'
	BEGIN
		RETURN
	END

	--
	-- MODIFICA ETTORE 2019-10-21: Memorizzo la configurazone per le fusioni di uguale livello di attendiblità
	--
	SET @FusionePazientiConUgualeAttendibilita = [dbo].[ConfigPazientiFusionePazientiConUgualeAttendibilita]()
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT TOP 1 P.Id
		, P.DataInserimento
		, P.DataModifica
		, P.DataDisattivazione
		, P.DataSequenza
		, P.LivelloAttendibilita
		, P.Ts
		, P.Provenienza
		, P.IdProvenienza
		, P.Disattivato
		, 0 AS Sinonimo
		, '' AS ProvenienzaRicerca
		, '' AS IdProvenienzaRicerca
		, P.Cognome
		, P.Nome
		, P.DataNascita
		, P.Sesso
		, P.ComuneNascitaCodice
		, P.Tessera
		--
		-- MODIFICA ETTORE 2016-07-21: Restituzione della data di decesso
		--
		, CASE WHEN P.CodiceTerminazione = '4' THEN
			P.DataTerminazioneAss 
		ELSE
			CAST(NULL AS DATETIME) 
		END AS DataDecesso

	FROM Pazienti AS P
		INNER JOIN Provenienze AS PRO
			ON PRO.Provenienza = P.Provenienza
	WHERE  
		--Nuova condizione di fusione 
		(P.CodiceFiscale = @CodiceFiscale AND P.Cognome = @Cognome  AND P.Nome = @Nome)
		--solo gli attivi
		AND P.Disattivato = 0
		--escludo la posizione passata nei parametri
		AND NOT 
			(
				P.Provenienza = @Provenienza
				AND P.IdProvenienza = @IdProvenienza
			)
		--La fusione automatica deve essere abilitata per le Provenienze
		AND PRO.FusioneAutomatica <> 0
		AND
			(
				--Funziona come prima: restituisce anche anagrafiche con stesso livello attendibilità del chiamante
				(@FusionePazientiConUgualeAttendibilita = 1 )
				OR
				--Non restituisco mai anagrafiche con livello attendibilità uguale a quella dell'anagrafica passata
				--E' la DAE a decidere poi l'ordine della fusione
				(@FusionePazientiConUgualeAttendibilita = 0 AND LivelloAttendibilita <> @LivelloAttendibilita) 
			)

	ORDER BY LivelloAttendibilita DESC, DataModifica DESC

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgCandidatoFusioneAutomaticaSelect] TO [DataAccessDll]
    AS [dbo];

