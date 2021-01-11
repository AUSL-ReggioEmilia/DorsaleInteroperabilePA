CREATE PROC [organigramma_admin].[AttributiLista]
(
 @UsoPerRuolo bit,
 @UsoPerUnitaOperativa bit,
 @UsoPerSistemaErogante bit
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      Codice,
      COALESCE(Descrizione + ' (' + Codice + ')', Codice ) as Descrizione
    
  FROM  [organigramma].[Attributi]
  WHERE 
	(@UsoPerRuolo = 1 AND UsoPerRuolo = @UsoPerRuolo) 
	OR	
	(@UsoPerUnitaOperativa = 1 AND UsoPerUnitaOperativa = @UsoPerUnitaOperativa)
	OR
	(@UsoPerSistemaErogante = 1 AND UsoPerSistemaErogante = @UsoPerSistemaErogante)

  ORDER BY Descrizione, Codice 

END
