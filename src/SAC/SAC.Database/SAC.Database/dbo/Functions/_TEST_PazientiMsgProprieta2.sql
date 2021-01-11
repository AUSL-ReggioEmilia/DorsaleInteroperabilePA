CREATE FUNCTION _TEST_PazientiMsgProprieta2
(
	@Provenienza AS Varchar(16)
	, @IdProvenienza AS Varchar(64)
)
RETURNS 
@Ret TABLE (Id uniqueidentifier, DataInserimento datetime, DataModifica datetime, DataDisattivazione datetime
		, DataSequenza datetime, LivelloAttendibilita Tinyint, Ts binary(8), Provenienza varchar(16), IdProvenienza varchar(64)
		, Disattivato Tinyint, Sinonimo int, ProvenienzaRicerca varchar(16), IdProvenienzaRicerca varchar(64), Cognome varchar(64), Nome varchar(64)
		, DataNascita datetime, Sesso varchar(1), ComuneNascitaCodice varchar(6), Tessera varchar(16), DataDecesso datetime)
AS
BEGIN
	
	INSERT INTO @Ret
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
		) AND Disattivato = 0
	ORDER BY Disattivato, LivelloAttendibilita DESC, DataDisattivazione DESC

	
	RETURN 
END