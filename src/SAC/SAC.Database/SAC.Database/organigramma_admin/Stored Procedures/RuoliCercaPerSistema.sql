
-- =============================================
-- Author:		Bitti Simone
-- Create date: 2016-10-25
-- Description:	Restituisce la lista dei Ruoli. Se viene specificato l'id del Sistema restituisce la lista dei Ruoli in base al Sistema
-- =============================================

CREATE PROC [organigramma_admin].[RuoliCercaPerSistema]
(
 @IdSistema uniqueidentifier = NULL, --se si passa NULL filtra su tutti i sistemi
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
  IF @IdSistema IS NULL BEGIN

	 SELECT TOP (ISNULL(@Top, 1000)) 
		  R.ID as ID,      --passo l'Id del ruolo tanto per non lasciare null
		  R.ID as IDRuolo, --idem         
		  R.ID AS IdSistema, 
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
	  RS.ID,
	  RS.IdRuolo,
	  RS.IdSistema,
	  R.Codice,
	  R.Descrizione
	  FROM organigramma.RuoliSistemi RS
	  INNER JOIN 
		organigramma.Ruoli R ON RS.IdRuolo = R.ID
	  WHERE 
		RS.IdSistema = @idSistema AND
		(
		  (R.Descrizione LIKE '%' + @DescrizioneRuolo + '%' OR @DescrizioneRuolo IS NULL) AND 
		  (R.Codice LIKE '%' + @CodiceRuolo + '%' OR @CodiceRuolo IS NULL)
		)
	  ORDER BY R.Codice 

	END

END