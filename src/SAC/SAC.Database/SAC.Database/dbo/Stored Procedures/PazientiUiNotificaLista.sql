-- =============================================
-- Author:		Simone Bitti
-- Create date: 2017-09-15
-- Description:	Ottiene la lista dei pazienti modificati in un determinato periodo temporale.
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiNotificaLista] 
	@DataModificaDal AS DATETIME,
	@DataModificaAl AS DATETIME
AS
BEGIN
	SET NOCOUNT ON;

	--IMPOSTO LA DATA CORRENTE COME DEFAULT DEL PARAMETRO @DataModificaAl NEL CASO IN CUI SIA NULL.
	IF @DataModificaAl IS NULL SET @DataModificaAl = GETDATE()
		SELECT
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
  WHERE	(Disattivato = 0) --OTTENGO SOLO I PAZIENTI ATTIVI.
	AND (DataModifica BETWEEN @DataModificaDal AND @DataModificaAl)
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiNotificaLista] TO [DataAccessUi]
    AS [dbo];

