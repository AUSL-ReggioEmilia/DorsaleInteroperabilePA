
CREATE PROCEDURE [dbo].[PazientiUiGestioneLista1]
(
	@Cognome varchar(64) = NULL,
	@Nome varchar(64) = NULL,
	@AnnoNascita as int = NULL,
	@CodiceFiscale as varchar(16) = NULL,
	@IdSac as uniqueidentifier = NULL,
	@Disattivato as tinyint = NULL,
	@Occultato as bit = NULL,
	@Provenienza as varchar(16) = NULL,
	@IdEsterno as varchar(100) = NULL
)
WITH RECOMPILE --Ricalcola sempre il piano di esecuzione
AS
BEGIN
/*
	MODIFICA ETTORE 2014-03-26: 
		1)	Corretto il filtro nel caso @Disattivato = 255 (==TUTTI). 
			Se TUTTI non filtro per nessun valore del campo Disattivato
		2)	Aggiunta gestione data di decesso: si deve visualizzare la data che è sul record, NON quella aggregata!!!
		
	MODIFICA ETTORE 2014-07-16: 		
		Se PGR.ProvinciaNascitaNome = '??' non visualizzo più '(??)' di fianco al nome del comune/nazione
*/

	SET NOCOUNT ON;

	IF @Disattivato = 255 
		SET @Disattivato = null
	
	SELECT TOP 1000 
		PGR.Id
		, PGR.DataModifica
		, PGR.DataDisattivazione
		, PGR.LivelloAttendibilita
		, PGR.Disattivato
		, PGR.DisattivatoDescrizione
		, (PGR.Provenienza + ' (' + PGR.IdProvenienza + ')') as Provenienza      
		, PGR.Occultato
		, PGR.Cognome
		, PGR.Nome
		, PGR.DataNascita
		--
		-- MODIFICA ETTORE 2014-07-16: non visualizzo '??' se la Provincia è sconosciuta
		--
		, CASE WHEN PGR.ProvinciaNascitaNome = '??' THEN
			PGR.ComuneNascitaNome
			ELSE
			PGR.ComuneNascitaNome + ' (' + PGR.ProvinciaNascitaNome + ')'
			END AS ComuneNascita
		, PGR.Sesso
		, PGR.CodiceFiscale
		, PGR.ComuneResDescrizione
		, PGR.ProvinciaResDescrizione
		, PGR.RegioneResDescrizione
		, (SELECT COUNT(*) FROM PazientiFusioni PF 
			WHERE PF.IdPaziente = PGR.Id and PF.Abilitato = 1 
			) as NumeroFuse
		--
		-- Determino la Data di decesso sul record
		--
		, CASE WHEN CodiceTerminazione = '4' THEN
			DataTerminazioneAss
		ELSE
			CAST(NULL AS DATETIME)
		END AS DataDecesso		
	FROM 
		PazientiUiBaseGestioneResult AS PGR WITH(NOLOCK)
	WHERE
		(@Cognome IS NULL or PGR.Cognome LIKE @Cognome + '%')
	AND (@Nome IS NULL or PGR.Nome LIKE @Nome + '%')
	AND (@AnnoNascita IS NULL or YEAR(PGR.DataNascita) = @AnnoNascita)
	AND (@CodiceFiscale IS NULL or PGR.CodiceFiscale = @CodiceFiscale)
	AND (@IdSac IS NULL OR PGR.Id = @IdSac)
	AND (@Occultato IS NULL or PGR.Occultato = @Occultato)
	AND (@Provenienza IS NULL or PGR.Provenienza = @Provenienza)
	AND (@IdEsterno IS NULL or PGR.IdProvenienza = @IdEsterno)
	AND (
			(@Disattivato IS NULL) --se disattivato NULL allora faccio vedere sia attivi che fusi che cancellati
			or PGR.Disattivato = @Disattivato
		)
	ORDER BY PGR.Cognome, PGR.Nome
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiGestioneLista1] TO [DataAccessUi]
    AS [dbo];

