




-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Restituisce l'attivo corrispondente all'@IdProvenienza per la provenienza associata all'@Utente 
-- Modify date: 2016-07-21 - ETTORE: Restituzione della data di decesso
-- Modify date: 2019-10-29 - ETTORE: Riattivazione anagrafiche cancellate logicamente [ASMN-4052] 
--									 Restituisco anche le anagrafiche nello stato CANCELLATO (Disattivato=1)
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgProprieta2]
(
	  @Utente AS varchar(64)
	, @IdProvenienza AS varchar(64)
)
AS
BEGIN
DECLARE @Provenienza AS varchar(16)

	SET NOCOUNT ON;
	
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	
	IF dbo.LeggePazientiPermessiLettura(@Utente) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Utente, 0, 'PazientiMsgProprieta', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi!', 16, 1)
		RETURN 1002
	END

	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------

	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante PazientiMsgProprieta!', 16, 1)
		RETURN 1003
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT TOP 1 Id
		, DataInserimento
		, DataModifica
		, DataDisattivazione
		, DataSequenza
		, LivelloAttendibilita
		, Ts
		, Provenienza
		, IdProvenienza
		, Disattivato
		, CASE WHEN (IdProvenienza = @IdProvenienza AND Provenienza = @Provenienza) THEN 0
				ELSE 1 END AS Sinonimo
		, @Provenienza AS ProvenienzaRicerca
		, @IdProvenienza AS IdProvenienzaRicerca
		, Cognome
		, Nome
		, DataNascita
		, Sesso
		, ComuneNascitaCodice
		, Tessera
		--
		-- MODIFICA ETTORE 2016-07-21: Restituzione della data di decesso
		--
		, CASE WHEN CodiceTerminazione = '4' THEN
			DataTerminazioneAss 
		ELSE
			CAST(NULL AS DATETIME) 
		END AS DataDecesso

	FROM 
		Pazienti
	WHERE 
		(
			(Provenienza = @Provenienza AND IdProvenienza = @IdProvenienza)
			OR Id IN (
				SELECT IdPaziente FROM PazientiSinonimi
					WHERE Provenienza = @Provenienza
						AND IdProvenienza = @IdProvenienza
						AND Abilitato = 1
				)
		) AND Disattivato IN (0, 1) --ATTIVE o CANCELLATE
	ORDER BY Disattivato, LivelloAttendibilita DESC, DataDisattivazione DESC

END










GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgProprieta2] TO [DataAccessDll]
    AS [dbo];

