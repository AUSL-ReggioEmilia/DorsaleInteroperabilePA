

-- =============================================
-- Author:		Bitti Simone
-- Create date: 2016-10-25
-- Description:	Restituisce la lista dei Ruoli. Se viene specificato l'id della Unita Operativa  restituisce la lista dei Ruoli in base all'Unita Operativa.
-- =============================================

CREATE PROC [organigramma_admin].[RuoliCercaPerUnitaOperativa]
(

 @IdUnitaOperativa uniqueidentifier = NULL, --se si passa NULL filtra su tutti i sistemi
 @CodiceRuolo varchar(16) = NULL,
 @DescrizioneRuolo varchar(128) = NULL,
 @Top INT = NULL

)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  /*
  * Se viene specificato l'id del Sistema restituisce la lista dei Ruoli in base al Sistema.
  * Altrimenti cerco tra tutti i sistemi presenti su DB
  */
  IF @IdUnitaOperativa IS NULL BEGIN

	 SELECT TOP (ISNULL(@Top, 1000)) 
		  R.ID as ID,      --passo l'Id del ruolo tanto per non lasciare null
		  R.ID as IDRuolo, --idem         
		  R.ID AS IdUnitaOperativa, 
		  R.Codice,
		  R.Descrizione
	  FROM  Organigramma.Ruoli R 
	  WHERE 
		(
		  (R.Descrizione LIKE '%' + @DescrizioneRuolo + '%' OR @DescrizioneRuolo IS NULL) AND 
		  (R.Codice LIKE '%' + @CodiceRuolo + '%' OR @CodiceRuolo IS NULL)
		)   
	  ORDER BY R.Codice

  END
  ELSE BEGIN
  
	 SELECT TOP (ISNULL(@Top, 1000)) 
		  RUO.ID,
		  RUO.IdRuolo,
		  RUO.IdUnitaOperativa,
		  UO.Codice,
		  UO.Descrizione
	  FROM  organigramma.RuoliUnitaOperative RUO
	  INNER JOIN 
		organigramma.Ruoli UO ON RUO.IdRuolo=UO.ID
	  WHERE 
		RUO.IdUnitaOperativa = @IdUnitaOperativa AND
		(
		  (UO.Descrizione LIKE @DescrizioneRuolo + '%' OR @DescrizioneRuolo IS NULL) AND 
		  (UO.Codice LIKE @CodiceRuolo + '%' OR @CodiceRuolo IS NULL)
		)
	  ORDER BY UO.Codice 

	END

END