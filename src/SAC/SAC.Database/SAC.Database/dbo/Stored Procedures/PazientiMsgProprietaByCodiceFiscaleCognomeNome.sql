



-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Cerca il paziente attivo valido come paziente di destinazione
--				durante una fusione(merge) automatica ricercandolo per Cognome, Nome e CodiceFiscale
-- ModifyDate date: 2016-07-21: Ettore: Restituzione della data di decesso 
-- ModifyDate date: 2019-06-25: Ettore: Esclusione delle anagrafiche con provenienza impostata con FusioneAutomatica = 0
--										Aggiunto TOP 1
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgProprietaByCodiceFiscaleCognomeNome]
	  @Utente AS varchar(64)
	, @IdProvenienza AS varchar(64)
	, @CodiceFiscale AS varchar(16)
	, @Cognome AS varchar(64)
	, @Nome AS varchar(64)
AS
BEGIN
	DECLARE @Provenienza AS varchar(16)
	SET NOCOUNT ON;
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	IF dbo.LeggePazientiPermessiLettura(@Utente) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Utente, 0, 'PazientiMsgProprietaByCodiceFiscaleCognomeNome', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi!', 16, 1)
		RETURN 1002
	END
	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------
	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante PazientiMsgProprietaByCodiceFiscaleCognomeNome!', 16, 1)
		RETURN 1003
	END
	---------------------------------------------------
	-- Controllo del Codice Fiscale, Cognome e Nome
	---------------------------------------------------

	IF @CodiceFiscale IS NULL
	BEGIN
		RAISERROR('Errore ''CodiceFiscale'' non valorizzato durante PazientiMsgProprietaByCodiceFiscaleCognomeNome!', 16, 1)
		RETURN 1004
	END
	IF @Cognome IS NULL
	BEGIN
		RAISERROR('Errore ''Cognome'' non valorizzato durante PazientiMsgProprietaByCodiceFiscaleCognomeNome!', 16, 1)
		RETURN 1004
	END
	IF @Nome IS NULL
	BEGIN
		RAISERROR('Errore ''Nome'' non valorizzato durante PazientiMsgProprietaByCodiceFiscaleCognomeNome!', 16, 1)
		RETURN 1004
	END
	
	IF @CodiceFiscale = '0000000000000000'
	BEGIN
		RETURN
	END

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
		--escludo la posizione
		AND NOT (P.Provenienza = @Provenienza
			AND P.IdProvenienza = @IdProvenienza)
		AND PRO.FusioneAutomatica <> 0

	ORDER BY LivelloAttendibilita DESC, DataModifica DESC

END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgProprietaByCodiceFiscaleCognomeNome] TO [DataAccessDll]
    AS [dbo];

