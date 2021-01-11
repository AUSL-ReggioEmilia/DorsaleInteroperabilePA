

-- =============================================
-- Author:		SIMONE BITTI
-- Modify date: 2016-10-19 SIMONEB: Aggiunti i parametri @CodiceDescrizionePrestazione e @IdSistemaErogante per filtrare le prestazioni contenute nei profili
-- Description:	Ottiene la lista dei profili di prestazioni
-- ModifyData: 2018-01-22 SimoneB: Aggiunto il parametro @Note
-- =============================================

CREATE PROCEDURE [dbo].[UiProfiliPrestazioniList]

@codiceDescrizione as varchar(max) = NULL,
@Attivo AS BIT = NULL,
@CodiceDescrizionePrestazione AS VARCHAR(MAX) = NULL,
@IdSistemaErogante AS UNIQUEIDENTIFIER = NULL,
@Note AS VARCHAR(1024) = NULL

AS
BEGIN
	SET NOCOUNT ON
	SELECT [ID]
		,Codice
		,[Descrizione]
		,Tipo
		,UtenteModifica as UserName
		,Attivo
		,Note
	FROM [dbo].[Prestazioni] PP
	WHERE (@Attivo IS NULL OR Attivo = @Attivo)
	AND Tipo IN (1,2)
	AND (@codiceDescrizione IS NULL OR Codice LIKE '%' + @codiceDescrizione + '%' OR Descrizione LIKE '%'+ @codiceDescrizione + '%')
	AND ( @Note IS NULL OR Note LIKE '%' + @Note +'%')
	AND 
	(
		EXISTS (
			SELECT *
			FROM dbo.[Prestazioni] P

				OUTER APPLY [dbo].[GetProfiloGerarchia2](P.ID) GER

				LEFT JOIN dbo.[Prestazioni] PF
					ON PF.ID = GER.IDFiglio

			WHERE P.Tipo <> 0
			AND P.ID = PP.[Id]
			AND (@CodiceDescrizionePrestazione IS NULL OR PF.Codice LIKE '%' + @CodiceDescrizionePrestazione +'%' OR  PF.Descrizione LIKE '%' + @CodiceDescrizionePrestazione +'%')	
			AND (@IdSistemaErogante IS NULL OR PF.IDSistemaErogante = @IdSistemaErogante)																
		) 
	)
  ORDER BY Descrizione

SET NOCOUNT OFF
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiProfiliPrestazioniList] TO [DataAccessUi]
    AS [dbo];

