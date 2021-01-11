
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-05-20
-- Modify date: 
-- Description: Ricerca dei ruoli associati all'oscuramento passato, 
--              cerca su tutti i ruoli se si passa @IdOscuramento = NULL
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentoRuoliCerca]
(
 @IdOscuramento uniqueidentifier = NULL, --se si passa NULL filtra su tutti i ruoli
 @Codice varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  IF @IdOscuramento IS NULL BEGIN
	 /* 
	 **   cerco fra tutti i ruoli presenti su DB SAC
	 */
	 SELECT TOP (ISNULL(@Top, 1000)) 
		  CAST(NULL AS UNIQUEIDENTIFIER) AS IdOscuramento,
		  RUO.ID AS IdRuolo, 
		  RUO.Codice,
		  RUO.Descrizione,
		  RUO.Attivo
	
	  FROM  dbo.SAC_Ruoli RUO
	  WHERE 
		(
		  (RUO.Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND 
		  (RUO.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) 
		)   
	  ORDER BY 
		  RUO.Codice 

  END
  ELSE BEGIN

	 /* 
	 **   cerco fra i ruoli associati all'oscuramento
	 */
	  SELECT TOP (ISNULL(@Top, 1000)) 
		  OSC.IdOscuramento,
		  OSC.IdRuolo,		
		  RUO.Codice,
		  RUO.Descrizione,
          RUO.Attivo
          
	  FROM  dbo.OscuramentoRuoli OSC
	  INNER JOIN 
			dbo.SAC_Ruoli RUO ON OSC.IdRuolo = RUO.ID
	  WHERE 
		OSC.IdOscuramento = @IdOscuramento AND
		(
		  (RUO.Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND		 
		  (RUO.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL)
		)
	  ORDER BY 
		  RUO.Codice 

	END

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentoRuoliCerca] TO [ExecuteFrontEnd]
    AS [dbo];

