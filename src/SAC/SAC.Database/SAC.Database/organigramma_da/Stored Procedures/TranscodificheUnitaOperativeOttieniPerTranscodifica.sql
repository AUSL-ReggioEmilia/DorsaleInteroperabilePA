

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna una lista di transcodifiche per codice transcodificato
-- =============================================
CREATE PROC [organigramma_da].[TranscodificheUnitaOperativeOttieniPerTranscodifica]
(
  @TransAzienda varchar(16)
 ,@TransCodice varchar(16)
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[TranscodificheUnitaOperativeOttieniPerTranscodifica]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[TranscodificheUnitaOperativeOttieniPerTranscodifica]!', 16, 1)
		RETURN
	END

	--Eseguo query
	SELECT 
		[UnitaOperativaAzienda],
		[UnitaOperativaCodice],
		[UnitaOperativaDescrizione],
		[SistemaAzienda],
		[SistemaCodice],
		[TransAzienda],
		[TransCodice],
		[TransDescrizione]
	FROM  [organigramma_da].[TranscodificheUnitaOperative]
	WHERE [TransAzienda] = @TransAzienda
		AND [TransDescrizione] = @TransCodice
END



