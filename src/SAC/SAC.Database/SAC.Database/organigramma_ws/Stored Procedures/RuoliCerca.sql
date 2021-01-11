

-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-08
-- Description:	Cerca nei Ruoli e ritorna una lista
-- Modify date: 2017-01-12
-- =============================================
CREATE PROC [organigramma_ws].[RuoliCerca]
(
 @Top INT = NULL,
 @Ordinamento varchar(128) = NULL,
 @Codice varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
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


	SELECT TOP (ISNULL(@Top, 1000)) 
		   [Id]
		  ,[Codice]
		  ,[Descrizione]
		  ,[Attivo]
	FROM  [organigramma].[Ruoli]
	WHERE 
		(Codice LIKE @Codice + '%' OR @Codice IS NULL) AND 
		(Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND 
		(Attivo = @Attivo OR @Attivo IS NULL)
	
	ORDER BY 
		--Default
		CASE @Ordinamento  WHEN '' THEN [Codice] END ASC
		--Ascendente	
		, CASE @Ordinamento  WHEN 'Codice@ASC' THEN Codice END ASC
		, CASE @Ordinamento  WHEN 'Descrizione@ASC' THEN Descrizione END ASC
		, CASE @Ordinamento  WHEN 'Attivo@ASC' THEN Attivo END ASC
		--Discendente	
		, CASE @Ordinamento  WHEN 'Codice@DESC' THEN Codice END DESC
		, CASE @Ordinamento  WHEN 'Descrizione@DESC' THEN Descrizione END DESC
		, CASE @Ordinamento  WHEN 'Attivo@DESC' THEN Attivo END DESC

END