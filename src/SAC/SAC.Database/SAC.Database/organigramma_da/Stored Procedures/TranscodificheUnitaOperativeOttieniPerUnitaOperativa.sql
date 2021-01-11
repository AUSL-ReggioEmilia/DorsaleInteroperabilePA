

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna una lista di transcodifiche per unita operativa
-- =============================================
CREATE PROC [organigramma_da].[TranscodificheUnitaOperativeOttieniPerUnitaOperativa]
(
  @UnitaOperativaAzienda varchar(16)
 ,@UnitaOperativaCodice varchar(16)
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[TranscodificheUnitaOperativeOttieniPerUnitaOperativa]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[TranscodificheUnitaOperativeOttieniPerUnitaOperativa]!', 16, 1)
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
	WHERE [UnitaOperativaAzienda] = @UnitaOperativaAzienda
		AND [UnitaOperativaCodice] = @UnitaOperativaCodice
END



