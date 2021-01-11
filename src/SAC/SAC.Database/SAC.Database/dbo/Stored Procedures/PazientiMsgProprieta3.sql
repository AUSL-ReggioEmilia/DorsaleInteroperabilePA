




-- =============================================
-- Author:		ETTORE
-- Create date: 2016-02-22
-- Description:	Utilizzata per avere il record con IdProvenienza = @IdProvenienza (per la provenienza associata all'utente @Utente)
--				a prescindere dal suo stato di fusione
-- Modify date: 2016-07-21 - ETTORE: Restituzione della data di decesso 
-- Modify date: 2019-10-29 - ETTORE: Riattivazione anagrafiche cancellate logicamente [ASMN-4052] 
--									 Corretta la valorizzazione del campo Sinonimo (comunque tale campo non viene usato)
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgProprieta3]
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
		EXEC PazientiEventiAccessoNegato @Utente, 0, 'PazientiMsgProprieta3', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi!', 16, 1)
		RETURN 1002
	END

	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------

	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante PazientiMsgProprieta3!', 16, 1)
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
		--2019-10-29 - ETTORE: Corretta la valorizzazione del campo Sinonimo (comunque tale campo non viene usato) 
		, CASE WHEN Disattivato <> 2 THEN 0
				ELSE 1 END AS Sinonimo --Sinonimo significa che l'anagrafica è fusa!
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

	FROM Pazienti
	WHERE 
		Provenienza = @Provenienza
		AND IdProvenienza = @IdProvenienza
		AND Disattivato IN (0,2)
	ORDER BY Disattivato, LivelloAttendibilita DESC, DataDisattivazione DESC
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgProprieta3] TO [DataAccessDll]
    AS [dbo];

