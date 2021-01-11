-- =============================================
-- Author:		SIMONE BITTI
-- Modify date: 2016-10-19 SIMONEB: Aggiunti i parametri @CodiceDescrizionePrestazione e @IdSistemaErogante per filtrare i gruppiPrestazioni in base al codice,descrizione e sistema erogante delle prestazioni.
-- Ottiene la lista dei GruppiPrestazioni in base ai parametri che gli vengono passati.

-- Modify date: 2019-06-03 LucaB: eliminato filtro (P.Tipo = 0 OR P.Tipo IS NULL) che cercava il codice solo nelle prestazioni e non nei profili
-- =============================================

CREATE PROCEDURE [dbo].[UiGruppiPrestazioniList2]

@Descrizione AS VARCHAR(128) = NULL,
@Preferiti AS BIT = NULL,
@CodiceDescrizionePrestazione AS VARCHAR(MAX) = NULL,
@IdSistemaErogante AS UNIQUEIDENTIFIER = NULL,
@Note AS VARCHAR(1024) = NULL

AS
BEGIN
SET NOCOUNT ON

	SELECT [ID]
      ,[Descrizione]
      ,Preferiti
      ,dbo.GetUiPrestazioniGruppiPrestazioniCount([ID]) as CountPrestazioni
	  ,[Note]
	FROM [dbo].[GruppiPrestazioni] GP1
	WHERE (@Descrizione IS NULL OR [Descrizione] LIKE '%' + @Descrizione + '%')
		AND (@Note IS NULL OR [Note] LIKE '%' + @Note +'%')
	AND (@Preferiti IS NULL OR Preferiti = @Preferiti)
	AND(
		(
			EXISTS ( SELECT *
					FROM dbo.[GruppiPrestazioni] GP
						LEFT JOIN dbo.[PrestazioniGruppiPrestazioni] PGP
							ON GP.ID = PGP.IDGruppoPrestazioni
						LEFT JOIN dbo.[Prestazioni] P
							ON P.ID = PGP.IDPrestazione
					WHERE (GP.ID = GP1.ID)
						AND (@CodiceDescrizionePrestazione IS NULL OR P.Codice LIKE '%'+ @CodiceDescrizionePrestazione + '%' 
								OR p.Descrizione LIKE '%' + @CodiceDescrizionePrestazione +'%')
						AND (@IdSistemaErogante IS NULL OR P.IDSistemaErogante = @IdSistemaErogante)
			)
		)
		OR 
		(
			EXISTS(SELECT *
					FROM dbo.[GruppiPrestazioni] GP
						LEFT JOIN dbo.[PrestazioniGruppiPrestazioni] PGP
							ON GP.ID = PGP.IDGruppoPrestazioni
						-- NUOVO su SQL 2014
						LEFT JOIN dbo.[Prestazioni] P
							ON P.ID = PGP.IDPrestazione
						OUTER APPLY [dbo].[GetProfiloGerarchia2](P.ID) GER
						LEFT JOIN dbo.[Prestazioni] PF
							ON PF.ID = GER.IDFiglio
					WHERE (P.Tipo <> 0 OR P.Tipo IS NULL)
					AND (GP.ID = GP1.ID)
					AND (@CodiceDescrizionePrestazione IS NULL OR PF.Codice LIKE '%'+ @CodiceDescrizionePrestazione+'%' 
						OR PF.Descrizione LIKE '%' + @CodiceDescrizionePrestazione+ '%')
					AND (@IdSistemaErogante IS NULL OR PF.IDSistemaErogante = @IdSistemaErogante)
				)
		)
	)
	ORDER BY Descrizione

END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiGruppiPrestazioniList2] TO [DataAccessUi]
    AS [dbo];

