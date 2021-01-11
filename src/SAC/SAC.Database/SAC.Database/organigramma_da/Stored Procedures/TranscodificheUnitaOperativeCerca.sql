

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Cerca le trascodifiche delle UO e ritorna una lista
-- =============================================
CREATE PROC [organigramma_da].[TranscodificheUnitaOperativeCerca]
(
 @UnitaOperativaAzienda varchar(16) = NULL,
 @UnitaOperativaCodice varchar(16) = NULL,
 @UnitaOperativaDescrizione varchar(128) = NULL,
 @SistemaAzienda varchar(16) = NULL,
 @SistemaCodice varchar(16) = NULL,
 @TransAzienda varchar(16) = NULL,
 @TransCodice varchar(16) = NULL,
 @TransDescrizione varchar(128) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[TranscodificheUnitaOperativeCerca]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[TranscodificheUnitaOperativeCerca]!', 16, 1)
		RETURN
	END

	--Eseguo query
	SELECT TOP (ISNULL(@Top, 100)) 
		[UnitaOperativaAzienda],
		[UnitaOperativaCodice],
		[UnitaOperativaDescrizione],
		[SistemaAzienda],
		[SistemaCodice],
		[TransAzienda],
		[TransCodice],
		[TransDescrizione]
	FROM  [organigramma_da].[TranscodificheUnitaOperative]
	WHERE 
		(UnitaOperativaAzienda LIKE @UnitaOperativaAzienda + '%' OR @UnitaOperativaAzienda IS NULL) AND 
		(UnitaOperativaCodice LIKE @UnitaOperativaCodice + '%' OR @UnitaOperativaCodice IS NULL) AND 
		(UnitaOperativaDescrizione LIKE @UnitaOperativaDescrizione + '%' OR @UnitaOperativaDescrizione IS NULL) AND 
		(SistemaAzienda LIKE @SistemaAzienda + '%' OR @SistemaAzienda IS NULL) AND 
		(SistemaCodice LIKE @SistemaCodice + '%' OR @SistemaCodice IS NULL) AND 
		(TransAzienda LIKE @TransAzienda + '%' OR @TransAzienda IS NULL) AND 
		(TransCodice LIKE @TransCodice + '%' OR @TransCodice IS NULL) AND 
		(TransDescrizione LIKE @TransDescrizione + '%' OR @TransDescrizione IS NULL)

END


