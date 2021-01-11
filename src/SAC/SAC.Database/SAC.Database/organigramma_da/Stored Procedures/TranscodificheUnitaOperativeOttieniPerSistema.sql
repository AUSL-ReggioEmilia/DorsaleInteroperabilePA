

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna una lista di transcodifiche per sistema
-- =============================================
CREATE PROC [organigramma_da].[TranscodificheUnitaOperativeOttieniPerSistema]
(
  @SistemaAzienda varchar(16)
 ,@SistemaCodice varchar(16)
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[TranscodificheUnitaOperativeOttieniPerSistema]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[TranscodificheUnitaOperativeOttieniPerSistema]!', 16, 1)
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
	WHERE [SistemaAzienda] = @SistemaAzienda
		AND [SistemaCodice] = @SistemaCodice
END


