CREATE PROC [organigramma_admin].[RuoliAttributiCerca]
(
 @IdRuolo uniqueidentifier,
 @CodiceAttributo varchar(16) = NULL,
 @Descrizione varchar(256) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN

	SELECT TOP (ISNULL(@Top, 1000)) 
		ID,IdRuolo,CodiceAttributo,Note, Descrizione, TipoAttributo	
	FROM 
		[organigramma_admin].[UnionAttributi]
	WHERE 
		IdRuolo = @IdRuolo AND
		(	  
			(CodiceAttributo LIKE '%' + @CodiceAttributo + '%' OR @CodiceAttributo IS NULL)
			AND
			(Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) 			
		)
		
END
