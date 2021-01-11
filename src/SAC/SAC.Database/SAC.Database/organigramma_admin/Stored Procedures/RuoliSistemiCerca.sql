-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Restituisce in base ai parametri o la lista dei Sistemi o la lista Sistemi associati ad un ruolo
-- Modify Date: 2017-03-23 ETTORE: restituito flag Attivo e nuovo parametro @Attivo con DEFAULT NULL
-- =============================================
CREATE PROC [organigramma_admin].[RuoliSistemiCerca]
(
 @IdRuolo uniqueidentifier = NULL, --se si passa NULL filtra su tutti i sistemi
 @Codice varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
 @CodiceAzienda varchar(16) = NULL,
 @Top INT = NULL,
 @Attivo BIT = NULL --Nuovo parametro NULLABILE
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  IF @IdRuolo IS NULL BEGIN
	 /* 
	 **   cerco fra tutti i sistemi presenti su DB
	 */
	 SELECT TOP (ISNULL(@Top, 1000)) 
		  S.ID as ID,      --passo l'Id del sistema tanto per non lasciare null
		  S.ID as IDRuolo, --idem         
		  S.ID AS IdSistema, 
		  S.Codice,
		  S.Descrizione,
		  S.CodiceAzienda,
		  S.CodiceAzienda + ' - ' +  S.Codice + ' - ' +  ISNULL(S.Descrizione,'') as NomeConcatenato,
		  S.Attivo --nuovo campo
	  FROM  Organigramma.Sistemi S 
	  WHERE 
		(
		  (S.CodiceAzienda = @CodiceAzienda OR @CodiceAzienda IS NULL) AND 
		  (S.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) AND 
		  (S.Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND
		  (S.Attivo = @Attivo OR @Attivo IS NULL) --nuovo filtro
		)   
	  ORDER BY 
		  S.CodiceAzienda, S.Codice 

  END
  ELSE BEGIN

	 /* 
	 **   cerco fra i sistemi associati al ruolo
	 */
	  SELECT TOP (ISNULL(@Top, 1000)) 
		  RS.ID,
		  RS.IdRuolo,
		  RS.IdSistema,
		  S.Codice,
		  S.Descrizione,
		  S.CodiceAzienda,
		  S.CodiceAzienda + ' - ' +  S.Codice + ' - ' +  ISNULL(S.Descrizione,'') as NomeConcatenato,
		  S.Attivo --nuovo campo
	  FROM  organigramma.RuoliSistemi RS
	  INNER JOIN 
		organigramma.Sistemi S ON RS.IdSistema = S.ID
	  WHERE 
		RS.IdRuolo = @IdRuolo AND
		(
		  (S.CodiceAzienda = @CodiceAzienda OR @CodiceAzienda IS NULL) AND 
		  (S.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) AND 
		  (S.Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND
		  (S.Attivo = @Attivo OR @Attivo IS NULL) --nuovo filtro
		)
	  ORDER BY 
		  S.CodiceAzienda, S.Codice 

	END

END