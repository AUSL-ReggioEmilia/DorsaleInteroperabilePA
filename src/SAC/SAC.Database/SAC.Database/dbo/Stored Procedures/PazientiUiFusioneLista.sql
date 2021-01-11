
CREATE PROCEDURE [dbo].[PazientiUiFusioneLista]
(	
	@IdPazienteAttivo as uniqueidentifier 
)
WITH RECOMPILE --Ricalcola sempre il piano di esecuzione
AS
BEGIN
/*
	MODIFICA ETTORE 2014-03-27
		1) aggiunto gestione data di decesso: devo restituire la data presente sul record
*/
	SET NOCOUNT ON;
	SELECT * FROM(
		SELECT TOP 1000 
			P.Id
			, DataModifica
			, DataDisattivazione
			, LivelloAttendibilita
			, Disattivato
			, DisattivatoDescrizione
			, (Provenienza + ' (' + IdProvenienza + ')') as Provenienza      
			, Occultato
			, Cognome
			, Nome
			, DataNascita
			, (ComuneNascitaNome + ' (' + ProvinciaNascitaNome + ')') as ComuneNascita
			, Sesso
			, CodiceFiscale
			, ComuneResDescrizione
			, ProvinciaResDescrizione
			, RegioneResDescrizione
			, CASE WHEN CodiceTerminazione = '4' THEN
				DataTerminazioneAss
				ELSE
					CAST(NULL AS DATETIME)
				END AS DataDecesso
		FROM 
			PazientiUiBaseGestioneResult AS P 
		WHERE 
			P.Id = @IdPazienteAttivo
		UNION	
		SELECT TOP 1000 
			P.Id
			, DataModifica
			, DataDisattivazione
			, LivelloAttendibilita
			, Disattivato
			, DisattivatoDescrizione
			, (Provenienza + ' (' + IdProvenienza + ')') as Provenienza      
			, Occultato
			, Cognome
			, Nome
			, DataNascita
			, (ComuneNascitaNome + ' (' + ProvinciaNascitaNome + ')') as ComuneNascita
			, Sesso
			, CodiceFiscale
			, ComuneResDescrizione
			, ProvinciaResDescrizione
			, RegioneResDescrizione
			, CASE WHEN CodiceTerminazione = '4' THEN
				DataTerminazioneAss
				ELSE
					CAST(NULL AS DATETIME)
				END AS DataDecesso
		FROM 
			PazientiUiBaseGestioneResult AS P 
			INNER JOIN PazientiFusioni PF 
				ON P.Id = PF.IdPazienteFuso
		WHERE PF.IdPaziente = @IdPazienteAttivo and PF.Abilitato = 1
	  ) AS pazienti
	  ORDER BY Disattivato
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiFusioneLista] TO [DataAccessUi]
    AS [dbo];

