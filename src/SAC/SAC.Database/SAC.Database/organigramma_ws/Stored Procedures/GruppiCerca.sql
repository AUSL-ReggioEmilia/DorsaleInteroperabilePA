-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-04
-- Description:	Cerca nei gruppi di AD e ritorna una lista
-- =============================================
CREATE PROC [organigramma_ws].[GruppiCerca]
(
 @Top INT = NULL,
 @Ordinamento varchar(128),
 @Gruppo varchar(128) = NULL,
 @Descrizione varchar(256) = NULL,
 @Attivo bit = NULL 
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON

	--
	-- Imposto '' per l'ordinamento di default
	--
	SET @Ordinamento = ISNULL(@Ordinamento,'')

	SELECT TOP (ISNULL(@Top, 100)) 
		[Id],
		[Gruppo],
		[Descrizione],
		[Email],
		[Attivo]
	FROM
		[organigramma_ws].[Gruppi]
	WHERE 
		(Gruppo LIKE '%' + @Gruppo + '%' OR @Gruppo IS NULL) AND 
		(Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND
		(Attivo = @Attivo OR @Attivo IS NULL)

	ORDER BY 
		--Default
		CASE @Ordinamento  WHEN '' THEN [Gruppo] END ASC
		--Ascendente	
		, CASE @Ordinamento  WHEN 'Gruppo@ASC' THEN Gruppo END ASC
		, CASE @Ordinamento  WHEN 'Descrizione@ASC' THEN Descrizione END ASC
		, CASE @Ordinamento  WHEN 'Attivo@ASC' THEN Attivo END ASC
		--Discendente	
		, CASE @Ordinamento  WHEN 'Gruppo@DESC' THEN Gruppo END DESC
		, CASE @Ordinamento  WHEN 'Descrizione@DESC' THEN Descrizione END DESC
		, CASE @Ordinamento  WHEN 'Attivo@DESC' THEN Attivo END DESC


END