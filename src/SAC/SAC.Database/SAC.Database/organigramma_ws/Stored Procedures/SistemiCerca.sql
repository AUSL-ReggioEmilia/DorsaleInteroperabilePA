-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-08
-- Description:	Ricerca sistemi, ritorna una lista
-- =============================================
CREATE PROC [organigramma_ws].[SistemiCerca]
(
 @Top INT = NULL,
 @Ordinamento varchar(128) = NULL,
 @Codice varchar(16) = NULL,
 @CodiceAzienda varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
 @Erogante bit = NULL,
 @Richiedente bit = NULL,
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
		[ID],
		[Codice],
		[CodiceAzienda],
		[Descrizione],
		[Erogante],
		[Richiedente],
		[Attivo]
	FROM  [organigramma].[Sistemi]
	WHERE 
		(Codice LIKE @Codice + '%' OR @Codice IS NULL) AND 
		(CodiceAzienda LIKE @CodiceAzienda + '%' OR @CodiceAzienda IS NULL) AND 
		(Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND 
		(Erogante = @Erogante OR @Erogante IS NULL) AND 
		(Richiedente = @Richiedente OR @Richiedente IS NULL) AND 
		(Attivo = @Attivo OR @Attivo IS NULL)

	ORDER BY 
		[CodiceAzienda]
		--Default
		,CASE @Ordinamento  WHEN '' THEN [Codice] END ASC
		--Ascendente	
		, CASE @Ordinamento  WHEN 'Codice@ASC' THEN Codice END ASC
		, CASE @Ordinamento  WHEN 'Descrizione@ASC' THEN Descrizione END ASC
		, CASE @Ordinamento  WHEN 'Attivo@ASC' THEN Attivo END ASC
		--Discendente	
		, CASE @Ordinamento  WHEN 'Codice@DESC' THEN Codice END DESC
		, CASE @Ordinamento  WHEN 'Descrizione@DESC' THEN Descrizione END DESC
		, CASE @Ordinamento  WHEN 'Attivo@DESC' THEN Attivo END DESC

END